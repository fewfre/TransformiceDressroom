package app.ui.panes.base
{
	import app.ui.common.FancyScrollbox;
	import com.fewfre.display.Grid;
	import app.data.ConstantsApp;
	import flash.display.DisplayObject;
	import flash.ui.Keyboard;
	import com.fewfre.display.ButtonBase;
	import flash.events.Event;
	import app.ui.panes.infobar.GridManagementWidget;
	import app.ui.panes.infobar.Infobar;

	public class GridSidePane extends SidePane
	{
		// Storage
		protected var _scrollbox : FancyScrollbox;
		protected var _grid : Grid;
		protected var _infoBar : Infobar;
		
		// Properties
		public function get scrollbox() : FancyScrollbox { return _scrollbox; }
		public function get grid() : Grid { return _grid; }
		public function get infoBar() : Infobar { return _infoBar; }
		
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

		public function addInfoBar(pInfobar:Infobar) : Infobar {
			_infoBar = addChild(pInfobar) as Infobar;
			_infoBar.x = _infoBar.y = 5;
			_scrollbox.y += 60;
			_scrollbox.setSize(ConstantsApp.PANE_WIDTH, 385 - 60);
			
			_infoBar
				.on(GridManagementWidget.REVERSE_CLICKED, _onInfobarReverseGridClicked)
				.on(GridManagementWidget.LEFT_ARROW_CLICKED, _onInfobarLeftArrowClicked)
				.on(GridManagementWidget.RIGHT_ARROW_CLICKED, _onInfobarRightArrowClicked);
			
			return pInfobar;
		}
		
		public function scrollItemIntoView(pItem:DisplayObject) : void {
			_scrollbox.scrollItemIntoView(pItem);
		}
		
		public function handleKeyboardDirectionalInput(keyCode:uint) : void {
			// override me
		}
		
		///////////////////////
		// Events
		///////////////////////
		protected function _onInfobarReverseGridClicked(e:Event) : void {
			this.grid.reverse();
		}
		protected function _onInfobarLeftArrowClicked(e:Event) : void {
			handleKeyboardDirectionalInput(Keyboard.LEFT);
		}
		protected function _onInfobarRightArrowClicked(e:Event) : void {
			handleKeyboardDirectionalInput(Keyboard.RIGHT);
		}
	}
}