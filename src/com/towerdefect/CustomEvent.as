package com.towerdefect
{
	import flash.events.Event;
	/**The CustomEvent class is for storing custom events. Surprisingly...
	 * ...
	 * @author insighter
	 */
	public class CustomEvent extends Event
	{
		public var args:*;
		public static const CUSTOM:String = "custom";
		public static const CHAT_ENTER:String = "chat_enter";
		public static const MENU:String = "menu";
		public static const CONTENT_LOADED:String = "CONTENT_LOADED";
		public static const CARDS_LOADED:String = "CARDS_LOADED";
		public static const ACTION:String = "action";
		public static const CARD_DOUBLECLICK:String = "card_doubleClick";
		public static const XML_LOADED:String = "xml_loaded";
		public static const CARD_MOUSE_UP:String = "mouse_up";
		public static const CARD_MOUSE_DOWN:String = "mouse_down";
		public static const CARD_MOUSE_OVER:String = "mouse_over_card";
		public static const CARD_CHOOSED:String = "card_choosed";
		public static const SFS_LOGIN:String = "SFS_LOGIN";
		public static const GAME_START:String = "GAME_START";		
		
		public static const BASEMC_MOUSE_DOWN:String = "BASEMC_MOUSE_DOWN";
		public static const BASEMC_MOUSE_OUT:String = "BASEMC_MOUSE_OUT";
		public static const BASEMC_MOUSE_OVER:String = "BASEMC_MOUSE_OVER";
		
		public function CustomEvent(type:String, args:*= null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.args = args;
		}
	}
	
}