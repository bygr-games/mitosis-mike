package sample;

class VioletProjectileStrategy implements ProjectileStrategy {
	var speed = 0.16;
	var lifetimeS = 2.0;

	public function new() {}

	public function initGraphics(projectile:Projectile):Void {
		projectile.iwid = 8;
		projectile.ihei = 4;
		projectile.setPivots(0.5, 0.5);

		projectile.vBase.setFricts(0.82, 1);
		projectile.cd.setS("projectileLife", lifetimeS);

		var b = new h2d.Bitmap(h2d.Tile.fromColor(0x8F00FF, projectile.iwid, projectile.ihei), projectile.spr);
		b.tile.setCenterRatio(0.5, 0.5);
	}

	public function update(projectile:Projectile):Void {
		if( !projectile.cd.has("projectileLife") ) {
			emitImpact(projectile.centerX, projectile.centerY, 0x8F00FF);
			projectile.destroy();
			return;
		}

		projectile.vBase.addX(projectile.dir * speed);

		if( !projectile.cd.hasSetS("projectileTrail", 0.03) ) {
			var p = projectile.fx.allocMain_add(D.tiles.fxDot, projectile.centerX, projectile.centerY);
			p.setCenterRatio(0.5, 0.5);
			p.setScale(0.45);
			p.alpha = 0.7;
			p.lifeS = 0.15;
			p.colorize(0x8F00FF);
		}
	}

	public function onXCollision(projectile:Projectile, dir:Int):Void {
		emitImpact(projectile.centerX, projectile.centerY, 0x8F00FF);
		projectile.destroy();
	}

	public function onEnemyHit(projectile:Projectile, enemy:SampleEnemy):Void {
		emitImpact(enemy.centerX, enemy.centerY, 0x8F00FF);
		projectile.destroy();
	}

	public function onPlayerHit(projectile:Projectile, player:SamplePlayer):Void {
		emitImpact(player.centerX, player.centerY, 0x8F00FF);
		projectile.destroy();
	}

	public function dispose():Void {}

	function emitImpact(x:Float, y:Float, color:Col):Void {
		for( i in 0...8 ) {
			var p = Game.ME.fx.allocMain_add(D.tiles.fxDot, x, y);
			p.setCenterRatio(0.5, 0.5);
			p.alpha = 1;
			p.setScale(0.7);
			p.lifeS = 0.18;
			p.frict = 0.86;
			p.moveAwayFrom(x, y, Lib.rnd(0.5, 1.3));
			p.colorize(color);
		}
	}
}
