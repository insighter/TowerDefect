package com.towerdefect
{
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author insighter
	 */
	public class ProjectileParams
	{
		public var damage:Number;
		public var speed:Number;
		public var size:Number;
		public var type:String;
		public var className:Class;
		private var init:Init;
		/**
             * 
             * @param	args [optional]	An initialisation object for specifying default instance properties.
			 * -	Arguments of initialisation object that will be catched by this constructor:
			 * -	damage : int = 0		The damage this projectile deals by itself, not considering tower damage. 
			 * -				For example, if tower damage is 2, and it's projectile is FireBall
			 * -				with fire damage 1, then summary damage will be 3.					
			 * -	speed : int = 1		Speed of motion animation. Motion time = 1/speed. When 0 it's like bullet - you don't see it at all
			 * -	size : Number = 1		Scale of original image
             */
		public function ProjectileParams(args:Object):void
		{
			init = new Init(args);
			damage = init.getNumber("damage", 0);
			speed = init.getNumber("speed", 1);
			size = init.getNumber("size", 1);
			type = init.getString("type", "");
			className = getDefinitionByName(init.getString("className", "")) as Class;
		}
	}
}