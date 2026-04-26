package sample;

class ScaredEnemyStrategy extends BaseEnemyStrategy {
	static inline var DETECTION_RANGE_TILES = 5.0;
	static var STEP_HEIGHT_PX = Const.GRID;
	static inline var COLLISION_EPSILON = 0.001;

	var runSpeed = 0.055;

	public function new() {
		super();
	}

	override public function initHitbox(enemy:SampleEnemy):Void {
		setHitbox(enemy, 16, 32);
	}

	override public function update(enemy:SampleEnemy):Void {
		applyGravityIfAirborne(enemy);

		var player = getClosestNearbyPlayer(enemy);
		if( player==null )
			return;

		var fleeDir = player.centerX >= enemy.centerX ? -1 : 1;
		enemy.dir = fleeDir;

		if( isOnGround(enemy) && enemy.hasWallInDirectionIgnoringLevelBounds(fleeDir) && tryClimbStep(enemy, fleeDir) )
			return;

		var canLeaveLevel = enemy.willExitLevelHorizontally(fleeDir, runSpeed);
		if( isOnGround(enemy) && !enemy.hasWallInDirectionIgnoringLevelBounds(fleeDir) && ( enemy.hasGroundAhead(fleeDir) || canLeaveLevel ) )
			enemy.vBase.addX(fleeDir * runSpeed);
	}

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

	function tryClimbStep(enemy:SampleEnemy, dir:Int):Bool {
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

	function isPlacementFreeAt(enemy:SampleEnemy, targetAttachX:Float, targetAttachY:Float):Bool {
		var targetLeft = targetAttachX - enemy.pivotX * enemy.wid;
		var targetRight = targetAttachX + (1-enemy.pivotX) * enemy.wid;
		var targetTop = targetAttachY - enemy.pivotY * enemy.hei;
		var targetBottom = targetAttachY + (1-enemy.pivotY) * enemy.hei;
		var leftCx = pxToLevelCoord(targetLeft + COLLISION_EPSILON);
		var rightCx = pxToLevelCoord(targetRight - COLLISION_EPSILON);
		var topCy = pxToLevelCoord(targetTop + COLLISION_EPSILON);
		var bottomCy = pxToLevelCoord(targetBottom - COLLISION_EPSILON);

		for( probeCy in topCy...bottomCy+1 )
			for( probeCx in leftCx...rightCx+1 )
				if( enemy.level.hasWallCollision(probeCx, probeCy) )
					return false;

		return true;
	}

	function hasGroundSupportAt(enemy:SampleEnemy, targetAttachX:Float, targetAttachY:Float):Bool {
		var targetLeft = targetAttachX - enemy.pivotX * enemy.wid;
		var targetRight = targetAttachX + (1-enemy.pivotX) * enemy.wid;
		var targetBottom = targetAttachY + (1-enemy.pivotY) * enemy.hei;
		var leftCx = pxToLevelCoord(targetLeft + COLLISION_EPSILON);
		var rightCx = pxToLevelCoord(targetRight - COLLISION_EPSILON);
		var supportCy = pxToLevelCoord(targetBottom + COLLISION_EPSILON);

		for( probeCx in leftCx...rightCx+1 )
			if( enemy.level.hasCollision(probeCx, supportCy) )
				return true;

		return false;
	}

	inline function pxToLevelCoord(v:Float):Int {
		return Std.int(Math.floor(v / Const.GRID));
	}
}