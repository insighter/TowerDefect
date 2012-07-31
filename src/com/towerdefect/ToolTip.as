package com.towerdefect {
	import flash.events.*;
	import flash.display.*;
	import flash.filters.BevelFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.utils.Dictionary;
	/**
         * The ToolTip is abstract main tooltip class that binds ToolTip objects to their DisplayObjects
         *
         * @author insighter
         */
	public class ToolTip
	{
		private var tips:Dictionary;
		private var init:Init;
		public var main:Sprite;
		public var maxWidth:Number;
		public var showDelay:Number;
		public var transparency:Number;
		public var bgColor:uint;
		public var textColor:uint;
		public var fontName:String;
		public var titleSize:int;
		public var descriptionSize:int;
		public var verticalOffset:Number;
		public var glowFilter:GlowFilter;
		public var bevelFilter:BevelFilter;
		public var dropShadowFilter:DropShadowFilter;
		/**
             * 
             * @param	args [optional]	An initialisation object for specifying default instance properties.
			 * -	Arguments of initialisation object that will be catched by this constructor:
			 * -	main : Sprite		Reference to main class, where tooltips should appear as childs
			 * -	transparency : Number = 0.85
			 * -	showDelay : Int = 400
			 * -	maxWidth : Int = 400
			 * -	textColor : uint = 0x555555
			 * -	bgColor : uint = 0x000000
			 * -	fontName : String = segoeFont.swc (lib)
			 * -	titleSize : Int = 14
			 * -	descriptionSize : Int = 12
			 * -	verticalOffset : Int = 20
			 */
		public function ToolTip(args:Object)
		{
			init = new Init(args);
			main = init.getObject("main") as Sprite;
			transparency = init.getNumber("transparency", 0.85);
			showDelay = init.getInt("showDelay", 400);
			maxWidth = init.getInt("maxWidth", 400);
			textColor = init.getColor("textColor", 0x555555);
			bgColor = init.getColor("bgColor", 0x000000);
			fontName = init.getString("fontName", new mySegoePrint().fontName);
			titleSize = init.getInt("titleSize", 14);
			descriptionSize = init.getInt("descriptionSize", 12);
			verticalOffset = init.getInt("verticalOffset", 20);
			glowFilter = init.getObject("glowFilter") as GlowFilter;
			bevelFilter = init.getObject("bevelFilter") as BevelFilter;
			dropShadowFilter = init.getObject("dropShadowFilter") as DropShadowFilter;
			tips = new Dictionary(true);
		}
		/**
         * Creates and binds ToolTip object to the DisplayObject
		 * 
		 * @param	args [optional]	An initialisation object for specifying default instance properties.
		 * -	Arguments of initialisation object that will be catched by this constructor:
		 * -	object : DisplayObject		Target DisplayObject
		 * -	icon : (BitmapData || MovieClip || String)	If it's String, it will be loaded using URLRequest
		 * -	iconW : int = 30
		 * -	iconH : int = 30
		 * -	title : String
		 * -	description : String
		 * 
		 * If some property from the list below is missing, the tooltip's one will be used by default.
		 * So it is possible to make all tooltips of the application look similar, or to customize each one of them
		 * -	transparency : Number
		 * -	showDelay : Int
		 * -	maxWidth : Int
		 * -	textColor : uint
		 * -	bgColor : uint
		 * -	useShadow : Boolean
		 * -	shadowColor : uint
		 * -	fontName : String
		 * -	titleSize : Int
		 * -	descriptionSize : Int
		 * -	verticalOffset : Int
		 */
		public function addToolTip(args:Object):void
		{
			args.tooltip = this;
			if(!args.hasOwnProperty("glowFilter")) args.glowFilter = this.glowFilter;
			if(!args.hasOwnProperty("bevelFilter")) args.bevelFilter = this.bevelFilter;
			if(!args.hasOwnProperty("dropShadowFilter")) args.dropShadowFilter = this.dropShadowFilter;
			var obj:DisplayObject = args.object as DisplayObject;
			var tip:TooltipObj = new TooltipObj( args );
			tips[obj]=tip;
			obj.addEventListener(MouseEvent.MOUSE_OVER , mOver,false,0,true);
			obj.addEventListener(MouseEvent.MOUSE_OUT , mOut,false,0,true);
			obj.addEventListener(MouseEvent.MOUSE_DOWN, mDown,false,0,true);			
		}
		
		public function removeToolTip(obj:DisplayObject):void
		{
			if (tips[obj] == null) return;
			(tips[obj] as TooltipObj).hideTip();
			obj.removeEventListener(MouseEvent.MOUSE_OVER , mOver);
			obj.removeEventListener(MouseEvent.MOUSE_OUT , mOut);
			obj.removeEventListener(MouseEvent.MOUSE_DOWN, mDown);
		}
				
		private function mOver(e:MouseEvent):void
		{
			var tip:TooltipObj = tips[e.currentTarget];
			tip.showTip();
		}
		
		private function mOut(e:MouseEvent):void
		{			
			var tip:TooltipObj = tips[e.currentTarget];
			tip.hideTip();			
		}
		
		private function mDown(e:MouseEvent):void
		{
			var tip:TooltipObj = tips[e.currentTarget];
			tip.hideTip();
		}
		/**
         * Destroys main tooltip class and all it's ToolTip objects
         */	
		public function destroy():void
		{
			for (var key:* in tips)
			{
				removeToolTip(key);
			}
			tips = null;
			main = null;
		}
	}
}