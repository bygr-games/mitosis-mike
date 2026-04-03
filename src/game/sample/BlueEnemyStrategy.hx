package sample;

/**
	Blue Enemy Strategy: walks back and forth like a Koopa Troopa from Super Mario Bros.
	Moves in one direction until hitting a collision or cliff, then turns around.
**/
class BlueEnemyStrategy implements EnemyStrategy {
	var walkSpeed = 0.045;
	var currentDir = 1; // 1 for right, -1 for left

	public function new() {}

	public function initHitbox(enemy:SampleEnemy):Void {
		enemy.iwid = 16;
		enemy.ihei = 16;
		enemy.setPivots(0.5, 1);
	}

	public function update(enemy:SampleEnemy):Void {
		// Apply gravity if not on ground
		if( !isOnGround(enemy) )
			enemy.vBase.addY(0.05);

		// Turn before moving if there is a wall ahead or a cliff ahead
		if( isOnGround(enemy) && ( isCollisionInDirection(enemy, currentDir) || isCliff(enemy, currentDir) ) ) {
			currentDir *= -1;
			enemy.dir = currentDir;
		}

		// Walk in current direction
		enemy.vBase.addX(currentDir * walkSpeed);
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
		// If collision happened, force a turn around
		currentDir *= -1;
		enemy.dir = currentDir;
	}

	public function initGraphics(enemy:SampleEnemy):Void {
		// Graphics are now managed centrally in SampleEnemy.
	}

	public function dispose():Void {}

	// Helper functions
	private function isOnGround(enemy:SampleEnemy):Bool {
		return !enemy.destroyed && enemy.vBase.dy == 0 && enemy.hasGroundSupport();
	}

	private function isCollisionBelow(enemy:SampleEnemy):Bool {
		return enemy.hasGroundSupport();
	}

	private function isCollisionInDirection(enemy:SampleEnemy, dir:Int):Bool {
		return enemy.hasWallInDirection(dir);
	}

	private function isCliff(enemy:SampleEnemy, dir:Int):Bool {
		// A cliff is when there's ground below current position but no ground ahead
		return isCollisionBelow(enemy) && !enemy.hasGroundAhead(dir);
	}
}
