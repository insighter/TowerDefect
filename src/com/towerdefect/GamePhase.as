package com.towerdefect
{
	/**
	 * ...
	 * @author insighter
	 */
	public class GamePhase
	{
		private var _constructionMode:Boolean;
		private var _mainPhase:String;
		public function GamePhase()
		{
			this._constructionMode = false;
		}
		
		public function get constructionMode():Boolean
		{
			return _constructionMode;
		}
		public function set constructionMode(on:Boolean):void
		{
			this._constructionMode = on;
		}
		
		public function get mainPhase():String
		{
			return this._mainPhase;
		}
		public function set mainPhase(phase:String):void
		{
			this._mainPhase = phase;
		}
	}
}