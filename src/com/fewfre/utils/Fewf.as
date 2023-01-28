package com.fewfre.utils
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	
	// Global access class
	public class Fewf
	{
		// Storage
		public static var _assets : AssetManager;
		public static var _i18n : I18n;
		public static var _dispatcher : EventDispatcher;
		public static var _sharedObject : SharedObjectManager;
		public static var _sharedObjectGlobal : SharedObjectManager;
		public static var _stage : Stage;
		public static var _isExternallyLoaded : Boolean;
		public static var _swfUrlBase : String;
		
		// Properties
		public static function get assets() : AssetManager { return _assets; }
		public static function get i18n() : I18n { return _i18n; }
		public static function get dispatcher() : EventDispatcher { return _dispatcher; }
		public static function get sharedObject() : SharedObjectManager { return _sharedObject; }
		public static function get sharedObjectGlobal() : SharedObjectManager { return _sharedObjectGlobal; }
		public static function get stage() : Stage { return _stage; }
		public static function get isExternallyLoaded() : Boolean { return _isExternallyLoaded; }
		public static function get swfUrlBase() : String { return _swfUrlBase; }
		
		public static function init(pStage:Stage, pSwfUrlBase:String, uniqID:String) : void {
			_assets = new AssetManager();
			_i18n = new I18n();
			_dispatcher = new EventDispatcher();
			_sharedObject = new SharedObjectManager(uniqID);
			_sharedObjectGlobal = new SharedObjectManager("fewfre");
			_stage = pStage;
			_isExternallyLoaded = !!pSwfUrlBase;
			_swfUrlBase = pSwfUrlBase || "";
		}
	}
}
