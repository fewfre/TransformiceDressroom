package app.ui.panes
{
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
	import app.data.ShareCodeFilteringData;
	import flash.display.Sprite;
	import flash.utils.setTimeout;
	import app.ui.panes.base.ButtonGridSidePane;
	import app.ui.panes.infobar.Infobar;
	import flash.display.DisplayObject;

	public class ShopCategoryPaneForFiltering extends ButtonGridSidePane
	{
		private var _type: ItemType;
		private var _itemDataVector: Vector.<ItemData>;
		
		public function get type():ItemType { return _type; }
		
		public static const ITEM_TOGGLED : String = 'ITEM_TOGGLED';
		public static const DEFAULT_SKIN_COLOR_BTN_CLICKED : String = 'DEFAULT_SKIN_COLOR_BTN_CLICKED';
		
		// Constructor
		public function ShopCategoryPaneForFiltering(pType:ItemType) {
			this._type = pType;
			var buttonPerRow:int = 6;
			if(_type == ItemType.SKIN || _type == ItemType.POSE) { buttonPerRow = 5; }
			super(buttonPerRow);
			
			this.addInfobar( new Infobar({ showEyeDropper:false, hideItemPreview:true, gridManagement:{ hideRandomize:true, hideArrows:true } }) );
			this.infobar.showColorWheel(false);
			
			// We want them to start reversed
			grid.reverse();
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
		
		/****************************
		* Events
		*****************************/
		protected override function _onCellPushButtonToggled(e:FewfEvent) : void {
			var btn:PushButton = e.target as PushButton;
			btn.alpha = btn.pushed ? 1 : 0.5;
			ShareCodeFilteringData.toggleItemData(btn.data.itemData, btn.pushed);
			btn.data.customizeButton.visible = btn.pushed;
			ShareCodeFilteringData.updateShareCodeCache();
			// dispatchEvent(new FewfEvent(ITEM_TOGGLED, e.data));
		}
	}
}
