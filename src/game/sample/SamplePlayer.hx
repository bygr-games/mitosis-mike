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
	static inline var BASE_WIDTH = 16;
	static inline var BASE_HEIGHT = 32;
	static inline var SPLIT_COUNT = 2;
	static inline var SPLIT_MIN_SPEED_X = 0.22;
	static inline var SPLIT_MAX_SPEED_X = 0.38;
	static inline var SPLIT_MIN_SPEED_Y = 0.45;
	static inline var SPLIT_MAX_SPEED_Y = 0.72;
	static inline var COLLISION_EPSILON = 0.001;
	static inline var SPAWN_IMMUNITY_S = 1.0;
	static inline var CAMERA_FIT_PADDING = 32.0;
	static inline var CAMERA_VISIBLE_PADDING = 12.0;
	static inline var CAMERA_DEFAULT_ZOOM = 1;
	static var SIZE_LEVELS = [
		{ wid:16, hei:32 },
		{ wid:12, hei:24 },
		{ wid:8, hei:16 },
		{ wid:6, hei:12 },
		{ wid:4, hei:8 },
		{ wid:3, hei:6 },
	];

	var ca : ControllerAccess<GameAction>;
	var immunityShader : NegativeColorShader;
	var walkSpeed = 0.;
	static var levelStartByUid : Map<Int,{ cx:Int, cy:Int }>;
	var fallbackBitmap : Null<h2d.Bitmap>;
	var sizeLevel(default,null) : Int;

	var animIdle : Null<String>;
	var animRun : Null<String>;
	var animJump : Null<String>;
	var animFall : Null<String>;
	var animShoot : Null<String>;
	var currentAnim : Null<String>;

	// This is TRUE if the player is not falling
	var onGround(get,never) : Bool;
		inline function get_onGround() return !destroyed && vBase.dy==0 && hasGroundSupport();

	inline function pxToLevelCoord(v:Float) {
		return Std.int(Math.floor(v / Const.GRID));
	}

	inline function isSolidPlayer(other:SamplePlayer) {
		return other!=this && !other.destroyed && other.isAlive();
	}

	inline function overlapsPlayerX(other:SamplePlayer) {
		return right > other.left + COLLISION_EPSILON && left < other.right - COLLISION_EPSILON;
	}

	inline function overlapsPlayerY(other:SamplePlayer) {
		return bottom > other.top + COLLISION_EPSILON && top < other.bottom - COLLISION_EPSILON;
	}

	function getSolidColumnOnRight() : Null<Float> {
		var probeCx = pxToLevelCoord(right);
		var topCy = pxToLevelCoord(top + COLLISION_EPSILON);
		var bottomCy = pxToLevelCoord(bottom - COLLISION_EPSILON);
		for( probeCy in topCy...bottomCy+1 )
			if( level.hasCollision(probeCx, probeCy) )
				return probeCx * Const.GRID;

		var best:Null<Float> = null;
		for( e in Entity.ALL )
			if( !e.destroyed && e.is(SamplePlayer) ) {
				var other = e.as(SamplePlayer);
				if( !isSolidPlayer(other) || !overlapsPlayerY(other) )
					continue;

				if( right > other.left && left < other.left && centerX <= other.centerX )
					if( best==null || other.left<best )
						best = other.left;
			}

		return best;
	}

	function getSolidColumnOnLeft() : Null<Float> {
		var probeCx = pxToLevelCoord(left - COLLISION_EPSILON);
		var topCy = pxToLevelCoord(top + COLLISION_EPSILON);
		var bottomCy = pxToLevelCoord(bottom - COLLISION_EPSILON);
		for( probeCy in topCy...bottomCy+1 )
			if( level.hasCollision(probeCx, probeCy) )
				return (probeCx + 1) * Const.GRID;

		var best:Null<Float> = null;
		for( e in Entity.ALL )
			if( !e.destroyed && e.is(SamplePlayer) ) {
				var other = e.as(SamplePlayer);
				if( !isSolidPlayer(other) || !overlapsPlayerY(other) )
					continue;

				if( left < other.right && right > other.right && centerX >= other.centerX )
					if( best==null || other.right>best )
						best = other.right;
			}

		return best;
	}

	function getGroundCollisionRow() : Null<Float> {
		var probeCy = pxToLevelCoord(bottom);
		var leftCx = pxToLevelCoord(left + COLLISION_EPSILON);
		var rightCx = pxToLevelCoord(right - COLLISION_EPSILON);
		for( probeCx in leftCx...rightCx+1 )
			if( level.hasCollision(probeCx, probeCy) )
				return probeCy * Const.GRID;

		var best:Null<Float> = null;
		for( e in Entity.ALL )
			if( !e.destroyed && e.is(SamplePlayer) ) {
				var other = e.as(SamplePlayer);
				if( !isSolidPlayer(other) || !overlapsPlayerX(other) )
					continue;

				if( bottom > other.top && top < other.top && centerY <= other.centerY )
					if( best==null || other.top<best )
						best = other.top;
			}

		return best;
	}

	function getCeilingCollisionRow() : Null<Float> {
		var probeCy = pxToLevelCoord(top - COLLISION_EPSILON);
		var leftCx = pxToLevelCoord(left + COLLISION_EPSILON);
		var rightCx = pxToLevelCoord(right - COLLISION_EPSILON);
		for( probeCx in leftCx...rightCx+1 )
			if( level.hasCollision(probeCx, probeCy) )
				return (probeCy + 1) * Const.GRID;

		var best:Null<Float> = null;
		for( e in Entity.ALL )
			if( !e.destroyed && e.is(SamplePlayer) ) {
				var other = e.as(SamplePlayer);
				if( !isSolidPlayer(other) || !overlapsPlayerX(other) )
					continue;

				if( top < other.bottom && bottom > other.bottom && centerY >= other.centerY )
					if( best==null || other.bottom>best )
						best = other.bottom;
			}

		return best;
	}

	function hasGroundSupport() {
		if( getGroundCollisionRow()!=null )
			return true;

		for( e in Entity.ALL )
			if( !e.destroyed && e.is(SamplePlayer) ) {
				var other = e.as(SamplePlayer);
				if( !isSolidPlayer(other) )
					continue;

				if( right > other.left + COLLISION_EPSILON && left < other.right - COLLISION_EPSILON && M.fabs(bottom - other.top) <= COLLISION_EPSILON*4 )
					return true;
			}

		return false;
	}

	static function loadLevelStarts() {
		if( levelStartByUid!=null )
			return;

		levelStartByUid = new Map();
		var raw:Dynamic = haxe.Json.parse(hxd.Res.levels.mitosisWorld.entry.getText());
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

	static function resolveSurvivorsMidpoint(out:LPoint) {
		var totalX = 0.0;
		var totalY = 0.0;
		var count = 0;

		for( e in Entity.ALL )
			if( !e.destroyed && e.is(SamplePlayer) ) {
				var player = e.as(SamplePlayer);
				if( !player.isAlive() )
					continue;

				totalX += player.centerX;
				totalY += player.centerY;
				count++;
			}

		if( count==0 )
			return false;

		out.levelX = totalX / count;
		out.levelY = totalY / count;
		return true;
	}

	static function getSurvivorBounds() {
		var minX = 9999999.0;
		var minY = 9999999.0;
		var maxX = -9999999.0;
		var maxY = -9999999.0;
		var count = 0;

		for( e in Entity.ALL )
			if( !e.destroyed && e.is(SamplePlayer) ) {
				var player = e.as(SamplePlayer);
				if( !player.isAlive() )
					continue;

				minX = M.fmin(minX, player.left);
				minY = M.fmin(minY, player.top);
				maxX = M.fmax(maxX, player.right);
				maxY = M.fmax(maxY, player.bottom);
				count++;
			}

		if( count==0 )
			return null;

		return {
			minX:minX,
			minY:minY,
			maxX:maxX,
			maxY:maxY,
		};
	}

	static function updateSurvivorCameraZoom() {
		if( !Game.exists() )
			return;

		var bounds = getSurvivorBounds();
		if( bounds==null )
			return;

		var fitWidth = M.fmax(Const.GRID*2, bounds.maxX-bounds.minX) + CAMERA_FIT_PADDING*2;
		var fitHeight = M.fmax(Const.GRID*2, bounds.maxY-bounds.minY) + CAMERA_FIT_PADDING*2;
		var zoomX = Game.ME.stageWid / Const.SCALE / fitWidth;
		var zoomY = Game.ME.stageHei / Const.SCALE / fitHeight;
		var desiredZoom = M.fmin(CAMERA_DEFAULT_ZOOM, M.fmin(zoomX, zoomY));

		var camera = Game.ME.camera;
		var allVisible = bounds.minX >= camera.pxLeft + CAMERA_VISIBLE_PADDING
			&& bounds.maxX <= camera.pxRight - CAMERA_VISIBLE_PADDING
			&& bounds.minY >= camera.pxTop + CAMERA_VISIBLE_PADDING
			&& bounds.maxY <= camera.pxBottom - CAMERA_VISIBLE_PADDING;

		if( !allVisible || camera.zoom > desiredZoom ) {
			camera.centerOnTarget();
			camera.forceZoom(desiredZoom);
		}
		else
			camera.zoomTo(desiredZoom);
	}


	public function new(?spawnX:Float, ?spawnY:Float, trackCamera=true, sizeLevel=0) {
		super(5,5);
		this.sizeLevel = M.iclamp(sizeLevel, 0, SIZE_LEVELS.length-1);
		applySizeLevel();

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

		camera.trackPoint(resolveSurvivorsMidpoint, trackCamera);
		camera.clampToLevelBounds = true;

		// Init controller
		ca = App.ME.controller.createAccess();
		ca.lockCondition = Game.isGameControllerLocked;
		ucd.setS("spawnImmunity", SPAWN_IMMUNITY_S);
		immunityShader = new NegativeColorShader();
		spr.addShader(immunityShader);

		initGraphics();
	}

	inline function getSizeData() {
		return SIZE_LEVELS[sizeLevel];
	}

	inline function hasNextSizeLevel() {
		return sizeLevel < SIZE_LEVELS.length-1;
	}

	inline function isSmallestSize() {
		return sizeLevel == SIZE_LEVELS.length-1;
	}

	inline function isEnemyThreat(from:Null<Entity>) {
		if( from==null || !isSmallestSize() )
			return false;

		if( from.is(SampleEnemy) )
			return true;

		if( from.is(Projectile) ) {
			var projectile = from.as(Projectile);
			return projectile!=null && projectile.targetType=="player";
		}

		return false;
	}

	function applySizeLevel() {
		var size = getSizeData();
		iwid = size.wid;
		ihei = size.hei;
		sprScaleX = wid / BASE_WIDTH;
		sprScaleY = hei / BASE_HEIGHT;
	}

	override public function hit(dmg:Int, from:Null<Entity>) {
		if( ucd.has("spawnImmunity") || isEnemyThreat(from) )
			return;

		super.hit(dmg, from);
	}

	override function postUpdate() {
		super.postUpdate();
		immunityShader.intensity = ucd.has("spawnImmunity") ? 1 : 0;
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
		return !destroyed && vBase.dy==0 && hasGroundSupport();
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
		var childSizeLevel = sizeLevel + 1;

		if( hasNextSizeLevel() ) {
			for( i in 0...SPLIT_COUNT ) {
				var child = new SamplePlayer(spawnX, spawnY, i==0, childSizeLevel);
				child.applySplitFling(i);
			}
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

	function resolveEnemyPush(enemy:SampleEnemy) {
		var overlapLeft = right - enemy.left;
		var overlapRight = enemy.right - left;
		var overlapUp = bottom - enemy.top;
		var overlapDown = enemy.bottom - top;
		var pushX = centerX < enemy.centerX ? -overlapLeft : overlapRight;
		var pushY = centerY < enemy.centerY ? -overlapUp : overlapDown;

		if( M.fabs(pushX) <= M.fabs(pushY) ) {
			setPosPixel(attachX + pushX, attachY);
			vBase.clearX();
			vBump.clearX();
			bump(pushX<0 ? -0.03 : 0.03, 0);
		}
		else {
			setPosPixel(attachX, attachY + pushY);
			vBase.clearY();
			vBump.clearY();
			bump(0, pushY<0 ? -0.03 : 0.03);
		}
	}


	/** X collisions **/
	override function onPreStepX() {
		super.onPreStepX();

		// Right collision
		var rightCollisionX = dxTotal>0 ? getSolidColumnOnRight() : null;
		if( rightCollisionX!=null )
			xr = rightCollisionX / Const.GRID - ( (1-pivotX) * wid ) / Const.GRID - cx;

		// Left collision
		var leftCollisionX = dxTotal<0 ? getSolidColumnOnLeft() : null;
		if( leftCollisionX!=null )
			xr = leftCollisionX / Const.GRID + ( pivotX * wid ) / Const.GRID - cx;
	}


	/** Y collisions **/
	override function onPreStepY() {
		super.onPreStepY();

		// Land on ground
		var groundCollisionY = dyTotal>0 ? getGroundCollisionRow() : null;
		if( groundCollisionY!=null ) {
			setSquashY(0.5);
			vBase.clearY();
			vBump.clearY();
			yr = groundCollisionY / Const.GRID - ( (1-pivotY) * hei ) / Const.GRID - cy;
			ca.rumble(0.2, 0.06);
			onPosManuallyChangedY();
		}

		// Ceiling collision
		var ceilingCollisionY = dyTotal<0 ? getCeilingCollisionRow() : null;
		if( ceilingCollisionY!=null )
			yr = ceilingCollisionY / Const.GRID + ( pivotY * hei ) / Const.GRID - cy;
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

		// Enemy body contact
		for( e in Entity.ALL )
			if( !e.destroyed && e.is(SampleEnemy) ) {
				var enemy = e.as(SampleEnemy);
				if( !Lib.rectangleOverlaps(left, top, wid, hei, enemy.left, enemy.top, enemy.wid, enemy.hei) )
					continue;

				if( isSmallestSize() )
					resolveEnemyPush(enemy);
				else {
					kill(enemy);
					break;
				}
			}

		updateSurvivorCameraZoom();

		updateAnimState();
	}
}

private class NegativeColorShader extends hxsl.Shader {
	static var SRC = {
		@param var intensity : Float;
		var pixelColor : Vec4;

		function fragment() {
			pixelColor.rgb = pixelColor.rgb * (1.0 - intensity) + (vec3(1.0) - pixelColor.rgb) * intensity;
		}
	};

	public function new() {
		super();
		intensity = 0;
	}
}