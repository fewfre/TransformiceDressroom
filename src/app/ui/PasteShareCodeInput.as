package app.ui
{
	import com.fewfre.display.TextTranslated;
	import app.ui.common.RoundedRectangle;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.events.FocusEvent;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import app.ui.common.FancyInput;
	
	public class PasteShareCodeInput extends Sprite
	{
		// Storage
		private var _input              : FancyInput;
		private var _placeholderState   : String;
		private var _placeholderTimeout : Number;
		
		// Constructor
		// pData = { x:Number, y:Number, width?:Number, onChange:(code, (state:String)=>void)=>void }
		public function PasteShareCodeInput(pData:Object) {
			this.x = pData.x;
			this.y = pData.y;
			var tOnShareCodeEntered = pData.onChange;
			
			_input = new FancyInput({ width:pData.width || 250, placeholder:"share_paste" }).appendTo(this);
			
			// Why TEXT_INPUT - https://stackoverflow.com/a/10049605/1411473
			_input.field.addEventListener(TextEvent.TEXT_INPUT, function(e){
				var code = e.text;//_text.text;
				_input.text = "";
				_forceShareFieldUnfocus();
				tOnShareCodeEntered(code, _setShareCodeProgress);
				e.preventDefault();
			});
			_setShareCodeProgress("placeholder");
		}
		
		private function focusIn(event:Event):void {
			if(_placeholderState != "focusIn") {
				_setShareCodeProgress("focusIn");
			}
		}
		
		private function focusOut(event:Event):void {
			if(_placeholderState == "focusIn") {
				_input.text = "";
				_forceShareFieldUnfocus();
				_setShareCodeProgress("placeholder");
			}
		}
		
		private function _forceShareFieldUnfocus():void {
			_input.stage.focus = null;
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
					_input.placeholderTextBase.setText("share_paste");
					_input.placeholderTextBase.color = 0x666666;
					break;
				}
				case "loading": {
					_input.placeholderTextBase.setUntranslatedText('...');
					_input.placeholderTextBase.color = 0x666666;
					break;
				}
				case "success": {
					_input.placeholderTextBase.setText("share_paste_success");
					_input.placeholderTextBase.color = 0x01910d;
					_placeholderTimeout = setTimeout(function(){
						_setShareCodeProgress("placeholder");
					}, 1000);
					break;
				}
				case "invalid": {
					_input.placeholderTextBase.setText("share_paste_invalid");
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
