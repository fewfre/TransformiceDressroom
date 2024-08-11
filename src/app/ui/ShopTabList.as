package app.ui
{
	import app.ui.buttons.PushButton;
	import com.fewfre.display.RoundRectangle;
	import com.fewfre.events.FewfEvent;
	import flash.display.Sprite;

	public class ShopTabList extends Sprite
	{
		// Constants
		public static const TAB_CLICKED : String = "shop_tab_clicked"; // FewfEvent<string>
		
		private static const MARGIN_X : Number = 5;
		private static const MARGIN_Y : Number = 5;

		// Storage
		private var _bg: RoundRectangle;
		private var _tabs: Vector.<PushButton> = new Vector.<PushButton>();

		// Constructor
		public function ShopTabList(pWidth:Number, pHeight:Number) {
			_bg = new RoundRectangle(pWidth, pHeight).appendTo(this).drawAsTray();
			_tabs = new Vector.<PushButton>();
		}
		public function move(pX:Number, pY:Number) : ShopTabList { x = pX; y = pY; return this; }
		public function appendTo(pParent:Sprite): ShopTabList { pParent.addChild(this); return this; }
		
		// Vector<{ text:String, id:String }
		public function populate(pTabs:Vector.<Object>) : ShopTabList {
			var tHeight:Number = Math.min(65, (_bg.height - MARGIN_Y) / pTabs.length - MARGIN_Y);
			var tWidth:Number = _bg.width - (MARGIN_X * 2);
			var tYSpacing:Number = tHeight + MARGIN_Y;
			var tX:Number = MARGIN_X;
			var tY:Number = MARGIN_Y - tYSpacing; // Go back one space to account for loop adding a space.

			_clearAll();
			for(var i = 0; i < pTabs.length; i++) {
				var tBttn:PushButton = _createTab(pTabs[i].text, tX, tY += tYSpacing, tWidth, tHeight, pTabs[i].id);
				_tabs.push(tBttn);
			}
			return this;
		}
		private function _createTab(pText:String, pX:Number, pY:Number, pWidth:Number, pHeight:Number, pId:String) : PushButton {
			return new PushButton({ width:pWidth, height:pHeight, text:pText, data:{ id:pId } })
				.setAllowToggleOff(false)
				.onToggle(function(e:FewfEvent):void{
					_untoggleAll(e.target as PushButton);
					dispatchEvent(new FewfEvent(TAB_CLICKED, pId));
				})
				.move(pX, pY).appendTo(this) as PushButton;
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
		
		public function getTabButton(pId:String) : PushButton {
			for each(var tab:PushButton in _tabs) {
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
		private function _untoggleAll(pTab:PushButton=null) : void {
			PushButton.untoggleAll(_tabs, pTab);
		}
		
		// Clear current tabs (if any)
		private function _clearAll() : void {
			for(var i = 0; i < _tabs.length; i++) { removeChild(_tabs[i]); }
			_tabs = new Vector.<PushButton>();
		}
	}
}
