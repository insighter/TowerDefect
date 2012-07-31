package com.towerdefect
{
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author insighter
	 */
	public class CreatureParams
	{
		public var health:Number;
		public var score:Number;
		public var speed:Number;
		public var size:Number;
		public var type:String;
		public var className:Class;
		private var init:Init;
		/**
             * 
             * @param	args [optional]	An initialisation object for specifying default instance properties.
			 * -	Arguments of initialisation object that will be catched by this constructor:
			 * -	speed : int = 1		Speed of movement. Motion time to the next tile = 1/speed. When 0 it's like bullet - you don't see it at all. Bullet-creature, omg!!!
			 * -	size : int = 1		Scale of original image.
             */
		public function CreatureParams(args:Object):void
		{
			init = new Init(args);
			health = init.getNumber("health", 1);
			speed = init.getNumber("speed", 1);
			score = init.getNumber("score", 0);
			size = init.getNumber("size", 0);
			type = init.getString("type", "");
			className = getDefinitionByName(init.getString("className", "")) as Class;
		}
	}
}