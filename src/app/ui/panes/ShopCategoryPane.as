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

	public class ShopCategoryPane extends TabPane
	{
		private var _type: ItemType;
		private var _defaultSkinColorButton: ScaleButton;
		
		public function get type():ItemType { return _type; }
		
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
		
		public function toggleGridButtonWithData(pData:ItemData) : void {
			if(pData) {
				var tIndex:int = GameAssets.getItemIndexFromTypeID(_type, pData.id);
				buttons[ tIndex ].toggleOn();
			}
		}
		
		/****************************
		* Private
		*****************************/
		private function _setupGrid(pItemList:Vector.<ItemData>) : void {
			var buttonPerRow:int = 6;
			var scale:Number = 1;
			if(_type == ItemType.SKIN || _type == ItemType.POSE) {
					buttonPerRow = 5;
					scale = 1;
			}

			var grid:Grid = this.grid;
			if(!grid) { grid = this.addGrid( new Grid(385, buttonPerRow) ).setXY(15, 5); }
			grid.reset();

			var shopItem : MovieClip;
			var shopItemButton : PushButton;
			var i:int = -1;
			while (i < pItemList.length-1) { i++;
				shopItem = GameAssets.getItemImage(pItemList[i]);
				shopItem.scaleX = shopItem.scaleY = scale;

				shopItemButton = new PushButton({ width:grid.cellSize, height:grid.cellSize, obj:shopItem, id:i, data:{ type:_type, id:i } });
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
		
		private function _addDefaultSkinColorButtonIfSkinPane() : void {
			if(_type == ItemType.SKIN) {
				// Customizeable fur color button
				// cannot attach to button due to main button eating mouse events
				_defaultSkinColorButton = grid.addChild(new ScaleButton({ obj:new $ColorWheel(), obj_scale:0.5 })) as ScaleButton;
				_defaultSkinColorButton.addEventListener(ButtonBase.CLICK, function():void{
					buttons[GameAssets.defaultSkinIndex].toggleOn();
					dispatchEvent(new Event(DEFAULT_SKIN_COLOR_BTN_CLICKED));
				});
				_repositionDefaultSkinColorButtonIfExists();
			}
		}
		private function _repositionDefaultSkinColorButtonIfExists() : void {
			if(_defaultSkinColorButton) {
				var tSkinButton = buttons[GameAssets.defaultSkinIndex];
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
