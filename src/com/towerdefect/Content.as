package com.towerdefect
{
	public class Content
	{
		public static var sounds:Array=[
			new SoundC("mainTheme", "../sound/soundResistance.mp3"),
			new SoundC("menuOver", "../sound/menuOver.mp3"),
			new SoundC("menuClick", "../sound/menuClick.mp3"),
			new SoundC("tileOver", "../sound/tileOver.mp3"),
			new SoundC("aTower", "../sound/aTower.mp3"),
			new SoundC("bTower", "../sound/bTower.mp3"),
			new SoundC("tick", "../sound/tick.mp3")
		];
		
		public static var images:Array = [
			new Image("fone.game", 		"../images/main/game.jpg"),	
			new Image("fone.field", 	"../images/main/field.png"),
			
			new Image("fone.panelG", 	"../images/main/panelG.png"),
			new Image("fone.panelS", 	"../images/main/panelS.png"),
			new Image("fone.panelO", 	"../images/main/panelO.png"),
			
			new Image("tile.1", 		"../images/tile/tile_s1.jpg"),
			
			new Image("tower.1", 		"../images/tower/tower1.png"),
			
			new Image("circle.w", 		"../images/balls/circleW.png"),
			new Image("circle.b", 		"../images/balls/circleB.png"),
			new Image("circle.g", 		"../images/balls/circleG.png"),
			new Image("circle.d", 		"../images/balls/circleD.png"),
			new Image("circle.r", 		"../images/balls/circleR.png"),
			new Image("circle.y", 		"../images/balls/circleY.png"),
		];
	}
}