package sample;

/**
	SampleEnemy is an Entity that spawns from level data and exhibits different
	behaviors based on its strategy pattern implementation.
	
	Supported types:
	- "saw": walks back and forth, turns on collision/cliff
	- "red": stays in place and jumps constantly
	- "shooting": stays in place, shoots toward player every 3 seconds, and does not hurt on contact
	- "scared": runs away from nearby players and does not hurt them on contact
	- "spike": stays in place and splits players on contact
**/
class SampleEnemy extends Entity {
	static inline var COLLISION_EPSILON = 0.001;

	var strategy : EnemyStrategy;
	var enemyType : String;
	var enemyLib : SpriteLib;
	var fallbackBitmap : Null<h2d.Bitmap>;

	var animIdle : Null<String>;
	var animRun : Null<String>;
	var animJump : Null<String>;
	var animFall : Null<String>;
	var animShoot : Null<String>;
	var currentAnim : Null<String>;

	public inline function isHarmless() {
		return enemyType=="scared" || enemyType=="shooting" || enemyType=="green";
	}

	inline function pxToLevelCoord(v:Float) {
		return Std.int(Math.floor(v / Const.GRID));
	}

	function getSolidColumnOnRight() : Null<Float> {
		var probeCx = pxToLevelCoord(right);
		var topCy = pxToLevelCoord(top + COLLISION_EPSILON);
		var bottomCy = pxToLevelCoord(bottom - COLLISION_EPSILON);
		for( probeCy in topCy...bottomCy+1 )
			if( level.hasWallCollision(probeCx, probeCy) )
				return probeCx * Const.GRID;

		return null;
	}

	function getSolidColumnOnRightInBounds() : Null<Float> {
		var probeCx = pxToLevelCoord(right);
		if( probeCx<0 || probeCx>=level.cWid )
			return null;

		var topCy = pxToLevelCoord(top + COLLISION_EPSILON);
		var bottomCy = pxToLevelCoord(bottom - COLLISION_EPSILON);
		for( probeCy in topCy...bottomCy+1 )
			if( level.isValid(probeCx, probeCy) && level.hasWallCollision(probeCx, probeCy) )
				return probeCx * Const.GRID;

		return null;
	}

	function getSolidColumnOnLeft() : Null<Float> {
		var probeCx = pxToLevelCoord(left - COLLISION_EPSILON);
		var topCy = pxToLevelCoord(top + COLLISION_EPSILON);
		var bottomCy = pxToLevelCoord(bottom - COLLISION_EPSILON);
		for( probeCy in topCy...bottomCy+1 )
			if( level.hasWallCollision(probeCx, probeCy) )
				return (probeCx + 1) * Const.GRID;

		return null;
	}

	function getSolidColumnOnLeftInBounds() : Null<Float> {
		var probeCx = pxToLevelCoord(left - COLLISION_EPSILON);
		if( probeCx<0 || probeCx>=level.cWid )
			return null;

		var topCy = pxToLevelCoord(top + COLLISION_EPSILON);
		var bottomCy = pxToLevelCoord(bottom - COLLISION_EPSILON);
		for( probeCy in topCy...bottomCy+1 )
			if( level.isValid(probeCx, probeCy) && level.hasWallCollision(probeCx, probeCy) )
				return (probeCx + 1) * Const.GRID;

		return null;
	}

	function getGroundCollisionRow() : Null<Float> {
		var probeCy = pxToLevelCoord(bottom);
		var leftCx = pxToLevelCoord(left + COLLISION_EPSILON);
		var rightCx = pxToLevelCoord(right - COLLISION_EPSILON);
		for( probeCx in leftCx...rightCx+1 )
			if( level.hasCollision(probeCx, probeCy) )
				return probeCy * Const.GRID;

		return null;
	}

	function getCeilingCollisionRow() : Null<Float> {
		var probeCy = pxToLevelCoord(top - COLLISION_EPSILON);
		var leftCx = pxToLevelCoord(left + COLLISION_EPSILON);
		var rightCx = pxToLevelCoord(right - COLLISION_EPSILON);
		for( probeCx in leftCx...rightCx+1 )
			if( level.hasWallCollision(probeCx, probeCy) )
				return (probeCy + 1) * Const.GRID;

		return null;
	}

