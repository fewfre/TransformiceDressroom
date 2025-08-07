package app.ui.panes
{	
	import app.data.GameAssets;
	import app.data.ItemType;
	import app.ui.buttons.PushButton;
	import app.ui.panes.base.ButtonGridSidePane;
	import app.ui.panes.infobar.Infobar;
	import app.world.data.ItemData;
	import app.world.data.OutfitData;
	import app.world.events.ItemDataEvent;
	import com.fewfre.events.FewfEvent;
	import flash.display.MovieClip;
	import flash.events.Event;

	public class WornItemsPane extends ButtonGridSidePane
	{
		// Constants
		public static const ITEM_CLICKED : String = "item_clicked"; // ItemDataEvent
		
		// Constructor
		public function WornItemsPane() {
			super(4);
			
			this.addInfobar( new Infobar({ showBackButton:true, hideItemPreview:true, gridManagement:false }) )
				.on(Infobar.BACK_CLICKED, function(e):void{ dispatchEvent(new Event(Event.CLOSE)); });
		}
		
		/****************************
		* Public
		*****************************/
		public override function open() : void {
			super.open();
		}
		public function init(pOutfitData:OutfitData) : void {
			_renderItems(pOutfitData);
		}
		
		/****************************
		* Private
		*****************************/
		private function _renderItems(pOutfitData:OutfitData) : void {
			resetGrid();
			
			for each(var itemType:ItemType in ItemType.ALL) {
				if(itemType === null) { continue; }
				_addItemButton( pOutfitData.getItemData(itemType) );
			}
			refreshScrollbox();
		}
		
		public function _addItemButton(itemData:ItemData) : void {
			// If no item data OR item is default pose (since pointless too, plus the skin will already show the default pose) don't add a button 
			if(!itemData || itemData.matches(GameAssets.defaultPose)) { return; }
			var shopItem : MovieClip = GameAssets.getColoredItemImage(itemData);
			shopItem.scaleX = shopItem.scaleY = 2;

			var shopItemButton : PushButton = new PushButton({ width:grid.cellSize, height:grid.cellSize, obj:shopItem, data:itemData });
			shopItemButton.on(PushButton.TOGGLE, function(e:FewfEvent){ dispatchEvent(new ItemDataEvent(ITEM_CLICKED, e.data as ItemData)) });
			
			// Finally add to grid (do it at end so auto event handlers can be hooked up properly)
			addToGrid(shopItemButton);
		}
	}
}
