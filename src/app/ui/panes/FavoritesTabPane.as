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
	import app.world.events.ItemDataEvent;
	import com.fewfre.events.FewfEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import app.ui.buttons.PushButton;
	import flash.display.DisplayObject;
	import com.fewfre.display.DisplayWrapper;
	
	public class FavoritesTabPane extends ButtonGridSidePane
	{
		// Constants
		public static const ITEMDATA_SELECTED : String = "itemdata_selected"; // ItemDataEvent
		public static const ITEMDATA_REMOVED : String = "itemdata_removed"; // ItemDataEvent
		public static const ITEMDATA_GOTO : String = "itemdata_goto"; // ItemDataEvent
		
		// Storage
		private var _deleteAllConfirmScreen:TrashConfirmScreen;
		private var _getIfItemDataWorn:Function; // (data:ItemData) => bool;
		
		// Constructor
		public function FavoritesTabPane(pGetIfItemDataWorn:Function) {
			super(5);
			_getIfItemDataWorn = pGetIfItemDataWorn;
			this.addInfoBar( new Infobar({ showBackButton:true, gridManagement:{ hideRandomizeLock:true, hideArrows:true } }) )
				.on(Infobar.BACK_CLICKED, function(e):void{ dispatchEvent(new Event(Event.CLOSE)); });
			infobar.changeImage(new $HeartFull())
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
			PushButton.withObject(itemImage, "auto", { size:grid.cellSize, data:{ itemData:itemData } })
				.toggle(_getIfItemDataWorn(itemData), false)
				.onToggle(function(e:FewfEvent){ _dispatchItemData(itemData, (e.target as PushButton).pushed); })
				.appendTo(cell);
			
			// Add on top of main button
			cell.addChild(actionTray);
			
			// Corresponding Delete Button
			ScaleButton.withObject(new $Trash(), 0.4).move(grid.cellSize-5, 5).appendTo(actionTray)
				.onButtonClick(function(e:Event){ _deleteFavorite(itemData); });
			
			// Corresponding GoTo Button
			var gtcpIconHolder:Sprite = new Sprite();
			DisplayWrapper.wrap(new $BackArrow(), gtcpIconHolder).toScale(-1, 1);
			ScaleButton.withObject(gtcpIconHolder, 0.5).move(grid.cellSize-6, grid.cellSize-6).appendTo(actionTray)
				.onButtonClick(function(e:Event){
					_dispatchItemData(itemData); // Toggle item on before going to it
					dispatchEvent(new ItemDataEvent(ITEMDATA_GOTO, itemData));
				});
			
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
		
		private function _dispatchItemData(itemData:ItemData, pSelected:Boolean=true) : void {
			dispatchEvent(new ItemDataEvent(pSelected ? ITEMDATA_SELECTED : ITEMDATA_REMOVED, itemData));
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
			// var list:Vector.<ItemData> = FavoriteItemsLocalStorageManager.getAllFavorites();
			// if(list.length > 0) {
			// 	_dispatchItemData( list[ Math.floor(Math.random() * list.length) ] );
			// }
			var tLength = grid.cells.length;
			var cell:DisplayObject = grid.cells[ Math.floor(Math.random() * tLength) ];
			var btn:PushButton = _findPushButtonInCell(cell);
			btn.toggleOn();
			if(_flagOpen) scrollItemIntoView(cell);
		}
		
		// We don't want this functionality for favorites since multiple can be selected at once
		public override function handleKeyboardDirectionalInput(keyCode:uint) : void {}
		// More than 1 item can be selected, so we need custom logic
		protected override function _onCellPushButtonToggled(e:FewfEvent) : void {
			for each(var btn:PushButton in buttons) {
				var tItemData:ItemData = btn.data.itemData;
				btn.toggle(_getIfItemDataWorn(tItemData), false);
			}
		}
	}
}