	public inline function hasGroundSupport() {
		return getGroundCollisionRow()!=null;
	}

	public inline function hasWallInDirection(dir:Int) {
		return dir>0 ? getSolidColumnOnRight()!=null : getSolidColumnOnLeft()!=null;
	}

	public inline function hasWallInDirectionIgnoringLevelBounds(dir:Int) {
		return dir>0 ? getSolidColumnOnRightInBounds()!=null : getSolidColumnOnLeftInBounds()!=null;
	}

	public inline function hasGroundAhead(dir:Int) {
		var probeX = dir>0 ? right + COLLISION_EPSILON : left - COLLISION_EPSILON;
		var probeCx = pxToLevelCoord(probeX);
		var probeCy = pxToLevelCoord(bottom + COLLISION_EPSILON);
		return level.hasCollision(probeCx, probeCy);
	}

	public inline function willExitLevelHorizontally(dir:Int, moveAmount:Float) {
		var offset = M.fabs(moveAmount);
		return dir>0 ? right + offset > level.pxWid : left - offset < 0;
	}

	public inline function hasLeftLevelHorizontally() {
		return right<=0 || left>=level.pxWid;
	}

	/**
		Create an enemy at a specific grid position with a given type
	**/
	public function new(cx:Int, cy:Int, type:String) {
		super(5, 5);

		enemyType = switch(type.toLowerCase()) {
			case "blue": "saw";
			default: type.toLowerCase();
		};
		setPosCase(cx, cy);

		// Initialize physics
		vBase.setFricts(0.84, 0.94);

		// Create strategy based on type
		strategy = switch(enemyType) {
			case "saw": new SawEnemyStrategy();
			case "red": new RedEnemyStrategy();
			case "shooting", "green": new ShootingEnemyStrategy();
			case "scared": new ScaredEnemyStrategy();
			case "spike": new SpikeEnemyStrategy();
			default: 
				trace('Unknown enemy type: $type, defaulting to saw');
				new SawEnemyStrategy();
		}

		strategy.initHitbox(this);

		// Initialize graphics through strategy
		strategy.initGraphics(this);
		initGraphics();
	}

	function initGraphics() {
		enemyLib = switch(enemyType) {
			case "red": Assets.enemyRed;
			case "saw": Assets.enemySaw;
			case "shooting", "green": Assets.enemyShooting;
			case "scared": Assets.enemyScared;
			case "spike": Assets.enemySpike;
			default: Assets.enemySaw;
		}

		var baseNames = [
			enemyType,
			"enemy_" + enemyType,
			enemyType + "Enemy",
			"sample_" + enemyType
		];

		animIdle = resolveFirstExisting(["idle", "enemy_idle", "enemy"]);
		animRun = resolveFirstExisting(["run", "enemy_run"]);
		animJump = resolveFirstExisting(["jump", "enemy_jump"]);
		animFall = resolveFirstExisting(["fall", "enemy_fall"]);
		animShoot = resolveFirstExisting(["shoot", "enemy_shoot"]);

		if( animIdle==null )
			animIdle = resolveStateAnim(baseNames, "idle");
		if( animRun==null )
			animRun = resolveStateAnim(baseNames, "run");
		if( animJump==null )
			animJump = resolveStateAnim(baseNames, "jump");
		if( animFall==null )
			animFall = resolveStateAnim(baseNames, "fall");
		if( animShoot==null )
			animShoot = resolveStateAnim(baseNames, "shoot");

		if( animIdle!=null )
			applyAnim(animIdle);
		else
			createFallbackBitmap();
	}

	function createFallbackBitmap() {
		if( fallbackBitmap!=null )
			return;

		var col = switch(enemyType) {
			case "saw": 0x0000FF;
			case "red": 0xFF0000;
			case "shooting", "green": 0x008000;
			case "scared": 0x7A7AFF;
			case "spike": 0x666666;
			default: 0xBBBBBB;
		}

		fallbackBitmap = new h2d.Bitmap(h2d.Tile.fromColor(col, Std.int(iwid), Std.int(ihei)), spr);
		fallbackBitmap.tile.setCenterRatio(0.5, 1);
	}

