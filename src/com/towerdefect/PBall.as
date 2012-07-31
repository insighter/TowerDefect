package com.towerdefect
{
	import com.greensock.easing.ExpoOut;
	import com.towerdefect.Projectile;
	import com.greensock.TweenMax;
	import flash.filters.DropShadowFilter;
	/**
	 * ...
	 * @author insighter
	 */
	public class PBall extends Projectile
	{
		private var init:Init;
		
		public function PBall(args:Object)
		{
			_params=new ProjectileParams({
				className:"com.towerdefect.PBall",
				type:"ball",
				damage:5,
				speed:2,
				size:1
			});
			args.dropShadowFilter = new DropShadowFilter(4, 45, 0x000000, 0.8, 6, 6, 1, 3);//Ball projectile has shadow
			super(args);
			init = new Init(args);
		}
		
		public override function fire():void
		{
			super.fire();
			TweenMax.to(this, 0.3, { dropShadowFilter: { distance:30 }, ease:ExpoOut, repeat:1, yoyo:true } );
		}
		
		public override function hitTarget():void
		{
			if(!_muted)
				soundManager.playSound("ballHit");
			super.hitTarget();
		}
	}
}