package com.towerdefect
{
	import com.greensock.easing.BounceOut;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	/**
         * ImageMC = BaseMC + Image (BitmapData, passed in <image> parameter). Provides basic loop animation on mouse ROLL_OVER
         *
         * @author insighter
         * @version 1.0
         */
	public class ImageMC extends BaseMC
	{
		private var init:Init;
		
		/**
             * 
             * @param	args [optional]	An initialisation object for specifying default instance properties.
			 * -	Arguments of initialisation object that will be catched by this constructor:
			 * -	image : BitmapData = null
			 * -	imageOpaque : Number = 1
			 * -	animation : Boolean = false
			 * -	centerImage : Boolean = true	Whether or not center image
             */
		public function ImageMC(args:Object=null)
		{
			super(args);
			this.init = new Init(args);
			var image:BitmapData = init.getBitmap("image");
			if(image!=null)
			{
				var u:Bitmap=new Bitmap(image, "auto", true);
				addChild(u);
				if (rect.width != 0) u.width = rect.width;
				if (rect.height != 0) u.height = rect.height;
				if (init.getBoolean("centerImage", true))
				{
					u.x = -u.width / 2;
					u.y = -u.height / 2;
				}
				u.alpha = init.getNumber("imageOpaque", 1);
			}
			if (init.getBoolean("animation", false))
			{
				addEventListener(MouseEvent.MOUSE_OVER, tweenLoop);
				addEventListener(MouseEvent.MOUSE_OUT, tweenOff);
			}
		}
		
		private function tweenLoop(e:MouseEvent = null):void
		{					
			var sx:Number = 1;
			var sy:Number = 1;
			if(scaleX==1)
			{
				sx=1.2;
				sy=1.2;
			}
			TweenMax.to(this, 0.2, {scaleX:sx, scaleY:sy, ease:BounceOut, onComplete:tweenLoop, repeat:-1, yoyo:1} );
		}
		
		private function tweenOff(event:MouseEvent):void
		{
			/*scaleTWX.removeEventListener(TweenEvent.MOTION_FINISH, tweenLoop);
			scaleTWX = new Tween(this, "scaleX", None.easeNone, scaleX, 1, 0.2, true);
			scaleTWY = new Tween(this, "scaleY", None.easeNone, scaleY, 1, 0.2, true);	*/			
		}
	}
}