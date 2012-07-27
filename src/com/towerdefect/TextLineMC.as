package com.towerdefect
{
	import com.greensock.easing.ExpoInOut;
	import com.greensock.TweenLite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.text.Font;
	import flash.text.FontStyle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.AntiAliasType;
	/**
         * TextLineMC = BaseMC + TextField. Provides animation effect when text changes
         * *This TextField is single-line only
		 * 
         * @author insighter
         */
	public class TextLineMC extends BaseMC
	{
		private var textField:TextField;
		private var tf:TextFormat;
		private var oldText:String;
		private var init:Init;
		private var holder:BaseMC;
		private var segoeFont:Font;
				
		/**
             * 
             * @param	args [optional]	An initialisation object for specifying default instance properties.
			 * -	Arguments of initialisation object that will be catched by this constructor:
			 * -	fontLeading : int = -5
			 * -	fontName : Class = null
			 * -	fontSize : int = 12
			 * -	fontAlign : String = "center"
			 * -	fontColor : uint = 0xFF0000
			 * -	text : String = "No text"		The text to show upon create
             */
		public function TextLineMC(args:Object=null)
		{
			this.init = new Init(args);
			mouseChildren = false;
			tf = new TextFormat();
			var fontObj:Object = init.getObject("fontName");
			if (fontObj == null) fontObj = new mySegoePrint();
			tf.font = fontObj.fontName;
			tf.size = init.getInt("fontSize", 12);
			textField = new TextField();
			textField.textColor = init.getColor("fontColor", uint(0xFFFFFF));
			textField.selectable = false;
			textField.autoSize = init.getString("textFieldAutoSize", TextFieldAutoSize.CENTER);
			textField.multiline = false;
			textField.embedFonts = false;
			textField.defaultTextFormat = tf;
			textField.htmlText = Utils.toHTML(init.getString("text", "No text"));
			textField.antiAliasType = AntiAliasType.ADVANCED;
			addChild(textField);
			super(args);
		}
		
		public function setText(text:String):void
		{			
			if (oldText!=text)
				changeValueEffects();
			textField.htmlText = "<font color='" + textField.textColor + "'>"+Utils.toHTML(text);
			oldText = text;
		}
		
		private function changeValueEffects():void
		{
			//The sound named 'changeTextValueSound' should has been already added to the soundManager instance
			//in the parent class using addExternalSound(s.path, s.name) function
			if (soundManager!=null)
				soundManager.playSound("changeTextValueSound", 1);
			TweenLite.to(this, 0.1, { scaleX:1, scaleY:1.2 + Utils.RandF(5) / 10, ease:ExpoInOut } );
			//TweenLite.to(this, 0.1, { scaleX:1, scaleY:1, ease:ExpoInOut, delay:0.1} );		
		}
	}
}