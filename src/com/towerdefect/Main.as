package com.towerdefect
{
	import com.greensock.motionPaths.RectanglePath2D;
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.system.fscommand;
	import flash.text.TextFieldAutoSize;

	/**
	 * ...
	 * @author insighter
	 */
	public class Main extends Sprite 
	{
		private var menuScreen:BaseMC;
		private var menu:Menu;
		
		private var gameScreen:BaseMC;
		private var field:Field;
		private var panelG:BaseMC;//Game panel
		private var panelS:BaseMC;//Stat panel
		private var panelO:BaseMC;//Options panel
		private var toolTip:AToolTip;
		
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
			//Creating GAME SCREEN and it's childs
			gameScreen = new BaseMC( { 
				image:Utils.getBMPByName(images, "fone.game"),
				rect:new Rectangle(0, -200, stage.stageWidth, stage.stageHeight),
				centerImage:false
			} );
			field = new Field( {
				name:"field",
				showOnCreate:true,
				image:Utils.getBMPByName(images, "fone.field"),
				rect:new Rectangle(75, 25, 550, 550),
				tileImages:Utils.getAllBMPByName(images, "tile."),
				tileCountX:parseInt(xml.vars.@tileCountX),
				tileCountY:parseInt(xml.vars.@tileCountY),
				tileWidth:parseInt(xml.vars.@tileWidth),
				tileHeight:parseInt(xml.vars.@tileHeight),
				gridSpacing:parseInt(xml.vars.@gridSpacing),
				centerImage:false,
				animationScale:1.005,
				animationTime:0.4,
				forceAnimation:true,
				mouseSpecialEffect:{deltaX:stage.stageWidth/2, deltaY:stage.stageHeight/2, shiftX:15, shiftY:15}
			});
			panelG = new BaseMC( {
				name:"panelG",
				image:Utils.getBMPByName(images, "fone.panelG"),
				imageCenter:true,
				rect:new Rectangle(630, 326, 140, 550),
				showOnCreate:false
			});
			panelS = new BaseMC( {
				name:"panelS",
				image:Utils.getBMPByName(images, "fone.panelS"),
				imageCenter:true,
				rect:new Rectangle(275, 20, 550, 40),
				showOnCreate:false
			});
			panelO = new BaseMC( {
				name:"panelO",
				image:Utils.getBMPByName(images, "fone.panelO"),
				imageCenter:true,
				rect:new Rectangle(630, 20, 140, 40),
				showOnCreate:false
			});
			gameScreen.addChild(field);
			gameScreen.addChild(panelG);
			gameScreen.addChild(panelS);
			gameScreen.addChild(panelO);
			addChild(gameScreen);
			gameScreen.scale(1, 1.6);
			
			//Creating MAIN MENU SCREEN and it's childs
			menuScreen = new BaseMC( {
				name:"menuScreen",
				rect:new Rectangle(0, 0, stage.stageWidth, stage.stageHeight),
				soundManager:soundManager
			});
			menu = new Menu( {
				name:"mainMenu",
				xmlUrl:"config/mainMenu.xml",
				soundManager:soundManager
			});
			var title1:TextLineMC = new TextLineMC( {
			text:"{5T{4ower} D}{4efe<wct}>}",
				rect:new Rectangle(300, 0, 0, 0),
				fontColor:textColor,
				dropShadowFilter:0x000000
			});
			var title2:TextLineMC = new TextLineMC( {
			text:"COPYRIGHT © 2012 BY INSIGHTER : ALL RIGHTS RESERVED",
				rect:new Rectangle(150, 570, 0, 0),
				fontColor:textColor,
				textFieldAutoSize:TextFieldAutoSize.LEFT,
				dropShadowFilter:0x000000,
				mouseSpecialEffect: {deltaX:250, shiftX:30}
			});
			menuScreen.addChild(menu);
			menuScreen.addChild(title1);
			menuScreen.addChild(title2);
			addChild(menuScreen);
		}
		
		private function menuClick(e:CustomEvent):void
		{
			switch(e.args)
			{
				case "quit": fscommand("quit"); break;
				case "game": startGame(); break;
				case "hsco": break;
			}
		}
		
		private function startGame():void
		{
			toolTip = new AToolTip( {
				main:this,
				opaque:0.85,
				showDelay:400,
				maxWidth:400,
				textColor:0x555555,
				bgColor:0x000000,
				useShadow:true,
				shadowColor:0x000000,
				fontName:new mySegoePrint().fontName,
				titleSize:14,
				descriptionSize:12
			});
			assignToolTip();
			menuScreen.hide(0.3, -50);
			gameScreen.scale(1, 1);
			gameScreen.move(0, 0);
			field.forceAnimation = false;
			field.deleteSpecialEffect();
			field.move(0, 50);
			field.addFilter("bevel", 0x222222);
			panelG.show();
			panelS.show();
			panelO.show();
			//field.tileField();
			var cannon1:BaseMC = new BaseMC( {
				image:Utils.getBMPByName(images, "tower.1"),
				centerImage:true,
				rect:new Rectangle(0, 200, 25, 25),
				showOnCreate:true,
				forceAnimation:true,
				animationScale:1.2
			});
			panelG.addChild(cannon1);
			cannon1.addEventListener(MouseEvent.MOUSE_DOWN, capture, false, 0, true);
		}
		
		private function assignToolTip():void
		{
			toolTip.addToolTip( {
				object:panelG,
				title:"Игровая панель", 
				description:"Проверка^ Это текст"
			});
		}
		
		private function capture(e:MouseEvent):void
		{
			field.cannon = e.currentTarget as BaseMC;
		}
	}
	
}