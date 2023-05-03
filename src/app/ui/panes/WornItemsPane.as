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
	
	public class WornItemsPane extends TabPane
	{
		// Storage
		private var _character : Character;
		private var _onItemClicked	: Function;
		
		// Constructor
		public function WornItemsPane(pCharacter:Character, pOnItemClicked:Function) {
			super();
			_character = pCharacter;
			_onItemClicked = pOnItemClicked;
			
			this.addInfoBar( new ShopInfoBar({ showBackButton:true, showGridManagementButtons:false }) );
			this.addGrid( new Grid(385, 4).setXY(15,5) );
			this.infoBar.hideImageCont();
			
			UpdatePane();
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
			grid.reset();
			buttons = [];
			
			_addItemButton( _character.getItemData(ItemType.SKIN) );
			for each(var itemType:ItemType in ItemType.LOOK_CODE_ITEM_ORDER) {
				_addItemButton( _character.getItemData(itemType) );
			}
			
			UpdatePane();
		}
		
		public function _addItemButton(itemData:ItemData) : void {
			if(!itemData) { return; }
			var shopItem : MovieClip = GameAssets.getItemImage(itemData);
			shopItem.scaleX = shopItem.scaleY = 2;

			var shopItemButton : PushButton = new PushButton({ width:grid.cellSize, height:grid.cellSize, obj:shopItem, data:itemData });
			grid.add(shopItemButton);
			this.buttons.push(shopItemButton);
			shopItemButton.addEventListener(PushButton.STATE_CHANGED_AFTER, function(e:FewfEvent){ _onItemClicked(e.data); });
		}
	}
}
