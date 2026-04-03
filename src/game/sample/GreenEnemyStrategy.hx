package sample;

class GreenEnemyStrategy implements EnemyStrategy {
	var shootIntervalS = 3.0;

	public function new() {}

	public function initHitbox(enemy:SampleEnemy):Void {
		enemy.iwid = 16;
		enemy.ihei = 16;
		enemy.setPivots(0.5, 1);
	}

	public function update(enemy:SampleEnemy):Void {
		if( !isOnGround(enemy) )
			enemy.vBase.addY(0.05);

		var player = getPlayer();
		if( player!=null ) {
			enemy.dir = player.centerX >= enemy.centerX ? 1 : -1;

			if( !enemy.cd.hasSetS("greenEnemyShoot", shootIntervalS) ) {
				enemy.cd.setS("enemyShootAnim", 0.1);
				new Projectile(enemy.centerX + enemy.dir * 8, enemy.centerY - 4, enemy.dir, "violet", "player");
			}
		}
	}

	public function onYCollision(enemy:SampleEnemy):Void {
		if( enemy.yr > 1 && isCollisionBelow(enemy) ) {
			enemy.vBase.clearY();
			enemy.vBump.clearY();
			enemy.yr = 1;
		}
	}

	public function onXCollision(enemy:SampleEnemy, dir:Int):Void {
		// Green enemy does not move horizontally.
	}

	public function initGraphics(enemy:SampleEnemy):Void {
		// Graphics are now managed centrally in SampleEnemy.
	}

	public function dispose():Void {}

	function getPlayer():SamplePlayer {
		for( e in Entity.ALL )
			if( !e.destroyed && e.is(SamplePlayer) )
				return e.as(SamplePlayer);

		return null;
	}

	private function isOnGround(enemy:SampleEnemy):Bool {
		return !enemy.destroyed && enemy.vBase.dy == 0 && enemy.hasGroundSupport();
	}

	private function isCollisionBelow(enemy:SampleEnemy):Bool {
		return enemy.hasGroundSupport();
	}
}
