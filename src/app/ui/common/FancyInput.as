package app.ui.common
{
	import com.fewfre.display.RoundRectangle;
	import com.fewfre.display.TextTranslated;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	public class FancyInput
	{
		// Storage
		private var _root			: Sprite;
		private var _textField       : TextField;
		private var _placeholderText : TextTranslated;
		private var _background      : RoundRectangle;
		
		// Properties
		public function get root() : Sprite { return _root; }
		public function get text() : String { return _textField.text; }
		public function set text(pVal:String) : void { setText(pVal); }
		public function get field() : TextField { return _textField; }
		public function get placeholderTextBase() : TextTranslated { return _placeholderText; }
		
		// Constructor
		// pData = { width?:Number, height?:Number=18, padding?:Number=5 }
		public function FancyInput(pData:Object) {
			_root = new Sprite();
			var padding = pData.padding != null ? pData.padding : 5;
			
			var tTFWidth:Number = pData.width ? pData.width : 250;
			var tTFHeight:Number = pData.height ? pData.height : 18;
			// So much easier than doing it with those darn native text field options which have no padding.
			_background = new RoundRectangle(tTFWidth+padding*2, tTFHeight+padding*2).toOrigin(0.5)
				.appendTo(_root).toRadius(7).draw3d(0xdcdfea, 0x444444);
			
			_textField = _root.addChild(new TextField()) as TextField;
			_textField.type = TextFieldType.INPUT;
			_textField.multiline = false;
			_textField.width = tTFWidth;
			_textField.height = tTFHeight;
			_textField.x = padding - _background.width*0.5;
			_textField.y = padding - _background.height*0.5;
			
			_placeholderText = new TextTranslated("", { originX:0, x:_textField.x+4, color:0x666666 }).appendToT(_root);
			_placeholderText.mouseChildren = false;
			_placeholderText.mouseEnabled = false;
			
			_textField.addEventListener(FocusEvent.FOCUS_IN, _onFocusIn);
			_textField.addEventListener(FocusEvent.FOCUS_OUT, _onFocusOut);
			// https://stackoverflow.com/a/3215687/1411473
			_textField.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, _onFocusOut);
			_textField.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, _onFocusOut);
		}
		public function move(pX:Number, pY:Number) : FancyInput { _root.x = pX; _root.y = pY; return this; }
		public function appendTo(pParent:Sprite): FancyInput { pParent.addChild(_root); return this; }
		public function on_field(type:String, listener:Function): FancyInput { _textField.addEventListener(type, listener); return this; }
		public function off_field(type:String, listener:Function): FancyInput { _textField.removeEventListener(type, listener); return this; }
		
		protected function _onFocusIn(event:Event):void {
			_placeholderText.alpha = 0;
		}
		
		protected function _onFocusOut(event:Event):void {
			if(_textField.text == "") {
				_placeholderText.alpha = 1;
			}
			forceShareFieldUnfocus();
		}
		
		public function forceShareFieldUnfocus():void {
			_textField.stage.focus = null;
		}
		
		public function setText(pVal:String) : FancyInput {
			_textField.text = pVal;
			_placeholderText.alpha = _textField.text == "" ? 1 : 0;
			return this;
		}
		
		public function setPlaceholderText(pText:String) : FancyInput { _placeholderText.setText(pText); return this; }
		public function setPlaceholderUntranslatedText(pText:String) : FancyInput { _placeholderText.setUntranslatedText(pText); return this; }
		
		public function setRestrict(pRestrict:String): FancyInput { _textField.restrict = pRestrict; return this; }
	}
}
