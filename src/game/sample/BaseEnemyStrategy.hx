package sample;

class BaseEnemyStrategy implements EnemyStrategy {
	static inline var GRAVITY = 0.05;

	public function new() {}

	public function initHitbox(enemy:SampleEnemy):Void {}

	public function update(enemy:SampleEnemy):Void {}

	public function onYCollision(enemy:SampleEnemy):Void {
		landIfGrounded(enemy);
	}

	public function onXCollision(enemy:SampleEnemy, dir:Int):Void {}

	public function dispose():Void {}

	inline function setHitbox(enemy:SampleEnemy, width:Int, height:Int):Void {
		enemy.iwid = width;
		enemy.ihei = height;
		enemy.setPivots(0.5, 1);
	}

	inline function applyGravityIfAirborne(enemy:SampleEnemy):Void {
		if( !isOnGround(enemy) )
			enemy.vBase.addY(GRAVITY);
	}

	inline function landIfGrounded(enemy:SampleEnemy):Void {
		if( enemy.yr > 1 && hasGroundSupport(enemy) ) {
			enemy.vBase.clearY();
			enemy.vBump.clearY();
			enemy.yr = 1;
		}
	}

	inline function isOnGround(enemy:SampleEnemy):Bool {
		return !enemy.destroyed && enemy.vBase.dy == 0 && hasGroundSupport(enemy);
	}

	inline function hasGroundSupport(enemy:SampleEnemy):Bool {
		return enemy.hasGroundSupport();
	}

	inline function eachAlivePlayer(cb:SamplePlayer->Void):Void {
		for( e in Entity.ALL )
			if( !e.destroyed && e.is(SamplePlayer) )
				cb(e.as(SamplePlayer));
	}

	function findClosestPlayer(enemy:SampleEnemy, distanceFn:(SampleEnemy, SamplePlayer)->Float, ?maxDistance:Null<Float>):Null<SamplePlayer> {
		var nearest : Null<SamplePlayer> = null;
		var nearestDist = maxDistance==null ? 999999.0 : maxDistance;

		eachAlivePlayer(function(player) {
			var dist = distanceFn(enemy, player);
			if( dist <= nearestDist ) {
				nearest = player;
				nearestDist = dist;
			}
		});

		return nearest;
	}

	function hasAnyPlayer(enemy:SampleEnemy, predicate:(SampleEnemy, SamplePlayer)->Bool):Bool {
		var found = false;

		eachAlivePlayer(function(player) {
			if( !found && predicate(enemy, player) )
				found = true;
		});

		return found;
	}
}