package com.towerdefect
{
	import com.greensock.easing.ElasticOut;
	import com.greensock.TweenLite;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.filters.BevelFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.events.MouseEvent;
	/**
         * The BaseMC is a basic class that provides several commonly used functions like animated show/hide, 
		 * using predefined border filters
         *
         * @author insighter
         * @version 1.0
         */
	public class BaseMC extends MovieClip
	{		
		protected var sf:DropShadowFilter;
		protected var gf:GlowFilter;
		protected var bf:BevelFilter;
		protected var opaque:Number;		
		protected var rect:Rectangle; 
		protected var soundManager:SoundManager;
		protected var _mouseDownMethod:String;
		protected var filterColor:uint;
		private var init:Init;
		/**
             * 
             * @param	args [optional]	An initialisation object for specifying default instance properties.
			 * -	Arguments of initialisation object that will be catched by this constructor:
			 * -	name : String = "baseMC"
			 * -	opaque : Number = 1
			 * -	showOnCreate : Boolean = true		If should appear immediately after creation
			 * -	rect : Rectangle = new Rectangle(0, 0, 0, 0)	Position and size
			 * -	soundManager : SoundManager = null	Exemplar of SoundManager class
			 * -	filters : Boolean = true			If should use some predefined filters that look like border
			 * -	filterColor : uint = 0x000000		The color of that border
			 * -	useEvents : Boolean = false			If should react on mouse
             */
		public function BaseMC(args:Object=null)
		{
			this.init = new Init(args);
			this.sf = new DropShadowFilter();
			this.gf = new GlowFilter();
			this.bf = new BevelFilter();
			this.filterColor = init.getColor("filterColor", uint(0x000000));
			if (init.getBoolean("filters", true)) setFilters();
			this.name = init.getString("name", "baseMC");
			this.soundManager = init.getObject("soundManager", SoundManager) as SoundManager;
			this.rect = init.getRectangle("rect", new Rectangle(0, 0, 0, 0));
   			this.x = rect.x;
			this.y = rect.y;
			this.opaque = init.getNumber("opaque", 1);
			this.alpha = 0;
			if (init.getBoolean("showOnCreate", true)) show();
			if (init.getBoolean("useEvents", false))									//
			{
				addEventListener(MouseEvent.ROLL_OVER, mouseOver, false, 0, true);
				addEventListener(MouseEvent.ROLL_OUT, mouseOut, false, 0, true);
				addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true);
			}
			//this._mouseDownMethod = init.getString("mouseDownMethod", this.name);	//mouseDownMethod : to eventDispatcher on mouseDown
		}
		
		public function get method():String
		{
			return _mouseDownMethod;
		}
		
		public function scale(from:Number, to:Number, time:Number = 0.3):void
		{
			TweenLite.fromTo(this, time, { scaleX: to }, { scaleY: to} );
		}
		
		public function show(time:Number=0.3):void
		{			
			TweenLite.fromTo(this, time, { alpha: 0 }, { alpha: opaque} );
		}
		
		public function hide(time:Number = 0.3, shiftX:int = 0, shiftY:int = 0):void
		{						
			TweenLite.fromTo(this, time, { alpha: opaque }, { alpha: 0, x:shiftX, y:shiftY} );
		}
		
		public function destroy(time:Number=0.3, shiftX:int = 0):void
		{
			TweenLite.to(this, time, { x: shiftX, alpha:0, onComplete:rem} );
		}

		private function rem():void
		{
			this.parent.removeChild(this);
		}
	
		private function setFilters():void
		{
			sf.angle=40;
			sf.blurX=3;
			sf.blurY=3;			
			sf.quality=3;
			bf.distance=1;
			bf.blurX=2;
			bf.blurY=2;
			bf.highlightColor = filterColor;
			bf.shadowColor = filterColor;
			this.filters = [bf, sf];
		}
		
		public function removeFilters():void
		{
			this.filters = [];
		}
		
		private function mouseOver(e:MouseEvent):void
		{
			dispatchEvent(new CustomEvent(CustomEvent.BASEMC_MOUSE_OVER, this, true));
		}
		
		private function mouseOut(e:MouseEvent):void
		{
			dispatchEvent(new CustomEvent(CustomEvent.BASEMC_MOUSE_OUT, this, true));
		}
		
		private function mouseDown(e:MouseEvent):void
		{
			dispatchEvent(new CustomEvent(CustomEvent.BASEMC_MOUSE_DOWN, this, true));
		}
	}
	
}