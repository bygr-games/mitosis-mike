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

		// Spawn saw enemies
		if( level.data.l_Entities.all_SawEnemy != null ) {
			for( sawSpawn in level.data.l_Entities.all_SawEnemy )
				new SampleEnemy(sawSpawn.cx, sawSpawn.cy, "saw");
		}

		// Spawn red enemies
		if( level.data.l_Entities.all_RedEnemy != null ) {
			for( redSpawn in level.data.l_Entities.all_RedEnemy ) {
				new SampleEnemy(redSpawn.cx, redSpawn.cy, "red");
			}
		}

		// Spawn shooting enemies
		if( level.data.l_Entities.all_ShootingEnemy != null ) {
			for( shootingSpawn in level.data.l_Entities.all_ShootingEnemy )
				new SampleEnemy(shootingSpawn.cx, shootingSpawn.cy, "shooting");
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

