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

	public class ErrorScreen
	{
		// Storage
		private var _root   : Sprite;
		private var _text   : TextBase;
		private var _string : String;
		
		// Properties
		public function get root() : Sprite { return _root; }
		
		// Constructor
		public function ErrorScreen() {
			_root = new Sprite();
			_root.x = ConstantsApp.CENTER_X;
			_root.y = ConstantsApp.CENTER_Y;
			
			/****************************
			* Click Tray
			*****************************/
			GameAssets.createScreenBackdrop().appendTo(_root).on(MouseEvent.CLICK, _onCloseClicked);
			
			/****************************
			* Background
			*****************************/
			var tWidth:Number = 500, tHeight:Number = 200;
			new RoundRectangle(tWidth, tHeight).toOrigin(0.5).toRadius(25).draw3d(0xFFDDDD, 0xFF0000).appendTo(_root);

			/****************************
			* Message
			*****************************/
			// We manually x center the text since we're using wordWrap which uses width instead of textWidth
			_text = new TextBase("", { color:0x330000, originX:0, originY:0.5, x:-(tWidth - 20) / 2 }).appendTo(_root);
			_text.enableWordWrapUsingWidth(tWidth - 20);
			
			/****************************
			* Close Button
			*****************************/
			new ScaleButton(new $WhiteX()).move(tWidth/2 - 5, -tHeight/2 + 5).appendTo(_root).onButtonClick(_onCloseClicked);
		}
		public function appendTo(pParent:Sprite): ErrorScreen { pParent.addChild(_root); return this; }
		public function removeSelf(): ErrorScreen { if(_root.parent){ _root.parent.removeChild(_root); } return this; }
		public function on(type:String, listener:Function): ErrorScreen { _root.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): ErrorScreen { _root.removeEventListener(type, listener); return this; }
		public function onCloseRemoveSelf(): ErrorScreen { this.on(Event.CLOSE, function(e:Event):void { removeSelf(); }); return this; }
		
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
			_root.dispatchEvent(new Event(Event.CLOSE));
		}
	}
}
