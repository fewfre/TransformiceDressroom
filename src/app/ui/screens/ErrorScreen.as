package app.ui.screens
{
	import app.data.GameAssets;
	import app.ui.buttons.ScaleButton;
	import com.fewfre.display.RoundRectangle;
	import com.fewfre.display.TextBase;
	import com.fewfre.utils.Fewf;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import app.data.ConstantsApp;

	public class ErrorScreen extends Sprite
	{
		// Storage
		private var _text			: TextBase;
		private var _string			: String;
		
		// Constructor
		public function ErrorScreen() {
			this.x = ConstantsApp.CENTER_X;
			this.y = ConstantsApp.CENTER_Y;
			
			/****************************
			* Click Tray
			*****************************/
			GameAssets.createScreenBackdrop().appendTo(this).on(MouseEvent.CLICK, _onCloseClicked);
			
			/****************************
			* Background
			*****************************/
			var tWidth:Number = 500, tHeight:Number = 200;
			new RoundRectangle(tWidth, tHeight).toOrigin(0.5).toRadius(25).draw3d(0xFFDDDD, 0xFF0000).appendTo(this);

			/****************************
			* Message
			*****************************/
			// We manually x center the text since we're using wordWrap which uses width instead of textWidth
			_text = new TextBase("", { color:0x330000, originX:0, originY:0.5, x:-(tWidth - 20) / 2 }).appendTo(this);
			_text.field.width = tWidth - 20;
			_text.field.wordWrap = true;
			
			/****************************
			* Close Button
			*****************************/
			ScaleButton.withObject(new $WhiteX()).move(tWidth/2 - 5, -tHeight/2 + 5).appendTo(this).onButtonClick(_onCloseClicked);
		}
		public function on(type:String, listener:Function): ErrorScreen { this.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): ErrorScreen { this.removeEventListener(type, listener); return this; }
		
		public function open(errorText:String) : void {
			// If screen already open just append to existing message
			if(_string) {
				errorText = _string+"\n\n"+errorText;
			}
			_text.text = _string = errorText;
		}
		
		private function _onCloseClicked(pEvent:Event) : void {
			_close();
		}
		
		private function _close() : void {
			_text.text = _string = "";
			dispatchEvent(new Event(Event.CLOSE));
		}
	}
}
