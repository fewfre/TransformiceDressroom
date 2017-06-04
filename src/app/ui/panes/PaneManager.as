package app.ui.panes
{
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import fl.containers.*;
	import flash.display.*;

	public class PaneManager extends MovieClip
	{
		// Storage
		protected var _panes	: Object; // Tab pane should be stored in here to easy access the one you desire.
		
		// Constructor
		public function PaneManager() {
			super();
			_panes = {};
		}
		
		public function addPane(pID:String, pPane:TabPane) : TabPane {
			_panes[pID] = pPane;
			return pPane;
		}
		
		public function openPane(pID:String) : void {
			closeAllPanes();
			addChild(_panes[pID]).open();
		}
		
		public function closePane(pID:String) : void {
			_closePane(_panes[pID]);
		}
		
		protected function _closePane(pPane:TabPane) : void {
			if(!pPane.flagOpen) { return; }
			removeChild(pPane).close();
		}
		
		public function getPane(pID:String) : TabPane {
			return _panes[pID];
		}
		
		public function closeAllPanes() : void {
			for(var key in _panes) {
				_closePane(_panes[key]);
			}
		}
		
		public function dirtyAllPanes() : void {
			for(var key in _panes) {
				_panes[key].makeDirty();
			}
		}
	}
}
