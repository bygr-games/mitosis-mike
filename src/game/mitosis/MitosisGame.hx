package mitosis;

import mitosis.enemies.MitosisEnemy;

/**
	This small class creates game entities (player and enemies) from level data
**/
class MitosisGame extends Game {
	public function new() {
		super();
	}

	override function startLevel(l:World_Level) {
		super.startLevel(l);

		if( level.data.l_Entities.all_PlayerExit != null ) {
			for( exitSpawn in level.data.l_Entities.all_PlayerExit )
				new MitosisPlayerExit(exitSpawn.cx, exitSpawn.cy);
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
				new MitosisRecombobulator(cx, cy, requiredPercentage);
			}
		}
		
		// Spawn player
		new MitosisPlayer();

		// Spawn saw enemies
		if( level.data.l_Entities.all_SawEnemy != null ) {
			for( sawSpawn in level.data.l_Entities.all_SawEnemy )
				new MitosisEnemy(sawSpawn.cx, sawSpawn.cy, "saw");
		}

		// Spawn red enemies
		if( level.data.l_Entities.all_RedEnemy != null ) {
			for( redSpawn in level.data.l_Entities.all_RedEnemy )
				new MitosisEnemy(redSpawn.cx, redSpawn.cy, "red");
		}

		// Spawn shooting enemies
		if( level.data.l_Entities.all_ShootingEnemy != null ) {
			for( shootingSpawn in level.data.l_Entities.all_ShootingEnemy )
				new MitosisEnemy(shootingSpawn.cx, shootingSpawn.cy, "shooting");
		}

		// Spawn scared enemies
		if( level.data.l_Entities.all_ScaredEnemy != null ) {
			for( scaredSpawn in level.data.l_Entities.all_ScaredEnemy )
				new MitosisEnemy(scaredSpawn.cx, scaredSpawn.cy, "scared");
		}

		// Spawn spike enemies
		if( level.data.l_Entities.all_SpikeEnemy != null ) {
			for( spikeSpawn in level.data.l_Entities.all_SpikeEnemy )
				new MitosisEnemy(spikeSpawn.cx, spikeSpawn.cy, "spike");
		}

		// Spawn falling objects
		var fallingObjectSpawns:Array<Dynamic> = cast Reflect.field(level.data.l_Entities, "all_FallingObject");
		if( fallingObjectSpawns != null ) {
			for( fallingObjectSpawn in fallingObjectSpawns ) {
				var cx:Int = cast Reflect.field(fallingObjectSpawn, "cx");
				var cy:Int = cast Reflect.field(fallingObjectSpawn, "cy");
				var rawType:Dynamic = Reflect.field(fallingObjectSpawn, "f_type");
				if( rawType==null )
					rawType = Reflect.field(fallingObjectSpawn, "type");
				var sliceType = rawType==null ? "falling_object" : cast rawType;
				new FallingObject(cx, cy, sliceType);
			}
		}
	}
}



