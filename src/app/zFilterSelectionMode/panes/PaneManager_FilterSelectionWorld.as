package app.zFilterSelectionMode.panes
{
	import app.data.ItemType;
	import app.ui.panes.base.*;
	import app.zFilterSelectionMode.panes.*;

	public class PaneManager_FilterSelectionWorld extends PaneManager
	{
		// Pane IDs
		
		// Constructor
		public function PaneManager_FilterSelectionWorld() {
			super();
		}
		
		// ShopCategoryPane methods
		public function openFilterSelectionShopPane(pType:ItemType) : ShopCategoryPaneForFilteringSelection { return openPane(itemTypeToFilterId(pType)) as ShopCategoryPaneForFilteringSelection; }
		public function getFilterSelectionShopPane(pType:ItemType) : ShopCategoryPaneForFilteringSelection { return getPane(itemTypeToFilterId(pType)) as ShopCategoryPaneForFilteringSelection; }
		
		/////////////////////////////
		// Static
		/////////////////////////////
		public static function itemTypeToFilterId(pType:ItemType) : String { return "filter_"+pType.toString(); }
	}
}