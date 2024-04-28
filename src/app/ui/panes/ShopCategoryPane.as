package app.ui.panes
{
	
	import app.ui.ShopInfoBar;
	import app.data.ItemType;
	import app.data.GameAssets;
	import flash.display.MovieClip;
	import app.ui.buttons.PushButton;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.display.ButtonBase;
	import app.ui.buttons.ScaleButton;
	import flash.events.Event;
	import app.world.data.ItemData;
	import com.fewfre.display.Grid;
	import com.fewfre.utils.FewfUtils;

	public class ShopCategoryPane extends TabPane
	{
		private var _type: ItemType;
		private var _itemDataVector: Vector.<ItemData>;
		private var _defaultItemData: ItemData;
		
		private var _defaultSkinColorButton: ScaleButton;
		
		public function get type():ItemType { return _type; }
		public function get defaultItemData():ItemData { return _defaultItemData; }
		
		public static const ITEM_TOGGLED : String = 'ITEM_TOGGLED';
		public static const DEFAULT_SKIN_COLOR_BTN_CLICKED : String = 'DEFAULT_SKIN_COLOR_BTN_CLICKED';
		
		// Constructor
		public function ShopCategoryPane(pType:ItemType) {
			super();
			this._type = pType;
			this.addInfoBar( new ShopInfoBar({ showEyeDropButton:_type!=ItemType.POSE, showGridManagementButtons:true }) );
			_setupGrid(GameAssets.getItemDataListByType(_type));
			
			infoBar.reverseButton.addEventListener(ButtonBase.CLICK, _onReverseGrid);
		}
		
		/****************************
		* Public
		*****************************/
		public override function open() : void {
			super.open();
		}
		
		public function getButtonWithItemData(itemData:ItemData) : PushButton {
			return FewfUtils.arrayFind(buttons, function(b:PushButton){ return itemData.matches(b.data.itemData) });
		}
		
		public function toggleGridButtonWithData(pData:ItemData) : PushButton {
			if(pData && getButtonWithItemData(pData)) {
				var btn:PushButton = getButtonWithItemData(pData);
				btn.toggleOn();
				return btn;
			}
			return null;
		}
		
		public function filterItemIds(pIds:Vector.<String>) : void {
			var list:Vector.<ItemData> = GameAssets.getItemDataListByType(_type);
			if(pIds) { list = list.filter(function(data:ItemData, i, a){ return pIds.indexOf(data.id) >= 0 }) }
			_setupGrid(list);
		}
		
		/****************************
		* Private
		*****************************/
		private function _setupGrid(pItemList:Vector.<ItemData>) : void {
			_itemDataVector = pItemList;
			_setDefaultItemDataFromList(pItemList);
			var buttonPerRow:int = 6;
			var scale:Number = 1;
			if(_type == ItemType.SKIN || _type == ItemType.POSE) {
					buttonPerRow = 5;
					scale = 1;
			}

			var grid:Grid = this.grid;
			if(!grid) { grid = this.addGrid( new Grid(385, buttonPerRow) ).setXY(15, 5); }
			grid.reset();
			buttons = [];

			var itemData : ItemData, shopItem : MovieClip, shopItemButton : PushButton;
			for(var i:int = 0; i < pItemList.length; i++) {
				itemData = pItemList[i];
				shopItem = GameAssets.getItemImage(itemData);
				shopItem.scaleX = shopItem.scaleY = scale;

				shopItemButton = new PushButton({ width:grid.cellSize, height:grid.cellSize, obj:shopItem, id:i, data:{ type:_type, id:i, itemID:itemData.id, itemData:itemData } });
				grid.add(shopItemButton);
				this.buttons.push(shopItemButton);
				shopItemButton.addEventListener(PushButton.STATE_CHANGED_AFTER, _onItemToggled);
			}
			
			if(_type !== ItemType.POSE) {
				// Start these ones reversed by default
				grid.reverse();
			}
			_addDefaultSkinColorButtonIfSkinPane();
			
			this.UpdatePane();
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
		
		private function _getButtonWithItemId(pId:String) : PushButton {
			return FewfUtils.arrayFind(buttons, function(b:PushButton){ return b.data.itemID == pId });
		}
		
		private function _addDefaultSkinColorButtonIfSkinPane() : void {
			if(_defaultSkinColorButton) {
				_defaultSkinColorButton.parent.removeChild(_defaultSkinColorButton);
			}
			_defaultSkinColorButton = null;
			if(_type == ItemType.SKIN && !!_getButtonWithItemId(GameAssets.defaultSkin.id)) {
				// Customizeable fur color button
				// cannot attach to button due to main button eating mouse events
				_defaultSkinColorButton = grid.addChild(new ScaleButton({ obj:new $ColorWheel(), obj_scale:0.5 })) as ScaleButton;
				_defaultSkinColorButton.addEventListener(ButtonBase.CLICK, function():void{
					var btn:PushButton = _getButtonWithItemId(GameAssets.defaultSkin.id);
					btn.toggleOn();
					dispatchEvent(new Event(DEFAULT_SKIN_COLOR_BTN_CLICKED));
				});
				_repositionDefaultSkinColorButtonIfExists();
			}
		}
		private function _repositionDefaultSkinColorButtonIfExists() : void {
			if(_defaultSkinColorButton) {
				var tSkinButton = _getButtonWithItemId(GameAssets.defaultSkin.id);
				_defaultSkinColorButton.x = tSkinButton.x + 60;
				_defaultSkinColorButton.y = tSkinButton.y + 12;
			}
		}
		
		/****************************
		* Events
		*****************************/
		private function _onItemToggled(e:FewfEvent) : void {
			dispatchEvent(new FewfEvent(ITEM_TOGGLED, e.data));
		}
		
		private function _onReverseGrid(e:Event) : void {
			this.grid.reverse();
			_repositionDefaultSkinColorButtonIfExists();
		}
	}
}
