package sample;

class Projectile extends Entity {
	var strategy : ProjectileStrategy;
	public var projectileType(default, null) : String;

	public function new(x:Float, y:Float, shotDir:Int, type:String) {
		super(0, 0);

		projectileType = type;
		dir = shotDir;
		setPosPixel(x, y);
		vBase.setFricts(0.82, 1);

		strategy = switch( type.toLowerCase() ) {
			case "basic": new BasicProjectileStrategy();
			default:
				trace('Unknown projectile type: $type, defaulting to basic');
				new BasicProjectileStrategy();
		}

		strategy.initGraphics(this);
	}

	override function dispose() {
		super.dispose();
		if( strategy!=null ) {
			strategy.dispose();
			strategy = null;
		}
	}

	override function onPreStepX() {
		super.onPreStepX();

		if( xr > 0.8 && level.hasCollision(cx + 1, cy) ) {
			xr = 0.8;
			strategy.onXCollision(this, 1);
		}

		if( xr < 0.2 && level.hasCollision(cx - 1, cy) ) {
			xr = 0.2;
			strategy.onXCollision(this, -1);
		}
	}

	override function fixedUpdate() {
		if( destroyed )
			return;

		strategy.update(this);
		super.fixedUpdate();

		if( destroyed )
			return;

		for( e in Entity.ALL ) {
			if( e.destroyed || !e.is(SampleEnemy) )
				continue;

			if( Lib.rectangleOverlaps(left, top, wid, hei, e.left, e.top, e.wid, e.hei) ) {
				var enemy = e.as(SampleEnemy);
				enemy.kill(this);
				strategy.onEnemyHit(this, enemy);
				break;
			}
		}
	}
}
