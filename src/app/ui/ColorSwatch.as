package app.ui
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	
	public class ColorSwatch extends Sprite
	{
		// Constants
		public static const BUTTON_CLICK:String="button_click";
		public static const ENTER_PRESSED:String="enter_pressed";
		
		// Storage
		public var selected:Boolean=false;
		private var _swatch:Sprite;
		private var _border:Sprite;
		private var _text:TextField;
		
		// Properties
		public function get textValue():String { return _text.text; }
		public function set value(pColor:uint) : void
		{
			_swatch.graphics.clear();
			_swatch.graphics.beginFill(pColor);
			_swatch.graphics.drawRoundRect(1, 1, 18, 18, 5);
			_swatch.graphics.endFill();
			_text.text = pColor.toString(16);
		}
		
		// Constructor
		public function ColorSwatch()
		{
			super();
			_text = addChild(new TextField());
			_text.defaultTextFormat = new TextFormat("Verdana", 11, 12763866);
			_text.x = 30;
			_text.y = 0;
			_text.border = true;
			_text.height = 18;
			_text.width = 60;
			_text.type = "input";
			_text.text = "000000";
			_text.maxChars = 6;
			_text.restrict = "0-9a-f";
			_text.addEventListener(flash.events.KeyboardEvent.KEY_UP, _onTextInputKeyUp);
			_text.addEventListener(flash.events.MouseEvent.CLICK, _onSwatchClicked);
			
			_swatch = addChild(new Sprite());
			_swatch.buttonMode = true;
			_swatch.graphics.beginFill(0);
			_swatch.graphics.drawRoundRect(1, 1, 18, 18, 5);
			_swatch.graphics.endFill();
			_swatch.addEventListener(flash.events.MouseEvent.CLICK, _onSwatchClicked);
			
			_border = addChild(new Sprite());
			_border.graphics.lineStyle(1.5, 0);
			_border.graphics.drawRoundRect(0, 0, 20, 20, 5);
		}

		private function _onTextInputKeyUp(pEvent:KeyboardEvent) : void {
			if(_text.text != "" || pEvent.charCode == 13) {
				dispatchEvent(new Event(ENTER_PRESSED));
			}
		}
		private function _onSwatchClicked(pEvent:MouseEvent) : void {
			dispatchEvent(new flash.events.Event(BUTTON_CLICK));
		}

		public function select() : void
		{
			if(selected) { return; }
			
			selected = true;
			_border.graphics.clear();
			_border.graphics.lineStyle(0.5, 8947848);
			_border.graphics.drawRoundRect(-1.5, -1.5, 23, 23, 5);
			_border.graphics.lineStyle(1.5, 0);
			_border.graphics.drawRoundRect(0, 0, 20, 20, 5);
		}

		public function unselect() : void
		{
			selected = false;
			_border.graphics.clear();
			_border.graphics.lineStyle(1.5, 0);
			_border.graphics.drawRoundRect(0, 0, 20, 20, 5);
		}
	}
}
