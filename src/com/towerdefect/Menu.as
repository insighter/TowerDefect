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
		private var init:Init;
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
		
       	private function XMLLoaded(e:CustomEvent):void
        {
			if (e.args != xmlUrl) return;//Отсеиваем события от ненужных xmlLoader-ов (если одновременно загружались несколько)
			xmlLoader.removeEventListener(CustomEvent.XML_LOADED, XMLLoaded);  
			var xml:XML = xmlLoader.xml;
			this.x = xml.vars.@x;
			this.y = xml.vars.@y;
			
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
			
			//Clearing previous menu items and creating new
			for each(var item:TextLineMC in menuItems)
				item.hide(0.3, -50);
			menuItems = new Array();
			var coor:int = 0;
			for (var i:int = 0; i < xml.item.length(); i++)
			{
				trace(i);
				var xx:int = 0;
				var yy:int = 0;
				if (menuParams.direction=="vertical")
					yy = coor;
				else
					xx = coor;				
				item = new TextLineMC( {
					name:this.name + "." + i.toString(),
					id:i,
					text:xml.item[i].text,
					rect:new Rectangle(xx, yy, 0, 0),
					fontAlign:TextFormatAlign.JUSTIFY,
					fontSize:menuParams.fontSize,
					fontColor:menuParams.fontColor,
					mouseDownMethod:xml.item[i].method,
					dispatchEvents:true,
					buttonMode:true,
					mouseSpecialEffect: {deltaX:350, shiftX:20, deltaY:300, shiftY:100}
				});
				glf = new GlowFilter(menuParams.glowColor, 0, 0, 0, 2, BitmapFilterQuality.HIGH);
				item.filters = [glf];
				addChild(item);
				menuItems.push(item);
				coor += menuParams.buttonSpacing+(menuParams.direction=="vertical" ? menuItems[menuItems.length-1].height : menuItems[menuItems.length-1].width);
			}
		}

		private function itemMouseOver(e:CustomEvent):void
		{
			var item:TextLineMC = e.args;
			TweenMax.fromTo(item, menuParams.animationTime, {alpha:item.alpha, glowFilter:{alpha:0, strength:0, blurX:0, blurY:0}}, {alpha:menuParams.curItemAlpha, ease:SineOut, glowFilter:{alpha:menuParams.glowAlpha, strength:menuParams.glowStrength, blurX:menuParams.glowBlurX, blurY:menuParams.glowBlurY}} );
			changeItemsAlpha(item);
			soundManager.playSound("menuOver");
		}
				
		private function itemMouseOut(e:CustomEvent):void
		{
			var item:TextLineMC = e.args;			
			TweenMax.to(item, menuParams.animationTime, {ease:SineOut, glowFilter:{alpha:0, strength:0, blurX:0, blurY:0}} );
			if (item.mouseY < 10 || item.mouseY > this.height-10 || item.mouseX>item.width-10 || item.mouseX<10)
				changeItemsAlpha(null);
		}			

		private function itemMouseDown(e:CustomEvent):void
		{			
			var item:TextLineMC = e.args;
			if (item != menuParams.currentItem)
			{				
				menuParams.currentItem = item;
				chooseItemAnimation();
				soundManager.playSound("menuClick");
				dispatchEvent(new CustomEvent(CustomEvent.MENU, item.method, true));
			}
		}
		
		private function chooseItemAnimation():void
		{
			TweenMax.to(menuParams.currentItem, menuParams.animationTime, { scaleX:2, scaleY:2 } );
			for each(var I:TextLineMC in menuItems) 
				if (I != menuParams.currentItem)
					TweenMax.to(I, menuParams.animationTime, { scaleX:0, scaleY:0 } );
		}
		
		private function changeItemsAlpha(activeItem:TextLineMC):void
		{
			if (activeItem == null)
				for each(var I:TextLineMC in menuItems) 
					TweenLite.to(I, menuParams.animationTime, { alpha:menuParams.curItemAlpha, ease:SineOut } );
			/*else 
				for each(I in menuItems)
					if (I != activeItem)
						TweenLite.to(I, menuParams.animationTime, {alpha:menuParams.itemAlpha, ease:SineOut} );*/
		}
    }
}