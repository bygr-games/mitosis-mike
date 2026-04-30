package mitosis.enemies;

import mitosis.MitosisPlayer;
import mitosis.projectiles.Projectile;

class ShootingEnemyStrategy extends BaseEnemyStrategy {
	var minShootIntervalS = 1.5;
	var maxShootIntervalS = 3.0;
	var maxInitialShootDelayS = 1.5;
	var recoverDistanceTiles = 6.0;
	var runSpeed = 0.055;
	var isScared = false;
	static var STEP_HEIGHT_PX = Const.GRID;

	public function new() {
		super();
	}

	override public function initHitbox(enemy:MitosisEnemy):Void {
		setHitbox(enemy, 16, 32);
		enemy.cd.setS("shootingEnemyShoot", enemy.rnd(0, maxInitialShootDelayS));
	}

	override public function update(enemy:MitosisEnemy):Void {
		applyGravityIfAirborne(enemy);

		if( hasAnyPlayerOnTop(enemy) )
			isScared = true;

		if( isScared ) {
			var closestPlayerByDistance = getClosestPlayerByTileDistance(enemy);
			if( closestPlayerByDistance!=null && enemy.distCase(closestPlayerByDistance)>=recoverDistanceTiles ) {
				isScared = false;
				enemy.cd.setS("shootingEnemyShoot", enemy.rnd(minShootIntervalS, maxShootIntervalS));
			}
		}

		if( isScared ) {
			fleeFromClosestPlayer(enemy);
			return;
		}

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

	function fleeFromClosestPlayer(enemy:MitosisEnemy):Void {
		var player = getClosestPlayerByTileDistance(enemy);
		if( player==null )
			return;

		var fleeDir = player.centerX >= enemy.centerX ? -1 : 1;
		enemy.dir = fleeDir;

		if( isOnGround(enemy) && enemy.hasWallInDirectionIgnoringLevelBounds(fleeDir) && tryClimbStep(enemy, fleeDir) )
			return;

		if( isOnGround(enemy) && !enemy.hasWallInDirectionIgnoringLevelBounds(fleeDir) && enemy.hasGroundAhead(fleeDir) )
			enemy.vBase.addX(fleeDir * runSpeed);
	}

	function getClosestPlayer(enemy:MitosisEnemy):MitosisPlayer {
		return findClosestPlayer(enemy, function(origin, player) {
			return M.fabs(player.centerX - origin.centerX);
		});
	}

	function getClosestPlayerByTileDistance(enemy:MitosisEnemy):MitosisPlayer {
		return findClosestPlayer(enemy, function(origin, player) {
			return origin.distCase(player);
		});
	}

	function hasAnyPlayerOnTop(enemy:MitosisEnemy):Bool {
		return hasAnyPlayer(enemy, function(origin, player) {
			return isPlayerOnTop(origin, player);
		});
	}

	function isPlayerOnTop(enemy:MitosisEnemy, player:MitosisPlayer):Bool {
		return player.right > enemy.left + 2
			&& player.left < enemy.right - 2
			&& player.bottom <= enemy.top + 6;
	}

	function tryClimbStep(enemy:MitosisEnemy, dir:Int):Bool {
		var targetAttachX = enemy.attachX + dir * runSpeed * Const.GRID;
		var targetAttachY = enemy.attachY - STEP_HEIGHT_PX;

		if( !isPlacementFreeAt(enemy, enemy.attachX, targetAttachY) )
			return false;

		if( !isPlacementFreeAt(enemy, targetAttachX, targetAttachY) )
			return false;

		if( !hasGroundSupportAt(enemy, targetAttachX, targetAttachY) )
			return false;

		enemy.setPosPixel(targetAttachX, targetAttachY);
		enemy.vBase.clearY();
		enemy.vBump.clearY();
		enemy.vBase.addX(dir * runSpeed);
		return true;
	}

	function isPlacementFreeAt(enemy:MitosisEnemy, targetAttachX:Float, targetAttachY:Float):Bool {
		var targetLeft = targetAttachX - enemy.pivotX * enemy.wid;
		var targetRight = targetAttachX + (1-enemy.pivotX) * enemy.wid;
		var targetTop = targetAttachY - enemy.pivotY * enemy.hei;
		var targetBottom = targetAttachY + (1-enemy.pivotY) * enemy.hei;
		var leftCx = pxToLevelCoord(targetLeft + MitosisEnemy.COLLISION_EPSILON);
		var rightCx = pxToLevelCoord(targetRight - MitosisEnemy.COLLISION_EPSILON);
		var topCy = pxToLevelCoord(targetTop + MitosisEnemy.COLLISION_EPSILON);
		var bottomCy = pxToLevelCoord(targetBottom - MitosisEnemy.COLLISION_EPSILON);

		for( probeCy in topCy...bottomCy+1 )
			for( probeCx in leftCx...rightCx+1 )
				if( enemy.level.hasWallCollision(probeCx, probeCy) )
					return false;

		return true;
	}

	function hasGroundSupportAt(enemy:MitosisEnemy, targetAttachX:Float, targetAttachY:Float):Bool {
		var targetLeft = targetAttachX - enemy.pivotX * enemy.wid;
		var targetRight = targetAttachX + (1-enemy.pivotX) * enemy.wid;
		var targetBottom = targetAttachY + (1-enemy.pivotY) * enemy.hei;
		var leftCx = pxToLevelCoord(targetLeft + MitosisEnemy.COLLISION_EPSILON);
		var rightCx = pxToLevelCoord(targetRight - MitosisEnemy.COLLISION_EPSILON);
		var supportCy = pxToLevelCoord(targetBottom + MitosisEnemy.COLLISION_EPSILON);

		for( probeCx in leftCx...rightCx+1 )
			if( enemy.level.hasCollision(probeCx, supportCy) )
				return true;

		return false;
	}

	inline function pxToLevelCoord(v:Float):Int {
		return Std.int(Math.floor(v / Const.GRID));
	}

}

