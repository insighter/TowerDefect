package com.towerdefect
{
	import flash.display.BitmapData;
	public class Image
	{
		public var name:String = "";
		public var path:String = "";
		public var image:BitmapData;
		public function Image(name:String, path:String, image:BitmapData = null)
		{
			this.name = name;
			this.path = path;
			this.image = image;
		}
	}
	
}