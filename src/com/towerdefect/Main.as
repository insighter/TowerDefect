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
		private var field:FieldMC;
		private var soundManager:SoundManager;
		private var contentLoader:ContentLoader;
		private var images:Array;
		private var xmlLoader:XMLLoader;
		private var textColor:uint;
		private const xmlUrl:String = "config/Main.xml";
		private const maxFieldWidth:int = 600;
		private const maxFieldHeight:int = 600;
		private const minFieldWidth:int = 100;
		private const minFieldHeight:int = 100;
		private const maxGridCountX:int = 50;
		private const maxGridCountY:int = 50;
		private const minGridCountX:int = 1;
		private const minGridCountY:int = 1;
		private var xml:XML;
		
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
			xml = xmlLoader.xml;
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
			//Creating MAIN MENU SCREEN
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
				rect:new Rectangle(100, 0, 0, 0),
				fontSize:80,
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
			
			//Creating GAME SCREEN
			gameScreen = new ImageMC( { showOnCreate:false } );
			addChild(gameScreen);
			var W:int = Utils.matchInterval(parseInt(xml.vars.@fieldWidth), minFieldWidth, maxFieldWidth);
			var H:int = Utils.matchInterval(parseInt(xml.vars.@fieldHeight), minFieldHeight, maxFieldHeight);
			var gridX:int = Utils.matchInterval(parseInt(xml.vars.@gridCountX), minGridCountX, maxGridCountX);
			var gridY:int = Utils.matchInterval(parseInt(xml.vars.@gridCountY), minGridCountY, maxGridCountY);
			field = new FieldMC( {
				//image:Utils.getBMPByName(images, "fone.field"),
				fillColor:0x000000,
				rect:new Rectangle(300, stage.stageHeight / 2, W, H),
				tileImages:Utils.getAllBMPByName(images, "tile."),
				gridCountX:gridX,
				gridCountY:gridY,
				centerImage:false
			});
			field.scale(1, 0, 0.3);
			gameScreen.addChild(field);
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
			gameScreen.show(1);
			TweenLite.to(field, 0.3, { scaleX:1, scaleY:1 } );
			//field.tileField();
		}
	}
	
}