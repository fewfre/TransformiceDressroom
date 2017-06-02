package com.fewfre.utils
{
	public class Fewf
	{
		// Storage
		public static var _assets : AssetManager;
		public static var _i18n : I18n;
		
		// Properties
		public static function get assets() : AssetManager { return _assets; }
		public static function get i18n() : I18n { return _i18n; }
		
		public static function init() : void {
			_assets = new AssetManager();
			_i18n = new I18n();
		}
	}
}
