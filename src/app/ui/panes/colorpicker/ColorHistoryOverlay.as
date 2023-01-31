package app.ui.panes.colorpicker
{
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	import app.ui.buttons.ColorButton;
	import com.fewfre.display.ButtonBase;
	import com.fewfre.events.FewfEvent;
	
	public class ColorHistoryOverlay extends Sprite
	{
		// Constants
		public static const EVENT_COLOR_PICKED		: String = "event_color_picked";
		
		private static var HISTORY : Dictionary = new Dictionary();
		
		// Storage
		private var size : Number;
		
		// Constructor
		public function ColorHistoryOverlay(pSize:uint) {
			super();
			size = pSize;
			
			graphics.beginFill( 0x000000, 0.5 );
			graphics.drawRect( -size*0.5, -size*0.5, size, size );
		}
		
		/****************************
		* Public
		*****************************/
		// Clear old history tray data
		public function clearTray() : void {
			while(this.numChildren){
				this.removeChildAt(0);
			}
		}
		
		public function addHistory(itemID:String, color:int) {
			if(!HISTORY[itemID]) HISTORY[itemID] = [];
			var itemHistory = HISTORY[itemID];
			// Remove old value if there is one, and move it to front of the list
			if(itemHistory.indexOf(color) != -1) {
				itemHistory.splice(itemHistory.indexOf(color), 1);
			}
			itemHistory.unshift(color);
		}
		public function getHistoryColors(itemID:String) {
			if(!HISTORY[itemID]) HISTORY[itemID] = [];
			return HISTORY[itemID];
		}
		
		public function renderHistory(itemID:String) {
			var colors = getHistoryColors(itemID);
			if(colors.length > 0) {
				clearTray();
				
				var length = Math.min(colors.length, 9);
				var btnSize = 70, spacing = 10, columns = 3,
				tX = -(btnSize+spacing) * (columns-1)/2, tY = -(btnSize+spacing) * (columns-1)/2;
				for(var i = 0; i < length; i++) {
					var color = colors[i];
					var btn = new ColorButton({ color:color, x:tX+((i%columns) * (btnSize+spacing)), y:tY+(Math.floor(i/columns)*(btnSize+spacing)), size:btnSize });
					btn.addEventListener(ButtonBase.CLICK, _onHistoryColorClicked);
					this.addChild(btn);
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
