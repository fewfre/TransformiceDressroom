package app.ui.panes.colorpicker
{
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	import app.ui.buttons.ColorButton;
	import com.fewfre.events.FewfEvent;
	
	public class ColorHistoryOverlay extends Sprite
	{
		// Constants
		public static const EVENT_COLOR_PICKED		: String = "event_color_picked";
		
		// Static
		private static var HISTORY : Dictionary = new Dictionary();
		
		// Storage
		private var size : uint;
		
		// Constructor
		public function ColorHistoryOverlay(pSize:uint) {
			super();
			size = pSize;
			
			graphics.beginFill( 0x000000, 0.5 );
			graphics.drawRect( -size*0.5, -size*0.5, size, size );
		}
		public function move(pX:Number, pY:Number) : ColorHistoryOverlay { x = pX; y = pY; return this; }
		public function appendTo(pParent:Sprite): ColorHistoryOverlay { pParent.addChild(this); return this; }
		public function on(type:String, listener:Function): ColorHistoryOverlay { this.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): ColorHistoryOverlay { this.removeEventListener(type, listener); return this; }
		
		/****************************
		* Public
		*****************************/
		// Clear old history tray data
		public function clearTray() : void {
			this.removeChildren();
		}
		
		public function addHistory(itemID:String, color:int) {
			if(!HISTORY[itemID]) HISTORY[itemID] = [];
			var itemHistory:Array = HISTORY[itemID];
			// Remove old value if there is one, and move it to front of the list
			if(itemHistory.indexOf(color) != -1) {
				itemHistory.splice(itemHistory.indexOf(color), 1);
			}
			itemHistory.unshift(color);
		}
		public function getHistoryColors(itemID:String) : Array {
			if(!HISTORY[itemID]) HISTORY[itemID] = [];
			return HISTORY[itemID];
		}
		
		public function renderHistory(itemID:String) {
			var colors:Array = getHistoryColors(itemID);
			if(colors.length > 0) {
				clearTray();
				
				var length = Math.min(colors.length, 9);
				var btnSize = 70, spacing = 10, columns = 3,
				xx = -(btnSize+spacing) * (columns-1)/2, yy = -(btnSize+spacing) * (columns-1)/2;
				for(var i = 0; i < length; i++) {
					new ColorButton(colors[i], btnSize).appendTo(this)
						.move(xx+((i%columns) * (btnSize+spacing)), yy+(Math.floor(i/columns)*(btnSize+spacing)))
						.onButtonClick(_onHistoryColorClicked);
				}
			}
		}
		
		/****************************
		* Private
		*****************************/
		private function _onHistoryColorClicked(e:FewfEvent) {
			dispatchEvent(new FewfEvent(EVENT_COLOR_PICKED, e.data));
		}
	}
}
