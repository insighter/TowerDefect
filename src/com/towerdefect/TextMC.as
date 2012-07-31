package com.towerdefect
{
	import com.greensock.easing.ExpoInOut;
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.text.Font;
	import flash.text.FontStyle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.AntiAliasType;
	import flash.utils.Timer;
	/**
         * TextLineMC = BaseMC + TextField. 
		 * Provides animation effect when text changes for single-line exemplars
		 * Provides 'typing text' effect for multi-line exemplars
		 * 
         * @author insighter
         */
	public class TextMC extends BaseMC
	{
		private var textField:TextField;
		private var typingEffect:Boolean;
		private var _changeValueEffect:Boolean;
		private var typingTimer:Timer = new Timer(30, 0);
		private var bufTXT:Array = new Array();
		private var readyTXT:String = "";
		private var tf:TextFormat;
		private var oldText:String;
		private var init:Init;
		private var holder:BaseMC;
		private var segoeFont:Font;
		/**
             * 
             * @param	args [optional]	An initialisation object for specifying default instance properties.
			 * -	Arguments of initialisation object that will be catched by this constructor:
			 * -	multiLine : Boolean = false
			 * -	typingEffect : Boolean = false
			 * -	changeValueEffect : Boolean = false
			 * -	fontLeading : int = -5
			 * -	fontName : Class = null
			 * -	fontSize : int = 12
			 * -	fontAlign : String = "center"
			 * -	fontColor : uint = 0xFF0000
			 * -	text : String = ""		The text to show upon create
             */
		public function TextMC(args:Object=null)
		{
			super(args);
			this.init = new Init(args);
			mouseChildren = false;
			tf = new TextFormat();
			var fontObj:Object = init.getObject("fontName");
			if (fontObj == null) fontObj = new mySegoePrint();
			tf.font = fontObj.fontName;
			tf.size = init.getInt("fontSize", 12);
			tf.leading = init.getInt("fontLeading", -5);
			_changeValueEffect = init.getBoolean("changeValueEffect", true);
			typingEffect = init.getBoolean("typingEffect", false);
			textField = new TextField();
			textField.textColor = init.getColor("fontColor", uint(0xFFFFFF));
			textField.selectable = false;
			textField.autoSize = init.getString("textFieldAutoSize", TextFieldAutoSize.CENTER);
			if (init.getBoolean("multiLine", false))
			{
				textField.multiline = true;
				textField.wordWrap = true;
				textField.width = rect.width;
				textField.height = rect.height;
				_changeValueEffect = false;
			}
			textField.embedFonts = false;
			textField.defaultTextFormat = tf;
			textField.htmlText = Utils.toHTML(init.getString("text", ""));
			readyTXT = "<font size='"+tf.size+"' color='"+textField.textColor+"'>";
			textField.antiAliasType = AntiAliasType.ADVANCED;
			addChild(textField);
			typingTimer.addEventListener(TimerEvent.TIMER, typingTick);
		}
		
		public function clear():void
		{
			typingTimer.stop();
			readyTXT = "<font size='" + tf.size + "' color='" + textField.textColor + "'>";
			bufTXT = new Array();
			textField.htmlText="<font size='" + tf.size + "' color='" + textField.textColor + "'>";
		}
		
		public function setText(text:String):void
		{
			if (typingEffect)
				addText(text);
			else
			{
				if (oldText!=text && _changeValueEffect)
					changeValueEffect();
				textField.htmlText = Utils.toHTML(text);
				oldText = text;
			}
		}
		
		public function addText(text:String):void
		{
			bufTXT = bufTXT.concat(text.split(""));
			if(!typingTimer.running)
				typingTimer.start();
		}
		
		private function typingTick(event:TimerEvent):void
		{
			typingTimer.delay = 50;
			if(bufTXT[0]=='<')
			{
				bufTXT.shift();
				switch (bufTXT[0])
				{
					case 'y':readyTXT +=  "<font color='" + Utils.clrSYellow +	"'>"; break;
					case 'r':readyTXT +=  "<font color='" + Utils.clrSBRed + 	"'>"; break;
					case 'b':readyTXT +=  "<font color='" + Utils.clrSBBlue + 	"'>"; break;
					case 'g':readyTXT +=  "<font color='" + Utils.clrSBGreen + 	"'>"; break;
					case 'd':readyTXT +=  "<font color='" + Utils.clrSBlack + 	"'>"; break;
					case 'w':readyTXT +=  "<font color='" + Utils.clrSWhite + 	"'>"; break;
					default:readyTXT +=  "<"+bufTXT[0]; break;
				}
			}
			else if (bufTXT[0] == '{')
			{
				readyTXT +=  "<font size='" + bufTXT[1] + bufTXT[2] + bufTXT[3] + "'>";
				bufTXT.splice(0, 3);
			}
			else if(bufTXT[0]=='~')
			{
				typingTimer.delay=parseInt(bufTXT[1])*1000;
				bufTXT.splice(0, 1);
			}
			else switch (bufTXT[0])
			{												
				case '>' :	readyTXT +=  "</font>";	break;
				case '}' :	readyTXT +=  "</font>";	break;
				case '^' :	readyTXT +=  "<br>";	break;
				default :	readyTXT +=  bufTXT[0];	textField.htmlText = readyTXT; break;
			}
			bufTXT.shift();
			if(bufTXT.length==0)
				typingTimer.stop();				
			/*if (textArea.maxVerticalScrollPosition > 1 && scrollBar!=null && scrollBar.alpha == 0)
			{
				scrollBox.show();
				scrollBar.show();
				scrollUp.show();
				scrollDown.show();
			}
			if(textArea.verticalScrollPosition=textArea.maxVerticalScrollPosition-1)
				scroll();*/
		}
		
		private function changeValueEffect():void
		{
			//The sound named 'changeTextValueSound' should has been already added to the soundManager instance
			//in the parent class using addExternalSound(s.path, s.name) function
			if (soundManager!=null)
				soundManager.playSound("changeTextValueSound", 1);
			TweenMax.killTweensOf(this);
			TweenMax.to(this, 0.1, { scaleX:1, scaleY:1.2+Utils.RandF(0.5), ease:ExpoInOut , repeat:1, yoyo:true } );
			TweenMax.to(this, 0.03, { y:y-2, ease:Linear.easeNone , repeat:11, yoyo:true} );
		}
	}
}