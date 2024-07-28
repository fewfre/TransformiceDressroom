package app.ui.panes.base
{
	import app.ui.common.FancyScrollbox;
	import com.fewfre.display.Grid;
	import app.data.ConstantsApp;
	import flash.display.DisplayObject;
	import app.ui.ShopInfoBar;
	import flash.ui.Keyboard;
	import app.ui.buttons.PushButton;
	import flash.display.Sprite;
	import com.fewfre.events.FewfEvent;

	public class ButtonGridSidePane extends GridSidePane
	{
		// Storage
		public var buttons: Vector.<PushButton>;
		// private var _lastGridIndex : uint;
		
		// Constructor
		public function ButtonGridSidePane(pColumns:Number) {
			super(pColumns);
			buttons = new Vector.<PushButton>();
			// _lastGridIndex = 0;
		}

		public override function addToGrid(pItem:DisplayObject, addToStart:Boolean = false) : DisplayObject {
			super.addToGrid(pItem, addToStart);
			// For this to work the button must be added to `pItem` *before* it's passed in
			var btn:PushButton = _findPushButtonInCell(pItem);
			if(btn) {
				btn.on(PushButton.TOGGLE, _onCellPushButtonToggled);
				addToStart ? buttons.unshift(btn) : buttons.push(btn);
			}
			return pItem;
		}
		
		public override function resetGrid():void {
			super.resetGrid();
			buttons = new Vector.<PushButton>();
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
			if(_grid.cells.length > 0) {
				var activeButtonIndex:int = _findIndexOfActiveGridCell();
				// var activeButtonIndex:int = _findIndexActivePushButton(buttons);
				if(activeButtonIndex == -1) { activeButtonIndex = _grid.reversed ? buttons.length-1 : 0; }
				
				var dir:int = (pRight ? 1 : -1) * (_grid.reversed ? -1 : 1),
					length:uint = _grid.cells.length;
					
				var newI:int = activeButtonIndex+dir;
				// mod it so it wraps - `length` added before mod to allow a `-1` dir to properly wrap
				newI = (length + newI) % length;
				
				_activatePushButtonGridCell(_grid.cells[newI]);
			}
		}
		
		protected function _traversePaneButtonGridVertically(pUp:Boolean):void {
			if(_grid.cells.length > 0) {
				var activeButtonIndex:int = _findIndexOfActiveGridCell();
				// var activeButtonIndex:int = _findIndexActivePushButton(buttons);
				if(activeButtonIndex == -1) { activeButtonIndex = grid.reversed ? _grid.cells.length-1 : 0; }
				var dir:int = (pUp ? -1 : 1) * (_grid.reversed ? -1 : 1),
					length:uint = _grid.cells.length;
				
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
				
				_activatePushButtonGridCell(_grid.cells[newI]);
			}
		}
		
		// If component or a child of the component is a `PushButton` then push it
		protected function _activatePushButtonGridCell(cell:DisplayObject) : void {
			var btn:PushButton = _findPushButtonInCell(cell);
			if(btn) {
				btn.toggleOn();
				if(_flagOpen) scrollItemIntoView(cell);
			}
		}
		
		// If component or first child of the component is a `PushButton` then return it
		protected function _findPushButtonInCell(o:DisplayObject) : PushButton {
			if(!o) { return null; }
			if(o is PushButton) {
				return (o as PushButton);
			} else if(o is Sprite) {
				var sprite:Sprite = o as Sprite;
				if(sprite.numChildren > 0 && sprite.getChildAt(0) is PushButton) {
					return sprite.getChildAt(0) as PushButton;
				}
			}
			return null;
		}
		
		// protected function _getSelectedCell() : DisplayObject {
		// 	return _grid.cells[_lastGridIndex];
		// }
		
		// Find the pressed button
		protected function _findIndexActivePushButton(pButtons:Vector.<PushButton>):int {
			for(var i:int = 0; i < pButtons.length; i++){
				if((pButtons[i] as PushButton).pushed){
					return i;
				}
			}
			return -1;
		}
		
		protected function _findIndexOfActiveGridCell():int {
			var btn:PushButton;
			for(var i:int = 0; i < _grid.cells.length; i++){
				btn = _findPushButtonInCell(_grid.cells[i]);
				if(!!btn && btn.pushed){
					return i;
				}
			}
			return -1;
		}

		protected function _onCellPushButtonToggled(e:FewfEvent) : void {
			_untoggleAllCells(e.currentTarget as PushButton);
		}
		protected function _untoggleAllCells(pExceptButton:PushButton=null) : void {
			var btn:PushButton;
			for(var i:int = 0; i < _grid.cells.length; i++) {
				btn = _findPushButtonInCell(_grid.cells[i]);
				if (!!btn && btn.pushed && btn != pExceptButton) {
					btn.toggleOff();
				}
			}
		}
	}
}