package com.fewfre.display
{
	import com.fewfre.events.FewfEvent;
	import com.fewfre.utils.Fewf;
	import com.fewfre.utils.FewfUtils;
	import com.fewfre.utils.I18n;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class TextTranslated extends TextBase
	{
		protected var _i18n			: String;
		protected var _values		: Array; // Values used in i18n if {0} variables exist.

		// Properties
		public override function get text() : String { return _field.text; }
		public override function set text(pVal:String) : void { setText(pVal); }

		// Constructor
		// pArgs = { x:Number, y:Number, ?text:String, ?font:String, ?size:Number, ?color:int, ?origin:Number=0.5,
		//			?originX:Number=0.5, ?originY:Number=0.5, ?alpha:Number=1, ?values:*|Array }
		public function TextTranslated(pI18nKey:String, params:Object=null) {
			params = params || {};
			super("", params);
			
			_i18n = "";
			_values = params.values != null ? (params.values is Array ? params.values : [params.values]) : null;
			if(pI18nKey) {
				_setI18nData(pI18nKey);
			}
			
			_render();
			_addEventListeners();
		}
		public function setXYT(pX:Number, pY:Number) : TextTranslated { x = pX; y = pY; return this; }
		public function appendToT(target:Sprite): TextTranslated { target.addChild(this); return this; }

		/****************************
		* Events
		*****************************/
		protected function _addEventListeners() : void {
			Fewf.dispatcher.addEventListener(I18n.FILE_UPDATED, _onFileUpdated);
		}
		
		// Refresh text to new value.
		protected function _onFileUpdated(e:FewfEvent) : void {
			_setI18nData(_i18n);
			_render();
		}

		/****************************
		* Public
		*****************************/
		public override function setText(pKey:String) : void {
			_setI18nData(pKey != null ? pKey : "");
			_values = [];
			_render();
		}
		
		public function setUntranslatedText(pText:String) : void {
			_i18n = "";
			_text = pText;
			_values = [];
			_render();
		}
		
		public function setValues(...pValues) : void {
			_values = pValues[0] is Array ? pValues[0] : pValues;
			_render();
			
		}
		public function setTextWithValues(pKey:String, ...pValues) : void {
			_setI18nData(pKey != null ? pKey : "");
			_values = pValues[0] is Array ? pValues[0] : pValues;
			_render();
		}
		
		/****************************
		* Helper
		*****************************/
		protected function _setI18nData(pKey:String) : void {
			_i18n = pKey;
			var tI18nData:Object = Fewf.i18n.getData(pKey);
			if(tI18nData != null) {
				_text = tI18nData.text;
				_scale = tI18nData.scale != null ? tI18nData.scale : 1;
				_font = tI18nData.font != null ? tI18nData.font : Fewf.i18n.defaultFont;
			} else {
				_text = "<"+pKey+">";
			}
		}
		protected override function _getRenderText() : String {
			return _values != null ? FewfUtils.stringSubstitute(_text, _values) : _text;
		}
	}
}
