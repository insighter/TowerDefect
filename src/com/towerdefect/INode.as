package com.towerdefect 
{	
	public interface INode 
	{
		function get f():Number;
		function get g():Number;
		function get h():Number;
		
		function get x():Number;
		function get y():Number;
		
		function get row():int;
		function get col():int;
		
		function get parentNode():INode;
		
		function get traversable():Boolean;		

		function set f(value:Number):void;
		function set g(value:Number):void;
		function set h(value:Number):void;
		function set parentNode(value:INode):void;
		function set traversable(value:Boolean):void;
	}
}