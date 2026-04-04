package sample;

class ScaredEnemyStrategy implements EnemyStrategy {
	static inline var DETECTION_RANGE_TILES = 5.0;

	var runSpeed = 0.055;

	public function new() {}

	public function initHitbox(enemy:SampleEnemy):Void {
		enemy.iwid = 16;
		enemy.ihei = 32;
		enemy.setPivots(0.5, 1);
	}

	public function update(enemy:SampleEnemy):Void {
		if( !isOnGround(enemy) )
			enemy.vBase.addY(0.05);

		var player = getClosestNearbyPlayer(enemy);
		if( player==null )
			return;

		var fleeDir = player.centerX >= enemy.centerX ? -1 : 1;
		enemy.dir = fleeDir;

		var canLeaveLevel = enemy.willExitLevelHorizontally(fleeDir, runSpeed);
		if( isOnGround(enemy) && !enemy.hasWallInDirectionIgnoringLevelBounds(fleeDir) && ( enemy.hasGroundAhead(fleeDir) || canLeaveLevel ) )
			enemy.vBase.addX(fleeDir * runSpeed);
	}

	public function onYCollision(enemy:SampleEnemy):Void {
		if( enemy.yr > 1 && enemy.hasGroundSupport() ) {
			enemy.vBase.clearY();
			enemy.vBump.clearY();
			enemy.yr = 1;
		}
	}

	public function onXCollision(enemy:SampleEnemy, dir:Int):Void {
		// Scared enemies don't force a turn here; they only move when fleeing.
	}

	public function initGraphics(enemy:SampleEnemy):Void {
		// Graphics are managed centrally in SampleEnemy.
	}

	public function dispose():Void {}

	function getClosestNearbyPlayer(enemy:SampleEnemy):SamplePlayer {
		var nearest : Null<SamplePlayer> = null;
		var nearestDist = DETECTION_RANGE_TILES + 1;

		for( e in Entity.ALL ) {
			if( e.destroyed || !e.is(SamplePlayer) )
				continue;

			var player = e.as(SamplePlayer);
			var dist = enemy.distCase(player);
			if( dist <= DETECTION_RANGE_TILES && dist < nearestDist ) {
				nearest = player;
				nearestDist = dist;
			}
		}

		return nearest;
	}

	private function isOnGround(enemy:SampleEnemy):Bool {
		return !enemy.destroyed && enemy.vBase.dy == 0 && enemy.hasGroundSupport();
	}
}