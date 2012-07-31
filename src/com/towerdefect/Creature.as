package com.towerdefect
{
	import com.greensock.easing.Linear;
	import com.greensock.TweenMax;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author insighter
	 */
	public class Creature extends BaseMC implements ICreature
	{
		private var init:Init;
		protected var road:Array;
		protected var curNode:INode;
		protected var _params:CreatureParams;
		/**
             * 
             * @param	args [optional]	An initialisation object for specifying default instance properties.
			 *
			 * -	road : Array		INode array of builded road
			 * -	usePathFinder : Boolean = false		If should find the shortest way from road[0] to road[last]
             */
		public function Creature(args:Object)
		{
			init = new Init(args);
			road = init.getArray("road");
			if (init.getBoolean("usePathFinder", false))
				road = Pathfinder.findPath(road[0], road[road.length - 1], road);
			curNode = road[0] as INode;
			//The type of the projectile determines it's image, so you don't need to pass image parameter to the constructor
			args.image = Utils.getBMPByName(args.images, _params.type);
			args.name = _params.type;
			super(args);
		}
		
		public function beginMove():void
		{
			if (road.length == 1) return;
			moveToNext();
		}
		
		public function moveToNext():void
		{
			if (curNode == road[road.length - 1]) return;//Пока стоп
			curNode = road[road.indexOf(curNode) + 1];
			var time:Number;
			_params.speed == 0 ? time = 0 : time = 1 / _params.speed;
			TweenMax.to(this, time, {x: curNode.x, y:curNode.y, ease:Linear.easeNone, onComplete:moveToNext} );
		}
		
		public function killed():void
		{
			dispatchEvent(new CustomEvent(CustomEvent.CREATURE_KILLED, this, true));
		}
		
		public function get health():Number { return _params.health }
		public function set health(value:Number):void
		{
			_params.health = value;
			graphics.clear();
			graphics.lineStyle(1, 0xFF0000);
			graphics.moveTo( -width / 2, -height / 2 - 5);
			graphics.lineTo(-width / 2+_params.health, -height / 2 - 5);
			if (_params.health <= 0) killed();
		}
		
		public function get params():CreatureParams { return this._params; }
		public function set params(p:CreatureParams):void
		{
			this._params = p;
		}
		
		public function get score():Number { return _params.score; }
		public function set score(value:Number):void
		{
			_params.score = value;
		}
	}
}