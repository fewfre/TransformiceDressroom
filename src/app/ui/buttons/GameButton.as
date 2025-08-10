package app.ui.buttons
{
	import com.fewfre.display.ButtonBase;
	import app.data.ConstantsApp;
	import com.fewfre.display.RoundRectangle;
	import com.fewfre.display.TextBase;
	import flash.display.DisplayObject;
	import com.fewfre.display.DisplayWrapper;
	import com.fewfre.utils.FewfDisplayUtils;
	import flash.geom.Rectangle;
	import com.fewfre.display.TextTranslated;
	
	public class GameButton extends ButtonBase
	{
		// Storage
		protected var _bg    : RoundRectangle;
		protected var _image : DisplayObject;
		protected var _text  : TextBase;
		
		// Properties
		public function get Image():DisplayObject { return _image; }
		public function get Text():TextBase { return _text; }
		public function get Width():Number { return _bg.width; }
		public function get Height():Number { return _bg.height; }
		
		// Constructor
		// If pHeight isn't set it will default to the same as the width
		public function GameButton(pWidth:Number, pHeight:Number=NaN) {
			if(isNaN(pHeight)) pHeight = pWidth;
			(_bg = new RoundRectangle(pWidth, pHeight)).toRadius(7).appendTo(this);
			super();
		}
		public function setOrigin(pX:Number, pY:Object=null) : GameButton { _bg.toOrigin(pX, pY); _rerenderChildren(); return this; }
		public function resize(pWidth:Number, pHeight:Object = null) : GameButton { _bg.resize(pWidth, pHeight); _rerenderChildren(); return this; }

		/////////////////////////////
		// Public
		/////////////////////////////
		public function setTextObject(pTextObj:TextBase) : GameButton {
			_clearChildren();
			_text = pTextObj;
			var offsetY : Number = -_text.size*0.04; // The center origin logic for text seems to result in it being slightly lower than expected; knock it up a hair
			pTextObj.move(this.Width * (0.5 - _bg.originX), this.Height * (0.5 - _bg.originY) + offsetY).appendTo(this);
			return this;
		}
		public function setText(pKey:String, params:Object = null) : GameButton { return setTextObject(new TextTranslated(pKey, params)); }
		public function setTextUntranslated(pText:String, params:Object = null) : GameButton { return setTextObject(new TextBase(pText, params)); }

		// Sets the image and if needed scales it to fit into the button nicely
		public function setImage(pImage:DisplayObject, pDefaultScale:Number=NaN) : GameButton {
			if(isNaN(pDefaultScale)) pDefaultScale = pImage.scaleX;
			_clearChildren();
			_image = DisplayWrapper.wrap(pImage, this)
				.move(this.Width * (0.5 - _bg.originX), this.Height * (0.5 - _bg.originY)) // move it to center
				.toScale(pDefaultScale) // scale before fitting to bounds
				.fitWithinBounds(this.Width * 0.9, this.Height * 0.9, this.Width * 0.5, this.Height * 0.5) // force to be 50-90% of button size
				.root;
			
			var tBounds:Rectangle = _image.getBounds(_image);
			// Image's anchor is already centered from above, so alter postion to have image truly centered
			_image.x -= (tBounds.width / 2 + tBounds.left)*_image.scaleX;
			_image.y -= (tBounds.height / 2 + tBounds.top)*_image.scaleY;
			return this;
		}

		/////////////////////////////
		// Private
		/////////////////////////////
		protected function _clearChildren() : void {
			if(_image != null) { removeChild(_image); }
			if(_text != null) { removeChild(_text); }
		}
		
		protected function _rerenderChildren() : void {
			if(_text) setTextObject(_text);
			if(_image) setImage(_image, _image.scaleX);
		}

		/////////////////////////////
		// Render
		/////////////////////////////
		override protected function _renderUp() : void {
			_bg.draw3d(ConstantsApp.COLOR_BUTTON_BLUE, ConstantsApp.COLOR_BUTTON_OUTSET_TOP, ConstantsApp.COLOR_BUTTON_OUTSET_BOTTOM, ConstantsApp.COLOR_BUTTON_BLUE);
		}
		
		override protected function _renderDown() : void {
			if(_text) _text.color = 0xC2C2DA;
			_bg.draw3d(ConstantsApp.COLOR_BUTTON_MOUSE_DOWN, ConstantsApp.COLOR_BUTTON_OUTSET_BOTTOM, ConstantsApp.COLOR_BUTTON_BLUE, ConstantsApp.COLOR_BUTTON_MOUSE_DOWN);
		}
		
		override protected function _renderOver() : void {
			if(_text) _text.color = 0x012345;
			_bg.draw3d(ConstantsApp.COLOR_BUTTON_MOUSE_OVER, ConstantsApp.COLOR_BUTTON_OUTSET_BOTTOM, ConstantsApp.COLOR_BUTTON_BLUE, ConstantsApp.COLOR_BUTTON_MOUSE_OVER);
		}
		
		override protected function _renderOut() : void {
			if(_text) _text.color = 0xC2C2DA;
			_renderUp();
		}
		
		override protected function _renderDisabled() : void {
			_bg.draw3d(0x555555, ConstantsApp.COLOR_BUTTON_OUTSET_BOTTOM, ConstantsApp.COLOR_BUTTON_BLUE, 0x555555);
		}
	}
}
