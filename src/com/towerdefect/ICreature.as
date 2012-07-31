package com.towerdefect
{
	/**
	 * ...
	 * @author insighter
	 */
	public interface ICreature
	{
		function get x():Number;
		function get y():Number;
		
		function beginMove():void;
		function killed():void;
		
		function get health():Number;
		function set health(value:Number):void;
		
		function get score():Number;
		function set score(value:Number):void;
	}
}