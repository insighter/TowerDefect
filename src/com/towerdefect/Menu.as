package com.towerdefect
{	
	import com.greensock.easing.SineOut;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
    import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
    import flash.net.*;
    import flash.utils.*;    
	import flash.text.*;
	import flash.filters.*;  
	import flash.filters.BitmapFilterQuality;
	/**
	 * ...
	 * @author insighter
	 */
    public class Menu extends BaseMC
    {
		private var xmlLoader:XMLLoader;
		private var menuItems:Array;		
		private var xmlUrl:String;
		private var glf:GlowFilter;
		private var shf:DropShadowFilter;
		private var menuParams:MenuParams;
		private var items:Array;	
		private var curLevel:int;
		private var init:Init;
		private var effects:Object;
		/**
             * 
             * @param	args [optional]	An initialisation object for specifying default instance properties.
			 * -	Arguments of initialisation object that will be catched by this constructor:
			 * -	xmlUrl : String = ""
             */
        public function Menu(args:Object)
        {
			super(args);
			init = new Init(args);
			menuItems = new Array();
			addEventListener(CustomEvent.BASEMC_MOUSE_OVER, itemMouseOver, false, 0, true);
			addEventListener(CustomEvent.BASEMC_MOUSE_OUT, itemMouseOut, false, 0, true);
			addEventListener(CustomEvent.BASEMC_MOUSE_DOWN, itemMouseDown, false, 0, true);
			loadXML(init.getString("xmlUrl", ""));
		}
		
		//Can be reloaded later by new xmlUrl, that's why it's public
		public function loadXML(xmlUrl:String):void
		{
			this.xmlUrl = xmlUrl;
			xmlLoader = new XMLLoader(xmlUrl);
            xmlLoader.addEventListener(CustomEvent.XML_LOADED, XMLLoaded, false, 0, true); 
			xmlLoader.load();
		}
		
       	private function XMLLoaded(e:CustomEvent=null):void
        {
			xmlLoader.removeEventListener(CustomEvent.XML_LOADED, XMLLoaded);  
			xml = xmlLoader.xml;
			this.x = xml.vars.@x;
			this.y = xml.vars.@y;
			curLevel = 1;
			effects = new Object();
			for (var i:int = 0; i < xml.effect.length(); i++)
			{
				switch(String(xml.effect[i].name))
				{
					case "mouseDeltaX":
						effects.mouseDeltaX = xml.effect[i].mouseDelta;
						effects.menuDeltaX = xml.effect[i].menuDelta;
						break;
						
					case "mouseDeltaY": 
						effects.mouseDeltaY = xml.effect[i].mouseDelta;
						effects.menuDeltaY = xml.effect[i].menuDelta;
						break;
				}
			}
			
			//storing menu parameters
			menuParams = new MenuParams({
				"direction":		xml.vars.@direction,
				"buttonSpacing":	parseInt(xml.vars.@buttonSpacing),
				"textTopOffset":	parseInt(xml.vars.@textTopOffset),
				"textBottomOffset":	parseInt(xml.vars.@textBottomOffset),			
				"currentItem":		parseInt(xml.vars.@currentItem),
				"itemAlpha":		xml.vars.@itemAlpha,
				"curitemAlpha":		xml.vars.@curitemAlpha,
				"fontSize":			parseInt(xml.vars.font.@size),
				"fontColor":		xml.vars.font.@color.toString().replace("#", "0x"),
				"glowColor":		xml.vars.glow.@color.toString().replace("#", "0x"),
				"glowAlpha":		xml.vars.glow.@alpha,
				"glowBlurX":		parseInt(xml.vars.glow.@blurX),
				"glowBlurY":		parseInt(xml.vars.glow.@blurY),
				"glowStrength":		parseInt(xml.vars.glow.@strength),
				"animationTime":	xml.vars.@animationTime
			});
			loadItems();
		}
		
		private function loadItems():void
		{
			//Clearing previous menu items and creating new
			for each(var item:TextMC in menuItems)
			{
				item.removeListeners();
				var scale:Number = Utils.RandF(3)+1;
				item.hide(true, 0.5, -500, Utils.Rand(120)-200, scale, scale);
			}
			menuItems = new Array();
			var coor:int = 0;
			for (var i:int = 0; i < xml.item.length(); i++)
			{
				if (xml.item[i].level != curLevel) continue;
				var xx:int = 0;
				var yy:int = 0;
				var spec:Object = new Object();
				if (xml.item[i].useEffects != 0)
					spec = { mouseDeltaX:effects.mouseDeltaX, menuDeltaX:effects.menuDeltaX, mouseDeltaY:effects.mouseDeltaY, menuDeltaY:effects.menuDeltaY };
				if (menuParams.direction=="vertical")
					yy = coor;
				else
					xx = coor;
				item = new TextMC( {
					name:this.name + "." + i.toString(),
					id:i,
					text:xml.item[i].text,
					rect:new Rectangle(xx + Utils.setIfNaN(xml.item[i].shiftX), yy + Utils.setIfNaN(xml.item[i].shiftY), 0, 0),
					fontAlign:TextFormatAlign.JUSTIFY,
					fontSize:menuParams.fontSize,
					fontColor:menuParams.fontColor,
					mouseDownMethod:xml.item[i].method,
					dispatchEvents:true,
					buttonMode:true,
					mouseSpecialEffect: spec
				});
				glf = new GlowFilter(menuParams.glowColor, 0, 0, 0, 2, BitmapFilterQuality.HIGH);
				item.filters = [glf];
				addChild(item);
				menuItems.push(item);
				coor += menuParams.buttonSpacing + (menuParams.direction == "vertical" ? menuItems[menuItems.length - 1].height : menuItems[menuItems.length - 1].width);
			}
		}

		private function itemMouseOver(e:CustomEvent):void
		{
			var item:TextMC = e.args;
			TweenMax.fromTo(item, menuParams.animationTime, {alpha:item.alpha, glowFilter:{alpha:0, strength:0, blurX:0, blurY:0}}, {alpha:menuParams.curItemAlpha, ease:SineOut, glowFilter:{alpha:menuParams.glowAlpha, strength:menuParams.glowStrength, blurX:menuParams.glowBlurX, blurY:menuParams.glowBlurY}} );
			changeItemsAlpha(item);
			soundManager.playSound("menuOver");
		}
				
		private function itemMouseOut(e:CustomEvent):void
		{
			var item:TextMC = e.args;			
			TweenMax.to(item, menuParams.animationTime, {ease:SineOut, glowFilter:{alpha:0, strength:0, blurX:0, blurY:0}} );
			if (item.mouseY < 10 || item.mouseY > this.height-10 || item.mouseX>item.width-10 || item.mouseX<10)
				changeItemsAlpha(null);
		}			

		private function itemMouseDown(e:CustomEvent):void
		{			
			var item:TextMC = e.args;
			//if (item != menuParams.currentItem)
			{				
				menuParams.currentItem = item;
				//chooseItemAnimation();
				soundManager.playSound("menuClick");
				var newLevel:Number = parseInt(item.method);
				var method:String = item.method;
				if (!isNaN(newLevel))
				{
					curLevel = newLevel;
					loadItems();
					method=method.replace(newLevel.toString(), "");
				}
				dispatchEvent(new CustomEvent(CustomEvent.MENU, method, true));
			}
		}
		
		private function chooseItemAnimation():void
		{
			TweenMax.to(menuParams.currentItem, menuParams.animationTime, { scaleX:2, scaleY:2 } );
			for each(var I:TextMC in menuItems) 
				if (I != menuParams.currentItem)
					TweenMax.to(I, menuParams.animationTime, { scaleX:0, scaleY:0 } );
		}
		
		private function changeItemsAlpha(activeItem:TextMC):void
		{
			if (activeItem == null)
				for each(var I:TextMC in menuItems) 
					TweenLite.to(I, menuParams.animationTime, { alpha:menuParams.curItemAlpha, ease:SineOut } );
			/*else 
				for each(I in menuItems)
					if (I != activeItem)
						TweenLite.to(I, menuParams.animationTime, {alpha:menuParams.itemAlpha, ease:SineOut} );*/
		}
    }
}