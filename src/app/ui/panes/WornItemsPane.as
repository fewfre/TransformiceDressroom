package app.ui.panes
{
	import com.fewfre.display.*;
	import com.fewfre.utils.Fewf;
	import com.fewfre.utils.FewfDisplayUtils;
	import com.fewfre.events.FewfEvent;
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import app.world.elements.*;
	import flash.display.*;
	import flash.events.*;
	import flash.display.MovieClip;
	import flash.utils.ByteArray;
	import flash.net.FileReference;
	import flash.net.FileFilter;
	import flash.utils.setTimeout;
	import app.world.data.ItemData;
	import app.ui.panes.base.ButtonGridSidePane;
	import app.ui.panes.infobar.Infobar;
	import app.world.events.ItemDataEvent;
	
	public class WornItemsPane extends ButtonGridSidePane
	{
		// Constants
		public static const ITEM_CLICKED : String = "item_clicked"; // ItemDataEvent
		
		// Storage
		private var _character : Character;
		
		// Constructor
		public function WornItemsPane(pCharacter:Character) {
			super(4);
			_character = pCharacter;
			
			this.addInfobar( new Infobar({ showBackButton:true, hideItemPreview:true, gridManagement:false }) )
				.on(Infobar.BACK_CLICKED, function(e):void{ dispatchEvent(new Event(Event.CLOSE)); });
		}
		
		/****************************
		* Public
		*****************************/
		public override function open() : void {
			super.open();
			
			_renderItems();
		}
		
		/****************************
		* Private
		*****************************/
		private function _renderItems() : void {
			resetGrid();
			
			for each(var itemType:ItemType in ItemType.ALL) {
				if(itemType === null) { continue; }
				_addItemButton( _character.getItemData(itemType) );
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
