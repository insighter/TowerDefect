package com.towerdefect
{
	/**
	 * ...
	 * @author insighter
	 */
	public interface IProjectile  
	{
		function setTarget(target:ICreature):void;
		function hitTarget():void;
		function fire():void;
		
		function get damage():Number;
		function set damage(value:Number):void;
		
		function get params():ProjectileParams;
		function set params(p:ProjectileParams):void;
	}
}