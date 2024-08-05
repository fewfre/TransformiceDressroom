package app.world
{
	import app.data.ItemType;
	import app.ui.panes.*;
	import app.ui.panes.base.*;
	import app.ui.panes.colorpicker.ColorPickerTabPane;

	public class WorldPaneManager extends PaneManager
	{
		// Pane IDs
		public static const COLOR_PANE:String = "colorPane";
		public static const COLOR_FINDER_PANE:String = "colorFinderPane";
		
		public static const OTHER_PANE:String = "other";
		public static const OTHER_COLOR_PANE:String = "otherColorPane";
		
		public static const CONFIG_PANE:String = "config";
		public static const OUTFITS_PANE:String = "outfits";
		public static const FAVORITES_PANE:String = "favoritesPane";
		public static const WORN_ITEMS_PANE:String = "wornItemsPane";
		public static const ITEM_FILTERING_PANE:String = "filtering";
		
		// Constructor
		public function WorldPaneManager() {
			super();
		}
		
		// ShopCategoryPane methods
		public function openShopPane(pType:ItemType) : ShopCategoryPane { return openPane(itemTypeToId(pType)) as ShopCategoryPane; }
		public function getShopPane(pType:ItemType) : ShopCategoryPane { return getPane(itemTypeToId(pType)) as ShopCategoryPane; }
		
		public function getFilterShopPane(pType:ItemType) : ShopCategoryPaneForFiltering { return getPane(itemTypeToFilterId(pType)) as ShopCategoryPaneForFiltering; }
		
		// Shortcuts to get panes with correct typing
		public function get colorPickerPane() : ColorPickerTabPane { return getPane(COLOR_PANE) as ColorPickerTabPane; }
		public function get colorFinderPane() : ColorFinderPane { return getPane(COLOR_FINDER_PANE) as ColorFinderPane; }
		public function get otherPane() : OtherTabPane { return getPane(OTHER_PANE) as OtherTabPane; }
		public function get otherColorPickerPane() : ColorPickerTabPane { return getPane(OTHER_COLOR_PANE) as ColorPickerTabPane; }
		
		/////////////////////////////
		// Static
		/////////////////////////////
		public static function itemTypeToId(pType:ItemType) : String { return pType.toString(); }
		public static function itemTypeToFilterId(pType:ItemType) : String { return "filter_"+pType.toString(); }
	}
}