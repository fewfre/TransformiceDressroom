package app.ui.buttons
{
	import com.fewfre.display.ButtonBase;
	import app.ui.*;
	import flash.display.*;
	
	public class ColorButton extends SpriteButton
	{
		private var _box : Sprite;
		private var _color : int;
		private var _boxWidth : Number;
		private var _boxHeight : Number;
		
		public function get text() : int { return _color; }
		public function set text(pVal:int) : void { setColor(pVal); }
		
		public function get hex() : String { return _color.toString(16).toUpperCase(); }
		public function set hex(pVal:String) : void { setColor(parseInt(pVal, 16)); }
		
		// Constructor
		// pData = { x?:Number, y?:Number, width:Number, height:Number, padding:Number, color:int, hex:String }
		public function ColorButton(pData:Object) {
			super(pData);
			_color = pData.color;
			if(pData.hex != null) {
				_color = parseInt(pData.hex, 16);
			}
			_returnData = _color;
			
			var padding = pData.padding || 3;
			_boxWidth = pData.width-padding*2;
			_boxHeight = pData.height-padding*2;
			
			_box = new Sprite();
			ChangeImage(_box);
			
			render();
		}
		
		public function render() : void {
			_box.graphics.beginFill(this._color, 1);
			_box.graphics.drawRoundRect(-_boxWidth*0.5, -_boxHeight*0.5, _boxWidth, _boxHeight, 5, 5);
			_box.graphics.endFill();
		}
		
		public function setColor(color:int) : void {
			_color = color;
			_returnData = _color;
			render();
		}
	}
}
