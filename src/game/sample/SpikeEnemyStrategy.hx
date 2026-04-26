package sample;

class SpikeEnemyStrategy extends BaseEnemyStrategy {
	public function new() {
		super();
	}

	override public function initHitbox(enemy:SampleEnemy):Void {
		setHitbox(enemy, 16, 16);
	}

	override public function update(enemy:SampleEnemy):Void {
		applyGravityIfAirborne(enemy);
	}
}