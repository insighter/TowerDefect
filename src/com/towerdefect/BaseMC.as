package com.towerdefect
{
	import com.greensock.easing.ElasticOut;
	import com.greensock.easing.Quad;
	import com.greensock.easing.SlowMo;
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
		protected var xml:XML;
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
			 * -	glowFilter : uint = no filter		If should use GlowFilter
			 * -	bevelFilter : uint = no filter		If should use BevelFilter
			 * -	dropShadowFilter : uint = no filter	If should use DropShadowFilter
			 * -	useEvents : Boolean = false			If should react on mouse
			 * -	mouseDownMethod : String = name		Method to be called on mouseDown
			 * -	buttonMode : Boolean = false		Enable or not hand cursor
			 * -	xml : XML = null					Reference to main xml file
             */
		public function BaseMC(args:Object=null)
		{
			this.init = new Init(args);			
			this.name = init.getString("name", "baseMC");
			this.opaque = init.getNumber("opaque", 1);
			this.rect = init.getRectangle("rect", new Rectangle(0, 0, 0, 0));
   			this.x = rect.x;
			this.y = rect.y;
			this.soundManager = init.getObject("soundManager", SoundManager) as SoundManager;
			this.buttonMode = init.getBoolean("buttonMode", false);
			if (args.hasOwnProperty("glowFilter"))
				addFilter("glow", init.getColor("glowFilter", 0x000000));
			if (args.hasOwnProperty("bevelFilter"))
				addFilter("bevel", init.getColor("bevelFilter", 0x000000));
			if (args.hasOwnProperty("dropShadowFilter"))
				addFilter("shadow", init.getColor("dropShadowFilter", 0x000000));
			this.alpha = 0;			
			if (init.getBoolean("useEvents", false))
			{
				addEventListener(MouseEvent.ROLL_OVER, mouseOver, false, 0, true);
				addEventListener(MouseEvent.ROLL_OUT, mouseOut, false, 0, true);
				addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true);
			}
			this._mouseDownMethod = init.getString("mouseDownMethod", this.name);
			this.xml = init.getObject("xml", XML) as XML;
			this.visible = false;
			if (init.getBoolean("showOnCreate", true)) show();
		}
		
		public function addFilter(type:String, color:uint):void
		{
			switch(type)
			{
				case "glow":
					this.gf = new GlowFilter(color, 1, 3, 3, 1, 3);
					var tmpF:Array = this.filters;
					for (var i:int = 0; i < tmpF.length; i++) 
						if (tmpF[i] is GlowFilter)
							tmpF.splice(i, 1);
					tmpF.push(gf);
					this.filters = tmpF;
					break;
				case "bevel":
					this.bf = new BevelFilter(3, 45, color);
					tmpF = this.filters; 
					for (i = 0; i < tmpF.length; i++) 
						if (tmpF[i] is BevelFilter)
							tmpF.splice(i, 1);
					tmpF.push(bf);
					this.filters = tmpF;
					break;
				case "shadow":
					this.sf = new DropShadowFilter(4, 45, color);
					tmpF = this.filters; 
					for (i = 0; i < tmpF.length; i++) 
						if (tmpF[i] is DropShadowFilter)
							tmpF.splice(i, 1);
					tmpF.push(sf);
					this.filters = tmpF;
					break;
			}
		}
		
		public function get method():String
		{
			return _mouseDownMethod;
		}
		
		public function scale(from:Number, to:Number, time:Number = 0.3):void
		{
			TweenLite.fromTo(this, time, { scaleX: to }, { scaleY: to} );
		}
		
		public function size(width:int, height:int, time:Number = 0.3):void
		{
			TweenLite.to(this, time, { width: width, height:height} );
		}
		
		public function show(time:Number=0.3):void
		{
			visible = true;
			TweenLite.fromTo(this, time, { alpha: 0 }, { alpha: opaque} );
		}
		
		public function hide(time:Number = 0.3, shiftX:int = 0, shiftY:int = 0, scaleX:Number=1, scaleY:Number=1, destroy:Boolean=false):void
		{			
			if (destroy)
				TweenLite.fromTo(this, time, { alpha: opaque }, { alpha: 0, x:x+shiftX, y:y+shiftY, scaleX:scaleX, scaleY:scaleY, onComplete:rem } );
			else
				TweenLite.fromTo(this, time, { alpha: opaque }, { alpha: 0, x:x+shiftX, y:y+shiftY, scaleX:scaleX, scaleY:scaleY, onComplete:invis} );
		}
		
		private function invis():void
		{
			visible = false;
		}
		
		public function move(toX:int, toY:int, time:Number=0.3):void
		{
			TweenLite.to(this, time, { x: toX, y: toY, ease:Quad.easeOut} );
		}

		private function rem():void
		{
			this.parent.removeChild(this);
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