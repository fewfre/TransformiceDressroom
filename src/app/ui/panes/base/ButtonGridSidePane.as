package app.ui.panes.base
{
	import app.ui.common.FancyScrollbox;
	import com.fewfre.display.Grid;
	import app.data.ConstantsApp;
	import flash.display.DisplayObject;
	import app.ui.ShopInfoBar;
	import flash.ui.Keyboard;
	import app.ui.buttons.PushButton;

	public class ButtonGridSidePane extends GridSidePane
	{
		// Storage
		public var buttons: Vector.<PushButton>;
		
		// Constructor
		public function ButtonGridSidePane(pColumns:Number) {
			super(pColumns);
			buttons = new Vector.<PushButton>();
		}

		public function addButton(pItem:PushButton) : PushButton {
			buttons.push(pItem);
			addToGrid(pItem);
			return pItem;
		}

		public function clearButtons() : void {
			buttons = new Vector.<PushButton>();
			resetGrid();
		}
		
		public override function handleKeyboardDirectionalInput(keyCode:uint) : void {
			if (keyCode == Keyboard.RIGHT){
				_traversePaneButtonGrid(true);
			}
			else if (keyCode == Keyboard.LEFT) {
				_traversePaneButtonGrid(false);
			}
			else if (keyCode == Keyboard.UP){
				_traversePaneButtonGridVertically(true);
			}
			else if (keyCode == Keyboard.DOWN) {
				_traversePaneButtonGridVertically(false);
			}
		}
		
		protected function _traversePaneButtonGrid(pRight:Boolean):void {
			var pane:ButtonGridSidePane = this;
			if(pane && pane.grid && pane.buttons && pane.buttons.length > 0 && pane.buttons[0] is PushButton) {
				var activeButtonIndex:int = _findIndexActivePushButton(buttons);
				if(activeButtonIndex == -1) { activeButtonIndex = pane.grid.reversed ? buttons.length-1 : 0; }
				
				var dir:int = (pRight ? 1 : -1) * (pane.grid.reversed ? -1 : 1),
					length:uint = buttons.length;
					
				var newI:int = activeButtonIndex+dir;
				// mod it so it wraps - `length` added before mod to allow a `-1` dir to properly wrap
				newI = (length + newI) % length;
				
				var btn:PushButton = buttons[newI];
				btn.toggleOn();
				_scrollbox.scrollItemIntoView(btn);
			}
		}
		
		protected function _traversePaneButtonGridVertically(pUp:Boolean):void {
			var pane:ButtonGridSidePane = this;
			if(pane && pane.grid && pane.buttons && pane.buttons.length > 0 && pane.buttons[0] is PushButton) {
				var activeButtonIndex:int = _findIndexActivePushButton(buttons);
				if(activeButtonIndex == -1) { activeButtonIndex = grid.reversed ? buttons.length-1 : 0; }
				var dir:int = (pUp ? -1 : 1) * (grid.reversed ? -1 : 1),
					length:uint = buttons.length;
				
				var rowI:Number = Math.floor(activeButtonIndex / grid.columns);
				rowI = (rowI + dir); // increment row in direction
				rowI = (grid.rows + rowI) % grid.rows; // wrap it in both directions
				var colI = activeButtonIndex % grid.columns;
				
				// we want to stay in the same column, and just move up/down a row
				// var newRowI:Number = (grid.rows + rowI) % grid.rows;
				var newI:int = rowI*grid.columns + colI;
				
				// since row is modded, it can only ever be out of bounds at the end - this happens if the last
				// row doesn't have enough items to fill all columns, and active column is in one of them.
				if(newI >= length) {
					// we solve it by going an extra step in our current direction, mod it again so it can wrap if needed,
					// and then we recalculate the button i
					rowI += dir;
					rowI = (grid.rows + rowI) % grid.rows; // wrap it again
					newI = rowI*grid.columns + colI;
				}
				
				var btn:PushButton = buttons[newI];
				btn.toggleOn();
				_scrollbox.scrollItemIntoView(btn);
			}
		}
		
		// Find the pressed button
		protected function _findIndexActivePushButton(pButtons:Vector.<PushButton>):int {
			for(var i:int = 0; i < pButtons.length; i++){
				if((pButtons[i] as PushButton).pushed){
					return i;
				}
			}
			return -1;
		}
	}
}