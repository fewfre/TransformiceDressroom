package app.ui
{
	import app.ui.buttons.ScaleButton;
	import app.ui.common.FancyInput;
	import com.fewfre.events.FewfEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import app.ui.buttons.GameButton;
	
	public class PasteShareCodeInput extends Sprite
	{
		// Constants
		public static const CHANGE : String = "share_code_paste_change"; // FewfEvent<{ code:String, update:(state:String)=>void }>
		public static const UNDO_ICON_CLICKED : String = "undo_icon_clicked";
		
		// Storage
		private var _input              : FancyInput;
		private var _placeholderState   : String;
		private var _placeholderTimeout : Number;
		private var _undoIcon           : GameButton;
		
		// Constructor
		public function PasteShareCodeInput(pWidth:Number=250) {
			_input = new FancyInput({ width:pWidth }).setPlaceholderText("share_paste").appendTo(this);
			
			// Why TEXT_INPUT - https://stackoverflow.com/a/10049605/1411473
			_input.on_field(TextEvent.TEXT_INPUT, function(e){
				var code = e.text;//_text.text;
				_input.text = ""; // Remove it now that we already grabbed it
				_input.forceShareFieldUnfocus();
				dispatchEvent(new FewfEvent(CHANGE, { code:code, update:_setShareCodeProgress }));
				e.preventDefault();
			});
			_setShareCodeProgress("placeholder");
			
			(_undoIcon = new GameButton(20)).setImage(new $UndoArrow(), 0.5).setOrigin(1, 0.5).move(pWidth/2, 0).appendTo(this).setVisible(false)
				.onButtonClick(function(e:Event):void{ dispatchEvent(new Event(UNDO_ICON_CLICKED)); });
		}
		public function move(pX:Number, pY:Number) : PasteShareCodeInput { this.x = pX; this.y = pY; return this; }
		public function appendTo(pParent:Sprite): PasteShareCodeInput { pParent.addChild(this); return this; }
		public function on(type:String, listener:Function): PasteShareCodeInput { this.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): PasteShareCodeInput { this.removeEventListener(type, listener); return this; }
		
		public function toggleUndoIcon(pShow:Boolean) : PasteShareCodeInput {
			_undoIcon.setVisible(pShow);
			return this;
		}
		
		private function focusIn(event:Event):void {
			if(_placeholderState != "focusIn") {
				_setShareCodeProgress("focusIn");
			}
		}
		
		private function focusOut(event:Event):void {
			if(_placeholderState == "focusIn") {
				_input.text = "";
				_input.forceShareFieldUnfocus();
				_setShareCodeProgress("placeholder");
			}
		}
		
		private function _setShareCodeProgress(state):void {
			_placeholderState = state;
			_input.placeholderTextBase.alpha = 1;
			clearTimeout(_placeholderTimeout);
			switch(state) {
				case "focusIn": {
					_input.placeholderTextBase.alpha = 0;
					break;
				}
				case "placeholder": {
					_input.setPlaceholderText("share_paste");
					_input.placeholderTextBase.color = 0x666666;
					break;
				}
				case "loading": {
					_input.setPlaceholderUntranslatedText('...');
					_input.placeholderTextBase.color = 0x666666;
					break;
				}
				case "success": {
					_input.setPlaceholderText("share_paste_success");
					_input.placeholderTextBase.color = 0x01910d;
					_placeholderTimeout = setTimeout(function(){
						_setShareCodeProgress("placeholder");
					}, 1000);
					break;
				}
				case "invalid": {
					_input.setPlaceholderText("share_paste_invalid");
					_input.placeholderTextBase.color = 0xc93302;
					_placeholderTimeout = setTimeout(function(){
						_setShareCodeProgress("placeholder");
					}, 1000);
					break;
				}
			}
		};
	}
}
