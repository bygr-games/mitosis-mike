package sample;

/**
	This small class creates game entities (player and enemies) from level data
**/
class SampleGame extends Game {
	public function new() {
		super();
	}

	override function startLevel(l:World_Level) {
		super.startLevel(l);
		
		// Spawn player
		new SamplePlayer();

		// Spawn blue enemies
		if( level.data.l_Entities.all_BlueEnemy != null ) {
			for( blueSpawn in level.data.l_Entities.all_BlueEnemy ) {
				new SampleEnemy(blueSpawn.cx, blueSpawn.cy, "blue");
			}
		}

		// Spawn red enemies
		if( level.data.l_Entities.all_RedEnemy != null ) {
			for( redSpawn in level.data.l_Entities.all_RedEnemy ) {
				new SampleEnemy(redSpawn.cx, redSpawn.cy, "red");
			}
		}

		// Spawn green enemies (reflection keeps compatibility if LDtk entity is not defined yet)
		var greenSpawns:Array<Dynamic> = cast Reflect.field(level.data.l_Entities, "all_GreenEnemy");
		if( greenSpawns != null ) {
			for( greenSpawn in greenSpawns ) {
				var cx:Int = cast Reflect.field(greenSpawn, "cx");
				var cy:Int = cast Reflect.field(greenSpawn, "cy");
				new SampleEnemy(cx, cy, "green");
			}
		}
	}
}

