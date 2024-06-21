
package app.ui.panes.base
{
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import fl.containers.ScrollPane;
	import flash.display.*;
	import com.fewfre.display.Grid;

	public class SidePane extends Sprite
	{
		// Storage
		protected var _flagOpen : Boolean;
		protected var _flagDirty : Boolean;
		
		// Properties
		public function get flagOpen() : Boolean { return _flagOpen; }
		
		// Constructor
		public function SidePane() {
			super();
			_flagOpen = false;
			_flagDirty = true;
		}
		
		public function open() : void {
			_flagOpen = true;
			if(_flagDirty) {
				_flagDirty = false;
				_onDirtyOpen();
			}
		}
		
		public function close() : void {
			_flagOpen = false;
		}
		
		public function makeDirty() : void {
			_flagDirty = true;
		}
		
		protected function _onDirtyOpen() : void {
			// override me
		}
	}
}