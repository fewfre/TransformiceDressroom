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
		private var _text			: TextTranslated;
		private var _string			: String;
		
		// Constructor
		// pData = {  }
		public function ErrorScreen() {
			this.x = Fewf.stage.stageWidth * 0.5;
			this.y = Fewf.stage.stageHeight * 0.5;
			
			/****************************
			* Click Tray
			*****************************/
			var tClickTray = addChild(new Sprite());
			tClickTray.x = -5000;
			tClickTray.y = -5000;
			tClickTray.graphics.beginFill(0x000000, 0.2);
			tClickTray.graphics.drawRect(0, 0, -tClickTray.x*2, -tClickTray.y*2);
			tClickTray.graphics.endFill();
			tClickTray.addEventListener(MouseEvent.CLICK, _onCloseClicked);
			
			/****************************
			* Background
			*****************************/
			var tWidth:Number = 500, tHeight:Number = 200;
			_tray = new RoundedRectangle(tWidth, tHeight, { origin:0.5 }).appendTo(this).draw(0xFFDDDD, 25, 0xFF0000);

			/****************************
			* Message
			*****************************/
			// We manually x center the text since we're using wordWrap which uses width instead of textWidth
			_text = new TextTranslated({ color:0x330000, originX:0, originY:0.5, x:-(_tray.Width - 20) / 2 }).appendTo(this);
			_text.field.width = _tray.Width - 20;
			_text.field.wordWrap = true;
			
			/****************************
			* Close Button
			*****************************/
			var tCloseButton:ScaleButton = addChild(new ScaleButton({ x:tWidth*0.5 - 5, y:-tHeight*0.5 + 5, obj:new $WhiteX() })) as ScaleButton;
			tCloseButton.addEventListener(ButtonBase.CLICK, _onCloseClicked);
		}
		
		public function open(errorText:String) : void {
			// If screen already open just append to existing message
			if(_string) {
				errorText = _string+"\n\n"+errorText;
			}
			_text.setUntranslatedText(_string = errorText);
		}
		
		private function _onCloseClicked(pEvent:Event) : void {
			_close();
		}
		
		private function _close() : void {
			_text.setUntranslatedText(_string = "");
			dispatchEvent(new Event(Event.CLOSE));
		}
	}
}
