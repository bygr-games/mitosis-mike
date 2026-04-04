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

		if( level.data.l_Entities.all_PlayerExit != null ) {
			for( exitSpawn in level.data.l_Entities.all_PlayerExit )
				new SamplePlayerExit(exitSpawn.cx, exitSpawn.cy);
		}
		
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

		// Spawn shooting enemies (fall back to the old name to avoid breaking older maps)
		var shootingSpawns:Array<Dynamic> = cast Reflect.field(level.data.l_Entities, "all_ShootingEnemy");
		if( shootingSpawns == null )
			shootingSpawns = cast Reflect.field(level.data.l_Entities, "all_GreenEnemy");
		if( shootingSpawns != null ) {
			for( shootingSpawn in shootingSpawns ) {
				var cx:Int = cast Reflect.field(shootingSpawn, "cx");
				var cy:Int = cast Reflect.field(shootingSpawn, "cy");
				new SampleEnemy(cx, cy, "shooting");
			}
		}

		var scaredSpawns:Array<Dynamic> = cast Reflect.field(level.data.l_Entities, "all_ScaredEnemy");
		if( scaredSpawns != null ) {
			for( scaredSpawn in scaredSpawns ) {
				var cx:Int = cast Reflect.field(scaredSpawn, "cx");
				var cy:Int = cast Reflect.field(scaredSpawn, "cy");
				new SampleEnemy(cx, cy, "scared");
			}
		}
	}
}

