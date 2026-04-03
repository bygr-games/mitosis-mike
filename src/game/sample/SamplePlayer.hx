package sample;

import sample.Projectile;

/**
	SamplePlayer is an Entity with some extra functionalities:
	- user controlled (using gamepad or keyboard)
	- falls with gravity
	- has basic level collisions
	- some squash animations, because it's cheap and they do the job
**/

class SamplePlayer extends Entity {
	static inline var SPLIT_COUNT = 2;
	static inline var SPLIT_MIN_SPEED_X = 0.22;
	static inline var SPLIT_MAX_SPEED_X = 0.38;
	static inline var SPLIT_MIN_SPEED_Y = 0.45;
	static inline var SPLIT_MAX_SPEED_Y = 0.72;
	static inline var SPAWN_IMMUNITY_S = 1.0;

	var ca : ControllerAccess<GameAction>;
	var walkSpeed = 0.;
	static var levelStartByUid : Map<Int,{ cx:Int, cy:Int }>;
	var fallbackBitmap : Null<h2d.Bitmap>;

	var animIdle : Null<String>;
	var animRun : Null<String>;
	var animJump : Null<String>;
	var animFall : Null<String>;
	var animShoot : Null<String>;
	var currentAnim : Null<String>;

	// This is TRUE if the player is not falling
	var onGround(get,never) : Bool;
		inline function get_onGround() return !destroyed && vBase.dy==0 && yr==1 && level.hasCollision(cx,cy+1);

	static function loadLevelStarts() {
		if( levelStartByUid!=null )
			return;

		levelStartByUid = new Map();
		var raw:Dynamic = haxe.Json.parse(hxd.Res.levels.sampleWorld.entry.getText());
		var worlds:Array<Dynamic> = cast Reflect.field(raw, "worlds");
		if( worlds==null )
			return;

		for( world in worlds ) {
			var levels:Array<Dynamic> = cast Reflect.field(world, "levels");
			if( levels==null )
				continue;

			for( l in levels ) {
				var levelUid:Int = cast Reflect.field(l, "uid");
				var layers:Array<Dynamic> = cast Reflect.field(l, "layerInstances");
				if( layers==null )
					continue;

				for( layer in layers ) {
					if( Reflect.field(layer, "__identifier")!="Entities" )
						continue;

					var entities:Array<Dynamic> = cast Reflect.field(layer, "entityInstances");
					if( entities==null )
						continue;

					for( entity in entities ) {
						if( Reflect.field(entity, "__identifier")=="PlayerStart" ) {
							var grid:Array<Int> = cast Reflect.field(entity, "__grid");
							if( grid!=null && grid.length>=2 )
								levelStartByUid.set(levelUid, { cx:grid[0], cy:grid[1] });
							break;
						}
					}

					break;
				}
			}
		}
	}

	inline function getCurrentLevelStart() {
		loadLevelStarts();
		return levelStartByUid.get(level.data.uid);
	}


	public function new(?spawnX:Float, ?spawnY:Float, trackCamera=true) {
		super(5,5);

		if( spawnX!=null && spawnY!=null )
			setPosPixel(spawnX, spawnY);
		else {
			// Start point using level entity "PlayerStart"
			var start = getCurrentLevelStart();
			if( start!=null )
				setPosCase(start.cx, start.cy);
		}

		// Misc inits
		vBase.setFricts(0.84, 0.94);

		if( trackCamera ) {
			camera.trackEntity(this, true);
			camera.clampToLevelBounds = true;
		}

		// Init controller
		ca = App.ME.controller.createAccess();
		ca.lockCondition = Game.isGameControllerLocked;
		ucd.setS("spawnImmunity", SPAWN_IMMUNITY_S);

		initGraphics();
	}

	override public function hit(dmg:Int, from:Null<Entity>) {
		if( ucd.has("spawnImmunity") )
			return;

		super.hit(dmg, from);
	}

	function initGraphics() {
		animIdle = resolveFirstExisting([
			"idle",
			"player_idle",
			"samplePlayer_idle",
			"sample_player_idle",
			"player"
		]);
		animRun = resolveFirstExisting([
			"run",
			"player_run",
			"samplePlayer_run",
			"sample_player_run"
		]);
		animJump = resolveFirstExisting([
			"jump",
			"player_jump",
			"samplePlayer_jump",
			"sample_player_jump"
		]);
		animFall = resolveFirstExisting([
			"fall",
			"player_fall",
			"samplePlayer_fall",
			"sample_player_fall"
		]);
		animShoot = resolveFirstExisting([
			"shoot",
			"player_shoot",
			"samplePlayer_shoot",
			"sample_player_shoot"
		]);

		if( animIdle!=null )
			applyAnim(animIdle);
		else
			createFallbackBitmap();
	}

	function createFallbackBitmap() {
		if( fallbackBitmap!=null )
			return;
		fallbackBitmap = new h2d.Bitmap( h2d.Tile.fromColor(Green, iwid, ihei), spr );
		fallbackBitmap.tile.setCenterRatio(0.5,1);
	}

