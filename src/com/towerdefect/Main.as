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
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.fscommand;
	import flash.text.engine.TextLine;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getDefinitionByName;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author insighter
	 */
	public class Main extends Sprite 
	{
		private var copyRScreen:BaseMC;
		private var aboutScreen:TextMC;
		private var titleScreen:BaseMC;
		private var menuScreen:BaseMC;
		private var menu:Menu;
		private var gameScreen:BaseMC;
		private var buildMenu:BaseMC;
		private var buildMenuTowers:Array;
		private var field:BaseMC;
		private var panelG:BaseMC;
		private var panelS:BaseMC;
		private var panelO:BaseMC;
		private var scoreL:TextMC;
		private var toolTip:ToolTip;
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
		private var fieldW:int;
		private var fieldH:int;
		private var tileW:int;
		private var tileH:int;
		private var rows:int;
		private var cols:int;
		private var area:int;
		private var gridSpacing:int;
		private var roadTiles:Array;
		private var curTile:TileMC;
		private var road:Array;
		private var roadLength:int;
		private var score:int;
		
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
		
		//Apply XML and calculate some vars
		private function XMLLoaded(e:CustomEvent):void
        {
			xmlLoader.removeEventListener(CustomEvent.XML_LOADED, XMLLoaded);
			this.xml = xmlLoader.xml;
			this.textColor = xml.font.@color.toString().replace("#", "0x");
			this.tileW = parseInt(xml.field.tileWidth);					//Tile width
			this.tileH = parseInt(xml.field.tileHeight);				//Tile height
			this.gridSpacing = parseInt(xml.field.gridSpacing);			//Space between tiles
			this.rows = parseInt(xml.field.rows);						//Number of tiles (x-axis)
			this.cols = parseInt(xml.field.cols);						//Number of tiles (y-axis)
			this.area = rows * cols;									//Total Number of tiles
			this.fieldW = (tileW + gridSpacing) * cols - gridSpacing;	//Total width of field
			this.fieldH = (tileH + gridSpacing) * rows - gridSpacing;	//Total width of field
			
			this.roadLength = parseInt(xml.road.length);
			init();
		}
		
		private function init(e:Event = null):void 
		{
			stage.quality = StageQuality.BEST;
						
			soundManager = SoundManager.getInstance();
			
			phase = new GamePhase();
			
			for each(var s:SoundC in Content.sounds)
				soundManager.addExternalSound(s.path, s.name, s.defaultVolume);//Preparing all sounds
			soundManager.playSound("mainTheme", 0.8);

			images = Content.images;
			addEventListener(CustomEvent.CONTENT_LOADED, contentLoaded, false, 0, true);
			contentLoader = new ContentLoader( {
				rect:new Rectangle(stage.stageWidth/2, 300, 0, 0),
				name:"mainContentLoader",
				images:images,
				textColor:0x666666
			});
			addChild(contentLoader);
		}
		
		private function contentLoaded(e:CustomEvent):void
		{
			//Creating main ToolTip object that will manage all tooltips
			toolTip = new ToolTip( {
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
			//Field is where all the action will take place
			field = new BaseMC( {
				name:"field",
				phase:phase,
				image:Utils.getBMPByName(images, "fone.field"),
				rect:new Rectangle(350, 300, fieldW, fieldH),
				animationScale:1.005,
				animationTime:1.4,
				forceAnimation:true,
				mouseSpecialEffect: { mouseDeltaX:stage.stageWidth / 2, mouseDeltaY:stage.stageHeight / 2, menuDeltaX:15, menuDeltaY:15 }
			});
			//Grid is for grid.graphics animation
			grid = new BaseMC( {
				rect:new Rectangle(0, 0, field.width, field.height)
			});
			field.addChild(grid);
			//Some panels
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
			var scoreT:TextMC = new TextMC( {
				rect:new Rectangle( -270, -22, 0, 0),
				fontSize:20,
				text:"Score:"
			});
			scoreL = new TextMC( {
				rect:new Rectangle( -210, -22, 0, 0),
				fontSize:20,
				text:score
			});
			panelS.addChild(scoreT);
			panelS.addChild(scoreL);
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
			
			//Creating menu, title and copyright screens
			menuScreen = new Menu( {
				name:"mainMenu",
				xmlUrl:"config/mainMenu.xml",
				soundManager:soundManager
			});
			titleScreen = new TextMC( {
				text:"{100S}ound {100R}esistance",
				rect:new Rectangle(300, 0, 0, 0),
				fontSize:40,
				fontColor:textColor,
				dropShadowFilter:new DropShadowFilter(10, 45, 0x000000, 1, 10, 10, 1, 3),
				animationScale:1.01,
				animationTime:0.01,
				forceAnimation:true
			});
			copyRScreen = new TextMC( {
				text:"COPYRIGHT © 2012 BY INSIGHTER : ALL RIGHTS RESERVED",
				rect:new Rectangle(150, 570, 0, 0),
				fontColor:textColor,
				textFieldAutoSize:TextFieldAutoSize.LEFT,
				dropShadowFilter:new DropShadowFilter(10, 45, 0x000000, 1, 10, 10, 1, 3),
				mouseSpecialEffect: {mouseDeltaX:250, menuDeltaX:30}
			});
			aboutScreen = new TextMC( {
				rect:new Rectangle(130, 150, 450, 300),
				multiLine:true,
				showOnCreate:false,
				fontSize:18,
				fontColor:0x000000,
				typingEffect:true,
				fontLeading:-13
			});			
			addChild(aboutScreen);
			addChild(copyRScreen);
			addChild(menuScreen);
			addChild(titleScreen);
			addEventListener(CustomEvent.MENU, menuClick, false, 0, true);
			
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
				case "about": copyRScreen.hide(); aboutScreen.show(); loadAbout(); break;
				case "hideAbout": copyRScreen.show(); aboutScreen.hide(); tilesOpaque(0.5);break;
				case "replayAbout": loadAbout(); break;
			}
		}
		
		private function loadAbout():void
		{
			var textL:URLLoader = new URLLoader();
			textL.addEventListener(Event.COMPLETE, showLoaded, false, 0, true);  
			textL.load(new URLRequest("about.txt"));
		}
		
		private function showLoaded(e:Event):void
		{
			tilesOpaque(0);
			aboutScreen.clear();
			aboutScreen.setText(e.target.data);
		}
		
		private function startGame():void
		{
			//Visual
			menuScreen.hide(false, 0.3, -50);
			copyRScreen.hide();
			titleScreen.hide();
			gameScreen.scale(1, 1);
			gameScreen.move(0, 0);
			field.forceAnimation = false;
			field.deleteSpecialEffect();
			field.move(field.width/2, field.height/2+(stage.stageHeight-field.height));
			field.bevelFilter = new BevelFilter(1, 45, 0x222222, 1, 0x222222);
			panelG.show();
			panelS.show();
			panelO.show();
			
			tilesOpaque(0);
			mouseTiles(true);
			phase.mainPhase = "game";
			soundManager.fadeSound("mainTheme", 0, 3);
			beatTimer = new Timer(25, 320);
			beatTimer.addEventListener(TimerEvent.TIMER, nextBeat, false, 0, true);
			beatTimer.start();
			createRoad();
			createBuildMenu();
			addEventListener(CustomEvent.CREATURE_KILLED, creatureKilled, false, 0, true);
			
			score = 0;
		}
		
		private function createTiles():void
		{
			tiles = new Array();
			for (var i:int = 0; i < cols; i++)
				for (var j:int = 0; j < rows; j++)
				{
					var t:TileMC=new TileMC( {
						name:"tile." + String(i * cols + j + 1),
						image:Utils.getBMPByName(images, "tile.1"),
						opaque:0.4,
						row:j+1,
						col:i+1,
						rect:new Rectangle( -fieldW / 2 + j * (tileW + gridSpacing) + tileW / 2, -fieldH / 2 + i * (tileH + gridSpacing) + tileH / 2, tileW, tileH)
					});
					tiles.push(t);
					field.addChild(t); 
				}
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
		
		//Enable of disable hand cursor for all tiles
		public function mouseTiles(on:Boolean):void
		{
			for each(var t:TileMC in tiles)
				t.buttonMode = on;
		}
		
		public function tilesOpaque(value:Number):void
		{
			for each(var t:TileMC in tiles)
				t.opaque = value;
		}
		
		private function onTileOver(e:MouseEvent):void 
		{
			var tile:TileMC = e.currentTarget as TileMC;
			if (phase.mainPhase == "menu" && tile.opaque != 0)
			{
				soundManager.playSound("tileOver");
				tile.opaque = 0;
			}
			else if (phase.mainPhase == "game" && road.indexOf(tile) == -1)
				tile.opaque = 0.5;
		}
		
		private function onTileOut(e:MouseEvent):void 
		{
			var tile:TileMC = e.currentTarget as TileMC;
			if (phase.mainPhase == "game" && road.indexOf(tile) == -1)
				tile.opaque = 0;
		}
		
		private function onTileClick(e:MouseEvent):void
		{
			if (!phase.constructionMode) return;
			lastNode = e.currentTarget as TileMC;//remember the last tile that was clicked
			if (lastNode.tower == null)
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
			
			//Adding towers to the build menu
			towers = new Array();
			var tVolcano:TVolcano = new TVolcano( {
				rect:new Rectangle(-tileW, -tileH, 24, 24),
				soundManager:soundManager,
				beatTimer:beatTimer,
				images:images,
				targets:creatures,
				tileSize:Math.max(tileW, tileH)
			});
			var tCannon:TCannon = new TCannon( {
				rect:new Rectangle(0, -tileH, 24, 24),
				soundManager:soundManager,
				beatTimer:beatTimer,
				images:images,
				targets:creatures,
				tileSize:Math.max(tileW, tileH),
				bevelFilter:new BevelFilter(1, 45, 0xffffff, 1, 0x000000, 0, 0, 0, 1, 3)
			});
			buildMenu.addChild(tVolcano);
			buildMenu.addChild(tCannon);
			
			//Creating 'demo' towers that will appear in tooltip as icon
			var demoVolcano:TVolcano = new TVolcano( {
				rect:new Rectangle(12, 12, 24, 24),
				soundManager:soundManager,
				beatTimer:beatTimer,
				images:images,
				containProjectiles:true,
				muted:true,
				targetsAim:false
			});
			var demoCannon:TCannon = new TCannon( {
				rect:new Rectangle(12, 12, 24, 24),
				soundManager:soundManager,
				beatTimer:beatTimer,
				images:images,
				containProjectiles:true,
				muted:true,
				targetsAim:false,
				bevelFilter:new BevelFilter(1, 45, 0xffffff, 1, 0x000000, 0, 0, 0, 1, 3)
			});
			demoVolcano.build(0);
			demoCannon.build(0);
			toolTip.addToolTip( { object:tVolcano,	title:"<r"+tVolcano.params.title+">", text:tVolcano.params.getInfo(), icon:demoVolcano });
			toolTip.addToolTip( { object:tCannon,	title:"<r"+tCannon.params.title+">", text:tCannon.params.getInfo(), icon:demoCannon });
			tVolcano.addEventListener(MouseEvent.MOUSE_DOWN, buildTower, false, 0, true);
			tCannon.addEventListener(MouseEvent.MOUSE_DOWN, buildTower, false, 0, true);
		}
		
		private function showBuildMenu():void
		{
			buildMenu.addEventListener(MouseEvent.ROLL_OUT, hideBuildMenu, false, 0, true);
			buildMenu.addEventListener(MouseEvent.MOUSE_DOWN, hideBuildMenu, false, 0, true);
			buildMenu.move(lastNode.x, lastNode.y, 0);
			buildMenu.show();
			field.setChildIndex(buildMenu, field.numChildren - 1);
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
			var tClass:Class = tower.params.className;//Getting class of tower that was clicked in build menu
			//Creating new tower of that class
			var newTower:* = new tClass( {
				rect:new Rectangle(lastNode.x+1, lastNode.y+1, 24, 24),
				soundManager:soundManager,
				beatTimer:beatTimer,
				images:images,
				targets:creatures,
				tileSize:Math.max(tileW, tileH)
			});
			field.addChild(newTower);
			lastNode.tower = newTower;
			
			var curBeat:int = Math.round(beatTimer.currentCount * 25 / 125 / minStepCount);//remember the moment of music cycle
			newTower.build(curBeat);
		}
		
		private function nextBeat(e:TimerEvent):void
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
			roadTiles = tiles.concat();//Getting copy of all tiles array
			road = new Array();
			var borderTiles:Array = new Array();
			var t:TileMC;
			//Excluding border tiles if road shouldn't use them
			for (var i:int = 1; i < cols - 1; i++)
			{
				t = tiles[i];
				borderTiles.push(t);
				roadTiles.splice(roadTiles.indexOf(t), 1);
				t = tiles[area - i - 1];
				borderTiles.push(t);
				roadTiles.splice(roadTiles.indexOf(t), 1);
			}
			for (i = 1; i < rows - 1; i++)
			{
				t = tiles[i * rows];
				borderTiles.push(t);
				roadTiles.splice(roadTiles.indexOf(t), 1);
				t = tiles[rows * (i + 1) - 1];
				borderTiles.push(t);
				roadTiles.splice(roadTiles.indexOf(t), 1);
			}
			curTile = Utils.randElement(borderTiles) as TileMC;//Setting start tile of road
			do
			{
				road.push(curTile);	
				var connected:Array = Pathfinder.findConnectedNodes(curTile, roadTiles, false);
				curTile = Utils.randElement(connected);
				for each(var n:INode in connected)
					if(roadTiles.indexOf(n)!=-1)
						roadTiles.splice(roadTiles.indexOf(n), 1);
			}while (connected.length > 0 && road.length < this.roadLength);
			if (road.length < this.roadLength)
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
			var curCount:int = roadTimer.currentCount;
			var t:TileMC = road[curCount - 1] as TileMC;
			t.scale(1, 0, 0);
			t.scale(1, 1, 0.3);
			t.opaque = 0.8;
			var colored:int = road.length / 10;
			if (curCount > road.length - colored)
				t.opaque += 0.2 * (1 - (road.length - curCount) / colored);
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
			var c:Creature = new CStar( { 
				rect:new Rectangle(road[0].x, road[0].y, 20, 20),
				road:road,
				images:images, soundManager:soundManager
			});
			creatures.push(c);
			field.addChild(c);
			c.beginMove();
		}
		
		private function creatureKilled(e:CustomEvent):void
		{
			var c:Creature = e.args;
			creatures.splice(creatures.indexOf(c), 1);
			c.hide(true);
			score += c.score;
			scoreL.setText(score.toString());
		}
	}
}