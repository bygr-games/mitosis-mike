package sample;

interface ProjectileStrategy {
	function update(projectile:Projectile):Void;
	function onXCollision(projectile:Projectile, dir:Int):Void;
	function onEnemyHit(projectile:Projectile, enemy:SampleEnemy):Void;
	function initGraphics(projectile:Projectile):Void;
	function dispose():Void;
}
