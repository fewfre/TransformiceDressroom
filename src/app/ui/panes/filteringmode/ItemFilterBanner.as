package app.ui.panes.filteringmode
{
	import app.ui.buttons.PushButton;
	import app.ui.buttons.ScaleButton;
	import com.fewfre.display.DisplayWrapper;
	import com.fewfre.display.RoundRectangle;
	import com.fewfre.display.TextTranslated;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class ItemFilterBanner extends Sprite
	{
		// Constants
		public static const ONLY_INCLUDE_CUSTOMIZATIONS_TOGGLED = "ONLY_INCLUDE_CUSTOMIZATIONS_TOGGLED";
		public static const FILTER_BANNER_CLOSED                = "filter_banner_closed";
		
		// Storage
		private var _tray : Sprite;
		private var _customizationToggle : PushButton;
		
		// Properties
		public function get onlyShowCustomizableItemsToggleOn() : Boolean { return _customizationToggle.pushed; };
		
		// Constructor
		public function ItemFilterBanner() {
			// Don't addChild to anything until something calls show()
			_tray = new Sprite();
			
			var hh:Number = 28-2/*minus 2 because of extra border*/;
			new RoundRectangle(260, hh).toOrigin(0, 0.5).toRadius(4).drawSolid(0xDDDDFF, 0x0000FF, 2).appendTo(_tray);
			DisplayWrapper.wrap(new $FilterIcon(), _tray).toScale(0.25).move(11, 0);
			new TextTranslated("share_filter_banner", { x:20, originX:0, originY:0.5, color:0x111111 }).appendToT(_tray);
			(_customizationToggle = new PushButton(20)).setImage(new $ColorWheel(), 0.4).setOrigin(0.5).move(220, 0).appendTo(_tray)
				.onButtonClick(dispatchEventHandler(ONLY_INCLUDE_CUSTOMIZATIONS_TOGGLED));
			new ScaleButton(new $No(), 0.5).move(245, 0).appendTo(_tray)
				.onButtonClick(dispatchEventHandler(FILTER_BANNER_CLOSED));
		}
		public function move(pX:Number, pY:Number) : ItemFilterBanner { x = pX; y = pY; return this; }
		public function appendTo(pParent:Sprite): ItemFilterBanner { pParent.addChild(this); return this; }
		public function on(type:String, listener:Function): ItemFilterBanner { this.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): ItemFilterBanner { this.removeEventListener(type, listener); return this; }
		
		///////////////////////
		// Public
		///////////////////////
		public function show() : void {
			addChild(_tray);
		}
		
		public function hide() : void {
			if(_tray.parent) _tray.parent.removeChild(_tray);
		}
		
		///////////////////////
		// Private
		///////////////////////
		private function dispatchEventHandler(pEventName:String) : Function {
			return function(e):void{ dispatchEvent(new Event(pEventName)); };
		}
	}
}
