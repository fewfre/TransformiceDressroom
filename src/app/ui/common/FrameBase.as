package app.ui.common
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;

	public class FrameBase
	{
		// Constants
		private static const CORNER_PADDING : Number = 28;
		
		// Storage
		private var _root    : Sprite;
		private var _image   : Sprite;
		
		private var _width   : Number;
		private var _height  : Number;
		private var _originX : Number = 0.5;
		private var _originY : Number = 0.5;
		
		public function get root():Sprite { return _root };
		public function get width():Number { return _width };
		public function get height():Number { return _height };
		
		// Constructor
		public function FrameBase(pWidth:Number, pHeight:Number) {
			_root = new Sprite();
			_width = pWidth;
			_height = pHeight;
			
			_image = _root.addChild( new $FenetreBase() ) as Sprite;
			_image.scale9Grid = new Rectangle(CORNER_PADDING, CORNER_PADDING, 172-(CORNER_PADDING*2), 128-(CORNER_PADDING*2));
			
			_render();
		}
		public function move(pX:Number, pY:Number) : FrameBase { _root.x = pX; _root.y = pY; return this; }
		public function appendTo(pParent:Sprite): FrameBase { pParent.addChild(_root); return this; }
		public function toOrigin(pX:Number, pY:Object=null) : FrameBase {
			_originX = pX; _originY = pY != null ? pY as Number : pX; // if no originY, then set both to originX value
			_render();
			return this;
		}
		
		private function _render() : void {
			_image.x = 0 - (_width * _originX);
			_image.y = 0 - (_height * _originY);
			_image.scaleX = _image.scaleY = 1; // Reset back to 1, so that image width/height below return expected values for calculations
			_image.scaleX = _width /_image.width;
			_image.scaleY = _height / _image.height;
		}
	}
}
