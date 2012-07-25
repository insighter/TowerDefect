package com.towerdefect
{
	public class MenuParams
	{
		public var direction:String;
		public var buttonSpacing:int;
		public var textTopOffset:int;
		public var textBottomOffset:int;
		public var itemAlpha:Number;
		public var curItemAlpha:Number;
		public var currentItem:TextLineMC;
		public var fontSize:int;
		public var fontColor:uint;
		public var glowColor:uint;
		public var glowAlpha:Number;
		public var glowBlurX:int;
		public var glowBlurY:int;
		public var glowStrength:int;
		public var animationTime:Number;
		private var init:Init;
		
		public function MenuParams(args:Object)
		{
			this.init = new Init(args);
			this.direction = init.getString("direction", "vertical");
			this.buttonSpacing = init.getInt("buttonSpacing", 0);
			this.textTopOffset = init.getInt("textTopOffset", 0);
			this.textBottomOffset = init.getInt("textBottomOffset", 0);
			this.itemAlpha = init.getNumber("itemAlpha", 1);
			this.curItemAlpha = init.getNumber("curItemAlpha", 1);			
			this.fontSize = init.getInt("fontSize", 12);
			this.fontColor = init.getColor("fontColor", 0xFFFFFF);
			this.glowColor = init.getColor("glowColor", 0xFFFFFF);
			this.glowAlpha = init.getNumber("glowAlpha", 1);
			this.glowBlurX = init.getInt("glowBlurX", 5);
			this.glowBlurY = init.getInt("glowBlurY", 5);
			this.glowStrength = init.getInt("glowStrength", 1);
			this.animationTime = init.getNumber("animationTime", 1);
		}
	}
	
}