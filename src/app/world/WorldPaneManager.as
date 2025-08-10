package app.world
{
	import app.data.ItemType;
	import app.ui.panes.*;
	import app.ui.panes.base.*;
	import app.ui.panes.colorpicker.ColorPickerTabPane;
	import app.ui.panes.filteringmode.ShopCategoryPaneForFilteringSelection;

	public class WorldPaneManager extends PaneManager
	{
		// Pane IDs
		public static const COLOR_PANE:String = "colorPane";
		public static const COLOR_FINDER_PANE:String = "colorFinderPane";
		
		public static const OTHER_PANE:String = "otherPane";
		public static const OTHER_COLOR_PANE:String = "otherColorPane";
		
		public static const CONFIG_PANE:String = "configPane";
		public static const OUTFITS_PANE:String = "outfitsPane";
		public static const FAVORITES_PANE:String = "favoritesPane";
		public static const WORN_ITEMS_PANE:String = "wornItemsPane";
		
		// Constructor
		public function WorldPaneManager() {
			super();
		}
		
		// ShopCategoryPane methods
		public function openShopPane(pType:ItemType) : ShopCategoryPane { return openPane(itemTypeToId(pType)) as ShopCategoryPane; }
		public function getShopPane(pType:ItemType) : ShopCategoryPane { return getPane(itemTypeToId(pType)) as ShopCategoryPane; }
		
		public function getFilterSelectionShopPane(pType:ItemType) : ShopCategoryPaneForFilteringSelection { return getPane(itemTypeToFilterId(pType)) as ShopCategoryPaneForFilteringSelection; }
		
		// Shortcuts to get panes with correct typing
		public function get colorPickerPane() : ColorPickerTabPane { return getPane(COLOR_PANE) as ColorPickerTabPane; }
		public function get colorFinderPane() : ColorFinderPane { return getPane(COLOR_FINDER_PANE) as ColorFinderPane; }
		
		public function get otherPane() : OtherTabPane { return getPane(OTHER_PANE) as OtherTabPane; }
		public function get otherColorPickerPane() : ColorPickerTabPane { return getPane(OTHER_COLOR_PANE) as ColorPickerTabPane; }
		
		public function get configPane() : ConfigTabPane { return getPane(CONFIG_PANE) as ConfigTabPane; }
		public function get outfitsPane() : OutfitManagerTabPane { return getPane(OUTFITS_PANE) as OutfitManagerTabPane; }
		public function get favoritesPane() : FavoritesTabPane { return getPane(FAVORITES_PANE) as FavoritesTabPane; }
		public function get wornItemsPane() : WornItemsPane { return getPane(WORN_ITEMS_PANE) as WornItemsPane; }
		
		/////////////////////////////
		// Static
		/////////////////////////////
		public static function itemTypeToId(pType:ItemType) : String { return pType.toString(); }
		public static function itemTypeToFilterId(pType:ItemType) : String { return "filter_"+pType.toString(); }
	}
}