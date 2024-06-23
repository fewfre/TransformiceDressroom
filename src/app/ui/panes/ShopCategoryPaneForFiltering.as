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

	public class ShopCategoryPaneForFiltering extends ButtonGridSidePane
	{
		private var _type: ItemType;
		private var _itemDataVector: Vector.<ItemData>;
		
		private var _actionsGrid : Grid;
		
		public function get type():ItemType { return _type; }
		
		public static const ITEM_TOGGLED : String = 'ITEM_TOGGLED';
		public static const DEFAULT_SKIN_COLOR_BTN_CLICKED : String = 'DEFAULT_SKIN_COLOR_BTN_CLICKED';
		
		// Constructor
		public function ShopCategoryPaneForFiltering(pType:ItemType) {
			this._type = pType;
			var buttonPerRow:int = 6;
			if(_type == ItemType.SKIN || _type == ItemType.POSE) { buttonPerRow = 5; }
			super(buttonPerRow);
			
			this.addInfoBar( new Infobar({ showEyeDropper:false, hideItemPreview:true, gridManagement:{ hideRandomize:true, hideArrows:true } }) );
			this.infoBar.showColorWheel(false);
				
			_actionsGrid = _scrollbox.add(new Grid(385, grid.columns).setXY(grid.x,grid.y)) as Grid;
			
			// We want them to start reversed
			grid.reverse();
			_actionsGrid.reverse();
		}
		
		/****************************
		* Public
		*****************************/
		protected override function _onDirtyOpen() : void {
			_setupGrid(GameAssets.getItemDataListByType(_type));
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
		
		/****************************
		* Private
		*****************************/
		private function _setupGrid(pItemList:Vector.<ItemData>) : void {
			_itemDataVector = pItemList;

			clearButtons();
			_actionsGrid.reset();

			for(var i:int = 0; i < pItemList.length; i++) {
				_addButton(pItemList[i], 1, i);
			}
			refreshScrollbox();
		}
		
		private function _addButton(itemData:ItemData, pScale:Number, i:int) {
			var shopItem : MovieClip = GameAssets.getItemImage(itemData);
			shopItem.scaleX = shopItem.scaleY = pScale;
			
			var customizeButton : Sprite = _addCustomizeButton(itemData);
			_actionsGrid.add(customizeButton);

			var shopItemButton : PushButton = new PushButton({ width:grid.cellSize, height:grid.cellSize, obj:shopItem, id:i, data:{ type:_type, id:i, itemID:itemData.id, itemData:itemData, customizeButton:customizeButton } });
			addButton(shopItemButton);
			
			shopItemButton.alpha = 0.5;
			customizeButton.visible = false;
			if(ShareCodeFilteringData.hasId(_type, itemData.id)) {
				shopItemButton.alpha = 1;
				shopItemButton.toggleOn(false);
				customizeButton.visible = true;
			}
			shopItemButton.addEventListener(PushButton.STATE_CHANGED_AFTER, _onItemToggled);
		}
		
		private function _getButtonWithItemId(pId:String) : PushButton {
			return FewfUtils.vectorFind(buttons, function(b:PushButton){ return b.data.itemID == pId });
		}
		
		private function _addCustomizeButton(data:ItemData) : Sprite {
			if(!data.colors || data.colors.length == 0) { return new MovieClip(); }
			
			var btn : PushButton = new PushButton({ width:20, height:20, obj:new $ColorWheel(), data:{ itemData:data } });
			btn.alpha = 0.35;
			if(ShareCodeFilteringData.isCustomizable(data.type, data.id)) {
				btn.alpha = 1;
				btn.toggleOn(false);
			}
			btn.addEventListener(PushButton.STATE_CHANGED_AFTER, function(e:FewfEvent){
				ShareCodeFilteringData.setCustomizable(data.type, data.id, (e.target as PushButton).pushed);
				btn.alpha = ShareCodeFilteringData.isCustomizable(data.type, data.id) ? 1 : 0.35;
			});
			return btn;
		}
		
		/****************************
		* Events
		*****************************/
		private function _onItemToggled(e:FewfEvent) : void {
			var btn:PushButton = e.target as PushButton;
			btn.alpha = btn.pushed ? 1 : 0.5;
			if(btn.pushed) {
				ShareCodeFilteringData.addId(btn.data.type, btn.data.itemID);
				btn.data.customizeButton.visible = true;
			} else {
				ShareCodeFilteringData.removeId(btn.data.type, btn.data.itemID);
				btn.data.customizeButton.visible = false;
			}
			// dispatchEvent(new FewfEvent(ITEM_TOGGLED, e.data));
		}
		
		protected override function _onInfobarReverseGridClicked(e:Event) : void {
			this.grid.reverse();
			this._actionsGrid.reverse();
		}
	}
}
