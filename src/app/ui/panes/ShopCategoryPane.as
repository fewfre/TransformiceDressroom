package app.ui.panes
{	
	import app.data.ConstantsApp;
	import app.data.FavoriteItemsLocalStorageManager;
	import app.data.GameAssets;
	import app.data.ItemInfo;
	import app.data.ItemType;
	import app.data.ShareCodeFilteringData;
	import app.ui.buttons.GameButton;
	import app.ui.buttons.PushButton;
	import app.ui.common.FancyInput;
	import app.ui.panes.base.ButtonGridSidePane;
	import app.ui.panes.infobar.Infobar;
	import app.world.data.ItemData;
	import app.world.events.ItemDataEvent;

	import com.fewfre.display.DisplayWrapper;
	import com.fewfre.display.Grid;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.utils.Fewf;
	import com.fewfre.utils.FewfUtils;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.text.TextFormat;

	public class ShopCategoryPane extends ButtonGridSidePane
	{
		private var _type: ItemType;
		private var _itemDataVector: Vector.<ItemData>;
		private var _defaultItemData: ItemData;
		public var _favoritesGrid : Grid;
		
		private var _flagWaveInput: FancyInput;
		public function get flagWaveInput() : FancyInput { return _flagWaveInput; }
		
		public function get type():ItemType { return _type; }
		public function get defaultItemData():ItemData { return _defaultItemData; }
		public function get isItemTypeLocked():Boolean { return _infobar.isRefreshLocked; }
		
		public static const ITEM_SELECTED : String = 'ITEM_SELECTED'; // ItemDataEvent
		public static const ITEM_REMOVED : String = 'ITEM_REMOVED'; // ItemDataEvent
		public static const FLAG_WAVE_CODE_CHANGED : String = 'FLAG_WAVE_CODE_CHANGED';
		
		// Constructor
		public function ShopCategoryPane(pType:ItemType) {
			this._type = pType;
			var buttonPerRow:int = 6;
			if(_type == ItemType.SKIN || _type == ItemType.POSE) { buttonPerRow = 5; }
			super(buttonPerRow);
			
			if(_type !== ItemType.POSE && _type !== ItemType.EMOJI) {
				// Start these ones reversed by default
				grid.reverse();
			}
			
			var tOtherPaneType:Boolean = ItemType.OTHER_PANE_ITEM_TYPES.indexOf(_type) > -1;
			this.addInfobar( new Infobar({ showEyeDropper:_type!=ItemType.POSE, showDownload:true, gridManagement:{ hideRandomizeLock:tOtherPaneType }, showFavorites:true, showBackButton:tOtherPaneType }) );
			_infobar.on(Infobar.FAVORITE_CLICKED, _addRemoveFavoriteToggled);
			if(ItemInfo.supportedItemTypes.indexOf(_type) > -1) _infobar.addCustomObjectToRightSideTray( _createTopRightControlsTray() );
			_setupGrid(GameAssets.getItemDataListByType(_type));
			
			_favoritesGrid = new Grid(ConstantsApp.PANE_WIDTH, 10, 3).move(7, 60+5).appendTo(this);
			_renderFavorites();
			Fewf.dispatcher.addEventListener(ConstantsApp.FAVORITE_ADDED_OR_REMOVED, function(e:FewfEvent):void{
				if(e.data.itemType == _type) _renderFavorites();
			});
		}
		
		/****************************
		* Public
		*****************************/
		public override function open() : void {
			super.open();
		}
		
		public function setToggleStateGridButtonWithData(pData:ItemData, pOn:Boolean, pScrollIntoView:Boolean=false, pFireEvent:Boolean=true) : PushButton {
			var cell:DisplayObject = _getCellWithItemData(pData);
			if(cell) {
				var btn:PushButton = _findPushButtonInCell(cell);
				btn.toggle(pOn, pFireEvent);
				try {
					if(pOn && pScrollIntoView) scrollItemIntoView(cell);
				} catch(e){}
				return btn;
			}
			return null;
		}
		
		public function toggleGridButtonWithData(pData:ItemData, pScrollIntoView:Boolean=false) : PushButton {
			return setToggleStateGridButtonWithData(pData, true, pScrollIntoView)
		}
		
		// public function updateAllButtonsToItemData(pData:ItemData, pScrollIntoView:Boolean=false) : void {
		// 	if(!pData) _untoggleAllCells();
		// 	setToggleStateGridButtonWithData(pData, true, pScrollIntoView, false);
		// }
		
		public function scrollItemDataIntoView(itemData:ItemData) : void {
			if(flagOpen) scrollItemIntoView(_getCellWithItemData(itemData));
		}
		
		public function chooseRandomItem() : void {
			var tLength = grid.cells.length;
			var cell:DisplayObject = grid.cells[ Math.floor(Math.random() * tLength) ];
			var btn:PushButton = _findPushButtonInCell(cell);
			btn.toggleOn();
			if(_flagOpen) scrollItemIntoView(cell);
		}
		
		public function filterItemIds(pIds:Vector.<String>) : void {
			var list:Vector.<ItemData> = GameAssets.getItemDataListByType(_type);
			if(pIds) { list = list.filter(function(data:ItemData, i, a){ return pIds.indexOf(data.id) >= 0 }) }
			_setupGrid(list);
			_renderFavorites();
		}
		
		// Update image when colors have been changed
		public function refreshButtonImage(pItemData:ItemData) : void {
			if(!pItemData || !pItemData.isCustomizable) { return; }
			
			var btn:PushButton = _getButtonWithItemData(pItemData);
			if(!btn) return;
			btn.setImage(GameAssets.getColoredItemImage(pItemData));
		}
		
		public function updateInfobarWithItemData(itemData:ItemData, filterEnabled:Boolean=false) : void {
			if(!itemData) {
				this.infobar.removeInfo();
				return;
			}
			
			var showColorWheel : Boolean = itemData.isCustomizable;
			if(showColorWheel) {
				if(filterEnabled) {
					showColorWheel = ShareCodeFilteringData.isCustomizable(itemData);
					// If the item can normally be customized but they're turned off by filtering, force reset the color to default
					if(!showColorWheel) {
						itemData.setColorsToDefault();
					}
				}
			}
			this.infobar.addInfo( itemData, GameAssets.getColoredItemImage(itemData) );
			this.infobar.showColorWheel(showColorWheel);
		}
		
		/****************************
		* Private
		*****************************/
		protected function _getCellWithItemData(itemData:ItemData) : DisplayObject {
			return !itemData ? null : FewfUtils.vectorFind(grid.cells, function(c:DisplayObject){ return itemData.matches(_findPushButtonInCell(c).data.itemData) });
		}
		
		protected function _getButtonWithItemData(itemData:ItemData) : PushButton {
			return _findPushButtonInCell(_getCellWithItemData(itemData));
		}
		
		private function _setupGrid(pItemList:Vector.<ItemData>) : void {
			_itemDataVector = pItemList;
			_setDefaultItemDataFromList(pItemList);

			resetGrid();

			for(var i:int = 0; i < pItemList.length; i++) {
				_addButton(pItemList[i], 1, i);
			}
			
			refreshScrollbox();
		}
		
		private function _addButton(itemData:ItemData, pScale:Number, i:int) : void {
			var shopItem : MovieClip = GameAssets.getColoredItemImage(itemData);
			shopItem.scaleX = shopItem.scaleY = pScale;
			var cell:Sprite = new Sprite();

			var shopItemButton:PushButton = new PushButton(grid.cellSize).setImage(shopItem).setData({ type:_type, itemID:itemData.id, itemData:itemData }).appendTo(cell) as PushButton;
			
			_addFlagWaveInputIfNeeded(itemData, cell, shopItemButton);
			_addItemInfoIconIfNeeded(itemData, cell);
			
			// Finally add to grid (do it at end so auto event handlers can be hooked up properly)
			addToGrid(cell);
		}
		
		private function _setDefaultItemDataFromList(list:Vector.<ItemData>) : void {
			_defaultItemData = null;
			if(_type == ItemType.SKIN) {
				_defaultItemData = GameAssets.defaultSkin;
			} else if(_type == ItemType.POSE) {
				_defaultItemData = GameAssets.defaultPose;
			}
			// if filtering item & default item data is not in the current ItemData list, then pick a new one
			if(_defaultItemData && list && !FewfUtils.vectorFind(list, function(d:ItemData){ return _defaultItemData.matches(d) })) {
				_defaultItemData = list.length ? list[0] : null;
			}
		}
		
		private function _addFlagWaveInputIfNeeded(itemData:ItemData, cell:Sprite, parentButton:PushButton) : void {
			if(!GameAssets.poses[18].matches(itemData)) { return; }
			// Flag waving code text field
			// cannot attach to button due to main button eating mouse events
			_flagWaveInput = new FancyInput({ width:grid.cellSize-8, height:16, padding:2 }).move(grid.cellSize/2 + 0.5, 12).appendTo(cell);
			
			// Placeholder
			_flagWaveInput.setPlaceholderUntranslatedText('/f __');
			_flagWaveInput.placeholderTextBase.x += 14;
			
			// Center Text
			var tFormat:TextFormat = new TextFormat();
			tFormat.align = 'center';
			_flagWaveInput.field.defaultTextFormat = tFormat;
			
			_flagWaveInput.on_field(KeyboardEvent.KEY_UP, function(e):void{
				dispatchEvent(new FewfEvent(FLAG_WAVE_CODE_CHANGED, { code:_flagWaveInput.text }));
			});
			// paste support
			_flagWaveInput.on_field(TextEvent.TEXT_INPUT, function(e):void{
				if(e.text.length <= 1) return;
				dispatchEvent(new FewfEvent(FLAG_WAVE_CODE_CHANGED, { code:e.text }));
			});
			// select pose if textbox clicked
			_flagWaveInput.on_field(FocusEvent.FOCUS_IN, function():void{
				parentButton.toggleOn();
			});
		}
		
		private function _addItemInfoIconIfNeeded(itemData:ItemData, cell:Sprite) : void {
			if(!ItemInfo.get(itemData)) { return; }
			
			var icon:DisplayWrapper, offset:Number = 10;
			if(_type == ItemType.SKIN && ItemInfo.getSkin(itemData.id).isCostumeOnly) {
				icon = new DisplayWrapper(new $InventoryBag()).toScale(0.75);
			}
			else if(ItemInfo.get(itemData).isCheeseOnly) {
				icon = new DisplayWrapper(new $Fromage()).toScale(0.35);
			}
			else if(ItemInfo.get(itemData).isAlwaysInShop) {
				icon = new DisplayWrapper(new $AlwaysInShop()).toScale(0.7);
			}
			// else if(ItemInfo.get(itemData).isCollector) {
			// 	icon = new DisplayWrapper(new $CollectorItemIcon()).toScale(0.7);
			// }
			else if(ItemInfo.get(itemData).isEventReward) {
				icon = new DisplayWrapper(new $FireworkRockets()).toScale(0.75);
			}
			else if(ItemInfo.get(itemData).isStarCoin) {
				icon = new DisplayWrapper(new $StarCoin()).toScale(0.8);
			}
			else if(ItemInfo.get(itemData).isFreeish) {
				offset = 9;
				icon = new DisplayWrapper(new $GreenCircleItemType()).toScale(0.75);
			}
			
			if(icon) {
				icon.appendTo(cell).toAlpha(ItemInfo.showPurchaseTypeInUi ? 1 : 0).move(grid.cellSize - offset, grid.cellSize - offset).asSprite.mouseEnabled = false;
				Fewf.dispatcher.addEventListener(ConstantsApp.SHOW_PURCHASE_TYPE_TOGGLED, function(e:FewfEvent):void{
					icon.toAlpha(e.data.on ? 1 : 0);
				});
			}
		}
		
		/****************************
		* Favorites
		*****************************/
		private function _getIdsOfFilteredItems() : Vector.<String> {
			var availableIds:Vector.<String> = new Vector.<String>();
			for each(var tItemData:ItemData in _itemDataVector) {
				availableIds.push(tItemData.id);
			}
			return availableIds;
		}
		
		private function _renderFavorites() : void {
			var favIds:Array = FavoriteItemsLocalStorageManager.getFavoritesIdList(_type).concat().reverse(); // Reverse so newest show first
			
			_favoritesGrid.reset();
			_favoritesGrid.columns = Math.min(16, Math.max(10, favIds.length));
			
			var availableIds:Vector.<String> = _getIdsOfFilteredItems();
			var tItemData:ItemData;
			for each(var tId:String in favIds) {
				if(availableIds.indexOf(tId) == -1) continue;
				tItemData = GameAssets.getItemFromTypeID(_type, tId);
				if(tItemData) {
					_favoritesGrid.add(new GameButton(_favoritesGrid.cellSize).setImage(GameAssets.getItemImage(tItemData)).setData(tItemData)
						.onButtonClick(_favoriteClicked));
				}
			}
			
			// Update rest of UI to make room for it
			_scrollbox.y = 65 + _favoritesGrid.calculatedHeight+5; // shift it down an extra 5 so that main grid list isn't touching it (padding)
			_grid.y = favIds.length > 0 ? 0 : 3; // If fav grid exists, then shift grid up to avoid an extra gap between fav list and grid
			_scrollbox.resize(_scrollbox.scrollPane.width, defaultScrollboxHeight - (_favoritesGrid.calculatedHeight+3))
		}
		
		private function _favoriteClicked(e:FewfEvent) : void {
			var itemData:ItemData = (e.currentTarget as GameButton).data as ItemData;
			var btn:PushButton = _getButtonWithItemData(itemData);
			if(btn && btn.pushed) {
				// This allows clicking the button to toggle it off if already toggled
				btn.toggleOff(true);
			} else {
				toggleGridButtonWithData(itemData, true);
			}
			// _dispatchItemDataEvent(itemData, btn && !btn.pushed);
		}
		
		private function _addRemoveFavoriteToggled(e:FewfEvent) : void {
			var pushed:Boolean = e.data.pushed, tItemData:ItemData = _infobar.itemData;
			if(pushed) {
				FavoriteItemsLocalStorageManager.addFavorite(tItemData);
			} else {
				FavoriteItemsLocalStorageManager.removeFavorite(tItemData);
			}
		}
		
		/****************************
		* Top Right Controls
		*****************************/
		private function _createTopRightControlsTray() : Sprite {
			const tray:Sprite = new Sprite();
			_createPurchaseTypeToggleButton().appendTo(tray);
			return tray;
		}
		
		// NOTE: the show purchase toggle is global, so it needs to listen to the global state so it knows to change if a different toggle was pressed
		private var _showPurchaseTypeToggle:PushButton;
		private function _createPurchaseTypeToggleButton() : PushButton {
			(_showPurchaseTypeToggle = new PushButton(24)).setImage(new $AlwaysInShop(), 0.75).move((-24*1), 0)
			_showPurchaseTypeToggle
				.toggle(ItemInfo.showPurchaseTypeInUi, false)
				.onToggle(function(e:Event):void{
					ItemInfo.showPurchaseTypeInUi = !ItemInfo.showPurchaseTypeInUi;
					Fewf.dispatcher.dispatchEvent(new FewfEvent(ConstantsApp.SHOW_PURCHASE_TYPE_TOGGLED, { on:ItemInfo.showPurchaseTypeInUi }));
				});
				Fewf.dispatcher.addEventListener(ConstantsApp.SHOW_PURCHASE_TYPE_TOGGLED, function(e:FewfEvent):void{
					_showPurchaseTypeToggle.toggle(e.data.on, false);
					_showPurchaseTypeToggle.Image.alpha = e.data.on ? 1 : 0.5
				});
			_showPurchaseTypeToggle.Image.x += 0.5;
			_showPurchaseTypeToggle.Image.y += 0.5;
			_showPurchaseTypeToggle.Image.alpha = ItemInfo.showPurchaseTypeInUi ? 1 : 0.5;
			
			return _showPurchaseTypeToggle;
		}
		
		/****************************
		* Events
		*****************************/
		protected override function _onCellPushButtonToggled(e:FewfEvent) : void {
			super._onCellPushButtonToggled(e);
			_dispatchItemDataEvent(e.data.itemData, (e.currentTarget as PushButton).pushed);
		}
		
		private function _dispatchItemDataEvent(itemData:ItemData, selected:Boolean=true) : void {
			dispatchEvent(new ItemDataEvent(selected ? ITEM_SELECTED : ITEM_REMOVED, itemData));
		}
	}
}
