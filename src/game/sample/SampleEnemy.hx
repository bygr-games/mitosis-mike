package sample;

/**
	SampleEnemy is an Entity that spawns from level data and exhibits different
	behaviors based on its strategy pattern implementation.
	
	Supported types:
	- "blue": walks back and forth, turns on collision/cliff
	- "red": stays in place and jumps constantly
	- "green": stays in place and shoots toward player every 3 seconds
**/
class SampleEnemy extends Entity {
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

	/**
		Create an enemy at a specific grid position with a given type
	**/
	public function new(cx:Int, cy:Int, type:String) {
		super(5, 5);

		enemyType = type.toLowerCase();
		setPosCase(cx, cy);

		// Initialize physics
		vBase.setFricts(0.84, 0.94);

		// Create strategy based on type
		strategy = switch(type.toLowerCase()) {
			case "blue": new BlueEnemyStrategy();
			case "red": new RedEnemyStrategy();
			case "green": new GreenEnemyStrategy();
			default: 
				trace('Unknown enemy type: $type, defaulting to blue');
				new BlueEnemyStrategy();
		}

		// Initialize graphics through strategy
		strategy.initGraphics(this);
		initGraphics();
	}

	function initGraphics() {
		enemyLib = switch(enemyType) {
			case "red": Assets.enemyRed;
			case "blue": Assets.enemyBlue;
			case "green": Assets.enemyGreen;
			default: Assets.enemyBlue;
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
			case "blue": 0x0000FF;
			case "red": 0xFF0000;
			case "green": 0x008000;
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
		return !destroyed && vBase.dy==0 && yr==1 && level.hasCollision(cx, cy+1);
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
		if( xr > 0.8 && level.hasCollision(cx + 1, cy) ) {
			xr = 0.8;
			strategy.onXCollision(this, 1);
		}

		// Left collision
		if( xr < 0.2 && level.hasCollision(cx - 1, cy) ) {
			xr = 0.2;
			strategy.onXCollision(this, -1);
		}
	}

	/** Y collisions **/
	override function onPreStepY() {
		super.onPreStepY();

		// Land on ground or hit ceiling
		if( yr > 1 && level.hasCollision(cx, cy + 1) ) {
			vBase.clearY();
			vBump.clearY();
			yr = 1;
			strategy.onYCollision(this);
		}

		// Ceiling collision
		if( yr < 0.2 && level.hasCollision(cx, cy - 1) )
			yr = 0.2;
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
		super.fixedUpdate();

		// Apply strategy behavior
		strategy.update(this);
		updateAnimState();
	}
}
