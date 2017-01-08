package com.fewfre.utils
{
	import flash.utils.Dictionary;
	
	public class I18n
	{
		// Storage
		private var _data			: Dictionary;
		private var _defaultFont	: String = "Veranda";
		private var _defaultScale	: Number = 1;
		
		// Properties
		public function get defaultFont() : String { return _defaultFont; }
		public function get defaultScale() : Number { return _defaultScale; }
		
		// Constructor
		public function I18n() {
			_data = new Dictionary();
			// Allows clearing of text by passing an empty string.
			_data[""] = { text:"" };
			// Loading text that's needed before translation text is retrieved.
			_data["loading"] = { text:"Items left to load: {0}" };
			_data["loading_finished"] = { text:"Loading complete. Initializing..." };
			_data["loading_progress"] = { text:"{0}" };
		}
		
		public function parseFile(pJson:Object) : void {
			_defaultFont = pJson.defaultFont;
			_defaultScale = pJson.defaultScale;
			for(var key:String in pJson.strings) {
				/*_data[key] = new I18nData(pJson[key]);*/
				_data[key] = pJson.strings[key];
			}
		}
		
		public function getData(pKey:String) : Object {
			if(_data[pKey] != null) {
				return _data[pKey];
			} else {
				trace("[I18n](getData) No key '"+pKey+"' exists.");
				return null;
			}
		}
		
		public function getText(pKey:String) : String {
			if(_data[pKey] != null) {
				return _data[pKey].text;
			} else {
				trace("[I18n](getText) No key '"+pKey+"' exists.");
				return null;
			}
		}
	}
}
