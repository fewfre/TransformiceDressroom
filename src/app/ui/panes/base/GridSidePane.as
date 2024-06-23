package app.ui.panes.base
{
	import app.ui.common.FancyScrollbox;
	import com.fewfre.display.Grid;
	import app.data.ConstantsApp;
	import flash.display.DisplayObject;
	import app.ui.ShopInfoBar;
	import flash.ui.Keyboard;
	import com.fewfre.display.ButtonBase;

	public class GridSidePane extends SidePane
	{
		// Storage
		protected var _scrollbox : FancyScrollbox;
		protected var _grid : Grid;
		protected var _infoBar : ShopInfoBar;
		
		// Properties
		public function get scrollbox() : FancyScrollbox { return _scrollbox; }
		public function get grid() : Grid { return _grid; }
		public function get infoBar() : ShopInfoBar { return _infoBar; }
		
		// Constructor
		public function GridSidePane(pColumns:Number) {
			super();
			_scrollbox = new FancyScrollbox(ConstantsApp.PANE_WIDTH, 385).setXY(5, 5);
			addChild(_scrollbox);
			// Grid is purposely less wide than the scrollbox to add padding + prevent horizontal scrollbar
			_grid = new Grid(385, pColumns).setXY(15, 5);
			_scrollbox.add(_grid);
		}

		public function addToGrid(pItem:DisplayObject) : DisplayObject {
			_grid.add(pItem);
			return pItem;
		}

		public function resetGrid() : void {
			_grid.reset();
		}

		public function refreshScrollbox() : void {
			_scrollbox.refresh();
		}

		public function addInfoBar(pBar:ShopInfoBar) : void {
			_infoBar = addChild(pBar) as ShopInfoBar;
			_infoBar.x = _infoBar.y = 5;
			_scrollbox.y += 60;
			_scrollbox.setSize(ConstantsApp.PANE_WIDTH, 385 - 60);
			
			if(_infoBar.leftItemButton) _infoBar.leftItemButton.addEventListener(ButtonBase.CLICK, function(){ handleKeyboardDirectionalInput(Keyboard.LEFT); });
			if(_infoBar.rightItemButton) _infoBar.rightItemButton.addEventListener(ButtonBase.CLICK, function(){ handleKeyboardDirectionalInput(Keyboard.RIGHT); });
		}
		
		public function scrollItemIntoView(pItem:DisplayObject) : void {
			_scrollbox.scrollItemIntoView(pItem);
		}
		
		public function handleKeyboardDirectionalInput(keyCode:uint) : void {
			// override me
		}
	}
}