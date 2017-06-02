package com.fewfre.display
{
	import com.fewfre.utils.*;
	import flash.display.*;
	import flash.text.*;
	
	public class TextBase extends Sprite
	{
		// Constants
		public static const DEFAULT_SIZE : Number = 12;
		public static const DEFAULT_COLOR : int = 0xC2C2DA;

		// Storage
		protected var _text			: String;
		protected var _i18n			: String;
		protected var _values		: String; // Values used in i18n if {0} variables exist.
		
		protected var _field		: TextField;
		
		protected var _originX		: Number;
		protected var _originY		: Number;
		
		protected var _color		: int;
		protected var _size			: Number;
		protected var _font			: String;
		protected var _scale		: Number;

		// Properties
		public function get text() : String { return _field.text; }
		public function set text(pVal:String) : void { setText(pVal); }
		
		public function get field() : TextField { return _field; }
		
		public function set color(pVal:int) : void { _color = pVal; _render(); }
		public function set size(pVal:Number) : void { _size = pVal; _render(); }
		public function set font(pVal:String) : void { _font = pVal; _render(); }

		// Constructor
		// pArgs = { x:Number, y:Number, ?text:String, ?font:String, ?size:Number, ?color:int, ?origin:Number=0.5,
		//			?originX:Number=0.5, ?originY:Number=0.5, ?alpha:Number=1, ?values:*|Array }
		public function TextBase(pArgs:Object) {
			super();
			this.x = pArgs.x != null ? pArgs.x : 0;
			this.y = pArgs.y != null ? pArgs.y : 0;
			
			_color = pArgs.color != null ? pArgs.color : DEFAULT_COLOR;
			_size = pArgs.size != null ? pArgs.size : DEFAULT_SIZE;
			_font = pArgs.font != null ? pArgs.font : Fewf.i18n.defaultFont;
			_scale = 1;
			
			_i18n = "";
			_text = "";
			_values = pArgs.values != null ? (pArgs.values is Array ? pArgs.values : [pArgs.values]) : null;
			if(pArgs.text) {
				_setI18nData(pArgs.text);
			}
			
			_originX = 0.5;
			_originY = 0.5;
			if(pArgs.origin != null) { _originX = _originY = pArgs.origin; }
			if(pArgs.originX != null) { _originX = pArgs.originX; }
			if(pArgs.originY != null) { _originY = pArgs.originY; }
			originX = _originX;
			originY = _originY;
			
			alpha = pArgs.alpha != null ? pArgs.alpha : 1;
			
			_field = addChild(new TextField());
			_render();
		}

		/****************************
		* Render
		*****************************/
		protected function _render() : void {
			_field.defaultTextFormat = new TextFormat(_font, _size * _scale, _color);
			_field.autoSize = TextFieldAutoSize.CENTER;
			_field.text = _values != null ? FewfUtils.stringSubstitute(_text, _values) : _text;
			_field.x = -_field.textWidth * _originX - 2;
			_field.y = -_field.textHeight * _originY - 2;
		}

		/****************************
		* Public
		*****************************/
		public function setText(pKey:String, ...pValues) : void {
			_setI18nData(pKey != null ? pKey : "");
			_values = pValues[0] is Array ? pValues[0] : pValues;
			_render();
		}
		
		public function setValues(...pValues) : void {
			_values = pValues[0] is Array ? pValues[0] : pValues;
			_render();
		}
		
		/****************************
		* Helper
		*****************************/
		private function _setI18nData(pKey:String) : void {
			_i18n = pKey;
			var tI18nData = Fewf.i18n.getData(pKey);
			if(tI18nData != null) {
				_text = tI18nData.text;
				_scale = tI18nData.scale != null ? tI18nData.scale : 1;
				_font = tI18nData.font != null ? tI18nData.font : Fewf.i18n.defaultFont;
			} else {
				_text = "<"+pKey+">";
			}
		}
	}
}
