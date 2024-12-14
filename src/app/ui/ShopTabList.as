package app.ui
{
	import com.fewfre.display.RoundRectangle;
	import com.fewfre.events.FewfEvent;
	import flash.display.Sprite;
	import app.data.ConstantsApp;

	public class ShopTabList
	{
		// Constants
		public static const TAB_CLICKED : String = "shop_tab_clicked"; // FewfEvent<string>
		
		private static const MARGIN_X : Number = 5;
		private static const MARGIN_Y : Number = 5;
		private static const GAP : Number = 5;
		private static const MAX_BUTTON_HEIGHT : Number = 65;

		// Storage
		private var _root : Sprite;
		private var _bg: RoundRectangle;
		private var _tabs: Vector.<TabButton> = new Vector.<TabButton>();
		private var _buttonLayer: Sprite;
		private var _buttonWidth: Number;
		
		// Properties
		public function get x() : Number { return _root.x; }
		public function set x(pVal:Number) : void { _root.x = pVal; }
		public function get y() : Number { return _root.y; }
		public function set y(pVal:Number) : void { _root.y = pVal; }

		// Constructor
		public function ShopTabList(pWidth:Number, pHeight:Number) {
			_root = new Sprite();
			_buttonWidth = pWidth-MARGIN_X*2;
			_bg = new RoundRectangle(pWidth, pHeight).toOrigin(0).appendTo(_root).drawAsTray();
			_tabs = new Vector.<TabButton>();
			_buttonLayer = new Sprite(); _root.addChild(_buttonLayer);
		}
		public function move(pX:Number, pY:Number) : ShopTabList { this.x = pX; this.y = pY; return this; }
		public function appendTo(pParent:Sprite): ShopTabList { pParent.addChild(_root); return this; }
		public function on(type:String, listener:Function): ShopTabList { _root.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): ShopTabList { _root.removeEventListener(type, listener); return this; }
		
		///////////////////////
		// Setup
		///////////////////////
		public function reset() : void {
			_tabs = new Vector.<TabButton>();
			_buttonLayer.removeChildren();
		}
		
		public function addTab(pText:String, pId:String) : TabButton {
			var bttn:TabButton = new TabButton(_buttonWidth, MAX_BUTTON_HEIGHT, pText, pId);
			bttn.onToggle(_onTabClicked).appendTo(_buttonLayer);
			_tabs.push(bttn);
			_render();
			return bttn;
		}
		
		private function _render() : void {
			var tAreaHeight:Number = _bg.height - MARGIN_Y*2;
			
			var tButtonHeight:Number = Math.min(MAX_BUTTON_HEIGHT, (tAreaHeight - (GAP*(_tabs.length-1))) / _tabs.length);
			var xx:Number = MARGIN_X, yy:Number = MARGIN_Y;
			
			for(var i:int = 0; i < _tabs.length; i++) {
				_tabs[i].resize(_buttonWidth, tButtonHeight).move(xx, yy + (tButtonHeight+GAP)*i);
			}
		}
		
		///////////////////////
		// Public
		///////////////////////
		public function getSelectedTabId() : String {
			for(var i:int = 0; i < _tabs.length; i++) {
				if (_tabs[i].pushed) return _tabs[i].data.id.toString();
			}
			return null;
		}
		
		public function getTabButton(pId:String) : TabButton {
			for each(var tab:TabButton in _tabs) {
				if(tab.data.id == pId) return tab;
			}
			return null;
		}
		
		public function toggleTabOn(pId:String, pFireEvent:Boolean = true) : void {
			if(!pFireEvent) _untoggleAll(); // Manually untoggle them since they won't be if event doesn't fire
			getTabButton(pId).toggleOn(pFireEvent);
		}
		
		// We don't do it by default since coresponding pane may not exist when tab list populated.
		public function toggleOnFirstTab() : void {
			_tabs[0].toggleOn();
		}

		///////////////////////
		// Private
		///////////////////////
		private function _onTabClicked(e:FewfEvent) : void {
			_untoggleAll(e.target as TabButton);
			_root.dispatchEvent(new FewfEvent(TAB_CLICKED, e.data.id));
		}
			
		private function _untoggleAll(pTabToSkip:TabButton=null) : void {
			for(var i:int = 0; i < _tabs.length; i++) {
				if (_tabs[i].pushed && _tabs[i] != pTabToSkip) {
					_tabs[i].toggleOff(false);
				}
			}
		}
	}
}

import app.ui.buttons.PushButton;
import com.fewfre.display.DisplayWrapper;
import app.data.ConstantsApp;
import flash.display.Shape;
import com.fewfre.utils.Fewf;
import flash.display.Bitmap;
class TabButton extends PushButton {
	private var _lock:DisplayWrapper;
	
	public function TabButton(pWidth:Number, pHeight:Number, pText:String, pId:String) {
		super({ width:pWidth, height:pHeight });
		setData({ id:pId });
		setAllowToggleOff(false);
		
		_lock = DisplayWrapper.wrap(new $Lock(), this).move(2, 2).toScale(0);
		setLocked(false);
		setText(pText);
		
		_renderUp();
	}
	
	public function setLocked(pOn:Boolean) : TabButton {
		_lock.toScale(pOn ? 0.6 : 0);
		return this;
	}
}