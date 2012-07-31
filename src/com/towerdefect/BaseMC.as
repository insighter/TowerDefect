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
		protected var _opaque:Number;		
		protected var rect:Rectangle; 
		protected var soundManager:SoundManager;
		protected var _mouseDownMethod:String;
		protected var xml:XML;
		protected var bitmap:Bitmap;
		public var images:Array;
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
		private var _dropShadowFilter:DropShadowFilter;
		private var _glowFilter:GlowFilter;
		private var _bevelFilter:BevelFilter;
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
			 * -	xmlURL : String = null			Path to XML file to read parameters from (Not implemented yet)
			 * -	glowFilter : GlowFilter = null
			 * -	bevelFilter : BevelFilter = null
			 * -	dropShadowFilter : DropShadowFilter = null
			 * 
			 * -	reactOnMouse : Boolean = false		If should respond on mouse actions
			 * -	dispatchEvents : Boolean = false		If should dispatch CustomEvent on mouse actions. If set to TRUE, 'reactOnMouse' becomes TRUE.
			 * -	mouseAnimation:Boolean = false		If TRUE, animation loop starts on ROLL_OVER. If set to TRUE, 'reactOnMouse' becomes TRUE.
			 * -	forceAnimation:Boolean = false		Force animation process in spite of mouse position
			 * -	animationScale : Number = 1		Scale of object for use in animation loop on MouseOver
			 * -	animationTime : Number = 0.2
			 * -	mouseSpecialEffect:Object		If set to TRUE, 'reactOnMouse' become TRUE
			 * -	mouseDownMethod : String = name	Method to be called on mouseDown
			 * 
			 * -	image : BitmapData = null		Image that will be placed in MovieClip
			 * -	imageOpaque : Number = 1
			 * -	centerImage : Boolean = true		Whether or not center image. If true
			 * -	fillColor : uint = 0x000000			Fill movie clip with solid color instead of using image
			 * -	images : Array		Reference to the array of all preloaded images of main class
             */
		public function BaseMC(args:Object=null)
		{
			this.init = new Init(args);
			this.images = init.getArray("images");
			this.name = init.getString("name", "baseMC");
			this._opaque = init.getNumber("opaque", 1);
			this.rect = init.getRectangle("rect", new Rectangle(0, 0, 0, 0));
   			this.x = rect.x; this.x0 = x;
			this.y = rect.y; this.y0 = y;
			this.soundManager = init.getObject("soundManager", SoundManager) as SoundManager;
			this.buttonMode = init.getBoolean("buttonMode", false);
			this.glowFilter = init.getObject("glowFilter", GlowFilter) as GlowFilter;
			this.bevelFilter = init.getObject("bevelFilter", BevelFilter) as BevelFilter;
			this.dropShadowFilter = init.getObject("dropShadowFilter", DropShadowFilter) as DropShadowFilter;
			this._mouseDownMethod = init.getString("mouseDownMethod", this.name);
			this.xml = init.getObject("xml", XML) as XML;
			this.reactOnMouse = init.getBoolean("reactOnMouse", false);
			this.dispatchEvents = init.getBoolean("dispatchEvents", false);
			this.mouseAnimation = init.getBoolean("mouseAnimation", false);
			this.mouseSpecialEffect = init.getObject("mouseSpecialEffect");
			if (mouseSpecialEffect != null)
				addEventListener(Event.ENTER_FRAME, enterFrame, false, 0, true);
			if (dispatchEvent || _mouseAnimation || mouseSpecialEffect!=null) reactOnMouse = true;
			this.animationScale = init.getNumber("animationScale", 1);
			this.animationTime = init.getNumber("animationTime", 0.2);
			if (reactOnMouse)
			{
				addEventListener(MouseEvent.ROLL_OVER, mouseOver, false, 0, true);
				addEventListener(MouseEvent.ROLL_OUT, mouseOut, false, 0, true);
				addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true);
			}			
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
			this.alpha = 0;
			if (init.getBoolean("showOnCreate", true)) show();
		}
		
		public function get method():String
		{
			return _mouseDownMethod;
		}
		
		public function get opaque():Number
		{
			return this._opaque;
		}
		
		public function set opaque(value:Number):void
		{
			_opaque = value;
			show();
		}
		
		public function scale(valueX:Number, valueY:Number, time:Number = 0.3):void
		{
			if (time == 0)
			{
				scaleX = valueX;
				scaleY = valueY;
			}
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
		
		public function hide(destroy:Boolean=false, time:Number = 0.3, shiftX:int = 0, shiftY:int = 0, scaleX:Number=1, scaleY:Number=1):void
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
		
		public function move(toX:int, toY:int, time:Number = 0.3, ease:Boolean = true ):void
		{
			if (time == 0)
			{
				x = toX;
				y = toY;
			}
			if (ease)
				TweenLite.to(this, time, { x: toX, y: toY, ease:Quad.easeOut } );
			else
				TweenLite.to(this, time, { x: toX, y: toY, ease:Linear.easeNone} );
		}
		
		public function rotate(value:int, time:Number=0.3):void
		{
			if (time == 0)
				rotation = value;
			TweenLite.to(this, time, { rotation: value, ease:Linear.easeNone} );
		}
		
		public function rotateImage(value:int, time:Number=0.3):void
		{
			if (time == 0)
				bitmap.rotation = value;
			TweenLite.to(this.bitmap, time, { rotation: value, ease:Linear.easeNone} );
		}

		private function rem():void
		{
			this.parent.removeChild(this);
		}
		
		public function removeFilters():void
		{
			this.filters = [];
		}
		
		public function removeListeners():void
		{
			removeEventListener(MouseEvent.ROLL_OVER, mouseOver);
			removeEventListener(MouseEvent.ROLL_OUT, mouseOut);
			removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
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
			if (mouseSpecialEffect.hasOwnProperty("mouseDeltaX"))
				deltaX = mouseSpecialEffect.mouseDeltaX;
			if (mouseSpecialEffect.hasOwnProperty("mouseDeltaY"))
				deltaY = mouseSpecialEffect.mouseDeltaY;
			var procentX:Number = (this.mouseX - xc) / deltaX;
			var procentY:Number = (this.mouseY - yc) / deltaY;
			procentX = Utils.matchInterval(procentX, -1, 1);
			procentY = Utils.matchInterval(procentY, -1, 1);
			if(mouseSpecialEffect.hasOwnProperty("menuDeltaX"))
				this.x = x0 - procentX * mouseSpecialEffect.menuDeltaX;
			if(mouseSpecialEffect.hasOwnProperty("menuDeltaY"))
				this.y = y0 - procentY * mouseSpecialEffect.menuDeltaY;
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
		
		public function set glowFilter(gf:GlowFilter):void
		{
			if (gf == null) return;
			var F:Array = this.filters;
			for (var i:int = 0; i < F.length; i++) 
				if (F[i] is GlowFilter)
					F.splice(i, 1);
			this._glowFilter = gf;
			F.push(_glowFilter);
			this.filters = F;
		}
		
		public function set bevelFilter(bf:BevelFilter):void
		{
			if (bf == null) return;
			var F:Array = this.filters;
			for (var i:int = 0; i < F.length; i++) 
				if (F[i] is BevelFilter)
					F.splice(i, 1);
			this._bevelFilter = bf;
			F.push(_bevelFilter);
			this.filters = F;
		}
		
		public function set dropShadowFilter(sf:DropShadowFilter):void
		{
			if (sf == null) return;
			var F:Array = this.filters;
			for (var i:int = 0; i < F.length; i++) 
				if (F[i] is DropShadowFilter)
					F.splice(i, 1);
			this._dropShadowFilter = sf;
			F.push(_dropShadowFilter);
			this.filters = F;
		}
	}
	
}