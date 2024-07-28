package app.ui.panes.base
{
	import flash.display.Sprite;
	import com.fewfre.utils.Fewf;

	public class PaneManager extends Sprite
	{
		// Storage
		protected var _panes	: Object; // Tab pane should be stored in here to easy access the one you desire.
		
		// Constructor
		public function PaneManager() {
			super();
			_panes = {};
		}
		public function appendTo(pParent:Sprite): PaneManager { pParent.addChild(this); return this; }
		
		public function addPane(pID:String, pPane:SidePane) : SidePane {
			_panes[pID] = pPane;
			return pPane;
		}
		
		public function openPane(pID:String) : void {
			closeAllPanes();
			var pane:SidePane = _panes[pID];
			addChild(pane);
			pane.open();
			// This line is needed to fix a bug caused by clicking a button on a pane, changing panes
			// (which removed it from display), and then trying to use a keyboard event (since the
			// element we have focused was removed)
			Fewf.stage.focus = Fewf.stage;
		}
		
		public function closePane(pID:String) : void {
			_closePane(_panes[pID]);
		}
		
		protected function _closePane(pPane:SidePane) : void {
			if(!pPane.flagOpen) { return; }
			removeChild(pPane);
			pPane.close();
		}
		
		public function getPane(pID:String) : SidePane {
			return _panes[pID];
		}
		
		public function getOpenPane() : SidePane {
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
