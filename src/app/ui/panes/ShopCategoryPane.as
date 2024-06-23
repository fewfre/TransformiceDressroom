package app.ui.panes
{
	
	import app.ui.common.FancyInput;
	import app.ui.ShopInfoBar;
	import app.data.ItemType;
	import app.data.GameAssets;
	import flash.display.MovieClip;
	import app.ui.buttons.PushButton;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.display.ButtonBase;
	import com.fewfre.utils.FewfUtils;
	import app.ui.buttons.ScaleButton;
	import flash.events.Event;
	import app.world.data.ItemData;
	import com.fewfre.display.Grid;
	import flash.events.TextEvent;
	import flash.events.KeyboardEvent;
	import flash.events.FocusEvent;
	import flash.text.TextFormat;
	import app.ui.panes.base.ButtonGridSidePane;

	public class ShopCategoryPane extends ButtonGridSidePane
	{
		private var _type: ItemType;
		private var _itemDataVector: Vector.<ItemData>;
		private var _defaultItemData: ItemData;
		public var selectedButtonIndex : int;
		
		private var _defaultSkinColorButton: ScaleButton;
		private var _flagWaveInput: FancyInput;
		public function get flagWaveInput() : FancyInput { return _flagWaveInput; }
		
		public function get type():ItemType { return _type; }
		public function get defaultItemData():ItemData { return _defaultItemData; }
		
		public static const ITEM_TOGGLED : String = 'ITEM_TOGGLED';
		public static const DEFAULT_SKIN_COLOR_BTN_CLICKED : String = 'DEFAULT_SKIN_COLOR_BTN_CLICKED';
		public static const FLAG_WAVE_CODE_CHANGED : String = 'FLAG_WAVE_CODE_CHANGED';
		
		// Constructor
		public function ShopCategoryPane(pType:ItemType) {
			this._type = pType;
			var buttonPerRow:int = 6;
			if(_type == ItemType.SKIN || _type == ItemType.POSE) { buttonPerRow = 5; }
			super(buttonPerRow);
			
			if(_type !== ItemType.POSE) {
				// Start these ones reversed by default
				grid.reverse();
			}
			
			selectedButtonIndex = -1;
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
			return FewfUtils.vectorFind(buttons, function(b:PushButton){ return itemData.matches(b.data.itemData) });
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
			var scale:Number = 1;

			clearButtons();

			var itemData : ItemData, shopItem : MovieClip, shopItemButton : PushButton;
			for(var i:int = 0; i < pItemList.length; i++) {
				itemData = pItemList[i];
				shopItem = GameAssets.getItemImage(itemData);
				shopItem.scaleX = shopItem.scaleY = scale;

				shopItemButton = new PushButton({ width:grid.cellSize, height:grid.cellSize, obj:shopItem, id:i, data:{ type:_type, id:i, itemID:itemData.id, itemData:itemData } });
				addButton(shopItemButton);
				shopItemButton.addEventListener(PushButton.STATE_CHANGED_AFTER, _onItemToggled);
			}
			
			_addDefaultSkinColorButtonIfSkinPane();
			refreshScrollbox();
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
			return FewfUtils.vectorFind(buttons, function(b:PushButton){ return b.data.itemID == pId });
		}
		
		private function _addDefaultSkinColorButtonIfSkinPane() : void {
			if(_defaultSkinColorButton && _defaultSkinColorButton.parent) {
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
			if(_type == ItemType.POSE) {
				// Flag waving code text field
				// cannot attach to button due to main button eating mouse events
				_flagWaveInput = new FancyInput({ width:grid.cellSize-8, height:16, padding:2 });
				
				// Placeholder
				_flagWaveInput.placeholderTextBase.setUntranslatedText('/f __');
				_flagWaveInput.placeholderTextBase.x += 14;
				
				// Center Text
				var tFormat:TextFormat = new TextFormat();
				tFormat.align = 'center';
				_flagWaveInput.field.defaultTextFormat = tFormat;
				
				grid.addChild(_flagWaveInput);
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
					buttons[18].toggleOn();
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
			if(_flagWaveInput) {
				var tPoseButton = buttons[18];
				_flagWaveInput.x = tPoseButton.x + grid.cellSize/2 + 0.5;
				_flagWaveInput.y = tPoseButton.y + 12;
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
