package com.towerdefect
{	
	public class SoundC
	{
		public var name:String;
		public var path:String;
		public var defaultVolume:Number;
		
		public function SoundC(name:String, path:String, defaultVolume:Number=1)
		{
			this.name = name;
			this.path = path;
			this.defaultVolume = defaultVolume;
		}			
	}
	
}