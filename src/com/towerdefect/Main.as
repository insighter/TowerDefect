package com.towerdefect
{
	import com.greensock.motionPaths.RectanglePath2D;
	import com.greensock.plugins.GlowFilterPlugin;
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BevelFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.globalization.LocaleID;
	import flash.system.fscommand;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getDefinitionByName;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author insighter
	 */
	public class Main extends Sprite 
	{
		private var menuScreen:BaseMC;
		private var menu:Menu;
		private var gameScreen:BaseMC;
		private var buildMenu:BaseMC;
		private var buildMenuTowers:Array;
		private var field:BaseMC;
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
		private var phase:GamePhase;
		private var beatTimer:Timer;
		private var roadTimer:Timer;
		private var creaturesTimer:Timer;
		private var minStepCount:int = 8;
		private var towers:Array;
		private var creatures:Array;
		private var grid:BaseMC;
		private var tiles:Array;
		private var _startNode:INode;
		private var _endNode:INode;
		private const maxFieldWidth:int = 550;
		private const maxFieldHeight:int = 550;
		private const minFieldWidth:int = 100;
		private const minFieldHeight:int = 100;
		private const maxGridCountX:int = 50;
		private const maxGridCountY:int = 50;
		private const minGridCountX:int = 1;
		private const minGridCountY:int = 1;
		private var lastNode:TileMC;
		private var tileW:int;
		private var tileH:int;
		private var tileCountX:int;
		private var tileCountY:int;
		private var area:int;
		private var gridSpacing:int;
		private var roadTiles:Array;
		private var curTile:TileMC;
		private var road:Array;
		
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
			this.tileW = parseInt(xml.vars.@tileWidth);
			this.tileH = parseInt(xml.vars.@tileHeight);
			this.gridSpacing = parseInt(xml.vars.@gridSpacing);
			this.tileCountX = parseInt(xml.vars.@tileCountX);
			this.tileCountY = parseInt(xml.vars.@tileCountY);
			this.area = tileCountX * tileCountY;
			init();
		}
		
		private function init(e:Event = null):void 
		{
			stage.quality = StageQuality.BEST;
			addEventListener(CustomEvent.CONTENT_LOADED, contentLoaded, false, 0, true);
			addEventListener(CustomEvent.MENU, menuClick, false, 0, true);			
			soundManager = SoundManager.getInstance();
			phase = new GamePhase();
			for each(var s:SoundC in Content.sounds)
				soundManager.addExternalSound(s.path, s.name, s.defaultVolume);
			soundManager.playSound("mainTheme", 0.8);

			images = Content.images;
			contentLoader = new ContentLoader( {
				rect:new Rectangle(stage.stageWidth/2, 300, 0, 0),
				name:"mainContentLoader",
				images:images,
				textColor:textColor
			});
			addChild(contentLoader);
		}
		
		private function contentLoaded(e:CustomEvent):void
		{
			//Creating main AToolTip object that will manage all tooltips
			toolTip = new AToolTip( {
				main:this,
				opaque:0.85,
				showDelay:400,
				maxWidth:300,
				textColor:0x555555,
				bgColor:0x000000,
				fontName:new mySegoePrint().fontName,
				titleSize:14,
				descriptionSize:12,
				bevelFilter:new BevelFilter(1, 45, 0x666666, 1, 0x666666, 1, 0, 0),
				dropShadowFilter:new DropShadowFilter(5, 45, 0x000000, 1, 4, 4, 1, 3)
			});
			
			//Creating GAME SCREEN and it's childs
			gameScreen = new BaseMC( { 
				image:Utils.getBMPByName(images, "fone.game"),
				rect:new Rectangle(0, -200, stage.stageWidth, stage.stageHeight),
				centerImage:false
			} );
			field = new BaseMC( {
				name:"field",
				phase:phase,
				image:Utils.getBMPByName(images, "fone.field"),
				rect:new Rectangle(350, 300, (tileW + gridSpacing) * tileCountX - gridSpacing, (tileH + gridSpacing) * tileCountY - gridSpacing),
				animationScale:1.005,
				animationTime:1.4,
				forceAnimation:true,
				mouseSpecialEffect: { deltaX:stage.stageWidth / 2, deltaY:stage.stageHeight / 2, shiftX:15, shiftY:15 }
			});
			panelG = new BaseMC( {
				name:"panelG",
				image:Utils.getBMPByName(images, "fone.panelG"),
				imageCenter:true,
				rect:new Rectangle(626, 326, 140, 550),
				showOnCreate:false
			});
			panelS = new BaseMC( {
				name:"panelS",
				image:Utils.getBMPByName(images, "fone.panelS"),
				imageCenter:true,
				rect:new Rectangle(275, 24, 550, 40),
				showOnCreate:false
			});
			panelO = new BaseMC( {
				name:"panelO",
				image:Utils.getBMPByName(images, "fone.panelO"),
				imageCenter:true,
				rect:new Rectangle(626, 24, 140, 40),
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
			text:"{100S}ound {100R}esistance",
				rect:new Rectangle(300, 0, 0, 0),
				fontSize:40,
				fontColor:textColor,
				dropShadowFilter:new DropShadowFilter(10, 45, 0x000000, 1, 10, 10, 1, 3),
				animationScale:1.01,
				animationTime:0.01,
				forceAnimation:true
			});
			var title2:TextLineMC = new TextLineMC( {
			text:"COPYRIGHT © 2012 BY INSIGHTER : ALL RIGHTS RESERVED",
				rect:new Rectangle(150, 570, 0, 0),
				fontColor:textColor,
				textFieldAutoSize:TextFieldAutoSize.LEFT,
				dropShadowFilter:new DropShadowFilter(10, 45, 0x000000, 1, 10, 10, 1, 3),
				mouseSpecialEffect: {deltaX:250, shiftX:30}
			});
			menuScreen.addChild(menu);
			menuScreen.addChild(title1);
			menuScreen.addChild(title2);
			addChild(menuScreen);
			phase.mainPhase = "menu";
			createTiles();
			enableTiles();
			assignToolTip();			
		}
		
		private function assignToolTip():void
		{
			toolTip.addToolTip( { object:panelG,	title:"Игровая панель", text:"Проверка^ Это текст" } );
			toolTip.addToolTip( { object:panelS,	title:"Панель информации", text:"Пу{025сто}", bgColor:0x555555, textColor:0x000000, bevelFilter:new BevelFilter(1, 45, 0xFFFFFF, 1, 0xFFFFFF, 1, 0, 0, 1, 3) } );
			toolTip.addToolTip( { object:panelO,	title:"Панель правая, <rверхняя> =)", text:"<gДобавить> кнопку настроек^<gДобавить> управление громкостью" } );
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
			menuScreen.hide(false, 0.3, -50);
			gameScreen.scale(1, 1);
			gameScreen.move(0, 0);
			field.forceAnimation = false;
			field.deleteSpecialEffect();
			field.move(field.width/2, field.height/2+(stage.stageHeight-field.height));
			field.bevelFilter = new BevelFilter(1, 45, 0x222222, 1, 0x222222);
			hideTiles();
			mouseTiles(true);
			phase.mainPhase = "game";
			panelG.show();
			panelS.show();
			panelO.show();
			beatTimer = new Timer(25, 320);
			beatTimer.addEventListener(TimerEvent.TIMER, nextSoundStep, false, 0, true);
			beatTimer.start();
			soundManager.fadeSound("mainTheme", 0, 3);
			buildGrid();
			createRoad();
			createBuildMenu();
		}
		
		private function createTiles():void
		{
			tiles = new Array();
			for (var i:int = 0; i < tileCountY; i++)
				for (var j:int = 0; j < tileCountX; j++)
				{
					var t:TileMC=new TileMC( {
						name:"tile." + String(i * tileCountY + j + 1),
						image:Utils.getBMPByName(images, "tile.1"),
						opaque:0.4,
						row:j+1,
						col:i+1,
						rect:new Rectangle( -field.width / 2 + j * (tileW + gridSpacing) + tileW / 2, -field.height / 2 + i * (tileH + gridSpacing) + tileH / 2, tileW, tileH)
					});
					tiles.push(t);
					field.addChild(t); 
				}
		}
		
		private function buildGrid():void
		{
			grid = new BaseMC( {
				rect:new Rectangle(0, 0, field.width, field.height)
			});
			field.addChild(grid);
		}
		
		public function enableTiles():void
		{
			for each(var t:TileMC in tiles)
			{
				t.addEventListener(MouseEvent.ROLL_OVER, onTileOver, false, 0, true);
				t.addEventListener(MouseEvent.ROLL_OUT, onTileOut, false, 0, true);
				t.addEventListener(MouseEvent.MOUSE_DOWN, onTileClick, false, 0, true);				
			}
		}
		
		public function disableTiles():void
		{
			for each(var t:TileMC in tiles)
			{
				t.removeEventListener(MouseEvent.ROLL_OVER, onTileOver);
				t.removeEventListener(MouseEvent.ROLL_OUT, onTileOut);
				t.removeEventListener(MouseEvent.MOUSE_DOWN, onTileClick);				
			}			
		}
		
		public function mouseTiles(on:Boolean):void
		{
			for each(var t:TileMC in tiles)
				t.buttonMode = on;
		}
		
		public function showTiles():void
		{
			for each(var t:TileMC in tiles)
				t.opaque = 0.4;
		}
		
		public function hideTiles():void
		{
			for each(var t:TileMC in tiles)
				t.opaque = 0;
		}
		
		private function onTileOver(e:MouseEvent):void 
		{
			var node:TileMC = e.currentTarget as TileMC;
			if (phase.mainPhase == "menu" && node.opaque != 0)
			{
				soundManager.playSound("tileOver");
				node.opaque = 0.5;
			}
		}
		
		private function onTileOut(e:MouseEvent):void 
		{
			var node:TileMC = e.currentTarget as TileMC;
			if (phase.mainPhase == "menu")
				node.opaque = 0;
			if (node != _startNode && node != _endNode) node.removeFilters();
		}
		
		private function onTileClick(e:MouseEvent):void
		{
			if (!phase.constructionMode) return;
			lastNode = e.currentTarget as TileMC;
			if (lastNode.tower != null) return;
			showBuildMenu();
		}
		
		private function createBuildMenu():void
		{
			buildMenu = new BaseMC( {
				rect:new Rectangle(0, 0, 100, 100),
				opaque:0.8,
				image:Utils.getBMPByName(images, "buildMenu"),
				bevelFilter:new BevelFilter(2, 45, 0x555555, 1, 0x555555, 1, 0, 0, 1, 3),
				dropShadowFilter:new DropShadowFilter(4, 45, 0x000000, 1, 6, 6, 2, 3),
				showOnCreate:false
			});
			field.addChild(buildMenu);
			
			towers = new Array();
			var tVolcano:TVolcano = new TVolcano( {
				towerParams:TowerParams.volcano,
				rect:new Rectangle(-tileW, -tileH, 24, 24),
				soundManager:soundManager,
				beatTimer:beatTimer,
				images:images,
				targets:creatures
			});
			buildMenu.addChild(tVolcano);
			var tCannon:TCannon = new TCannon( {
				towerParams:TowerParams.cannon,
				rect:new Rectangle(0, -tileH, 24, 24),
				soundManager:soundManager,
				beatTimer:beatTimer,
				images:images,
				targets:creatures
			});
			buildMenu.addChild(tCannon);
			var tbVolcano:TVolcano = new TVolcano( {
				towerParams:TowerParams.volcano,
				rect:new Rectangle(12, 12, 24, 24),
				soundManager:soundManager,
				beatTimer:beatTimer,
				images:images,
				containProjectiles:true,
				muted:true,
				targetsAim:false
			});
			var tbCannon:TCannon = new TCannon( {
				towerParams:TowerParams.cannon,
				rect:new Rectangle(12, 12, 24, 24),
				soundManager:soundManager,
				beatTimer:beatTimer,
				images:images,
				containProjectiles:true,
				muted:true,
				targetsAim:false,
				bevelFilter:new BevelFilter(1, 45, 0xffffff, 1, 0x000000, 0, 0, 0, 1, 3)
			});
			tbVolcano.build(0);
			tbCannon.build(0);
			toolTip.addToolTip( { object:tVolcano,	title:"<r"+TowerParams.volcano.title+">", text:TowerParams.getInfo(TowerParams.volcano), icon:tbVolcano });
			toolTip.addToolTip( { object:tCannon,	title:"<r"+TowerParams.cannon.title+">", text:TowerParams.getInfo(TowerParams.cannon), icon:tbCannon });
			tVolcano.addEventListener(MouseEvent.MOUSE_DOWN, buildTower, false, 0, true);
			tCannon.addEventListener(MouseEvent.MOUSE_DOWN, buildTower, false, 0, true);
		}
		
		private function showBuildMenu():void
		{
			buildMenu.addEventListener(MouseEvent.ROLL_OUT, hideBuildMenu, false, 0, true);
			buildMenu.addEventListener(MouseEvent.MOUSE_DOWN, hideBuildMenu, false, 0, true);
			buildMenu.move(lastNode.x, lastNode.y, 0);
			buildMenu.show();
		}
		
		private function hideBuildMenu(e:MouseEvent=null):void
		{
			buildMenu.removeEventListener(MouseEvent.ROLL_OUT, hideBuildMenu);
			buildMenu.removeEventListener(MouseEvent.MOUSE_DOWN, hideBuildMenu);
			buildMenu.hide();
		}
		
		private function buildTower(e:MouseEvent):void
		{
			hideBuildMenu();
			var tower:Tower = e.currentTarget as Tower;
			
			var myClass:Class = tower.params.className;
			var newTower:* = new myClass( {
				towerParams:tower.params,
				rect:new Rectangle(lastNode.x+1, lastNode.y+1, 24, 24),
				soundManager:soundManager,
				beatTimer:beatTimer,
				images:images,
				targets:creatures
			});
			var curStep:int = Math.round(beatTimer.currentCount * 25 / 125 / minStepCount);
			field.addChild(newTower);
			lastNode.tower = newTower;
			newTower.build(curStep);
		}
		
		private function nextSoundStep(e:TimerEvent):void
		{			
			if (beatTimer.currentCount * 25 % 1000 == 0)
				soundManager.playSound("tick");
			if (beatTimer.currentCount == 40*8)
			{	
				beatTimer.reset();
				beatTimer.start();
			}
		}
		
		private function createRoad():void
		{
			var i:int;
			roadTiles = tiles.concat();
			road = new Array();
			for (i = 1; i < tileCountX - 1; i++)
			{
				roadTiles.splice(i, 1);
				roadTiles.splice(area - i - 1, 1);
			}
			for (i = 1; i < tileCountY - 1; i++)
			{
				roadTiles.splice(i * tileCountX, 1);
				roadTiles.splice(tileCountX * (i + 1) - 1, 1);
			}
			curTile = tiles[Utils.Rand(tileCountX - 2) + 1];
			do
			{
				road.push(curTile);	
				var connected:Array = Pathfinder.findConnectedNodes(curTile, roadTiles, false);
				curTile = Utils.randElement(connected);
				for each(var t:TileMC in connected)
					if(roadTiles.indexOf(t)!=-1)
						roadTiles.splice(roadTiles.indexOf(t), 1);
			}while(connected.length>0 && road.length<area / 10)
			if (road.length < area / 10) 
				createRoad();
			else 
			{
				roadTimer = new Timer(50, road.length);
				roadTimer.addEventListener(TimerEvent.TIMER, addRoadTile, false, 0, true);
				roadTimer.addEventListener(TimerEvent.TIMER_COMPLETE, roadAdded, false, 0, true);
				roadTimer.start();
			}
		}
				
		private function addRoadTile(e:TimerEvent):void
		{
			var t:TileMC = road[roadTimer.currentCount - 1] as TileMC;
			t.scale(1, 0, 0);
			t.scale(1, 1, 0.3);
			t.opaque = 0.8;
		}
		
		private function roadAdded(e:TimerEvent):void
		{
			creaturesGo();
			phase.constructionMode = true;
		}
		
		private function creaturesGo():void
		{
			creatures = new Array();
			creaturesTimer = new Timer(4000, 20);
			creaturesTimer.addEventListener(TimerEvent.TIMER, createCreature, false, 0, true);
			creaturesTimer.start();
		}
		
		private function createCreature(e:TimerEvent):void
		{
			var c:Creature = new Creature( { 
				image:Utils.getBMPByName(images, "creature.star2"),
				rect:new Rectangle(road[0].x, road[0].y, 20, 20),
				dropShadowFilter:new DropShadowFilter(2, 45, 0x000000, 1, 4, 4, 1, 3),
				road:road
			});
				creatures.push(c);
				field.addChild(c);
				c.beginMove();
		}
	}
}