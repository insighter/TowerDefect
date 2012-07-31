package com.towerdefect
{
	import com.greensock.easing.ExpoOut;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quart;
	import com.greensock.TweenMax;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.globalization.LocaleID;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author insighter
	 */
	public class Projectile extends BaseMC implements IProjectile
	{
		private var init:Init;
		protected var traj:TweenMax;
		protected var _muted:Boolean;
		protected var _params:ProjectileParams;
		protected var target:ICreature;
		protected var toX:Number;
		protected var toY:Number;
		
		public function Projectile(args:Object)
		{
			init = new Init(args);
			target = init.getObject("target") as Creature;
			_muted = init.getBoolean("muted", false);
			toX = Utils.Rand(100) + 50;
			toY = Utils.Rand(100) + 50;
			
			//The type of the projectile determines it's image, so you don't need to pass image parameter to the constructor
			args.image = Utils.getBMPByName(args.images, _params.type);
			args.name = _params.type;
			super(args);
		}
		
		public function setTarget(target:ICreature):void
		{
			this.target = target;
		}
		
		private function getDestination():void
		{
			if (target == null) return;
			toX = target.x;
			toY = target.y;
		}

		public function fire():void
		{
			getDestination();
			var time:Number;
			_params.speed == 0 ? time = 0:time = 1 / _params.speed;
			traj = TweenMax.to(this, time, { x:toX, y:toY, ease:Linear.easeNone, onComplete:hitTarget } );
			addEventListener(Event.ENTER_FRAME, refreshTrajectory, false, 0, true);
		}
		
		private function refreshTrajectory(e:Event):void
		{
			getDestination();
			traj.updateTo( { x:toX, y:toY } );
		}
		
		public function hitTarget():void
		{
			removeEventListener(Event.ENTER_FRAME, refreshTrajectory);
			this.parent.removeChild(this);
			if (target == null) return;
			target.health -= damage;
		}
		
		public function get damage():Number { return _params.damage }
		public function set damage(value:Number):void
		{
			_params.damage = value;
		}
		
		public function get params():ProjectileParams { return this._params; }
		public function set params(p:ProjectileParams):void
		{
			this._params = p;
		}
	}
}