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
		
		public static var clrSBlack:String = "#111111";
		public static var clrSBBlue:String = "#6666DD";
		public static var clrSBRed:String = "#AA4444";
		/**
         * Returns value if value is in interval, otherwise returns min if value < min or max if value > max
         */
		public static function matchInterval(value:Number, min:Number, max:Number):Number
		{
			if (value < min) return min;
			if (value > max) return max;
			return value;
		}
		
		public static function imgSmooth(e:Event):void
		{
			(e.target.content as Bitmap).smoothing=true;
		}
		
		public static function imgCenter(e:Event):void
		{									
			e.target.loader.x=-e.target.loader.width/2;
			e.target.loader.y=-e.target.loader.height/2;
		}
		
		public static function imgToIcon(e:Event):void
		{									
			e.target.loader.width=20;
			e.target.loader.height=20;
		}
		
		public static function imgStretH(e:Event):void
		{												
			e.target.loader.height*=2;
		}
		
		public static function imgStretW(e:Event):void
		{												
			e.target.loader.width*=2;
		}
		
		public static function to3Char(n:int):String
		{
			var str:String = n.toString();
			if(str.length<2)str="0"+str;
			if(str.length<3)str="0"+str;			
			return str;
		}
		
		public static function moduleDec(n:Number, val:Number):Number
		{
			var minus:Boolean = false;
			if (n < 0) 
			{
				minus = true;
				n = -n;
			}
			n -= Math.abs(val);
			if (minus) n = -n;
			return n;
		}
		
		public static function moduleInc(n:Number, val:Number):Number
		{
			var minus:Boolean = false;
			if (n < 0) 
			{
				minus = true;
				n = -n;
			}
			n += Math.abs(val);
			if (minus) n = -n;
			return n;
		}
		
		public static function rndSign():Number
		{
			var rnd:int = Rand(2);
			if (rnd == 0) return -1;
			else return 1;
		}
		
		public static function convertToBoolean(txt:String):Boolean
		{
			return(txt=="true");
		}
		
		public static function randElement(ar:Array):*
		{
			return ar[Rand(ar.length)];
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
						case 'd':TXT +=  "<font color='" + clrSBlack + 	"'>";break;
					}				
				}
				else if (arr[0] == '{')
				{
					arr.shift();
					switch (arr[0])
					{
						case '0':TXT +=  "<font size='10'>"; break;
						case '1':TXT +=  "<font size='12'>";break;
						case '2':TXT +=  "<font size='15'>";break;
						case '3':TXT +=  "<font size='25'>"; break;
						case '4':TXT +=  "<font size='50'>"; break;
						case '5':TXT +=  "<font size='100'>"; break;
						case '6':TXT +=  "<font size='150'>";break;
					}				
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
		
		public static function RandF(n:int):Number
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