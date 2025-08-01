package com.fewfre.display
{
	import com.fewfre.utils.Fewf;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class TextBase extends Sprite
	{
		// Constants
		public static const DEFAULT_SIZE : Number = 12;
		public static const DEFAULT_COLOR : int = 0xC2C2DA;

		// Storage
		protected var _text       : String;
		protected var _field      : TextField;
		
		protected var _originX    : Number;
		protected var _originY    : Number;
		
		protected var _color      : int;
		protected var _size       : Number;
		protected var _font       : String;
		protected var _scale      : Number;
		protected var _align      : String;
		
		protected var _bold       : Boolean;
		protected var _italic     : Boolean;

		// Properties
		public function get text() : String { return _field.text; }
		public function set text(pVal:String) : void { setText(pVal); }
		
		public function get field() : TextField { return _field; }
		
		public function get color() : int { return _color; }
		public function set color(pVal:int) : void { _color = pVal; _render(); }
		public function get size() : Number { return _size; }
		public function set size(pVal:Number) : void { _size = pVal; _render(); }
		public function get font() : String { return _font; }
		public function set font(pVal:String) : void { _font = pVal; _render(); }

		// Constructor
		/**
		 * pArgs:
		 *   ?x:Number, ?y:Number, ?text:String,
		 *   ?origin:Number=0.5, ?originX:Number=0.5, ?originY:Number=0.5, ?alpha:Number=1,
		 *   ?font:String, ?size:Number, ?color:int,
		 */
		public function TextBase(pText:String, params:Object=null) {
			params = params || {};
			super();
			this.x = params.x != null ? params.x : 0;
			this.y = params.y != null ? params.y : 0;
			
			_color = params.color != null ? params.color : DEFAULT_COLOR;
			_size = params.size != null ? params.size : DEFAULT_SIZE;
			_font = params.font != null ? params.font : Fewf.i18n.defaultFont;
			_scale = 1;
			_align = params.align != null ? params.align : TextFormatAlign.CENTER;
			
			_bold = params.bold != null ? params.bold : false;
			_italic = params.italic != null ? params.italic : false;
			
			_text = pText;
			
			_originX = 0.5;
			_originY = 0.5;
			if(params.origin != null) { _originX = _originY = params.origin; }
			if(params.originX != null) { _originX = params.originX; }
			if(params.originY != null) { _originY = params.originY; }
			
			alpha = params.alpha != null ? params.alpha : 1;
			
			_field = addChild(new TextField()) as TextField;
			_render();
		}
		public function move(pX:Number, pY:Number) : TextBase { x = pX; y = pY; return this; }
		public function appendTo(pParent:Sprite): TextBase { pParent.addChild(this); return this; }

		/****************************
		* Render
		*****************************/
		protected function _render() : void {
			_field.defaultTextFormat = new TextFormat(_font, _size * _scale, _color, _bold, _italic, null, null, null, _align);
			_field.autoSize = TextFieldAutoSize.CENTER;
			_field.text = _getRenderText();
			if(!_field.wordWrap) {
				_field.x = -_field.textWidth * _originX - 2;
			} else {
				// Since word wrapping uses a defined width, center on that instead
				_field.x = -_field.width * _originX - 2;
			}
			_field.y = -_field.textHeight * _originY - 2;
		}

		/****************************
		* Public
		*****************************/
		public function setText(pText:String) : void {
			_text = pText;
			_render();
		}
		
		public function enableWordWrapUsingWidth(pWidth:Number) : TextBase {
			_field.width = pWidth;
			_field.wordWrap = true;
			_render();
			return this;
		}
		
		/****************************
		* Helper
		*****************************/
		protected function _getRenderText() : String {
			return _text;
		}
	}
}
