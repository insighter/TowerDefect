package com.towerdefect
{
	import com.greensock.easing.*;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.filters.BevelFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.events.MouseEvent;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	/**
         * The BaseMC is a custom MovieClip with lots of features
         *
         * @author insighter
         */
	public class BaseMC extends MovieClip
	{		
		protected var sf:DropShadowFilter;
		protected var gf:GlowFilter;
		protected var bf:BevelFilter;
		protected var opaque:Number;		
		protected var rect:Rectangle; 
		protected var soundManager:SoundManager;
		protected var _mouseDownMethod:String;
		protected var xml:XML;
		protected var bitmap:Bitmap;
		private var xc:int=0;	//visual center x
		private var yc:int = 0;	//visual center y
		private var x0:int;		//initial x
		private var y0:int;		//initial y
		private var mouseSpecialEffect:Object;
		private var reactOnMouse:Boolean;
		private var _mouseAnimation:Boolean;
		private var _forceAnimation:Boolean;
		private var dispatchEvents:Boolean;
		private var animationScale:Number;
		private var animationTween:TweenMax;
		private var animationTime:Number;
		private var init:Init;
		/**
             * 
             * @param	args [optional]	An initialisation object for specifying default instance properties.
			 * -	Arguments of initialisation object that will be catched by this constructor:
			 * -	name : String = "baseMC"
			 * -	opaque : Number = 1
			 * -	showOnCreate : Boolean = true		If should appear immediately after creation
			 * -	rect : Rectangle = new Rectangle(0, 0, 0, 0)	Position and size
			 * -	soundManager : SoundManager = null	Exemplar of SoundManager class
			 * -	buttonMode : Boolean = false		Enables hand cursor on ROLL_OVER
			 * -	xml : XML = null				Reference to main xml file
			 * -	glowFilter : uint = no filter			If should use GlowFilter
			 * -	bevelFilter : uint = no filter			If should use BevelFilter
			 * -	dropShadowFilter : uint = no filter		If should use DropShadowFilter
			 * 
			 * -	reactOnMouse : Boolean = false		If should respond on mouse actions
			 * -	dispatchEvents : Boolean = false		If should dispatch CustomEvent on mouse actions. If set to TRUE, 'reactOnMouse' becomes TRUE.
			 * -	mouseAnimation:Boolean = false		If TRUE, animation loop starts on ROLL_OVER. If set to TRUE, 'reactOnMouse' becomes TRUE.
			 * -	forceAnimation:Boolean = false		Force animation process in spite of mouse position
			 * -	animationScale : Number = 1		Scale of object for use in animation loop on MouseOver
			 * -	animationTime : Number = 0.2
			 * -	mouseSpecialEffect:Boolean = false		If set to TRUE, 'reactOnMouse' become TRUE
			 * -	mouseDownMethod : String = name	Method to be called on mouseDown
			 * 
			 * -	image : BitmapData = null
			 * -	imageOpaque : Number = 1
			 * -	centerImage : Boolean = true		Whether or not center image
			 * -	fillColor : uint = 0x000000			Fill movie clip with solid color instead of using image
             */
		public function BaseMC(args:Object=null)
		{
			this.init = new Init(args);			
			this.name = init.getString("name", "baseMC");
			this.opaque = init.getNumber("opaque", 1);
			this.rect = init.getRectangle("rect", new Rectangle(0, 0, 0, 0));
   			this.x = rect.x; this.x0 = x;
			this.y = rect.y; this.y0 = y;
			this.soundManager = init.getObject("soundManager", SoundManager) as SoundManager;
			this.buttonMode = init.getBoolean("buttonMode", false);
			if (args.hasOwnProperty("glowFilter"))
				addFilter("glow", init.getColor("glowFilter", 0x000000));
			if (args.hasOwnProperty("bevelFilter"))
				addFilter("bevel", init.getColor("bevelFilter", 0x000000));
			if (args.hasOwnProperty("dropShadowFilter"))
				addFilter("shadow", init.getColor("dropShadowFilter", 0x000000));
			this.alpha = 0;			
			this._mouseDownMethod = init.getString("mouseDownMethod", this.name);
			this.xml = init.getObject("xml", XML) as XML;
			this.reactOnMouse = init.getBoolean("reactOnMouse", false);
			this.dispatchEvents = init.getBoolean("dispatchEvents", false);
			this.mouseAnimation = init.getBoolean("mouseAnimation", false);
			this.mouseSpecialEffect = init.getObject("mouseSpecialEffect");
			if (dispatchEvent || _mouseAnimation || mouseSpecialEffect!=null) reactOnMouse = true;
			this.animationScale = init.getNumber("animationScale", 1);
			this.animationTime = init.getNumber("animationTime", 0.2);
			if (reactOnMouse)
			{
				addEventListener(MouseEvent.ROLL_OVER, mouseOver, false, 0, true);
				addEventListener(MouseEvent.ROLL_OUT, mouseOut, false, 0, true);
				addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true);
			}
			if (mouseSpecialEffect != null)
				addEventListener(Event.ENTER_FRAME, enterFrame, false, 0, true);
			var image:BitmapData = init.getBitmap("image");
			var centerImage:Boolean = init.getBoolean("centerImage", true);
			if(image!=null)
			{
				bitmap=new Bitmap(image, "auto", true);
				addChild(bitmap);
				if (rect.width != 0) bitmap.width = rect.width;
				if (rect.height != 0) bitmap.height = rect.height;
				if (centerImage)
				{
					bitmap.x = -bitmap.width / 2;
					bitmap.y = -bitmap.height / 2;
					if (bitmap.width % 2 == 0) bitmap.x--;
					if (bitmap.height % 2 == 0) bitmap.y--;
				}
				bitmap.alpha = init.getNumber("imageOpaque", 1);
			}
			else if (args.hasOwnProperty("fillColor"))
			{
				graphics.beginFill(init.getColor("fillColor", 0x000000));
				this.graphics.drawRect(0, 0, rect.width, rect.height);
				graphics.endFill();
			}
			if (image == null || centerImage == false)
			{
				this.xc = this.width / 2;
				this.yc = this.height / 2;
			}
			this.forceAnimation = init.getBoolean("forceAnimation", false);
			this.visible = false;
			if (init.getBoolean("showOnCreate", true)) show();
		}
		
		public function get method():String
		{
			return _mouseDownMethod;
		}
		
		public function setOpaque(value:Number):void
		{
			opaque = value;
			show();
		}
		
		public function scale(valueX:Number, valueY:Number, time:Number = 0.3):void
		{
			TweenLite.to(this, time, { scaleX: valueX, scaleY: valueY} );
		}
		
		public function size(width:int, height:int, time:Number = 0.3):void
		{
			TweenLite.to(this, time, { width: width, height:height} );
		}
		
		public function show(time:Number=0.3):void
		{
			visible = true;
			TweenLite.to(this, time, { alpha: opaque} );
		}
		
		public function hide(time:Number = 0.3, shiftX:int = 0, shiftY:int = 0, scaleX:Number=1, scaleY:Number=1, destroy:Boolean=false):void
		{			
			if (destroy)
				TweenLite.to(this, time, {alpha: 0, x:x+shiftX, y:y+shiftY, scaleX:scaleX, scaleY:scaleY, onComplete:rem } );
			else
				TweenLite.to(this, time, {alpha: 0, x:x+shiftX, y:y+shiftY, scaleX:scaleX, scaleY:scaleY, onComplete:invis} );
		}
		
		private function invis():void
		{
			visible = false;
		}
		
		public function move(toX:int, toY:int, time:Number=0.3):void
		{
			TweenLite.to(this, time, { x: toX, y: toY, ease:Quad.easeOut} );
		}

		private function rem():void
		{
			this.parent.removeChild(this);
		}
		
		public function removeFilters():void
		{
			this.filters = [];
		}
		
		private function mouseOver(e:MouseEvent):void
		{
			if (_mouseAnimation && !_forceAnimation) animationStart();
			if(dispatchEvents)
				dispatchEvent(new CustomEvent(CustomEvent.BASEMC_MOUSE_OVER, this, true));
		}
		
		private function mouseOut(e:MouseEvent):void
		{
			if (_mouseAnimation && !_forceAnimation) animationFinish();
			if(dispatchEvents)
				dispatchEvent(new CustomEvent(CustomEvent.BASEMC_MOUSE_OUT, this, true));
		}
		
		private function mouseDown(e:MouseEvent):void
		{
			if(dispatchEvents)
				dispatchEvent(new CustomEvent(CustomEvent.BASEMC_MOUSE_DOWN, this, true));
		}
		
		private function enterFrame(e:Event):void
		{
			//When cursor shifts from center (xc) to deltaX (or lower), 
			//MovieClip shifts to shiftX (or lower, proportional)			
			var deltaX:int;
			var deltaY:int;
			if (mouseSpecialEffect.hasOwnProperty("deltaX"))
				deltaX = mouseSpecialEffect.deltaX;
			else 
				deltaX = this.width/2;
			if (mouseSpecialEffect.hasOwnProperty("deltaY"))
				deltaY = mouseSpecialEffect.deltaY;
			else 
				deltaY = this.height / 2;
			var procentX:Number = (this.mouseX - xc) / deltaX;
			var procentY:Number = (this.mouseY - yc) / deltaY;
			procentX = Utils.matchInterval(procentX, -1, 1);
			procentY = Utils.matchInterval(procentY, -1, 1);
			if(mouseSpecialEffect.hasOwnProperty("shiftX"))
				this.x = x0 - procentX * mouseSpecialEffect.shiftX;
			if(mouseSpecialEffect.hasOwnProperty("shiftY"))
				this.y = y0 - procentY * mouseSpecialEffect.shiftY;
		}
		
		public function deleteSpecialEffect():void
		{
			this.mouseSpecialEffect = null;
			removeEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		public function get forceAnimation():Boolean
		{
			return _forceAnimation;
		}
		
		public function set forceAnimation(force:Boolean):void
		{
			if (_forceAnimation == force) return;
			_forceAnimation = force;
			force ? animationStart() : animationFinish();
		}
		
		public function get mouseAnimation():Boolean
		{
			return _mouseAnimation;
		}
		
		public function set mouseAnimation(mouseA:Boolean):void
		{
			_mouseAnimation = mouseA;
		}
		
		protected function animationStart():void
		{
			animationTween=TweenMax.to(this, animationTime, {scaleX:animationScale, scaleY:animationScale, ease:BounceOut, repeat:-1, yoyo:1} );
		}
		
		private function animationFinish():void
		{
			animationTween.pause();
			TweenMax.to(this, animationTime, { scaleX:1, scaleY:1, ease:BounceOut } );
		}
		
		public function addFilter(type:String, color:uint):void
		{
			switch(type)
			{
				case "glow":
					this.gf = new GlowFilter(color, 1, 3, 3, 1, 3);
					var tmpF:Array = this.filters;
					for (var i:int = 0; i < tmpF.length; i++) 
						if (tmpF[i] is GlowFilter)
							tmpF.splice(i, 1);
					tmpF.push(gf);
					this.filters = tmpF;
					break;
				case "bevel":
					this.bf = new BevelFilter(1, 45, color, 1, color);
					tmpF = this.filters; 
					for (i = 0; i < tmpF.length; i++) 
						if (tmpF[i] is BevelFilter)
							tmpF.splice(i, 1);
					tmpF.push(bf);
					this.filters = tmpF;
					break;
				case "shadow":
					this.sf = new DropShadowFilter(10, 45, color, 1, 10, 10, 1, 3);
					tmpF = this.filters; 
					for (i = 0; i < tmpF.length; i++) 
						if (tmpF[i] is DropShadowFilter)
							tmpF.splice(i, 1);
					tmpF.push(sf);
					this.filters = tmpF;
					break;
			}
		}
	}
	
}