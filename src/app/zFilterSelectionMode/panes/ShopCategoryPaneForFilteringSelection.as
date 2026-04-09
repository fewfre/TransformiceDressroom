package app.zFilterSelectionMode.panes
{
	import app.data.GameAssets;
	import app.data.ItemType;
	import app.data.ShareCodeFilteringData;
	import app.ui.buttons.PushButton;
	import app.ui.panes.base.ButtonGridSidePane;
	import app.ui.panes.infobar.Infobar;
	import app.world.data.ItemData;
	import app.world.events.ItemDataEvent;
	import com.fewfre.events.FewfEvent;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import app.ui.panes.infobar.GridManagementWidget;
	import flash.events.Event;
	import app.zFilterSelectionMode.data.SortType_FilterSelectionMode;
	import com.fewfre.utils.FewfUtils;

	public class ShopCategoryPaneForFilteringSelection extends ButtonGridSidePane
	{
		private var _type: ItemType;
		private var _itemDataVector: Vector.<ItemData>;
		private var _sortType: SortType_FilterSelectionMode = SortType_FilterSelectionMode.ID;
		private var _sortReversed:Boolean = true; // Start reversed so newest items are at end of list (and thus start of grid)
		
		public function get type():ItemType { return _type; }
		
		public static const ITEM_TOGGLED : String = 'ITEM_TOGGLED'; // ItemDataEvent
		public static const DEFAULT_SKIN_COLOR_BTN_CLICKED : String = 'DEFAULT_SKIN_COLOR_BTN_CLICKED';
		
		// Constructor
		public function ShopCategoryPaneForFilteringSelection(pType:ItemType) {
			this._type = pType;
			var buttonPerRow:int = 6;
			if(_type == ItemType.SKIN || _type == ItemType.POSE) { buttonPerRow = 5; }
			super(buttonPerRow);
			
			this.addInfobar( new Infobar_FilterSelectionMode() );
			infobar.on(Infobar_FilterSelectionMode.REVERSE_CLICKED, function(e:Event):void { _sortReversed = !_sortReversed; _setupGrid(_itemDataVector); });
			infobar.on(Infobar_FilterSelectionMode.SORT_TYPE_CHANGED, function(e:FewfEvent):void { _sortType = e.data.sortType; _setupGrid(_itemDataVector); });
			
			// We want them to start reversed
			// NOTE: commented out as we are using custom sorting via _sortReversed, so we use that instead
			// grid.reverse();
		}
		
		/****************************
		* Public
		*****************************/
		protected override function _onDirtyOpen() : void {
			_setupGrid(GameAssets.getItemDataListByType(_type));
		}
		
		/****************************
		* Private
		*****************************/
		private function _setupGrid(pItemList:Vector.<ItemData>) : void {
			_itemDataVector = pItemList;
			// Clone so we don't mess with original order of the item data
			var sortedItems:Vector.<ItemData> = _itemDataVector.concat();
			if(_sortReversed) { sortedItems = sortedItems.reverse(); }
			trace("_sortReversed", _sortReversed, _sortType);
			// If sort type is ID or unrecognized, keep original order (which is ID order)
			if(_sortType == SortType_FilterSelectionMode.OWNED) { 
				FewfUtils.vectorStableMergeSort(sortedItems, function(a:ItemData, b:ItemData):int { return _compareBooleans(ShareCodeFilteringData.has(a), ShareCodeFilteringData.has(b)); });
			} else if(_sortType == SortType_FilterSelectionMode.CUSTOMIZABLE) {
				FewfUtils.vectorStableMergeSort(sortedItems, function(a:ItemData, b:ItemData):int { return _compareBooleans(ShareCodeFilteringData.isCustomizable(a), ShareCodeFilteringData.isCustomizable(b)) || _compareBooleans(ShareCodeFilteringData.has(a), ShareCodeFilteringData.has(b)); });
			}

			resetGrid();

			for(var i:int = 0; i < sortedItems.length; i++) {
				_addButton(sortedItems[i], 1, i);
			}
			refreshScrollbox();
		}
		
		private function _addButton(itemData:ItemData, pScale:Number, i:int) : void {
			var shopItem : Sprite = GameAssets.getItemImage(itemData);
			shopItem.scaleX = shopItem.scaleY = pScale;
			var cell:Sprite = new Sprite();
			
			var customizeButton : DisplayObject = _addCustomizeButton(itemData);

			var shopItemButton : PushButton = new PushButton(grid.cellSize).setImage(shopItem).setData({ type:_type, id:i, itemID:itemData.id, itemData:itemData, customizeButton:customizeButton }).appendTo(cell) as PushButton;
			
			cell.addChild( customizeButton );
			
			shopItemButton.alpha = 0.5;
			customizeButton.visible = false;
			if(ShareCodeFilteringData.hasId(_type, itemData.id)) {
				shopItemButton.toggleOn(false).setAlpha(1);
				customizeButton.visible = true;
			}
			
			// Finally add to grid (do it at end so auto event handlers can be hooked up properly)
			addToGrid(cell);
		}
		
		private function _addCustomizeButton(data:ItemData) : Sprite {
			if(!data.colors || data.colors.length == 0) { return new Sprite(); }
			
			var btn : PushButton = new PushButton(20).setImage(new $ColorWheel()).setData({ itemData:data }) as PushButton;
			btn.alpha = 0.35;
			if(ShareCodeFilteringData.isCustomizable(data)) {
				btn.toggleOn(false).setAlpha(1);
			}
			btn.on(PushButton.TOGGLE, function(e:FewfEvent){
				ShareCodeFilteringData.setCustomizable(data, (e.target as PushButton).pushed);
				ShareCodeFilteringData.updateShareCodeCache();
				btn.alpha = ShareCodeFilteringData.isCustomizable(data) ? 1 : 0.35;
			});
			return btn;
		}
		
		private function _compareBooleans(a:Boolean, b:Boolean) : int {
			return a && !b ? -1 : (!a && b ? 1 : 0);
		}
		
		/****************************
		* Events
		*****************************/
		protected override function _onCellPushButtonToggled(e:FewfEvent) : void {
			var btn:PushButton = e.target as PushButton;
			btn.alpha = btn.pushed ? 1 : 0.5;
			ShareCodeFilteringData.toggleItemData(btn.data.itemData, btn.pushed);
			btn.data.customizeButton.visible = btn.pushed;
			ShareCodeFilteringData.updateShareCodeCache();
			dispatchEvent(new ItemDataEvent(ITEM_TOGGLED, btn.data.itemData));
		}
	}
}
