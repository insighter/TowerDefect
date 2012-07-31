package com.towerdefect
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.display.BitmapData;
	public class Utils
	{		
		public static var clrSBMain:String="#CB9121";
		public static var clrBMain:uint = 0xCB9121;		
		
		public static var clrBRed:uint = 0xAA4444;
		public static var clrSBGreen:String = "#228822";
		public static var clrBGreen:uint=0x228822;
		
		public static var clrBBlue:uint=0x6666DD;
		public static var clrSBPenalty:String ="#776666";
		public static var clrSMain:String="#000000";
		public static var clrMain:uint = 0x000000;
		public static var clrSRed:String = "#220000";
		public static var clrRed:uint = 0x220000;
		public static var clrSGreen:String = "#002200";
		public static var clrGreen:uint=0x002200;
		public static var clrSBlue:String = "#000022";
		public static var clrBlue:uint=0x000022;
		public static var clrSYellow:String = "#CB9121";
		public static var clrYellow:uint=0xCB9121;
		public static var clrSPenalty:String = "#776666";
		public static var clrSWhite:String = "#666666";
		public static var clrSBlack:String = "#111111";
		public static var clrSBBlue:String = "#6666DD";
		public static var clrSBRed:String = "#993333";
		/**
         * Returns value if value is in interval, otherwise returns min if value < min or max if value > max
         */
		public static function matchInterval(value:Number, min:Number, max:Number):Number
		{
			if (value < min) return min;
			if (value > max) return max;
			return value;
		}
		
		public static function convertToBoolean(txt:String):Boolean
		{
			return(txt=="true");
		}
		
		public static function randElement(ar:Array):*
		{
			return ar[Rand(ar.length)];
		}
		
		public static function setIfNaN(value:Number):Number
		{
			if (isNaN(value)) return 0;
			return value;
		}
		
		public static function toHTML(str:String):String
		{
			var TXT:String="";
			var arr:Array = str.split("");
			do
			{
				if (arr[0] == '<')
				{
					arr.shift();
					switch (arr[0])
					{
						case 'y':TXT +=  "<font color='" + clrSYellow +	"'>"; break;
						case 'r':TXT +=  "<font color='" + clrSBRed + 		"'>";break;
						case 'b':TXT +=  "<font color='" + clrSBBlue + 		"'>";break;
						case 'g':TXT +=  "<font color='" + clrSBGreen + 	"'>"; break;
						case 'd':TXT +=  "<font color='" + clrSBlack + 	"'>"; break;
						case 'w':TXT +=  "<font color='" + clrSWhite + 	"'>";break;
					}				
				}
				else if (arr[0] == '{')
				{
					TXT +=  "<font size='" + arr[1] + arr[2] + arr[3] + "'>";
					arr.splice(0, 3);
				}
				else switch (arr[0])
				{												
					case '>' :	TXT +=  "</font>";	break;
					case '}' :	TXT +=  "</font>";	break;
					case '^' :	TXT +=  "<br>";		break;
					default :	TXT +=  arr[0]; 	break;
				}
				arr.shift();
			}
			while (arr.length>0);
			return TXT;
		}									
		
		public static function getTime(seconds:Boolean):String
		{
			var time:Date = new Date();
			var s:String = time.getSeconds().toString();
			var m:String = time.getMinutes().toString();
			var h:String = time.getHours().toString();
			if (m.length == 1)			
				m = "0" + m;			
			if (s.length == 1)			
				s = "0" + s;
			var t:String = h + ":" + m;
			if (seconds) t += s;
			t += "   ";
			return t;
		}
		
		public static function Rand(n:int):int
		{
			return (int)(n*Math.random());
		}
		
		public static function RandF(n:Number):Number
		{
			return (n*Math.random());
		}
		
		public static function getBMPByName(bmps:Array, name:String):BitmapData
		{
			for each(var c:Image in bmps)
				if (c.name.indexOf(name)!=-1)
					return c.image;
			return null;
		}
		
		public static function getAllBMPByName(bmps:Array, name:String):Array
		{
			var ar:Array = new Array();
			for each(var c:Image in bmps)
			{
				if (c.name.indexOf(name)!=-1)
					ar.push(c.image);
			}
			return ar;
		}		
		
		public static function getImageByName(bmps:Array, name:String):Image
		{
			for each(var c:Image in bmps)
				if (c.name.indexOf(name)!=-1)
					return c;
			return null;
		}
		
		public static function getAllImagesByName(bmps:Array, name:String):Array
		{
			var ar:Array = new Array();
			for each(var c:Image in bmps)
				if (c.name.indexOf(name)!=-1)
					ar.push(c);
			return ar;
		}					
	}
}