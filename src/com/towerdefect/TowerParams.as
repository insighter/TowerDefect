package com.towerdefect
{
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author insighter
	 */
	public class TowerParams
	{
		public var radius:Number;
		public var cost:Number;
		public var damage:Number;
		public var reload:Number;
		public var sample:String;
		public var title:String;
		public var text:String;
		public var type:String;
		public var className:Class;
		private var init:Init;
		
		public function TowerParams(args:Object):void
		{
			init = new Init(args);
			radius = init.getNumber("radius", 0);
			cost = init.getNumber("cost", 0);
			damage = init.getNumber("damage", 0);
			reload = init.getNumber("reload", 1);
			sample = init.getString("sample", "");
			title = init.getString("title", "");
			text = init.getString("text", "");
			type = init.getString("type", "");
			className = getDefinitionByName(init.getString("className", "")) as Class;
		}

		public function getInfo():String
		{
			return text+"^<gСтоимость:> " + cost + "^<gРадиус поражения:> " + radius +"^<gПерезарядка:> " + reload + "^<gУрон:> " + damage + "^<gЗвук:> " + sample;
		}
		
	}
}