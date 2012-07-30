package com.towerdefect
{
	public class Content
	{
		public static var sounds:Array=[
			new SoundC("mainTheme", 	"../sound/soundResistance.mp3"),
			new SoundC("menuOver", 		"../sound/menuOver.mp3"),
			new SoundC("menuClick", 	"../sound/menuClick.mp3"),
			new SoundC("tileOver", 		"../sound/tileOver.mp3"),
			new SoundC("volcano", 		"../sound/volcano.mp3"),
			new SoundC("cannon", 		"../sound/cannon.mp3"),
			new SoundC("tick", 			"../sound/tick.mp3"),
			new SoundC("ballHit", 		"../sound/ballHit.mp3", 0.3)
		];
		
		public static var images:Array = [
			new Image("fone.game", 		"../images/main/game.jpg"),	
			new Image("fone.field", 	"../images/main/field.png"),
			new Image("fone.buildMenu", "../images/main/game.jpg"),
			
			new Image("fone.panelG", 	"../images/main/panelG.png"),
			new Image("fone.panelS", 	"../images/main/panelS.png"),
			new Image("fone.panelO", 	"../images/main/panelO.png"),
			
			new Image("tile.1", 		"../images/tile/tile_s1.jpg"),
			
			new Image("tower.volcano",  "../images/tower/volcano.png"),
			new Image("tower.cannon", 	"../images/tower/cannon.png"),
			
			new Image("creature.star1", "../images/creatures/creature1.jpg"),
			new Image("creature.star2", "../images/creatures/creature2.png"),
			
			new Image("circle.w", 		"../images/balls/circleW.png"),
			new Image("circle.b", 		"../images/balls/circleB.png"),
			new Image("circle.g", 		"../images/balls/circleG.png"),
			new Image("circle.d", 		"../images/balls/circleD.png"),
			new Image("circle.r", 		"../images/balls/circleR.png"),
			new Image("circle.y", 		"../images/balls/circleY.png"),
		];
	}
}