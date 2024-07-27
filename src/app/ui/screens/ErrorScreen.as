package app.ui.screens
{
	import app.data.*;
	import app.ui.buttons.*;
	import app.ui.common.*;
	import app.world.data.*;
	import com.adobe.images.*;
	import com.fewfre.display.*;
	import com.fewfre.events.*;
	import com.fewfre.utils.*;
	import flash.display.*;
	import flash.events.*;
	
	public class ErrorScreen extends MovieClip
	{
		// Storage
		private var _tray			: RoundedRectangle;
		private var _text			: TextBase;
		private var _string			: String;
		
		// Constructor
		public function ErrorScreen() {
			this.x = Fewf.stage.stageWidth * 0.5;
			this.y = Fewf.stage.stageHeight * 0.5;
			
			/****************************
			* Click Tray
			*****************************/
			GameAssets.createScreenBackdrop().appendTo(this).on(MouseEvent.CLICK, _onCloseClicked);
			
			/****************************
			* Background
			*****************************/
			var tWidth:Number = 500, tHeight:Number = 200;
			_tray = new RoundedRectangle(tWidth, tHeight, { origin:0.5 }).appendTo(this).draw(0xFFDDDD, 25, 0xFF0000);

			/****************************
			* Message
			*****************************/
			// We manually x center the text since we're using wordWrap which uses width instead of textWidth
			_text = new TextBase("", { color:0x330000, originX:0, originY:0.5, x:-(_tray.Width - 20) / 2 }).appendTo(this);
			_text.field.width = _tray.Width - 20;
			_text.field.wordWrap = true;
			
			/****************************
			* Close Button
			*****************************/
			ScaleButton.withObject(new $WhiteX()).setXY(tWidth/2 - 5, -tHeight/2 + 5).appendTo(this).on(ButtonBase.CLICK, _onCloseClicked);
		}
		
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
