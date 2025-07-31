package app.data
{
	public class ConstantsApp
	{
		/////////////////////////////
		// Dimensions
		/////////////////////////////
		public static const APP_WIDTH   : Number = 900;
		public static const APP_HEIGHT  : Number = 425;
		public static const CENTER_X    : Number = APP_WIDTH/2;
		public static const CENTER_Y    : Number = APP_HEIGHT/2;
		
		public static const SHOP_WIDTH  : Number = 440;
		public static const SHOP_HEIGHT : Number = 400;
		public static const PANE_WIDTH  : Number = 430; // Inner shop width
		
		/////////////////////////////
		// General
		/////////////////////////////
		public static const VERSION           : String = "1.31";
		public static const SOURCE_URL        : String = "https://github.com/fewfre/TransformiceDressroom/blob/master/CHANGELOG.md";
		public static const DISCORD_URL       : String = "https://discord.gg/DREPH9GqWw";
		
		public static const DEFAULT_SKIN_ID   : int = 0;
		public static const DEFAULT_POSE_ID   : int = 0;
		
		public static const NUM_ITEMS_PER_ROW : int = 7;
		
		public static const DEFAULT_CHARACTER_SCALE : Number = 3;
		public static const ITEM_SAVE_SCALE   : int = 8; // Power of two is probably best
		
		public static var CONFIG_TAB_ENABLED: Boolean = true;
		public static var ANIMATION_DOWNLOAD_ENABLED: Boolean = true;
		
		/////////////////////////////
		// Global Events
		/////////////////////////////
		public static const DOWNLOAD_ITEM_DATA_IMAGE : String = "download_item_data_image"; // ItemDataEvent
		public static const FAVORITE_ADDED_OR_REMOVED : String = "favorite_added_or_removed"; // FewfEvent<{ itemType:ItemType }}>
		
		/////////////////////////////
		// Shared Object
		/////////////////////////////
		public static const SHARED_OBJECT_KEY_GLOBAL_LANG: String = 'lang';
		public static const SHARED_OBJECT_KEY_OUTFITS: String = 'saved-outfits';
		public static const SHARED_OBJECT_KEY_TYPE_FAVORITES_PREFIX: String = 'favorite-items-';
		public static const SHARED_OBJECT_KEY_LAST_FILTER_CODE: String = 'last-filter-code';
		public static const SHARED_OBJECT_KEY_AUTO_SAVE_LOOK: String = 'auto-save-look';
		public static const SHARED_OBJECT_KEY_HARDCODED_CANVAS_SAVE_SIZE: String = 'hardcoded-canvas-save-size';
		public static const SHARED_OBJECT_KEY_HARDCODED_SAVE_SCALE: String = 'hardcoded-save-scale';
		
		/////////////////////////////
		// Colors
		/////////////////////////////
		public static const APP_BG_COLOR					: int = 0x6A7495;
		
		public static const COLOR_BUTTON_BLUE				: int = 0x3C5064;
		public static const COLOR_BUTTON_DOWN				: int = 0x2C3947;
		public static const COLOR_BUTTON_MOUSE_OVER			: int = 0x42586E;
		public static const COLOR_BUTTON_MOUSE_DOWN			: int = 0x30404F;
		
		public static const COLOR_BUTTON_OUTSET_BOTTOM		: int = 0x11171C;
		public static const COLOR_BUTTON_OUTSET_TOP			: int = 0x5D7D90;
		
		public static const COLOR_TRAY_GRADIENT				: Array = [ 0x112528, 0x1E3D42 ];
		public static const COLOR_TRAY_B_1					: int = 0x6A8fA2;
		public static const COLOR_TRAY_B_2					: int = 0x11171C;
		public static const COLOR_TRAY_B_3					: int = 0x324650;
	}
}
