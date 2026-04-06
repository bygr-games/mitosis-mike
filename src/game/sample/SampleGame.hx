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

		var recombobulatorSpawns:Array<Dynamic> = cast Reflect.field(level.data.l_Entities, "all_Recombobulator");
		if( recombobulatorSpawns != null ) {
			for( recombobulatorSpawn in recombobulatorSpawns ) {
				var cx:Int = cast Reflect.field(recombobulatorSpawn, "cx");
				var cy:Int = cast Reflect.field(recombobulatorSpawn, "cy");
				var rawRequired:Dynamic = Reflect.field(recombobulatorSpawn, "f_RequiredPercentage");
				if( rawRequired==null )
					rawRequired = Reflect.field(recombobulatorSpawn, "RequiredPercentage");
				var requiredPercentage = rawRequired==null ? 0.0 : cast rawRequired;
				new SampleRecombobulator(cx, cy, requiredPercentage);
			}
		}
		
		// Spawn player
		new SamplePlayer();

		// Spawn saw enemies (fall back to the old name to avoid breaking older maps)
		var sawSpawns:Array<Dynamic> = cast Reflect.field(level.data.l_Entities, "all_SawEnemy");
		if( sawSpawns == null )
			sawSpawns = cast Reflect.field(level.data.l_Entities, "all_BlueEnemy");
		if( sawSpawns != null ) {
			for( sawSpawn in sawSpawns ) {
				var cx:Int = cast Reflect.field(sawSpawn, "cx");
				var cy:Int = cast Reflect.field(sawSpawn, "cy");
				new SampleEnemy(cx, cy, "saw");
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

		var spikeSpawns:Array<Dynamic> = cast Reflect.field(level.data.l_Entities, "all_SpikeEnemy");
		if( spikeSpawns != null ) {
			for( spikeSpawn in spikeSpawns ) {
				var cx:Int = cast Reflect.field(spikeSpawn, "cx");
				var cy:Int = cast Reflect.field(spikeSpawn, "cy");
				new SampleEnemy(cx, cy, "spike");
			}
		}
	}
}

