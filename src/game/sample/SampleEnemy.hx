package sample;

/**
	SampleEnemy is an Entity that spawns from level data and exhibits different
	behaviors based on its strategy pattern implementation.
	
	Supported types:
	- "blue": walks back and forth, turns on collision/cliff
	- "red": stays in place and jumps constantly
**/
class SampleEnemy extends Entity {
	var strategy : EnemyStrategy;
	var enemyType : String;

	/**
		Create an enemy at a specific grid position with a given type
	**/
	public function new(cx:Int, cy:Int, type:String) {
		super(5, 5);

		enemyType = type;
		setPosCase(cx, cy);

		// Initialize physics
		vBase.setFricts(0.84, 0.94);

		// Create strategy based on type
		strategy = switch(type.toLowerCase()) {
			case "blue": new BlueEnemyStrategy();
			case "red": new RedEnemyStrategy();
			default: 
				trace('Unknown enemy type: $type, defaulting to blue');
				new BlueEnemyStrategy();
		}

		// Initialize graphics through strategy
		strategy.initGraphics(this);
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
	}
}
