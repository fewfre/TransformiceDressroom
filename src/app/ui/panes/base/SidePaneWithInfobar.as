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

	public class SidePaneWithInfobar extends SidePane
	{
		// Storage
		protected var _infobar : Infobar;
		
		// Properties
		public function get infobar() : Infobar { return _infobar; }
		
		// Constructor
		public function SidePaneWithInfobar() {
			super();
		}

		public function addInfobar(pInfobar:Infobar) : Infobar {
			_infobar = pInfobar
				.on(GridManagementWidget.REVERSE_CLICKED, _onInfobarReverseGridClicked)
				.on(GridManagementWidget.LEFT_ARROW_CLICKED, _onInfobarLeftArrowClicked)
				.on(GridManagementWidget.RIGHT_ARROW_CLICKED, _onInfobarRightArrowClicked);
			_infobar.x = _infobar.y = 5;
			addChild(_infobar);
			
			return pInfobar;
		}
		
		public function handleKeyboardDirectionalInput(keyCode:uint) : void {
			// override me
		}
		
		///////////////////////
		// Events
		///////////////////////
		protected function _onInfobarReverseGridClicked(e:Event) : void {
			// override me
		}
		protected function _onInfobarLeftArrowClicked(e:Event) : void {
			handleKeyboardDirectionalInput(Keyboard.LEFT);
		}
		protected function _onInfobarRightArrowClicked(e:Event) : void {
			handleKeyboardDirectionalInput(Keyboard.RIGHT);
		}
	}
}