	function resolveFirstExisting(candidates:Array<String>) : Null<String> {
		for( id in candidates )
			if( enemyLib.exists(id) )
				return id;
		return null;
	}

	function resolveStateAnim(baseNames:Array<String>, state:String) : Null<String> {
		var candidates = new Array<String>();
		for( base in baseNames ) {
			candidates.push(base + "_" + state);
			candidates.push(base + state.substr(0,1).toUpperCase() + state.substr(1));
		}
		for( base in baseNames )
			candidates.push(base);

		return resolveFirstExisting(candidates);
	}

	inline function isOnGroundNow() {
		return !destroyed && vBase.dy==0 && hasGroundSupport();
	}

	function applyAnim(group:Null<String>) {
		if( group==null || currentAnim==group )
			return;

		currentAnim = group;
		spr.set(enemyLib, group, 0);

		if( spr.group!=null && spr.group.anim!=null && spr.group.anim.length>0 )
			spr.anim.playAndLoop(group);
		else if( spr.animAllocated )
			spr.anim.stopWithoutStateAnims(group, 0);
	}

	function updateAnimState() {
		var next : Null<String>;

		if( cd.has("enemyShootAnim") && animShoot!=null )
			next = animShoot;
		else if( !isOnGroundNow() )
			next = dyTotal<0 ? (animJump!=null ? animJump : animIdle) : (animFall!=null ? animFall : animIdle);
		else if( M.fabs(dxTotal)>0.03 )
			next = animRun!=null ? animRun : animIdle;
		else
			next = animIdle;

		applyAnim(next);
	}

	override function dispose() {
		super.dispose();
		if( strategy != null ) {
			strategy.dispose();
			strategy = null;
		}
	}

	/** X collisions **/
	override function onPreStepX() {
		super.onPreStepX();

		// Right collision
		var rightCollisionX = dxTotal>0
			? enemyType=="scared"
				? getSolidColumnOnRightInBounds()
				: getSolidColumnOnRight()
			: null;
		if( rightCollisionX!=null ) {
			xr = rightCollisionX / Const.GRID - ( (1-pivotX) * wid ) / Const.GRID - cx;
			strategy.onXCollision(this, 1);
		}

		// Left collision
		var leftCollisionX = dxTotal<0
			? enemyType=="scared"
				? getSolidColumnOnLeftInBounds()
				: getSolidColumnOnLeft()
			: null;
		if( leftCollisionX!=null ) {
			xr = leftCollisionX / Const.GRID + ( pivotX * wid ) / Const.GRID - cx;
			strategy.onXCollision(this, -1);
		}
	}

	/** Y collisions **/
	override function onPreStepY() {
		super.onPreStepY();

		// Land on ground or hit ceiling
		var groundCollisionY = dyTotal>0 ? getGroundCollisionRow() : null;
		if( groundCollisionY!=null ) {
			vBase.clearY();
			vBump.clearY();
			yr = groundCollisionY / Const.GRID - ( (1-pivotY) * hei ) / Const.GRID - cy;
			onPosManuallyChangedY();
			strategy.onYCollision(this);
		}

		// Ceiling collision
		var ceilingCollisionY = dyTotal<0 ? getCeilingCollisionRow() : null;
		if( ceilingCollisionY!=null ) {
			vBase.clearY();
			vBump.clearY();
			yr = ceilingCollisionY / Const.GRID + ( pivotY * hei ) / Const.GRID - cy;
			onPosManuallyChangedY();
		}
	}

	/**
		Update is called at variable framerate (before/after fixedUpdate).
		We store strategy update logic in fixedUpdate instead.
	**/
	override function preUpdate() {
		super.preUpdate();
	}

	/**
		FixedUpdate is called at constant 30 FPS. All physics calculations happen here.
	**/
	override function fixedUpdate() {
		if( destroyed )
			return;

		super.fixedUpdate();

		if( destroyed )
			return;

		if( enemyType=="scared" && hasLeftLevelHorizontally() ) {
			destroy();
			return;
		}

		// Apply strategy behavior
		strategy.update(this);
		if( destroyed )
			return;

		updateAnimState();
	}
}
