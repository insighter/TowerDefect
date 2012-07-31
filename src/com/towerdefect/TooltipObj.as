package com.towerdefect{
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.Timer;
	import flash.filters.DropShadowFilter;
	import flash.filters.BevelFilter;
	
	public class TooltipObj extends BaseMC
	{		
		private var obj:DisplayObject;
		private var title:String;
		private var description:String;		
		private var w:Number;			
		private var bg:Sprite;
		private var arrow:Sprite;
		private var titleTxt:TextField;
		private var descriptionTxt:TextField;
		private var padding:int = 4;
		
		private var main:Sprite;
		private var maxWidth:Number;
		private var showDelay:Number;
		private var transparency:Number;
		private var bgColor:uint;
		private var textColor:uint;
		private var shadowColor:uint;
		private var useShadow:Boolean;
		private var fontName:String;
		private var titleSize:int;
		private var descriptionSize:int;
		private var verticalOffset:Number;
		
		private var showTimer:Timer;
		private var arrowEdge:int = 12;
		private var xmouse:int = 30;
		private var hidden:Boolean=true;
		private var icon:*;
		private var iconL:Loader = new Loader();;
		private var iconW:int;
		private var iconH:int;
		private var bgHeight:Number;
		private var isFading:Boolean;
		private var tooltip:ToolTip;
		private var init:Init;
		/**
             * 
             * @param	args [optional]	An initialisation object for specifying default instance properties.
			 * -	Arguments of initialisation object that will be catched by this constructor:
			 * -	tooltip : AToolTip		Reference to the main tooltip class instance of application
			 * -	object : DisplayObject		Target DisplayObject
			 * -	icon : (BitmapData || BaseMC || String)	If it's String, it will be loaded using URLRequest
			 * -	iconW : int = 30
			 * -	iconH : int = 30
			 * -	title : String
			 * -	text : String
			 * 
			 * If some property from the list below is missing, the tooltip's one will be used by default.
			 * So it is possible to make all tooltips of the application look similar, or to customize each one of them
			 * -	transparency : Number
			 * -	showDelay : Int
			 * -	maxWidth : Int
			 * -	textColor : uint
			 * -	bgColor : uint
			 * -	fontName : String
			 * -	titleSize : Int
			 * -	descriptionSize : Int
			 * -	verticalOffset : Int
			 */
		public function TooltipObj(args:Object)
		{
			super(args);
			this.init = new Init(args);
			this.tooltip = init.getObject("tooltip", ToolTip) as ToolTip;
			this.main = tooltip.main;
			this.icon = init.getObject("icon");
			this.iconW = init.getInt("iconW", 30);
			this.iconH = init.getInt("iconH", 30);
			this.obj = init.getObject("object", DisplayObject) as DisplayObject;
			this.name = this.obj.name+".TP";
			this.title = init.getString("title", "");
			this.description  = init.getString("text", "");
			
			this.transparency = init.getNumber("transparency", tooltip.transparency);
			this.showDelay = init.getInt("showDelay", tooltip.showDelay);
			this.maxWidth = init.getInt("maxWidth", tooltip.maxWidth);
			this.textColor = init.getColor("textColor", tooltip.textColor);
			this.bgColor = init.getColor("bgColor", tooltip.bgColor);
			this.fontName = init.getString("fontName", tooltip.fontName);
			this.titleSize = init.getInt("titleSize", tooltip.titleSize);
			this.descriptionSize = init.getInt("descriptionSize", tooltip.descriptionSize);
			this.verticalOffset = init.getInt("verticalOffset", tooltip.verticalOffset);
			
			mouseEnabled = false;
			mouseChildren = false;
			opaque = this.transparency;
			initText();
			if (icon == null) return;
			if (icon is BitmapData)
			{
				icon = new Bitmap(icon, "auto", true);
				iconLoaded(null);
			}
			else if(icon is BaseMC)
			{
				iconLoaded(null);
			}		
			else
			{
				iconL.contentLoaderInfo.addEventListener(Event.COMPLETE , iconLoaded, false, 0, true);
				iconL.load(new URLRequest(icon));
			}
		}

		private function iconLoaded(e:Event):void
		{
			var iconSpace:Number = 2;
			if (e != null)
			{
				icon = e.target.content as Bitmap;
				icon.smoothing = true;
			}
			icon.width = iconW;
			icon.height = iconH;
			addChild(icon);
			icon.x = padding;
			icon.y = padding;
			if (icon is BaseMC)
			{
				icon.x += icon.width / 2;
				icon.y += icon.height / 2;
			}
			
			//align with the icon size
			titleTxt.x = icon.x + icon.width + iconSpace;
			if (titleTxt.x + titleTxt.width + padding > bg.width)
			{
				w = titleTxt.x + titleTxt.width + padding;
				bg.graphics.clear();
				bg.graphics.beginFill(bgColor);
				bg.graphics.drawRoundRect(0, 0, w, bgHeight, 6, 6);
			}
			
			//fit the description text
			if (descriptionTxt)
			{
				descriptionTxt.x = padding;
				descriptionTxt.width = w - 2*padding - iconSpace;
								
				//add more height
				if (descriptionTxt.y +descriptionTxt.height + padding > bg.height)
				{
					bgHeight = descriptionTxt.y +descriptionTxt.height + padding;
					bg.graphics.clear();
					bg.graphics.beginFill(bgColor);
					bg.graphics.drawRoundRect(0,0,w,bgHeight,6,6);
					
				}
			}
			
			//add height
			if(icon.height + 2*padding > bg.height) {
				bg.graphics.clear();
				bg.graphics.beginFill(bgColor);
				bg.graphics.drawRoundRect(0, 0, w, icon.height + 2 * padding, 6, 6);
				                      
				arrow.y = getH() + arrow.height ;
			}	
			
		}
		//height of tooltip
		private function getH():Number
		{
			return bg.height;
		}
		
		public function showTip():void
		{
			if(!hidden) return;
			hidden=false;
			showTimer = new Timer(showDelay);
			showTimer.addEventListener(TimerEvent.TIMER , show2);
			showTimer.start();
		}
	
		private function show2(e:TimerEvent):void
		{			
			showTimer.stop();
			showTimer.removeEventListener(TimerEvent.TIMER , show2);
			showTimer = null;
			main.addChild(this);
			alpha=0;
			isFading = true;
			followMouse();
			addEventListener(Event.ENTER_FRAME , followMouse);			
		}
		
		public function hideTip():void
		{
			if(hidden) return;
			hidden = true;
			removeEventListener(Event.ENTER_FRAME , followMouse);
			if (showTimer)
			{
				showTimer.stop();
				showTimer.removeEventListener(TimerEvent.TIMER , show2);
				showTimer = null;
				return;
			}
			main.removeChild(this);
		}
		
		private function followMouse(e:Event = null):void
		{					
			x = main.mouseX - xmouse;
			arrow.y = getH() + arrow.height ;
			arrow.x = xmouse;
			arrow.scaleY = 1;
			if (x < padding) 
			{
				x=padding;
				arrow.x = main.mouseX;
				
				if(arrow.x < arrowEdge) {
					arrow.x = arrowEdge;
				}
			}
			
			//right edge side
			if (x + w > main.stage.stageWidth - padding)
			{
				x = main.stage.stageWidth-w-padding;
				arrow.x = main.mouseX - x;
				if (arrow.x > w - arrowEdge) 
					arrow.x = w-arrowEdge;
			}
			
			//set y position
			y = main.mouseY - getH()-verticalOffset;
			
			//flip down
			if (y < padding) 
			{
				y = main.mouseY + verticalOffset + 20;
				arrow.y = - arrow.height;
				arrow.scaleY = -1;
			}
			
			if (isFading) alpha += 0.1;
			
			if (alpha >= transparency) 
			{
				alpha = transparency;
				isFading=false;
			}
			
		}
		
		private function initText():void
		{
			//create tooltip graphics
			bg = new Sprite();
			addChild(bg);
			
			//"arrow" graphics
			arrow = new Sprite();
			addChild(arrow);
			arrow.graphics.beginFill(bgColor);
			arrow.graphics.lineTo(0,0);
			arrow.graphics.lineTo(-3,-8);
			arrow.graphics.lineTo(3,-8);
			arrow.graphics.endFill();
				
			titleTxt = new TextField();
			titleTxt.textColor = textColor;
			titleTxt.x = padding;
			titleTxt.y = padding;
			titleTxt.multiline=false;
			titleTxt.autoSize = TextFieldAutoSize.LEFT;
			var fmt:TextFormat = new TextFormat();
			fmt.font = fontName;
			fmt.size = titleSize;
			fmt.bold = true;
			titleTxt.defaultTextFormat = fmt;
			titleTxt.embedFonts = true;
			addChild(titleTxt);
			titleTxt.htmlText = Utils.toHTML(title);
			w = titleTxt.width + 2 * padding;
					
			if (description != '') 
			{
				descriptionTxt = new TextField();
				descriptionTxt.textColor = textColor;
				descriptionTxt.x = padding;
				if (title != '')
					descriptionTxt.y = titleTxt.y + titleTxt.height;
				else
					descriptionTxt.y = padding;
				descriptionTxt.multiline=true;
				descriptionTxt.autoSize = TextFieldAutoSize.LEFT;		
				var fmt2:TextFormat = new TextFormat();
				fmt2.font = fontName;
				fmt2.size = descriptionSize;
				fmt2.leading = -4;
				descriptionTxt.defaultTextFormat = fmt2;
				descriptionTxt.embedFonts = true;
				//descriptionTxt.text = description;
				descriptionTxt.htmlText = Utils.toHTML(description);
				addChild(descriptionTxt);
				
				if (w < descriptionTxt.width + 2 * padding)
				{
					w = descriptionTxt.width + 2 * padding+10;
					if(w > maxWidth)
						w = maxWidth;
					descriptionTxt.width = w - 2*padding;
					descriptionTxt.wordWrap = true;
				}
			}
			bgHeight = 2*padding+titleTxt.height;
			if(descriptionTxt)
				bgHeight += descriptionTxt.height;
			
			//draw the tooltip graphics
			bg.graphics.beginFill(bgColor);
			bg.graphics.drawRoundRect(0,0,w,bgHeight,6,6);
			
			//put in the "arrow"
			arrow.y = getH() + arrow.height ;
			arrow.x = xmouse;
		}
	}
}