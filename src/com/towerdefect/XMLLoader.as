package com.towerdefect
{
    import flash.events.*;
    import flash.net.*;

    public class XMLLoader extends EventDispatcher
    {
        private var urlRequest:URLRequest;
        private var urlLoader:URLLoader;
        private var xmlUrl:String;
        private var _xml:XML;

        public function XMLLoader(url:String)
        {
            xmlUrl = url;
        }

        public function load():void
        {
            urlRequest = new URLRequest(xmlUrl);            
            urlLoader = new URLLoader(urlRequest);
            urlLoader.addEventListener(Event.COMPLETE, loaded, false, 0, true);
        }

        private function loaded(e:Event):void
        {
            _xml = new XML(e.target.data);
            dispatchEvent(new CustomEvent(CustomEvent.XML_LOADED, xmlUrl, true));
        }
				
		public function get xml():XML
        {
            return _xml;
        }
    }
}
