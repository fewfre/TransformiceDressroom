package com.fewfre.utils
{
	public class Fewf
	{
		// Storage
		public static var assets : AssetManager;
		public static var i18n : I18n;
		
		public static function init() : void {
			assets = new AssetManager();
			i18n = new I18n();
		}
	}
}
