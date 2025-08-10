package app.ui.buttons
{
	import com.fewfre.display.ButtonBase;
	import com.fewfre.events.FewfEvent;
	import app.data.ConstantsApp;
	import app.ui.*;
	import flash.display.*;
	
	public class ColorButton extends ButtonBase
	{
		// Storage
		private var _color : int;
		
		private var _width : Number;
		private var _height : Number;
		private var _originX : Number = 0.5;
		private var _originY : Number = 0.5;
		
		private var _selected : Boolean;
		private var _borderColor : uint;
		private var _baseBorderRadius : Number;
		private var _borderRadius : Number;
		
		// Properties
		public function get color() : int { return _color; }
		public function set color(pVal:int) : void { setColor(pVal); }
		
		public function get hex() : String { return _color.toString(16).toUpperCase(); }
		public function set hex(pVal:String) : void { setColor(parseInt(pVal, 16)); }
		
		public function get Width():Number { return _width; }
		public function get Height():Number { return _height; }
		
		public function get selected() : Boolean { return _selected; }
		public function set selected(pVal:Boolean) : void { _selected = pVal; _render(); }
		
		// Constructor
		// If pHeight isn't set it will default to the same as the width
		public function ColorButton(pColor:*, pWidth:Number, pHeight:Number=NaN) {
			if(isNaN(pHeight)) pHeight = pWidth;
			// If string assume it's hex string ("FF00CC") - if not it's an int (0xFF00CC)
			_color = pColor is String ? parseInt(pColor, color) : pColor;
			_returnData = _color;
			
			_width = pWidth;
			_height = pHeight;
			
			_baseBorderRadius = Math.min(_width, _height) / 3;
			
			super();
		}
		public function setOrigin(pX:Number, pY:Object=null) : ColorButton { _originX = pX; _originY = pY != null ? pY as Number : pX; _render(); return this; } // if no originY, then set both to originX value
		public function resize(pWidth:Number, pHeight:Object = null) : ColorButton { _width = pWidth; _height = pHeight != null ? pHeight as Number : pWidth; _render(); return this; }
		public function setColor(color:int) : ColorButton { _color = color; _returnData = _color; _render(); return this; }

		/****************************
		* Render
		*****************************/
		protected function _render() : void {
			var tX:Number = 0 - (_width * _originX);
			var tY:Number = 0 - (_height * _originY);
			var tBorderWidth:Number = _selected ? 2 : 1;
			var tBorderColor:uint = _selected ? 0xFFFFFF : _borderColor;
			
			this.alpha = _flagEnabled ? 1 : 0.75;
			
			graphics.clear();
			graphics.beginFill(_color);
			// Inner border to help add some seperation between color and out border, encase they're to similiar
			if(_selected) {
				graphics.lineStyle(tBorderWidth, 0x999999);
				graphics.drawRoundRect(tX+2, tY+2, _width-4, _height-4, _borderRadius, _borderRadius);
				graphics.endFill();
			}
			// True outer border
			graphics.lineStyle(tBorderWidth, tBorderColor);
			graphics.drawRoundRect(tX+1, tY+1, _width-2, _height-2, _borderRadius, _borderRadius);
			graphics.endFill();
		}
		
		override protected function _renderUp() : void {
			this.scale = 1;
			_borderRadius = _baseBorderRadius;
			_borderColor = 0x999999;
			_render();
		}
		
		override protected function _renderDown() : void {
			_renderOver();
		}
		
		override protected function _renderOver() : void {
			this.scale = 1.1;
			_borderRadius = _baseBorderRadius*1.333;
			_borderColor = 0x999999;
			_render();
		}
		
		override protected function _renderOut() : void {
			_renderUp();
		}
		
		override protected function _renderDisabled() : void {
			super._renderDisabled();
			_borderRadius = _baseBorderRadius*0.5;
			_borderColor = 0x555555;
			_selected = false;
			_render();
		}
	}
}
