package sample;

interface ProjectileStrategy {
	function update(projectile:Projectile):Void;
	function collidesWithLevelBounds():Bool;
	function onXCollision(projectile:Projectile, dir:Int):Void;
	function onYCollision(projectile:Projectile, dir:Int):Void;
	function onEnemyHit(projectile:Projectile, enemy:SampleEnemy):Void;
	function onPlayerHit(projectile:Projectile, player:SamplePlayer):Void;
	function initGraphics(projectile:Projectile):Void;
	function dispose():Void;
}
