package app.ui
{
	import app.ui.buttons.*;
	import app.ui.common.RoundedRectangle;
	import com.fewfre.events.FewfEvent;
	import flash.display.Sprite;

	public class ShopTabList extends Sprite
	{
		// Constants
		public static const TAB_CLICKED			: String = "shop_tab_clicked";

		// Storage
		private var _bg: RoundedRectangle;
		public var tabs: Vector.<PushButton> = new Vector.<PushButton>();

		// Constructor
		// pTabDataList = Vector.<{ text:String, event:String }> }
		public function ShopTabList(pWidth:Number, pHeight:Number) {
			_bg = new RoundedRectangle({ width:pWidth, height:pHeight }).appendTo(this).drawAsTray();
			
			tabs = new Vector.<PushButton>();
		}
		public function setXY(pX:Number, pY:Number) : ShopTabList { x = pX; y = pY; return this; }
		public function appendTo(target:Sprite): ShopTabList { target.addChild(this); return this; }
		
		// Array<{ text:String, event:String }
		public function populate(pTabs:Vector.<Object>) : ShopTabList {
			var tXMargin:Number = 5;
			var tYMargin:Number = 5;
			var tHeight:Number = Math.min(65, (_bg.Height - tYMargin) / pTabs.length - tYMargin);
			var tWidth:Number = _bg.Width - (tXMargin * 2);
			var tYSpacing:Number = tHeight + tYMargin;
			var tX:Number = tXMargin;
			var tY:Number = tYMargin - tYSpacing; // Go back one space for when for loop adds one space.

			_clearAll();
			for(var i = 0; i < pTabs.length; i++) {
				_createTab(pTabs[i].text, tX, tY += tYSpacing, tWidth, tHeight, pTabs[i].event);
			}
			return this;
		}

		private function _createTab(pText:String, pX:Number, pY:Number, pWidth:Number, pHeight:Number, pEvent:String) : PushButton {
			var tBttn:PushButton = new PushButton({ x:pX, y:pY, width:pWidth, height:pHeight, text:pText, allowToggleOff:false, data:{ event:pEvent } });
			// tBttn.addEventListener(PushButton.STATE_CHANGED_BEFORE, function(tBttn){ return function(){ untoggle(tBttn, pEvent); }; }(tBttn));//, false, 0, true
			tBttn.addEventListener(PushButton.STATE_CHANGED_BEFORE, function():void{ untoggle(tBttn, pEvent); });
			addChild(tBttn)
			tabs.push(tBttn);
			return tBttn;
		}
		
		// Clear current tabs (if any)
		private function _clearAll() : void {
			for(var i = 0; i < tabs.length; i++) {
				removeChild(tabs[i]);
			}
			tabs = new Vector.<PushButton>();
		}
		
		public function getTabButton(pEventName:String) : PushButton {
			for each(var tab:PushButton in tabs) {
				if(tab.data.event == pEventName) {
					return tab;
				}
			}
			return null;
		}
		
		public function toggleTabOn(pEventName:String, pFireEvent:Boolean = true) : void {
			getTabButton(pEventName).toggleOn(pFireEvent);
		}

		public function UnpressAll() : void {
			untoggle();
		}

		private function untoggle(pTab:PushButton=null, pEvent:String=null) : void {
			// if (pTab != null && pTab.pushed) { return; }

			for(var i:int = 0; i < tabs.length; i++) {
				if (tabs[i].pushed && tabs[i] != pTab) {
					tabs[i].toggleOff();
				}
			}

			if(pEvent!=null) { dispatchEvent(new FewfEvent(TAB_CLICKED, pEvent)); }
		}
	}
}
