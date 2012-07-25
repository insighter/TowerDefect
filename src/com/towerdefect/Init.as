package com.towerdefect
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
    public class Init
    {
		private var init:Object;
		
        public function Init(init:Object)
        {
            this.init = init;
        }

        public function getInt(name:String, def:int, bounds:Object = null):int
        {
             if (init == null || !init.hasOwnProperty(name))
                return def;
            var result:int = init[name];
            if (bounds != null)
            {
                if (bounds.hasOwnProperty("min"))
                {
                    var min:int = bounds["min"];
                    if (result < min)
                        result = min;
                }
                if (bounds.hasOwnProperty("max"))
                {
                    var max:int = bounds["max"];
                    if (result > max)
                        result = max;
                }
            }
            delete init[name];
            return result;
        }

        public function getNumber(name:String, def:Number, bounds:Object = null):Number
        {
             if (init == null || !init.hasOwnProperty(name))
                return def;
            var result:Number = init[name];
            if (bounds != null)
            {
                if (bounds.hasOwnProperty("min"))
                {
                    var min:Number = bounds["min"];
                    if (result < min)
                        result = min;
                }
                if (bounds.hasOwnProperty("max"))
                {
                    var max:Number = bounds["max"];
                    if (result > max)
                        result = max;
                }
            }
            delete init[name];
            return result;
        }

        public function getString(name:String, def:String):String
        {
            if (init == null || !init.hasOwnProperty(name))
                return def;
            var result:String = init[name];
            delete init[name];
            return result;
        }

        public function getBoolean(name:String, def:Boolean):Boolean
        {
           if (init == null || !init.hasOwnProperty(name))
                return def;
            var result:Boolean = init[name];
            delete init[name];
            return result;
        }

        public function getObject(name:String, type:Class = null):Object
        {
           if (init == null || !init.hasOwnProperty(name))
                return null;
            var result:Object = init[name];
            delete init[name];
            if (result == null)
                return null;
            if (type != null)
                if (!(result is type))
                    return null;
            return result;
        }

        public function getArray(name:String):Array
        {
            if (init == null || !init.hasOwnProperty(name))
                return [];
            var result:Array = init[name];
            delete init[name];
            return result;
        }
		
        public function getColor(name:String, def:uint):uint
        {
            if (init == null || !init.hasOwnProperty(name))
                return def;
            var result:uint = init[name];
            delete init[name];
            return result;
        }

        public function getBitmap(name:String):BitmapData
        {
            if (init == null || !init.hasOwnProperty(name))
                return null;
            var result:BitmapData = init[name];
            delete init[name];
            return result;
        }
		
		public function getRectangle(name:String, def:Rectangle):Rectangle
		{
			if (init == null || !init.hasOwnProperty(name))
                return def;
            var result:Rectangle = init[name];
            delete init[name];
            return result;
		}
    }
}
