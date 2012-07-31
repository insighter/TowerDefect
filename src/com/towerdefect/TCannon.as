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
	public class TCannon extends Tower
	{
		private var init:Init;
		
		public function TCannon(args:Object)
		{			
			_params = new TowerParams( {
				className:"com.towerdefect.TCannon",
				type:"cannon",
				title:"Странная двумерная пушка",
				text:"Не поворачивается, но отлично стреляет по всем направлениям.",
				cost:3,
				damage:1,
				reload:8,
				sample:"Snare", 
				radius:4
			});
			super(args);
			init = new Init(args);
		}
		
		public override function build(shotAtStep:int):void
		{
			scale(1, 1, 0);
			super.build(shotAtStep);
		}
		
		public override function prepare():void
		{
			projectile = new PBall( {
				rect:new Rectangle(this.x+10, this.y-4, 16, 16),
				target:target,
				soundManager:soundManager,
				muted:_muted,
				images:images
			});
			projectile.scale(0, 0, 0);
			if (containProjectiles)
			{
				this.addChild(projectile); 
				projectile.x = 0; 
				projectile.y = 0;
			}
			else 
				parent.addChild(projectile);
			super.prepare();
		}
		
		public override function unPrepare():void
		{
			projectile.hide(true, 1, 0, 0, 0, 0);
			super.unPrepare();
		}
		
		public override function shot():void
		{
			projectile.scale(0.3, 0.3, 0);
			projectile.fire();
			super.shot();
		}
	}
}