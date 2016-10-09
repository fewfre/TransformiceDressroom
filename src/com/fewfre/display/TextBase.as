package com.fewfre.display
{
	import flash.display.*;
	import flash.text.*;

	public class TextBase extends Sprite
	{
		// Constants
		public static const DEFAULT_FONT : String = "Verdana";
		public static const DEFAULT_SIZE : Number = 12;
		public static const DEFAULT_COLOR : int = 0xC2C2DA;

		// Storage
		protected var _text			: TextField;
		protected var _originX		: Number;
		protected var _originY		: Number;

		// Properties
		public function get field() : TextField { return _text; }

		public function get text() : String { return _text.text; }
		public function set text(pVal:String) { _text.text = pVal; }

		// Constructor
		// pData = { x:Number, y:Number, ?text:String, ?font:String, ?size:Number, ?color:int, ?origin:Number=0.5, ?originX:Number=0.5, ?originY:Number=0.5 }
		public function TextBase(pData:Object) {
			super();
			this.x = pData.x != null ? pData.x : 0;
			this.y = pData.y != null ? pData.y : 0;

			_text = addChild(new TextField());
			_text.defaultTextFormat = new TextFormat(
				pData.font != null ? pData.font : DEFAULT_FONT,
				pData.size != null ? pData.size : DEFAULT_SIZE,
				pData.color != null ? pData.color : DEFAULT_COLOR
			);
			_text.autoSize = TextFieldAutoSize.CENTER;
			_text.text = pData.text != null ? pData.text : "";

			originX = 0.5;
			originY = 0.5;
			if(pData.origin != null) { originX = originY = pData.origin; }
			if(pData.originX != null) { originX = pData.originX; }
			if(pData.originY != null) { originY = pData.originY; }

			_text.x = -_text.textWidth * originX - 2;
			_text.y = -_text.textHeight * originY - 2;
		}

		/****************************
		* Render
		*****************************/
		protected function _renderUp() : void {
			this.scaleX = this.scaleY = 1;
		}

		protected function _renderDown() : void
		{
			this.scaleX = this.scaleY = 0.9;
		}

		protected function _renderOver() : void {
			this.scaleX = this.scaleY = 1.1;
		}

		protected function _renderOut() : void {
			_renderUp();
		}

		protected function _renderDisabled() : void {
			this.scaleX = this.scaleY = 1;
		}

		/****************************
		* Methods
		*****************************/
		public function _dispatch(pEvent:String) : void {
			if(!_returnData) { dispatchEvent(new Event(pEvent)); }
			else {
				dispatchEvent(new FewfEvent(pEvent, _returnData));
			}
		}

		public function enable() : ButtonBase {
			_flagEnabled = true;
			_state = BUTTON_STATE_UP;
			_renderUp();
			return this;
		}

		/**********************************************************
		@description
		 **********************************************************/
		public function disable() : ButtonBase {
			_flagEnabled = false;
			_renderDisabled();
			return this;
		}
	}
}
