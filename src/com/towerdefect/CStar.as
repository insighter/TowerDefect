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
	public class CStar extends Creature
	{
		private var init:Init;
		
		public function CStar(args:Object)
		{
			_params = new CreatureParams({
				className:"com.towerdefect.CStar",
				type:"star",
				speed:1,
				size:1,
				score:1,
				health:20
			});
			args.dropShadowFilter = new DropShadowFilter(2, 45, 0x000000, 1, 4, 4, 1, 3);
			super(args);
			init = new Init(args);
		}
		
		public override function killed():void
		{
			soundManager.playSound("starKill");
			super.killed();
		}
	}
}