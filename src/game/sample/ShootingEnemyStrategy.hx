package sample;

class ShootingEnemyStrategy extends BaseEnemyStrategy {
	var minShootIntervalS = 1.5;
	var maxShootIntervalS = 3.0;
	var maxInitialShootDelayS = 1.5;

	public function new() {
		super();
	}

	override public function initHitbox(enemy:SampleEnemy):Void {
		setHitbox(enemy, 16, 32);
		enemy.cd.setS("shootingEnemyShoot", enemy.rnd(0, maxInitialShootDelayS));
	}

	override public function update(enemy:SampleEnemy):Void {
		applyGravityIfAirborne(enemy);

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

	function getClosestPlayer(enemy:SampleEnemy):SamplePlayer {
		return findClosestPlayer(enemy, function(origin, player) {
			return M.fabs(player.centerX - origin.centerX);
		});
	}

	function hasAnyPlayerOnTop(enemy:SampleEnemy):Bool {
		return hasAnyPlayer(enemy, function(origin, player) {
			return isPlayerOnTop(origin, player);
		});
	}

	function isPlayerOnTop(enemy:SampleEnemy, player:SamplePlayer):Bool {
		return player.right > enemy.left + 2
			&& player.left < enemy.right - 2
			&& player.bottom <= enemy.top + 6;
	}

}