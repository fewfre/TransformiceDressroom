package app.ui.panes
{
	import app.data.ConstantsApp;
	import app.data.FavoriteItemsLocalStorageManager;
	import app.data.GameAssets;
	import app.ui.buttons.ScaleButton;
	import app.ui.buttons.SpriteButton;
	import app.ui.panes.base.ButtonGridSidePane;
	import app.ui.panes.infobar.GridManagementWidget;
	import app.ui.panes.infobar.Infobar;
	import app.ui.screens.TrashConfirmScreen;
	import app.world.data.ItemData;
	import com.fewfre.events.FewfEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class FavoritesTabPane extends ButtonGridSidePane
	{
		// Constants
		public static const ITEMDATA_SELECTED : String = "itemdata_selected"; // FewfEvent<ItemData>
		
		// Storage
		private var _deleteAllConfirmScreen:TrashConfirmScreen;
		
		// Constructor
		public function FavoritesTabPane() {
			super(5);
			this.addInfoBar( new Infobar({ showBackButton:true, gridManagement:{ hideRandomizeLock:true, hideArrows:true } }) )
				.on(Infobar.BACK_CLICKED, function(e):void{ dispatchEvent(new Event(Event.CLOSE)); });
			infobar.ChangeImage(new $HeartFull())
			infobar.on(GridManagementWidget.RANDOMIZE_CLICKED, _onRandomizeClicked);
			
			// Delete all favorites logic
			_deleteAllConfirmScreen = new TrashConfirmScreen().move(ConstantsApp.PANE_WIDTH - 36, 31)
				.on(Event.CLOSE, function(e):void{ removeChild(_deleteAllConfirmScreen); })
				.on(TrashConfirmScreen.CONFIRM, _onDeleteAll);
			// Delete button (opens confirm screen)
			SpriteButton.withObject(new $Trash(), 'auto', { size:40 }).move(ConstantsApp.PANE_WIDTH - 40, 11).appendTo(this)
				.on(MouseEvent.CLICK, function(e):void{ addChild(_deleteAllConfirmScreen); });
		}
		
		/////////////////////////////
		// Public
		/////////////////////////////
		public override function open() : void {
			super.open();
			_renderFavoritesList();
		}
		
		/////////////////////////////
		// Private
		/////////////////////////////
		private function _renderFavoritesList() : void {
			resetGrid();
			
			var list:Vector.<ItemData> = FavoriteItemsLocalStorageManager.getAllFavorites();
			for each(var itemData:ItemData in list){
				_addFavButton(itemData);
			}
			
			refreshScrollbox();
		}
		
		public function _addFavButton(itemData:ItemData) : void {
			if(!itemData) { return; }
			var itemImage:MovieClip = GameAssets.getItemImage(itemData);
			
			var cell:Sprite = new Sprite();
			var actionTray:Sprite = new Sprite(); actionTray.alpha = 0;
			cell.addEventListener(MouseEvent.MOUSE_OVER, function(e){ actionTray.alpha = 1; });
			cell.addEventListener(MouseEvent.MOUSE_OUT, function(e){ actionTray.alpha = 0; });
			
			// main button
			SpriteButton.withObject(itemImage, "auto", { size:grid.cellSize, data:{ itemData:itemData } }).appendTo(cell)
				.onButtonClick(function(){ _dispatchItemData(itemData); });
			
			// Add on top of main button
			cell.addChild(actionTray);
			
			// Corresponding Delete Button
			ScaleButton.withObject(new $Trash(), 0.4).move(grid.cellSize-5, 5).appendTo(actionTray)
				.on(MouseEvent.CLICK, function(e){ _deleteFavorite(itemData); });
			
			// Finally add to grid (do it at end so auto event handlers can be hooked up properly)
			addToGrid(cell);
		}
		
		private function _deleteFavorite(itemData:ItemData) : void {
			FavoriteItemsLocalStorageManager.removeFavorite(itemData);
			_renderFavoritesList();
			if(FavoriteItemsLocalStorageManager.getAllFavorites().length == 0) {
				dispatchEvent(new Event(Event.CLOSE));
			}
		}
		
		private function _dispatchItemData(itemData:ItemData) : void {
			dispatchEvent(new FewfEvent(ITEMDATA_SELECTED, itemData));
		}
		
		/////////////////////////////
		// Events
		/////////////////////////////
		private function _onDeleteAll(e) : void {
			removeChild(_deleteAllConfirmScreen);
			FavoriteItemsLocalStorageManager.deleteAll();
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		private function _onRandomizeClicked(e) : void {
			var list:Vector.<ItemData> = FavoriteItemsLocalStorageManager.getAllFavorites();
			if(list.length > 0) {
				_dispatchItemData( list[ Math.floor(Math.random() * list.length) ] );
			}
		}
	}
}