	function resolveFirstExisting(candidates:Array<String>) : Null<String> {
		for( id in candidates )
			if( Assets.player.exists(id) )
				return id;
		return null;
	}

	inline function isOnGroundNow() {
		return !destroyed && vBase.dy==0 && yr==1 && level.hasCollision(cx,cy+1);
	}

	function applyAnim(group:Null<String>) {
		if( group==null || currentAnim==group )
			return;

		currentAnim = group;
		spr.set(Assets.player, group, 0);

		if( spr.group!=null && spr.group.anim!=null && spr.group.anim.length>0 )
			spr.anim.playAndLoop(group);
		else if( spr.animAllocated )
			spr.anim.stopWithoutStateAnims(group, 0);
	}

	function updateAnimState() {
		var next : Null<String>;

		if( cd.has("shootLock") && animShoot!=null )
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
		ca.dispose(); // don't forget to dispose controller accesses
	}


	override function onDie() {
		var spawnX = attachX;
		var spawnY = attachY;

		for( i in 0...SPLIT_COUNT ) {
			var child = new SamplePlayer(spawnX, spawnY, i==0);
			child.applySplitFling(i);
		}

		destroy();
	}

	function applySplitFling(index:Int) {
		cancelVelocities();
		var baseDir = index==0 ? -1 : 1;
		var horizontalSpeed = rnd(SPLIT_MIN_SPEED_X, SPLIT_MAX_SPEED_X) * baseDir;
		var verticalSpeed = -rnd(SPLIT_MIN_SPEED_Y, SPLIT_MAX_SPEED_Y);
		var horizontalJitter = rnd(0, 0.12, true);
		vBase.addX(horizontalSpeed + horizontalJitter);
		vBase.addY(verticalSpeed);
		dir = horizontalSpeed>=0 ? 1 : -1;
	}


	/** X collisions **/
	override function onPreStepX() {
		super.onPreStepX();

		// Right collision
		if( xr>0.8 && level.hasCollision(cx+1,cy) )
			xr = 0.8;

		// Left collision
		if( xr<0.2 && level.hasCollision(cx-1,cy) )
			xr = 0.2;
	}


	/** Y collisions **/
	override function onPreStepY() {
		super.onPreStepY();

		// Land on ground
		if( yr>1 && level.hasCollision(cx,cy+1) ) {
			setSquashY(0.5);
			vBase.clearY();
			vBump.clearY();
			yr = 1;
			ca.rumble(0.2, 0.06);
			onPosManuallyChangedY();
		}

		// Ceiling collision
		if( yr<0.2 && level.hasCollision(cx,cy-1) )
			yr = 0.2;
	}


	/**
		Control inputs are checked at the beginning of the frame.
		VERY IMPORTANT NOTE: because game physics only occur during the `fixedUpdate` (at a constant 30 FPS), no physics increment should ever happen here! What this means is that you can SET a physics value (eg. see the Jump below), but not make any calculation that happens over multiple frames (eg. increment X speed when walking).
	**/
	override function preUpdate() {
		super.preUpdate();

		walkSpeed = 0;
		if( onGround )
			cd.setS("recentlyOnGround",0.1); // allows "just-in-time" jumps


		// Jump
		if( cd.has("recentlyOnGround") && ca.isPressed(Jump) ) {
			vBase.addY(-0.85);
			setSquashX(0.6);
			cd.unset("recentlyOnGround");
			fx.dotsExplosionExample(centerX, centerY, 0xffcc00);
			ca.rumble(0.05, 0.06);
		}

		// Walk
		if( !isChargingAction() && ca.getAnalogDist2(MoveLeft,MoveRight)>0 ) {
			// As mentioned above, we don't touch physics values (eg. `dx`) here. We just store some "requested walk speed", which will be applied to actual physics in fixedUpdate.
			walkSpeed = ca.getAnalogValue2(MoveLeft,MoveRight); // -1 to 1
			dir = walkSpeed>0 ? 1 : -1;
		}

		// Shoot
		if( ca.isPressed(Shoot) && !cd.hasSetS("shootLock", 0.12) ) {
			new Projectile(centerX + dir*8, centerY-4, dir, "basic");
			ca.rumble(0.03, 0.03);
		}
	}


	override function fixedUpdate() {
		super.fixedUpdate();

		// Gravity
		if( !onGround )
			vBase.addY(0.05);

		// Apply requested walk movement
		if( walkSpeed!=0 )
			vBase.addX( walkSpeed*0.045 ); // some arbitrary speed

		// Start next level when touching a PlayerExit entity
		for( exit in level.data.l_Entities.all_PlayerExit )
			if( distCase(null, exit.cx, exit.cy) < 1 ) {
				if( !cd.hasSetS("levelExit", 0.2) )
					app.delayer.nextFrame( ()->game.startNextLevelWrap() );
				return;
			}

		// Die when touched by an enemy
		for( e in Entity.ALL )
			if( !e.destroyed && e.is(SampleEnemy) && distCase(e) < 1 )
				kill(e);

		updateAnimState();
	}
}