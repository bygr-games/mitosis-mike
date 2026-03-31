package sample;

/**
	Red Enemy Strategy: stays in place and jumps constantly.
	Similar to a jumping enemy pattern found in many 2D platformers.
**/
class RedEnemyStrategy implements EnemyStrategy {
	var jumpInterval = 0.8; // seconds between jumps

	public function new() {
	}

	public function update(enemy:SampleEnemy):Void {
		// Apply gravity
		if( !isOnGround(enemy) )
			enemy.vBase.addY(0.05);

		// Try to jump
		if( isOnGround(enemy) && !enemy.cd.hasSetS("redEnemyJump", jumpInterval) ) {
			enemy.vBase.addY(-0.85);
		}
	}

	public function onYCollision(enemy:SampleEnemy):Void {
		// Land on ground
		if( enemy.yr > 1 && isCollisionBelow(enemy) ) {
			enemy.vBase.clearY();
			enemy.vBump.clearY();
			enemy.yr = 1;
		}
	}

	public function onXCollision(enemy:SampleEnemy, dir:Int):Void {
		// Red enemy doesn't move horizontally, so no X collision handling needed
	}

	public function initGraphics(enemy:SampleEnemy):Void {
		// Create red square (FF0000)
		var b = new h2d.Bitmap(h2d.Tile.fromColor(0xFF0000, Std.int(enemy.iwid), Std.int(enemy.ihei)), enemy.spr);
		b.tile.setCenterRatio(0.5, 1);
	}

	public function dispose():Void {
	}

	// Helper functions
	private function isOnGround(enemy:SampleEnemy):Bool {
		return !enemy.destroyed && enemy.vBase.dy == 0 && enemy.yr == 1 && isCollisionBelow(enemy);
	}

	private function isCollisionBelow(enemy:SampleEnemy):Bool {
		return enemy.level.hasCollision(enemy.cx, enemy.cy + 1);
	}
}
