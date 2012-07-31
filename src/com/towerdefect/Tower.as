package com.towerdefect
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author insighter
	 */
	public class Tower extends BaseMC implements ITower
	{
		private var init:Init;
		protected var _params:TowerParams;
		protected var tileSize:int;
		protected var beatTimer:Timer;
		protected var prepareAtBeat:int;
		protected var shotAtBeat:int;
		protected var prepared:Boolean;
		protected var projectile:Projectile;
		protected var _active:Boolean;
		protected var _muted:Boolean;
		protected var targetsAim:Boolean;
		protected var containProjectiles:Boolean;
		protected var target:Creature;
		protected var aimTimer:Timer=new Timer(100, 0);
		protected var targets:Array;
		/**
             * 
             * @param	args [optional]	An initialisation object for specifying default instance properties.
			 *
			 * -	towerParams : TowerParams		Contains such parameters like cost, damage, reload time etc...
			 * -	beatTimer : Timer = null		Reference to the main rhytm timer of main class
			 * -	muted : Boolean = false		It won't use sounds
			 * -	targets : Array = []		Array of all possible targets for this tower
			 * -	field : BaseMC = null		Reference to main field
			 * -	active : Boolean = true		If should start it's activity immediately
			 * -	targetsAim : Boolean = true		If set to false, tower will aim at cursor instead of targets
			 * -	containProjectiles : Boolean = false	If true, it's projectiles will appear as it's childs, otherwise 
			 * 												they will be added as childs to this tower's parent MovieClip
             */
		public function Tower(args:Object)
		{			
			init = new Init(args);
			beatTimer = init.getObject("beatTimer") as Timer;
			targets = init.getArray("targets");
			_muted = init.getBoolean("muted", false);
			_active = init.getBoolean("active", true);
			targetsAim = init.getBoolean("targetsAim", true);
			containProjectiles = init.getBoolean("containProjectiles", false);
			tileSize = init.getInt("tileSize", 10);
			//The type of the tower determines it's image, so you don't need to pass image parameter to the constructor
			args.image = Utils.getBMPByName(args.images, _params.type);
			args.name = _params.type;
			args.buttonMode = true;
			if (targetsAim)
			{
				aimTimer.addEventListener(TimerEvent.TIMER, aimTarget, false, 0, true);
				aimTimer.start();
			}
			super(args);
		}
		
		public function build(shotAtBeat:int):void
		{
			if (shotAtBeat == 8) shotAtBeat = 0;
			this.shotAtBeat = shotAtBeat;
			prepareAtBeat = shotAtBeat - 2;
			if (prepareAtBeat < 0) prepareAtBeat += 8;
			beatTimer.addEventListener(TimerEvent.TIMER, beatTick, false, 0, true);
		}
		
		private function beatTick(e:TimerEvent):void
		{
			if (beatTimer.currentCount/40 == prepareAtBeat && _active && target!=null && targetsAim)
				prepare();
			if (beatTimer.currentCount/40 == shotAtBeat && _active && prepared)
				shot();
			if (prepared && target == null) 
				unPrepare();
		}
		
		public function prepare():void
		{
			prepared = true;
		}
		
		public function unPrepare():void
		{
			prepared = false;
		}
		
		private function aimTarget(e:TimerEvent):void
		{
			target = null;
			var dist:Number;
			var minDist:Number=10000;
			for each(var c:Creature in targets)
			{
				var difX:Number = this.x - c.x;
				var difY:Number = this.y - c.y;
				dist = Math.sqrt(difX*difX + difY * difY);
				if (dist < minDist && dist<=_params.radius*tileSize) 
				{
					minDist = dist;
					target = c;
				}
			}
		}
		
		public function shot():void
		{
			projectile.setTarget(target);
			if(!_muted)
				soundManager.playSound(name);
			prepared = false;
		}
		
		public function get muted():Boolean { return this._muted;	}
		public function set muted(value:Boolean):void
		{
			this._muted = value;
		}
		
		public function get active():Boolean { return this._active; }
		public function set active(a:Boolean):void
		{
			this._active = a;
		}
		
		public function get params():TowerParams { return this._params; }
		public function set params(p:TowerParams):void
		{
			this._params = p;
		}
		
	}
}