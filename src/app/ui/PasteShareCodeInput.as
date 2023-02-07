package app.ui
{
	import com.fewfre.display.TextBase;
	import app.ui.common.RoundedRectangle;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.events.FocusEvent;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	
	public class PasteShareCodeInput extends MovieClip
	{
		// Storage
		private var _textField			: TextField;
		private var _placeholderText	: TextBase;
		private var _placeholderState	: String;
		private var _placeholderTimeout	: Number;
		
		// Constructor
		// pData = { x:Number, y:Number, width?:Number, onChange:Function }
		public function PasteShareCodeInput(pData:Object) {
			this.x = pData.x;
			this.y = pData.y;
			var tOnShareCodeEntered = pData.onChange;
			
			var tTFWidth:Number = pData.width ? pData.width : 250, tTFHeight:Number = 18, tTFPaddingX:Number = 5, tTFPaddingY:Number = 5;
			// So much easier than doing it with those darn native text field options which have no padding.
			var tTextBackground:RoundedRectangle = new RoundedRectangle({ width:tTFWidth+tTFPaddingX*2, height:tTFHeight+tTFPaddingY*2, origin:0.5 })
				.appendTo(this).draw(0xdcdfea, 7, 0x444444);
			
			_textField = tTextBackground.addChild(new TextField()) as TextField;
			_textField.type = TextFieldType.INPUT;
			_textField.multiline = false;
			_textField.width = tTFWidth;
			_textField.height = tTFHeight;
			_textField.x = tTFPaddingX - tTextBackground.Width*0.5;
			_textField.y = tTFPaddingY - tTextBackground.Height*0.5;
			
			// Why TEXT_INPUT - https://stackoverflow.com/a/10049605/1411473
			_textField.addEventListener(TextEvent.TEXT_INPUT, function(e){
				var code = e.text;//_text.text;
				_textField.text = "";
				_forceShareFieldUnfocus();
				tOnShareCodeEntered(code, _setShareCodeProgress);
				e.preventDefault();
			});
			_placeholderText = tTextBackground.addChild(new TextBase({ text:"share_paste", originX:0, x:_textField.x+4 })) as TextBase;
			_placeholderText.mouseChildren = false;
			_placeholderText.mouseEnabled = false;
			_setShareCodeProgress("placeholder");
			
			_textField.addEventListener(FocusEvent.FOCUS_IN,  focusIn);
			_textField.addEventListener(FocusEvent.FOCUS_OUT, focusOut);
			// https://stackoverflow.com/a/3215687/1411473
			_textField.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, focusOut);
			_textField.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, focusOut);
		}
		
		private function focusIn(event:Event):void {
			if(_placeholderState != "focusIn") {
				_setShareCodeProgress("focusIn");
			}
		}
		
		private function focusOut(event:Event):void {
			if(_placeholderState == "focusIn") {
				_textField.text = "";
				_forceShareFieldUnfocus();
				_setShareCodeProgress("placeholder");
			}
		}
		
		private function _forceShareFieldUnfocus():void {
			_textField.stage.focus = null;
		}
		
		private function _setShareCodeProgress(state):void {
			_placeholderState = state;
			_placeholderText.alpha = 1;
			clearTimeout(_placeholderTimeout);
			switch(state) {
				case "focusIn": {
					_placeholderText.alpha = 0;
					break;
				}
				case "placeholder": {
					_placeholderText.setText("share_paste");
					_placeholderText.color = 0x666666;
					break;
				}
				case "success": {
					_placeholderText.setText("share_paste_success");
					_placeholderText.color = 0x01910d;
					_placeholderTimeout = setTimeout(function(){
						_setShareCodeProgress("placeholder");
					}, 1000);
					break;
				}
				case "invalid": {
					_placeholderText.setText("share_paste_invalid");
					_placeholderText.color = 0xc93302;
					_placeholderTimeout = setTimeout(function(){
						_setShareCodeProgress("placeholder");
					}, 1000);
					break;
				}
			}
		};
	}
}
