package com.towerdefect
{
	import com.greensock.motionPaths.RectanglePath2D;
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.system.fscommand;

	/**
	 * ...
	 * @author insighter
	 */
	public class Main extends Sprite 
	{
		private var menuScreen:ImageMC;
		private var gameScreen:ImageMC;
		private var menu:Menu;
		private var field:ImageMC;
		private var soundManager:SoundManager;
		private var contentLoader:ContentLoader;
		private var images:Array;
		private var xmlLoader:XMLLoader;
		private var textColor:uint;
		private const xmlUrl:String = "config/Main.xml";
		
		public function Main():void 
		{
			loadXML(xmlUrl);
		}
		
		public function loadXML(xmlUrl:String):void
		{
			xmlLoader = new XMLLoader(xmlUrl);
            xmlLoader.addEventListener(CustomEvent.XML_LOADED, XMLLoaded, false, 0, true); 
			xmlLoader.load();
		}
		
		private function XMLLoaded(e:CustomEvent):void
        {
			trace(e.args);
			if (e.args != xmlUrl) return;//Отсеиваем события от ненужных xmlLoader-ов (если одновременно загружались несколько)
			xmlLoader.removeEventListener(CustomEvent.XML_LOADED, XMLLoaded);  
			var xml:XML = xmlLoader.xml;
			this.textColor = xml.vars.font.@color.toString().replace("#", "0x");
			init();
		}
		
		private function init(e:Event = null):void 
		{
			stage.quality = StageQuality.BEST;
			addEventListener(CustomEvent.CONTENT_LOADED, contentLoaded, false, 0, true);
			addEventListener(CustomEvent.MENU, menuClick, false, 0, true);
			soundManager = SoundManager.getInstance();
			for each(var s:SoundC in Content.sounds)
				soundManager.addExternalSound(s.path, s.name);
			//soundManager.playSound("mainTheme", 0.8);
				
			images = Content.images;
			contentLoader = new ContentLoader( {
				rect:new Rectangle(stage.stageWidth/2, 300, 0, 0),
				name:"mainContentLoader",
				source:images,
				textColor:textColor
			});
			addChild(contentLoader);
		}
		
		private function contentLoaded(e:CustomEvent):void
		{
			menuScreen = new ImageMC( {
				name:"menuScreen",
				rect:new Rectangle(0, 0, 800, 600),
				soundManager:soundManager,
				image:Utils.getBMPByName(images, "fone.main"),
				imageOpaque:1,
				centerImage:false
			});
			addChild(menuScreen);
			menu = new Menu( {
				name:"main",
				xmlUrl:"config/mainMenu.xml",
				soundManager:soundManager
			});
			menuScreen.addChild(menu);
			var title1:TextLineMC = new TextLineMC( {
				text:"Tower",
				rect:new Rectangle(100, -30, 0, 0),
				fontSize:90,
				fontColor:textColor
			});
			var title2:TextLineMC = new TextLineMC( {
				text:"Defe<d{6ct}>",
				rect:new Rectangle(500, 0, 0, 0),
				fontSize:80,
				fontColor:textColor
			});
			menuScreen.addChild(title1);
			menuScreen.addChild(title2);
			gameScreen = new ImageMC( { showOnCreate:false } );
			addChild(gameScreen);
			field = new ImageMC( {
				
			});
		}
		
		private function menuClick(e:CustomEvent):void
		{
			switch(e.args)
			{
				case "quit": fscommand("quit"); break;
				case "game": startGame(); break;
			}
		}
		
		private function startGame():void
		{
			menuScreen.hide(0.3, -50);
			TweenLite.to(gameScreen, 1, { x:0, y:0, scaleX:1, scaleY:1 } );
		}
	}
	
}