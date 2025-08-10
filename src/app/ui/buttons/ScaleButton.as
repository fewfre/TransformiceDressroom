package app.ui.buttons
{
	import com.fewfre.display.ButtonBase;
	import flash.display.DisplayObject;
	
	public class ScaleButton extends ButtonBase
	{
		// Storage
		protected var _image       : DisplayObject;
		protected var _buttonBaseScale : Number = 1;
		
		// Properties
		public function get image():DisplayObject { return _image; }
		public function get buttonBaseScale():Number { return _buttonBaseScale; }
		public function set buttonBaseScale(pBaseScale:Number):void { _buttonBaseScale = pBaseScale; _rerenderCurrentState(); }
		
		// Constructor
		public function ScaleButton(pImage:DisplayObject=null, pBaseScale:Number=1) {
			super();
			_buttonBaseScale = pBaseScale;
			if(pImage) setImage(pImage);
		}

		public function setImage(pImage:DisplayObject, pBaseScale:Number=NaN) : ScaleButton {
			if(_image != null) { removeChild(_image); }
			_image = pImage;
			addChild(_image);
			_rerenderCurrentState();
			if(!isNaN(pBaseScale)) _buttonBaseScale = pBaseScale;
			return this;
		}
		
		/////////////////////////////
		// Render
		/////////////////////////////
		override protected function _renderDown() : void {
			this.scale = _buttonBaseScale*0.9;
		}

		override protected function _renderUp() : void {
			this.scale = _buttonBaseScale;
		}

		override protected function _renderOver() : void {
			this.scale = _buttonBaseScale*1.1;
		}

		override protected function _renderOut() : void {
			this.scale = _buttonBaseScale;
		}
		
		private function _rerenderCurrentState() : void {
			if(_state == BUTTON_STATE_DOWN) _renderDown();
			if(_state == BUTTON_STATE_UP) _renderUp();
			if(_state == BUTTON_STATE_OVER) _renderOver();
		}
	}
}
