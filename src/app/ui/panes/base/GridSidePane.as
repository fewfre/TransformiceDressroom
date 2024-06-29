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

	public class GridSidePane extends SidePaneWithInfobar
	{
		// Storage
		protected var _scrollbox : FancyScrollbox;
		protected var _grid : Grid;
		
		// Properties
		public function get scrollbox() : FancyScrollbox { return _scrollbox; }
		public function get grid() : Grid { return _grid; }
		public function get defaultScrollboxHeight() : Number { return _infoBar ? 385-60 : 385; }
		
		// Constructor
		public function GridSidePane(pColumns:Number) {
			super();
			_scrollbox = new FancyScrollbox(ConstantsApp.PANE_WIDTH, defaultScrollboxHeight).setXY(5, 5);
			addChild(_scrollbox);
			// Grid is purposely less wide than the scrollbox to add padding + prevent horizontal scrollbar
			_grid = new Grid(385, pColumns).setXY(15, 5);
			_scrollbox.add(_grid);
		}

		public function addToGrid(pItem:DisplayObject, addToStart:Boolean = false) : DisplayObject {
			_grid.add(pItem, addToStart);
			return pItem;
		}

		public function resetGrid() : void {
			_grid.reset();
		}

		public function refreshScrollbox() : void {
			_scrollbox.refresh();
		}

		public override function addInfoBar(pInfobar:Infobar) : Infobar {
			super.addInfoBar(pInfobar);
			_scrollbox.y += 60;
			_scrollbox.setSize(ConstantsApp.PANE_WIDTH, defaultScrollboxHeight);
			
			return pInfobar;
		}
		
		public function scrollItemIntoView(pItem:DisplayObject) : void {
			_scrollbox.scrollItemIntoView(pItem);
		}
		
		///////////////////////
		// Events
		///////////////////////
		protected override function _onInfobarReverseGridClicked(e:Event) : void {
			this.grid.reverse();
		}
	}
}