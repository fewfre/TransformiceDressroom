package com.fewfre.data
{
	import com.fewfre.events.FewfEvent;
	import com.fewfre.utils.Fewf;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	
	public class I18n
	{
		// Constants
		public static const GLOBAL_SHARED_OBJECT_KEY_LANG: String = 'lang';
		
		// Storage
		private var _messagesMap  : Dictionary;
		private var _defaultFont  : String = "Veranda";
		private var _defaultScale : Number = 1;
		private var _lang         : String;
		
		// Properties
		public function get defaultFont() : String { return _defaultFont; }
		public function get defaultScale() : Number { return _defaultScale; }
		public function get lang() : String { return _lang; }
		
		// Constants
		public static const FILE_UPDATED : String = "i18n_file_updated";
		
		// Constructor
		public function I18n() {
			_lang = "en";
			_messagesMap = new Dictionary();
			// Allows clearing of text by passing an empty string.
			_messagesMap[""] = { text:"" };
			// Loading text that's needed before translation text is retrieved.
			_messagesMap["loading"] = { text:"Items left to load: {0}" };
			_messagesMap["loading_finished"] = { text:"Loading complete. Initializing..." };
			_messagesMap["loading_progress"] = { text:"{0}" };
		}
		
		public function parseFile(pLang:String, pJson:Object) : void {
			_lang = pLang;
			_defaultFont = pJson.defaultFont;
			_defaultScale = pJson.defaultScale;
			for(var key:String in pJson.strings) {
				/*_messagesMap[key] = new I18nData(pJson[key]);*/
				_messagesMap[key] = pJson.strings[key];
			}
			Fewf.dispatcher.dispatchEvent(new FewfEvent(FILE_UPDATED));
		}
		
		public function getData(pKey:String, pSilenceLog:Boolean=false) : Object {
			if(_messagesMap[pKey] != null) {
				return _messagesMap[pKey];
			} else {
				if(!pSilenceLog) trace("[I18n](getData) No key '"+pKey+"' exists.");
				return null;
			}
		}
		
		public function getText(pKey:String, pSilenceLog:Boolean=false) : String {
			if(_messagesMap[pKey] != null) {
				return _messagesMap[pKey].text;
			} else {
				if(!pSilenceLog) trace("[I18n](getText) No key '"+pKey+"' exists.");
				return null;
			}
		}
		
		///////////////////////
		// Languages List
		///////////////////////
		private var _languagesCached : Vector.<I18nLangData>;
		public function getLanguagesList() : Vector.<I18nLangData> {
			if(_languagesCached) return _languagesCached;
			_languagesCached = new Vector.<I18nLangData>();
			var tLanguagesFromConfig:Array = Fewf.assets.getData("config").languages.list;
			for each(var tLangJson:Object in tLanguagesFromConfig) {
				_languagesCached.push(new I18nLangData(tLangJson));
			}
			return _languagesCached;
		}
		
		public function getConfigLangData(pLangCode:String=null) : I18nLangData {
			if(!pLangCode) { pLangCode = _lang; }
			var tLanguages:Vector.<I18nLangData> = getLanguagesList();
			for each(var langData:I18nLangData in tLanguages) {
				if(langData.code == pLangCode) { return langData; }
			}
			return null;
		}
		
		/**
		 * Should only be called after `config` file loaded for best results
		 */
		public function getDefaultLang() : String {
			var tConfig:Object = Fewf.assets.getData("config") || {};
			var tConfigLang:String = tConfig.languages["default"];
			
			// If user manually picked a language previously, override system check
			var detectedLang = Fewf.sharedObjectGlobal.getData(I18n.GLOBAL_SHARED_OBJECT_KEY_LANG) || Capabilities.language;
			
			var tFlagDefaultLangExists:Boolean = false;
			// http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/system/Capabilities.html#language
			if(detectedLang) {
				var tLanguages:Vector.<I18nLangData> = getLanguagesList();
				for each(var langData:I18nLangData in tLanguages) {
					if(detectedLang == langData.code || detectedLang == langData.code.split("-")[0]) {
						return langData.code;
					}
					if(tConfigLang == langData.code) {
						tFlagDefaultLangExists = true;
					}
				}
			}
			// If no language found matching saved language or system language, default to either the app's default (english by default)
			return tFlagDefaultLangExists ? tConfigLang : "en";
		}
	}
}