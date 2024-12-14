package app.ui.panes
{	
	import app.data.ConstantsApp;
	import app.data.FavoriteItemsLocalStorageManager;
	import app.data.GameAssets;
	import app.data.ItemType;
	import app.ui.buttons.PushButton;
	import app.ui.buttons.ScaleButton;
	import app.ui.buttons.SpriteButton;
	import app.ui.common.FancyInput;
	import app.ui.panes.base.ButtonGridSidePane;
	import app.ui.panes.infobar.Infobar;
	import app.world.data.ItemData;
	import app.world.events.ItemDataEvent;
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
		
		public static const ITEM_TOGGLED : String = 'ITEM_TOGGLED'; // ItemDataEvent
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
			
			this.addInfobar( new Infobar({ showEyeDropper:_type!=ItemType.POSE, showDownload:true, gridManagement:{ hideRandomizeLock:_type==ItemType.EMOJI }, showFavorites:true }) );
			_infobar.on(Infobar.FAVORITE_CLICKED, _addRemoveFavoriteToggled);
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
		
		public function getCellWithItemData(itemData:ItemData) : DisplayObject {
			return !itemData ? null : FewfUtils.vectorFind(grid.cells, function(c:DisplayObject){ return itemData.matches(_findPushButtonInCell(c).data.itemData) });
		}
		
		public function getButtonWithItemData(itemData:ItemData) : PushButton {
			return _findPushButtonInCell(getCellWithItemData(itemData));
		}
		
		public function toggleGridButtonWithData(pData:ItemData, pScrollIntoView:Boolean=false) : PushButton {
			var cell:DisplayObject = getCellWithItemData(pData);
			if(cell) {
				var btn:PushButton = _findPushButtonInCell(cell);
				btn.toggleOn();
				try {
					if(pScrollIntoView) scrollItemIntoView(cell);
				} catch(e){}
				return btn;
			}
			return null;
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
		}
		
		// Update image when colors have been changed
		public function refreshButtonImage(pItemData:ItemData) : void {
			if(!pItemData || !pItemData.isCustomizable) { return; }
			
			var btn:PushButton = this.getButtonWithItemData(pItemData);
			btn.setImage(GameAssets.getColoredItemImage(pItemData));
		}
		
		/****************************
		* Private
		*****************************/
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
			var shopItem : MovieClip = GameAssets.getItemImage(itemData);
			shopItem.scaleX = shopItem.scaleY = pScale;
			var cell:Sprite = new Sprite();

			var shopItemButton:PushButton = new PushButton({ width:grid.cellSize, height:grid.cellSize, obj:shopItem, data:{ type:_type, itemID:itemData.id, itemData:itemData } }).appendTo(cell) as PushButton;
			
			_addFlagWaveInputIfNeeded(itemData, cell, shopItemButton);
			
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
			_flagWaveInput = new FancyInput({ width:grid.cellSize-8, height:16, padding:2 });
			_flagWaveInput.x = grid.cellSize/2 + 0.5;
			_flagWaveInput.y = 12;
			cell.addChild(_flagWaveInput);
			
			// Placeholder
			_flagWaveInput.placeholderTextBase.setUntranslatedText('/f __');
			_flagWaveInput.placeholderTextBase.x += 14;
			
			// Center Text
			var tFormat:TextFormat = new TextFormat();
			tFormat.align = 'center';
			_flagWaveInput.field.defaultTextFormat = tFormat;
			
			_flagWaveInput.field.addEventListener(KeyboardEvent.KEY_UP, function(e):void{
				dispatchEvent(new FewfEvent(FLAG_WAVE_CODE_CHANGED, { code:_flagWaveInput.text }));
			});
			// paste support
			_flagWaveInput.field.addEventListener(TextEvent.TEXT_INPUT, function(e):void{
				if(e.text.length <= 1) return;
				dispatchEvent(new FewfEvent(FLAG_WAVE_CODE_CHANGED, { code:e.text }));
			});
			// select pose if textbox clicked
			_flagWaveInput.field.addEventListener(FocusEvent.FOCUS_IN, function():void{
				parentButton.toggleOn();
			});
		}
		
		/****************************
		* Favorites
		*****************************/
		private function _renderFavorites() : void {
			var favIds:Array = FavoriteItemsLocalStorageManager.getFavoritesIdList(_type).concat().reverse(); // Reverse so newest show first
			
			_favoritesGrid.reset();
			_favoritesGrid.columns = Math.min(16, Math.max(10, favIds.length));
			
			var tItemData:ItemData;
			for each(var tId:String in favIds) {
				tItemData = GameAssets.getItemFromTypeID(_type, tId);
				if(tItemData) {
					_favoritesGrid.add(SpriteButton.withObject(GameAssets.getItemImage(tItemData), "auto", { size:_favoritesGrid.cellSize, data:tItemData })
						.onButtonClick(_favoriteClicked));
				}
			}
			
			// Update rest of UI to make room for it
			_scrollbox.y = 65 + _favoritesGrid.calculatedHeight+5; // shift it down an extra 5 so that main grid list isn't touching it (padding)
			_grid.y = favIds.length > 0 ? 0 : 3; // If fav grid exists, then shift grid up to avoid an extra gap between fav list and grid
			_scrollbox.resize(_scrollbox.scrollPane.width, defaultScrollboxHeight - (_favoritesGrid.calculatedHeight+3))
		}
		
		private function _favoriteClicked(e:FewfEvent) : void {
			var itemData:ItemData = (e.currentTarget as SpriteButton).data as ItemData;
			var btn:PushButton = getButtonWithItemData(itemData);
			if(btn && btn.pushed) {
				// This allows clicking the button to toggle it off if already toggled
				btn.toggleOff(true);
			} else {
				toggleGridButtonWithData(itemData, true);
			}
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
		* Events
		*****************************/
		protected override function _onCellPushButtonToggled(e:FewfEvent) : void {
			super._onCellPushButtonToggled(e);
			dispatchEvent(new ItemDataEvent(ITEM_TOGGLED, e.data.itemData));
		}
	}
}
