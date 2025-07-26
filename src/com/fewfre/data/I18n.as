package com.fewfre.data
{
	import com.fewfre.events.FewfEvent;
	import com.fewfre.utils.Fewf;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	import app.data.ConstantsApp;
	
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
		
		public function setLangToLoadedLang(pLangCode:String) : void {
			_lang = pLangCode;
			_parseFile(Fewf.assets.getData(getConfigDefaultLangCode()));
			_parseFile(Fewf.assets.getData(pLangCode));
		}
		
		private function _parseFile(pJson:Object) : void {
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
		// Loading Helpers
		///////////////////////
		private function _getConfig() : * { return Fewf.assets.getData("config") || {}; }
			
		private function _loadLanguages(pLangCodes:Array, pCallback:Function) : void {
			var tConfigDefaultLangCode:String = getConfigDefaultLangCode();
			if(!tConfigDefaultLangCode) throw new Error("Can't load languages until config file has loaded!");
			
			var tUrls:Array = pLangCodes
				.filter(function(pLangCode:String,i,a):Boolean{ return !Fewf.assets.getData(pLangCode) }) // Filter out any we've already loaded
				.map(function(pLangCode:String,i,a):String{ return Fewf.swfUrlBase+"resources/i18n/"+pLangCode+".json" });
			
			if(tUrls.length == 0) { pCallback(); return; }
			Fewf.assets.loadWithCallback(tUrls, pCallback, { cacheBreaker:_getConfig().cachebreaker });
		}
		
		public function loadLanguagesIfNeededAndUseLastLang(pLangCodes:Array, pCallback:Function) : void {
			_loadLanguages(pLangCodes, function():void {
				setLangToLoadedLang(pLangCodes[pLangCodes.length-1]);
				pCallback();
			});
		}
		
		///////////////////////
		// Languages List
		///////////////////////
		private var _languagesCached : Vector.<I18nLangData>;
		public function getLanguagesList() : Vector.<I18nLangData> {
			if(_languagesCached) return _languagesCached;
			_languagesCached = new Vector.<I18nLangData>();
			var tLanguagesFromConfig:Array = _getConfig().languages.list;
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
		public function getConfigDefaultLangCode() : String {
			return _getConfig().languages["default"];
		}
		public function getSystemDetectedDefaultLangCodeOrFallback() : String {
			var tConfigLang:String = getConfigDefaultLangCode();
			
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
					if(langData.code == tConfigLang) {
						tFlagDefaultLangExists = true;
					}
				}
			}
			// If no language found matching saved language or system language, default to either the app's default (english by default)
			return tFlagDefaultLangExists ? tConfigLang : "en";
		}
	}
}