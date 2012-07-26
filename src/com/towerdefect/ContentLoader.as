package  com.towerdefect{		
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	/**
         * ContentLoader loads 
		 * using predefined border filters
         *
         * @author insighter
         */
	public class ContentLoader extends BaseMC
	{
		private var loader:Array=new Array();
		private var timer:Timer=new Timer(50, 10000);
		private var bytesTotal:Array=new Array();
		private var bytesLoaded:Array = new Array();	
		private var images:Array;
		private var loadedTMC:TextLineMC;
		private var remainTMC:TextLineMC;
		private var imagesTMC:TextLineMC;
		private var progressTMC:TextLineMC;
		private var progressBar:ImageMC;
		private var emptyBar:ImageMC;
		private var init:Init;
		/**
             * 
             * @param	args [optional]	An initialisation object for specifying default instance properties.
			 * -	Arguments of initialisation object that will be catched by this constructor:
			 * -	source : Array = []		Array of 'Image' class instances.
			 * -				At this moment each instance of Image class in this array should have two variables:
			 * -				name:String and path:String, where path is valid path to image file.
			 * -				Once image file is loaded using path variable, image variable 
			 * -				(the third variable of Image class instance) will be updated with loaded BitmapData.
			 * -	textColor : uint = 0xFFFFFF	The color to be passed to the text fields
			 * -	progressBarImage : BitmapData = null
			 * -	emptyBarImage : BitmapData = null
			 * -	
             */
		public function ContentLoader(args:Object=null)
		{
			super(args);
			init = new Init(args);
			images = init.getArray("source");
			var progressBarImage:BitmapData = init.getBitmap("progressBarImage");
			var emptyBarImage:BitmapData = init.getBitmap("emptyBarImage");
			var textColor:uint = init.getColor("textColor", 0xFFFFFF);
			timer.addEventListener(TimerEvent.TIMER, tick);
			timer.reset();
			timer.start();						
			loadedTMC = new TextLineMC( { rect:new Rectangle(-50, 0, 0, 0), fontColor:textColor} );
			remainTMC = new TextLineMC( { rect:new Rectangle(-50, 30, 0, 0), fontColor:textColor} );
			imagesTMC = new TextLineMC( { rect:new Rectangle(-50, -30, 0, 0), fontColor:textColor} );
			progressTMC = new TextLineMC( { rect:new Rectangle(-50, 60, 0, 0), fontColor:textColor} );
			addChild(loadedTMC);
			addChild(remainTMC);
			//addChild(imagesTMC);
			addChild(progressTMC);
			emptyBar = new ImageMC( {
				image:emptyBarImage,
				rect:new Rectangle(0, 100, 0, 0)
			});
			addChild(emptyBar);
			progressBar = new ImageMC( {
				image:progressBarImage,
				rect:new Rectangle(0, 100, 0, 0)
			});
			addChild(progressBar);
			
			load();
		}		
		
		private function load():void
		{
			var i:int = 0;
			for each(var c:Image in images)
			{				
				loader[i] = new Loader();
				loader[i].name="image."+i.toString();
				loader[i].load(new URLRequest(c.path));
				loader[i].contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);
				loader[i++].contentLoaderInfo.addEventListener(Event.COMPLETE, loaded);
			}
		}
		
		private function progress(e:ProgressEvent):void
		{
			var s:String=e.target.loader.name;
			bytesTotal[int(s.substr(s.indexOf('.')+1))]=e.bytesTotal-e.bytesLoaded;
			bytesLoaded[int(s.substr(s.indexOf('.')+1))]=e.bytesLoaded;			
		}
		
		private function loaded(e:Event):void
		{					
			(e.target.content as Bitmap).smoothing=true;
			var s:String = e.target.loader.name;
			var c:Image = images[int(s.substr(s.indexOf('.') + 1))];
			c.image = Bitmap(e.target.loader.content).bitmapData;//updating image variable of Image class instance
		}
				
		private function tick(e:Event):void
		{
			//Visualization of loading progress
			var progress:int=0;
			var loaded:int=0;
			var toLoad:int=0;
			for(var i:int=0;i<images.length;i++)
			{
				loaded+=bytesLoaded[i];
				toLoad+=bytesTotal[i];
			}
			progress=int(loaded*100/(loaded+toLoad));
			loadedTMC.setText("Загружено: " + (int(loaded / 1000)).toString() + " кб");
			remainTMC.setText("Осталось: " + (int(toLoad / 1000)).toString() + " кб");
			progressTMC.setText(progress.toString() + "%");
			imagesTMC.setText("Файлов: " + images.length.toString());
			
			for each(var c:Image in images)
				if(c.image==null)
					return;
			timer.stop();
			this.hide(0.3, 0, 0, 0, 0, true);
			dispatchEvent(new CustomEvent(CustomEvent.CONTENT_LOADED, this.name, true));
		}			
	}	
}