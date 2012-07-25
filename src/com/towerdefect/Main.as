package com.towerdefect
{
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	/**
	 * ...
	 * @author insighter
	 */
	public class Main extends Sprite 
	{
		private var menuScreen:BaseMC;
		private var gameScreen:BaseMC;
		private var menu:Menu;
		private var field:ImageMC;
		private var soundManager:SoundManager;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.quality = StageQuality.BEST;
			addEventListener(CustomEvent.MENU, menuClick, false, 0, true);
			soundManager = SoundManager.getInstance();
			menuScreen = new BaseMC( {
				name:"menuScreen",
				soundManager:soundManager
			});
			addChild(menuScreen);
			menu = new Menu( {
				name:"main",
				xmlUrl:"config/mainMenu.xml"
			});
			
			menuScreen.addChild(menu);
			gameScreen = new BaseMC( { showOnCreate:false } );
			addChild(gameScreen);
			field = new ImageMC();
			gameScreen.scaleX = 0;
			gameScreen.scaleY= 0;
		}
		
		private function menuClick(e:CustomEvent):void
		{
			menuScreen.hide(0.3, -50);
			TweenLite.to(gameScreen, 1, { x:0, y:0, scaleX:1, scaleY:1 } );
		}
		
	}
	
}