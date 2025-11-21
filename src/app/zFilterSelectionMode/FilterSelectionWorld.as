package app.zFilterSelectionMode
{
	import app.data.ConstantsApp;
	import app.data.ItemType;
	import app.ui.ShopTabList;
	import app.zFilterSelectionMode.panes.*;
	import com.fewfre.display.DisplayWrapper;
	import com.fewfre.display.RoundRectangle;
	import com.fewfre.events.FewfEvent;
	import flash.display.Sprite;
	import flash.display.Stage;
	import app.ui.panes.infobar.GridManagementWidget;
	import app.world.events.ItemDataEvent;
	import app.data.ShareCodeFilteringData;
	import flash.events.Event;

	public class FilterSelectionWorld extends Sprite
	{
		// Constants
		public static const CLOSED               : String = "CLOSED";
		public static const PREVIEW_MODE_CLICKED : String = "PREVIEW_MODE_CLICKED";
		
		// Storage
		private var _panes                        : PaneManager_FilterSelectionWorld;
		private var _shopTabs                     : ShopTabList;
		private var _filterSelectionModeInfoAside : FilterSelectionModeInfoAside;
		
		// Constructor
		public function FilterSelectionWorld() {
			super();
			_buildWorld();
		}
		
		private function _buildWorld() {
			/////////////////////////////
			// Setup UI
			/////////////////////////////
			_shopTabs = new ShopTabList(70, ConstantsApp.SHOP_HEIGHT).move(375, 10).appendTo(this).on(ShopTabList.TAB_CLICKED, _onTabClicked);
			_shopTabs.addTab("tab_furs", PaneManager_FilterSelectionWorld.itemTypeToFilterId(ItemType.SKIN));
			_shopTabs.addTab("tab_head", PaneManager_FilterSelectionWorld.itemTypeToFilterId(ItemType.HEAD));
			_shopTabs.addTab("tab_ears", PaneManager_FilterSelectionWorld.itemTypeToFilterId(ItemType.EARS));
			_shopTabs.addTab("tab_eyes", PaneManager_FilterSelectionWorld.itemTypeToFilterId(ItemType.EYES));
			_shopTabs.addTab("tab_mouth", PaneManager_FilterSelectionWorld.itemTypeToFilterId(ItemType.MOUTH));
			_shopTabs.addTab("tab_neck", PaneManager_FilterSelectionWorld.itemTypeToFilterId(ItemType.NECK));
			_shopTabs.addTab("tab_tail", PaneManager_FilterSelectionWorld.itemTypeToFilterId(ItemType.TAIL));
			_shopTabs.addTab("tab_hair", PaneManager_FilterSelectionWorld.itemTypeToFilterId(ItemType.HAIR));
			_shopTabs.addTab("tab_contacts", PaneManager_FilterSelectionWorld.itemTypeToFilterId(ItemType.CONTACTS));
			_shopTabs.addTab("tab_tattoo", PaneManager_FilterSelectionWorld.itemTypeToFilterId(ItemType.TATTOO));
			_shopTabs.addTab("tab_hand", PaneManager_FilterSelectionWorld.itemTypeToFilterId(ItemType.HAND));
			
			var tShop:RoundRectangle = new RoundRectangle(ConstantsApp.SHOP_WIDTH, ConstantsApp.SHOP_HEIGHT).move(450, 10)
				.appendTo(this).drawAsTray();
			_panes = new PaneManager_FilterSelectionWorld().appendTo(tShop.root) as PaneManager_FilterSelectionWorld;
			
			/////////////////////////////
			// Left Side
			/////////////////////////////
			_filterSelectionModeInfoAside = new FilterSelectionModeInfoAside().appendTo(this)
				.on(FilterSelectionModeInfoAside.EVENT_PREVIEW_ENABLED, _previewModeClicked)
				.on(FilterSelectionModeInfoAside.EVENT_STOP_FILTERING, function(e:FewfEvent){ _closeItemFilteringSelectionPane(); })
				.on(FilterSelectionModeInfoAside.EVENT_RESET_FILTERING, function(e:FewfEvent){ _resetItemFilteringSelectionPane(); });
			
			/////////////////////////////
			// Create item panes
			/////////////////////////////
			for each(var tType:ItemType in ItemType.TYPES_WITH_SHARE_FILTER_PANES) {
				_panes.addPane(PaneManager_FilterSelectionWorld.itemTypeToFilterId(tType), _setupItemPaneForFiltering(tType));
			}
		}
		
		private function _onTabClicked(pEvent:FewfEvent) : void {
			_panes.openPane(pEvent.data.toString());
		}
		
		private function _setupItemPaneForFiltering(pType:ItemType) : ShopCategoryPaneForFilteringSelection {
			var tPane:ShopCategoryPaneForFilteringSelection = new ShopCategoryPaneForFilteringSelection(pType);
			tPane.on(ShopCategoryPaneForFilteringSelection.ITEM_TOGGLED, function(e:ItemDataEvent):void{
				_refreshItemFilteringSelectionMode();
			});
			return tPane;
		}
		
		private function _dirtyAllItemFilteringPanes() : void {
			for each(var tType:ItemType in ItemType.TYPES_WITH_SHARE_FILTER_PANES) {
				var pane:ShopCategoryPaneForFilteringSelection = _panes.getFilterSelectionShopPane(tType);
				pane.makeDirty();
			}
		}
		
		private function _refreshItemFilteringSelectionMode() : void {
			_filterSelectionModeInfoAside.update();
		}
		
	//#region Public calls
		public function open() : void {
			_dirtyAllItemFilteringPanes();
			_filterSelectionModeInfoAside.update();
			_shopTabs.toggleOnFirstTab();
		}
	//#region Public calls
		
	//#region InfoAside Events
		private function _previewModeClicked(e:FewfEvent) : void {
			dispatchEvent(new Event(PREVIEW_MODE_CLICKED));
		}
		
		private function _closeItemFilteringSelectionPane() : void {
			dispatchEvent(new Event(CLOSED));
		}
		
		private function _resetItemFilteringSelectionPane() : void {
			ShareCodeFilteringData.reset();
			ShareCodeFilteringData.clearShareCodeCache();
			open();
		}
	//#endregion InfoAside Events
	}
}