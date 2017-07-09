package com.fewfre.utils
{
	import com.fewfre.events.*;
	import flash.utils.Dictionary;
	
	public class I18n
	{
		// Storage
		private var _data			: Dictionary;
		private var _defaultFont	: String = "Veranda";
		private var _defaultScale	: Number = 1;
		private var _lang			: String;
		
		// Properties
		public function get defaultFont() : String { return _defaultFont; }
		public function get defaultScale() : Number { return _defaultScale; }
		public function get lang() : String { return _lang; }
		
		// Constants
		public static const FILE_UPDATED : String = "i18n_file_updated";
		
		// Constructor
		public function I18n() {
			_lang = "en";
			_data = new Dictionary();
			// Allows clearing of text by passing an empty string.
			_data[""] = { text:"" };
			// Loading text that's needed before translation text is retrieved.
			_data["loading"] = { text:"Items left to load: {0}" };
			_data["loading_finished"] = { text:"Loading complete. Initializing..." };
			_data["loading_progress"] = { text:"{0}" };
		}
		
		public function parseFile(pLang:String, pJson:Object) : void {
			_lang = pLang;
			_defaultFont = pJson.defaultFont;
			_defaultScale = pJson.defaultScale;
			for(var key:String in pJson.strings) {
				/*_data[key] = new I18nData(pJson[key]);*/
				_data[key] = pJson.strings[key];
			}
			Fewf.dispatcher.dispatchEvent(new FewfEvent(FILE_UPDATED));
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
		
		public function getConfigLangData(pLangCode:String=null) : Object {
			if(!pLangCode) { pLangCode = _lang; }
			var tLanguages = Fewf.assets.getData("config").languages.list;
			for(var i = 0; i < tLanguages.length; i++) {
				if(tLanguages[i].code == pLangCode) {
					return tLanguages[i];
				}
			}
			return null;
		}
	}
}
