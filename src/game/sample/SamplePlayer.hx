package sample;

/**
	SamplePlayer is an Entity with some extra functionalities:
	- user controlled (using gamepad or keyboard)
	- falls with gravity
	- has basic level collisions
	- some squash animations, because it's cheap and they do the job
**/

class SamplePlayer extends Entity {
	var ca : ControllerAccess<GameAction>;
	var walkSpeed = 0.;
	static var levelStartByUid : Map<Int,{ cx:Int, cy:Int }>;

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


	public function new() {
		super(5,5);

		// Start point using level entity "PlayerStart"
		var start = getCurrentLevelStart();
		if( start!=null )
			setPosCase(start.cx, start.cy);

		// Misc inits
		vBase.setFricts(0.84, 0.94);

		// Camera tracks this
		camera.trackEntity(this, true);
		camera.clampToLevelBounds = true;

		// Init controller
		ca = App.ME.controller.createAccess();
		ca.lockCondition = Game.isGameControllerLocked;

		// Placeholder display
		var b = new h2d.Bitmap( h2d.Tile.fromColor(Green, iwid, ihei), spr );
		b.tile.setCenterRatio(0.5,1);
	}


	override function dispose() {
		super.dispose();
		ca.dispose(); // don't forget to dispose controller accesses
	}


	override function onDie() {
		// Respawn at start instead of destroying
		cancelVelocities();
		initLife(1);
		var start = getCurrentLevelStart();
		if( start!=null )
			setPosCase(start.cx, start.cy);
		else
			setPosCase(5, 5);
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
	}
}