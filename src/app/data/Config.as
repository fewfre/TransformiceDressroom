package app.data
{
	import com.fewfre.utils.Fewf;

	public class Config
	{
		private static function get(pConfigField:String) : * { return (Fewf.assets.getData("config") || {})[pConfigField]; }
		
		public static function get cacheBreaker() : String { return get("cachebreaker"); }
		public static function get languagesObject() : Object { return get("languages"); }
		
		// Scripts
		public static function get uploadToImgurUrl() : String { return _fixProtocol(get("upload2imgur_url")); }
		public static function get spriteSheetToGifUrl() : String { return _fixProtocol(get("spritesheet2gif_url")); }
		public static function get usernameLookupUrl() : String { return _fixProtocol(get("username_lookup_url")); }
		public static function get fetchPastebinUrl() : String { return _fixProtocol(get("fetchpastebin_url")); }
		public static function get createPasteBinUrl() : String { return _fixProtocol(get("createpastebin_url")); }
		private static function _fixProtocol(pUrl:String) : String { return pUrl ? pUrl.replace("https://", Fewf.networkProtocol+"://") : pUrl; }
		
		// Assets
		public static function get packs() : Object { return get("packs"); }
		public static function get packsExternal() : Array { return get("packs_external"); }
		public static function get emojis() : Array { return get("emojis"); }
	}
}
