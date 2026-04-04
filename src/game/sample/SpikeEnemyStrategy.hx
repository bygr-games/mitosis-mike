package sample;

class SpikeEnemyStrategy implements EnemyStrategy {
	public function new() {}

	public function initHitbox(enemy:SampleEnemy):Void {
		enemy.iwid = 16;
		enemy.ihei = 16;
		enemy.setPivots(0.5, 1);
	}

	public function update(enemy:SampleEnemy):Void {
		if( !isOnGround(enemy) )
			enemy.vBase.addY(0.05);
	}

	public function onYCollision(enemy:SampleEnemy):Void {
		if( enemy.yr > 1 && isCollisionBelow(enemy) ) {
			enemy.vBase.clearY();
			enemy.vBump.clearY();
			enemy.yr = 1;
		}
	}

	public function onXCollision(enemy:SampleEnemy, dir:Int):Void {
		// Spike enemy remains stationary.
	}

	public function initGraphics(enemy:SampleEnemy):Void {
		// Graphics are managed centrally in SampleEnemy.
	}

	public function dispose():Void {}

	private function isOnGround(enemy:SampleEnemy):Bool {
		return !enemy.destroyed && enemy.vBase.dy == 0 && enemy.hasGroundSupport();
	}

	private function isCollisionBelow(enemy:SampleEnemy):Bool {
		return enemy.hasGroundSupport();
	}
}