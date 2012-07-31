package com.towerdefect
{
	import com.greensock.easing.ExpoOut;
	import com.greensock.easing.Linear;
	import com.towerdefect.Projectile;
	import com.greensock.TweenMax;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.globalization.LocaleID;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author insighter
	 */
	public class TimeScale extends BaseMC
	{
		private var init:Init;
		private var arrow:BaseMC;
		private var beatTimer:Timer
		private var beatTiles:Array;
		private var tileW:int;
		private var orientation:String;
		private var arrowX0:int = 0;
		private var arrowY0:int = 0;
		private var beatShift:Number;//Shift of arrow on every beat in pixels
		private var arrowSize:int;
		private var graphObj:BaseMC;
		private var parentW:int;
		private var parentH:int;
		
		public function TimeScale(args:Object)
		{
			super(args);
			init = new Init(args);
			this.beatTimer = init.getObject("beatTimer") as Timer;
			this.tileW = init.getInt("tileW", 10);
			this.orientation = init.getString("orientation", "horizontal");
			parentW = init.getInt("parentW", 0);
			parentH = init.getInt("parentH", 0);
			this.arrowSize = init.getInt("arrowSize", 10);
			graphObj = new BaseMC( {
				rect:new Rectangle(0, 0, parentW, parentH)
			});
			addChild(graphObj);
			if (orientation == "horizontal")
			{
				beatShift = (parentW-arrowSize) / beatTimer.repeatCount;
				arrowX0 = -parentW / 2 - arrowSize / 2;
				arrowY0 = parentH / 2 + arrowSize / 2;;
			}
			else
			{
				beatShift = (parentH-arrowSize) / beatTimer.repeatCount;
				arrowX0 = -parentW / 2 - arrowSize / 2-2;
				arrowY0 = -parentH / 2 + arrowSize / 2;
			}
			arrow = new BaseMC( {
				image:Utils.getBMPByName(images, "timeArrow"),
				rect:new Rectangle( arrowX0, arrowY0, arrowSize, arrowSize)
			});
			
			trace(arrowX0 + " " + arrowY0);
			orientation != "horizontal" ? arrow.rotate(90)  : true;
			addChild(arrow);
			beatTimer.addEventListener(TimerEvent.TIMER, beatTick, false, 0, true);
			beatTiles = new Array();
			var tileX:int=0;
			var tileY:int=0;
			for (var i:int = 0; i<8; i++)
			{
				orientation == "horizontal" ? tileX = i * tileW + tileW / 2 : tileY = i * tileW + tileW / 2;
				var t:BaseMC = new BaseMC( {
					image:Utils.getBMPByName(images, "tile"),
					centerImage:true,
					rect:new Rectangle(tileX, tileY, tileW, tileW),
					opaque:0.5
				});
				addChild(t);
			}
		}
		
		private function beatTick(e:TimerEvent):void
		{
			if(orientation=="horizontal")
				TweenMax.fromTo(arrow, 25, { x:arrowX0+beatTimer.currentCount *beatShift}, { x:(arrowX0+(beatTimer.currentCount + 1)*beatShift), ease:Linear.easeNone } );
			else
				TweenMax.fromTo(arrow, 25, { y:arrowY0 + beatTimer.currentCount * beatShift }, { y:(arrowY0 + (beatTimer.currentCount + 1) * beatShift), ease:Linear.easeNone } );
			var par:BaseMC = parent as BaseMC;
			graphObj.graphics.clear();
			graphObj.graphics.lineStyle(1, 0x000000);
			graphObj.graphics.moveTo(-parentW/2, arrow.y);
			graphObj.graphics.lineTo(parentW/2, arrow.y);
			
		}
	}
}