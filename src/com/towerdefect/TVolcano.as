package com.towerdefect
{
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author insighter
	 */
	public class TVolcano extends Tower
	{
		private var init:Init;
		
		public function TVolcano(args:Object)
		{
			_params = new TowerParams({
				className:"com.towerdefect.TVolcano",
				type:"volcano",
				title:"Дырка в земле",
				text:"Выплёвывает круглые ядра, доставляя неудобство прохожим.",
				cost:3,
				damage:2,
				reload:8,
				sample:"Kick",
				radius:2
			});
			super(args);
			init = new Init(args);
		}
		
		public override function build(shotAtStep:int):void
		{
			scale(0.5, 0.5);
			super.build(shotAtStep);
		}
		
		public override function prepare():void
		{
			scale(1, 1, 3);
			projectile = new PBall( {
				rect:new Rectangle(this.x, this.y, 16, 16),
				target:target,
				soundManager:soundManager,
				muted:_muted,
				images:images
			});
			if (containProjectiles)
			{
				this.addChild(projectile); 
				projectile.x = 0; 
				projectile.y = 0;
			}
			else 
				parent.addChild(projectile);
			projectile.scale(0, 0, 0);
			projectile.scale(1, 1, 3);
			super.prepare();
		}
		
		public override function unPrepare():void
		{
			scale(0.5, 0.5, 1);
			projectile.hide(true, 1, 0, 0, 0, 0);
			super.unPrepare();
		}
		
		public override function shot():void
		{
			super.shot();
			scale(0.5, 0.5, 0.3);
			projectile.fire();
		}
	}
}