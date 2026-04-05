package sample;

class ShootingEnemyStrategy implements EnemyStrategy {
	var minShootIntervalS = 1.5;
	var maxShootIntervalS = 3.0;

	public function new() {}

	public function initHitbox(enemy:SampleEnemy):Void {
		enemy.iwid = 16;
		enemy.ihei = 32;
		enemy.setPivots(0.5, 1);
	}

	public function update(enemy:SampleEnemy):Void {
		if( !isOnGround(enemy) )
			enemy.vBase.addY(0.05);

		var shootUpward = hasAnyPlayerOnTop(enemy);
		var closestPlayer = shootUpward ? null : getClosestPlayer(enemy);
		if( shootUpward || closestPlayer!=null ) {
			if( !shootUpward )
				enemy.dir = closestPlayer.centerX >= enemy.centerX ? 1 : -1;

			if( !enemy.cd.has("shootingEnemyShoot") ) {
				enemy.cd.setS("shootingEnemyShoot", enemy.rnd(minShootIntervalS, maxShootIntervalS));
				enemy.cd.setS("enemyShootAnim", 0.1);
				if( shootUpward )
					new Projectile(enemy.centerX, enemy.top + 4, enemy.dir, "violet", "player", 0, -1);
				else
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
		// Shooting enemy does not move horizontally.
	}

	public function initGraphics(enemy:SampleEnemy):Void {
		// Graphics are now managed centrally in SampleEnemy.
	}

	public function dispose():Void {}

	function getClosestPlayer(enemy:SampleEnemy):SamplePlayer {
		var closest : Null<SamplePlayer> = null;
		var closestDist = 999999.0;

		for( e in Entity.ALL )
			if( !e.destroyed && e.is(SamplePlayer) ) {
				var player = e.as(SamplePlayer);
				var dist = M.fabs(player.centerX - enemy.centerX);
				if( dist < closestDist ) {
					closest = player;
					closestDist = dist;
				}
			}

		return closest;
	}

	function hasAnyPlayerOnTop(enemy:SampleEnemy):Bool {
		for( e in Entity.ALL )
			if( !e.destroyed && e.is(SamplePlayer) && isPlayerOnTop(enemy, e.as(SamplePlayer)) )
				return true;

		return false;
	}

	function isPlayerOnTop(enemy:SampleEnemy, player:SamplePlayer):Bool {
		return player.right > enemy.left + 2
			&& player.left < enemy.right - 2
			&& player.bottom <= enemy.top + 6;
	}

	private function isOnGround(enemy:SampleEnemy):Bool {
		return !enemy.destroyed && enemy.vBase.dy == 0 && enemy.hasGroundSupport();
	}

	private function isCollisionBelow(enemy:SampleEnemy):Bool {
		return enemy.hasGroundSupport();
	}
}