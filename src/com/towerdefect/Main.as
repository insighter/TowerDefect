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
		private var field:Field;
		private var soundManager:SoundManager;
		private var contentLoader:ContentLoader;
		private var images:Array;
		private var xmlLoader:XMLLoader;
		private var textColor:uint;
		private const xmlUrl:String = "config/Main.xml";
		private var xml:XML;
		
		public function Main():void 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
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
			xml = xmlLoader.xml;
			this.textColor = xml.vars.font.@color.toString().replace("#", "0x");
			init();
		}
		
		private function init(e:Event = null):void 
		{
			stage.quality = StageQuality.BEST;
			initEvents();
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
		
		private function initEvents():void
		{
			addEventListener(CustomEvent.CONTENT_LOADED, contentLoaded, false, 0, true);
			addEventListener(CustomEvent.MENU, menuClick, false, 0, true);
		}
		
		private function contentLoaded(e:CustomEvent):void
		{
			//Creating GAME SCREEN
			gameScreen = new ImageMC( { 
				image:Utils.getBMPByName(images, "fone.game"),
				rect:new Rectangle(0, 0, stage.stageWidth, stage.stageHeight),
				centerImage:false
			} );
			addChild(gameScreen);
			field = new Field( {
				showOnCreate:true,
				image:Utils.getBMPByName(images, "fone.field"),
				rect:new Rectangle(0, 50, 550, 550),
				tileImages:Utils.getAllBMPByName(images, "tile."),
				tileCountX:parseInt(xml.vars.@tileCountX),
				tileCountY:parseInt(xml.vars.@tileCountY),
				tileWidth:parseInt(xml.vars.@tileWidth),
				tileHeight:parseInt(xml.vars.@tileHeight),
				gridSpacing:parseInt(xml.vars.@gridSpacing),
				centerImage:false
			});
			gameScreen.addChild(field);
			
			//Creating MAIN MENU SCREEN
			menuScreen = new ImageMC( {
				name:"menuScreen",
				rect:new Rectangle(0, 0, stage.stageWidth, stage.stageHeight),
				soundManager:soundManager,
				//image:Utils.getBMPByName(images, "fone.main"),
				//imageOpaque:1,
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
				rect:new Rectangle(100, 0, 0, 0),
				fontSize:30,
				fontColor:textColor
			});
			var title2:TextLineMC = new TextLineMC( {
				text:"Defe<d{3ct}>",
				rect:new Rectangle(220, 0, 0, 0),
				fontSize:30,
				fontColor:textColor
			});
			menuScreen.addChild(title1);
			menuScreen.addChild(title2);
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
			field.move(0, 50);
			field.tileField();
		}
	}
	
}