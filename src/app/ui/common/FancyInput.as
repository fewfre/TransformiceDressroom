package app.ui.common
{
	import com.fewfre.display.RoundRectangle;
	import com.fewfre.display.TextTranslated;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	public class FancyInput extends Sprite
	{
		// Storage
		private var _textField			: TextField;
		private var _placeholderText	: TextTranslated;
		
		// Properties
		public function get text() : String { return _textField.text; }
		public function set text(pVal:String) : void { setText(pVal); }
		public function get field() : TextField { return _textField; }
		public function get placeholderTextBase() : TextTranslated { return _placeholderText; }
		
		// Constructor
		// pData = { text?:String, placeholder?:String, x:Number, y:Number, width?:Number, height?:Number=18, padding?:Number=5 }
		public function FancyInput(pData:Object) {
			this.x = pData.x;
			this.y = pData.y;
			var padding = pData.padding != null ? pData.padding : 5;
			
			var tTFWidth:Number = pData.width ? pData.width : 250;
			var tTFHeight:Number = pData.height ? pData.height : 18;
			// So much easier than doing it with those darn native text field options which have no padding.
			var tTextBackground:RoundRectangle = new RoundRectangle(tTFWidth+padding*2, tTFHeight+padding*2).toOrigin(0.5)
				.appendTo(this).toRadius(7).draw3d(0xdcdfea, 0x444444);
			
			_textField = addChild(new TextField()) as TextField;
			_textField.type = TextFieldType.INPUT;
			_textField.multiline = false;
			_textField.width = tTFWidth;
			_textField.height = tTFHeight;
			_textField.x = padding - tTextBackground.width*0.5;
			_textField.y = padding - tTextBackground.height*0.5;
			
			_placeholderText = new TextTranslated(pData.placeholder, { originX:0, x:_textField.x+4, color:0x666666 }).appendToT(this);
			_placeholderText.mouseChildren = false;
			_placeholderText.mouseEnabled = false;
			
			setText(pData.text || "");
			
			_textField.addEventListener(FocusEvent.FOCUS_IN, _onFocusIn);
			_textField.addEventListener(FocusEvent.FOCUS_OUT, _onFocusOut);
			// https://stackoverflow.com/a/3215687/1411473
			_textField.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, _onFocusOut);
			_textField.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, _onFocusOut);
		}
		public function move(pX:Number, pY:Number) : FancyInput { x = pX; y = pY; return this; }
		public function appendTo(pParent:Sprite): FancyInput { pParent.addChild(this); return this; }
		
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
		
		public function setText(pVal:String) : void {
			_textField.text = pVal;
			_placeholderText.alpha = _textField.text == "" ? 1 : 0;
		}
	}
}
