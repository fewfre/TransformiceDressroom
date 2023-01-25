package app.ui.panes
{
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import fl.containers.*;
	import flash.display.*;
	import com.fewfre.utils.Fewf;

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
			(addChild(_panes[pID]) as TabPane).open();
			// This line is needed to fix a bug caused by clicking a button on a pane, changing panes
			// (which removed it from display), and then trying to use a keyboard event (since the
			// element we have focused was removed)
			Fewf.stage.focus = Fewf.stage;
		}
		
		public function closePane(pID:String) : void {
			_closePane(_panes[pID]);
		}
		
		protected function _closePane(pPane:TabPane) : void {
			if(!pPane.flagOpen) { return; }
			(removeChild(pPane) as TabPane).close();
		}
		
		public function getPane(pID:String) : TabPane {
			return _panes[pID];
		}
		
		public function getOpenPane() : TabPane {
			for(var key in _panes) {
				if(_panes[key].flagOpen) {
					return _panes[key];
				}
			}
			return null;
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
