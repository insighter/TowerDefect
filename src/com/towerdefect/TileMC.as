package com.towerdefect
{
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	public class TileMC extends BaseMC implements INode
	{
		//Interface variables
		private var _parentNode:INode;		
		private var _f:Number;
		private var _g:Number;
		private var _h:Number;
		private var _traversable:Boolean = true;
		private var _tower:Tower;
		
		private var W:int;
		private var H:int;
		
		public var _row:int;
		public var _col:int;
		private var init:Init;
		/**
             * 
             * @param	args [optional]	An initialisation object for specifying default instance properties.
			 * -	Arguments of initialisation object that will be catched by this constructor:
			 * -	row : int = 1
			 * -	col : int = 1
             */
		public function TileMC(args:Object=null) 
		{
			super(args);
			init = new Init(args);
			var rect:Rectangle = init.getRectangle("rect", new Rectangle(1, 1, 10, 10));
			this.W = rect.width;
			this.H = rect.height;
			this.row = init.getInt("row", 1);
			this.col = init.getInt("col", 1);
		}
		
		//Interface INode
		public function get parentNode():INode { return _parentNode; }		
		public function set parentNode(value:INode):void 
		{
			_parentNode = value;
		}
		
		public function get f():Number { return _f; }		
		public function set f(value:Number):void 
		{
			_f = value;
		}
		
		public function get g():Number { return _g; }		
		public function set g(value:Number):void 
		{
			_g = value;
		}
		
		public function get h():Number { return _h; }		
		public function set h(value:Number):void 
		{
			_h = value;
		}
		
		public function get traversable():Boolean { return _traversable; }		
		public function set traversable(value:Boolean):void 
		{
			_traversable = value;
		}
		
		public function get row():int { return _row; }		
		public function set row(value:int):void 
		{
			_row = value;
		}
		
		public function get col():int { return _col; }
		public function set col(value:int):void 
		{
			_col = value;
		}
		
		public function get tower():Tower { return _tower; }
		public function set tower(t:Tower):void
		{
			_tower = t;
		}
	}
}