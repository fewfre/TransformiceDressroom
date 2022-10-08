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
		
		public var Width:Number;
		public var Height:Number;
		public var originX:Number;
		public var originY:Number;
		
		private var _selected : Boolean;
		private var _borderColor : int;
		private var _baseBorderRadius : Number;
		private var _borderRadius : Number;
		
		
		// Properties
		public function get color() : int { return _color; }
		public function set color(pVal:int) : void { setColor(pVal); }
		
		public function get hex() : String { return _color.toString(16).toUpperCase(); }
		public function set hex(pVal:String) : void { setColor(parseInt(pVal, 16)); }
		
		public function get selected() : Boolean { return _selected; }
		public function set selected(pVal:Boolean) : void { _selected = pVal; _render(); }
		
		// Constructor
		// pData = { color:int, x?:Number, y?:Number,
		//           width:Number, height:Number, OR size:Number,
		//           ?origin:Number=0.5, ?originX:Number, ?originY:Number }
		public function ColorButton(pData:Object) {
			// If string assume it's hex string ("FF00CC") - if not it's an int (0xFF00CC)
			_color = pData.color is String ? parseInt(pData.color, color) : pData.color;
			pData.data = _color;
			
			Width = pData.width != null ? pData.width : pData.size;
			Height = pData.height != null ? pData.height : pData.size;
			originX = pData.originX != null ? pData.originX : (pData.origin != null ? pData.origin : 0.5);
			originY = pData.originY != null ? pData.originY : (pData.origin != null ? pData.origin : 0.5);
			
			_baseBorderRadius = Math.min(Width, Height) / 3;
			
			super(pData);
		}
		
		public function setColor(color:int) : void {
			_color = color;
			_returnData = _color;
			_render();
		}
		
		// Default dispatch is a bit buggy when `0` is passed, so manually throwing event
		override public function _dispatch(pEvent:String) : void {
			dispatchEvent(new FewfEvent(pEvent, _returnData));
		}

		/****************************
		* Render
		*****************************/
		protected function _render() : void {
			var tX:Number = 0 - (Width * originX);
			var tY:Number = 0 - (Height * originY);
			var tBorderWidth = _selected ? 2 : 1;
			var tBorderColor = _selected ? 0xFFFFFF : _borderColor;
			
			this.alpha = _flagEnabled ? 1 : 0.75;
			
			graphics.clear();
			graphics.beginFill(_color);
			// Inner border to help add some seperation between color and out border, encase they're to similiar
			if(_selected) {
				graphics.lineStyle(tBorderWidth, 0x999999);
				graphics.drawRoundRect(tX+2, tY+2, Width-4, Height-4, _borderRadius, _borderRadius);
				graphics.endFill();
			}
			// True outer border
			graphics.lineStyle(tBorderWidth, tBorderColor);
			graphics.drawRoundRect(tX+1, tY+1, Width-2, Height-2, _borderRadius, _borderRadius);
			graphics.endFill();
		}
		
		override protected function _renderUp() : void {
			this.scaleX = this.scaleY = 1;
			_borderRadius = _baseBorderRadius;
			_borderColor = 0x999999;
			_render();
		}
		
		override protected function _renderDown() : void {
			_renderOver();
		}
		
		override protected function _renderOver() : void {
			this.scaleX = this.scaleY = 1.1;
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
