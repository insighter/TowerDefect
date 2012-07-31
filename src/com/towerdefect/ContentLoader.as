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
         *
         * @author insighter
         */
	public class ContentLoader extends BaseMC
	{
		private var loader:Array=new Array();
		private var timer:Timer=new Timer(50, 10000);
		private var bytesTotal:Array=new Array();
		private var bytesLoaded:Array = new Array();	
		private var loadedTMC:TextMC;
		private var remainTMC:TextMC;
		private var progressTMC:TextMC;
		private var progressBar:BaseMC;
		private var emptyBar:BaseMC;
		private var init:Init;
		/**
             * 
             * @param	args [optional]	An initialisation object for specifying default instance properties.
			 * -	images : Array = []	Array of 'Image' class instances.
			 * -				At this moment each of those instances has two non-zero variables: 'name' and 'path'
			 * -				and the variable image:BitmapData=null. Once image file is loaded using 'path' variable, 
			 * -				image:BitmapData variable will be updated with loaded BitmapData.
			 * -	textColor : uint = 0xFFFFFF	The color to be passed to the text fields
			 * -	
             */
		public function ContentLoader(args:Object=null)
		{
			super(args);
			init = new Init(args);
			var textColor:uint = init.getColor("textColor", 0xFFFFFF);
			timer.addEventListener(TimerEvent.TIMER, tick);
			timer.reset();
			timer.start();						
			loadedTMC = new TextMC( { rect:new Rectangle(-50, 0, 0, 0), fontColor:textColor} );
			remainTMC = new TextMC( { rect:new Rectangle(-50, 30, 0, 0), fontColor:textColor} );
			progressTMC = new TextMC( { rect:new Rectangle(-50, 60, 0, 0), fontColor:textColor} );
			addChild(loadedTMC);
			addChild(remainTMC);
			addChild(progressTMC);
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
			
			for each(var c:Image in images)
				if(c.image==null)
					return;
			timer.stop();
			this.hide(true, 0.3, 0, 0, 0, 0);
			dispatchEvent(new CustomEvent(CustomEvent.CONTENT_LOADED, this.name, true));
		}			
	}	
}