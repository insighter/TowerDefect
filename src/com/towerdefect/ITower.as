package com.towerdefect
{
	/**
	 * ...
	 * @author insighter
	 */
	public interface ITower
	{
		function build(shotAtStep:int):void;
		function prepare():void;
		function unPrepare():void;
		function shot():void;
			
		function get active():Boolean;
		function set active(value:Boolean):void;
		
		function get muted():Boolean;
		function set muted(value:Boolean):void;
		
		function get params():TowerParams;
		function set params(p:TowerParams):void;
	}
}