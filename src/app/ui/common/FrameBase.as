package app.ui.common
{
	import com.fewfre.utils.*;
	import flash.display.*;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	
	public class FrameBase extends Sprite
	{
		// Storage
		private var _image:MovieClip;
		public var Width:Number;
		public var Height:Number;
		public var originX:Number;
		public var originY:Number;
		
		// Constructor
		// pData = { x:Number, y:Number, width:Number, height:Number, ?origin:Number, ?originX:Number=0, ?originY:Number=0 }
		public function FrameBase(pData:Object)
		{
			super();
			
			this.x = pData.x;
			this.y = pData.y;
			Width = pData.width;
			Height = pData.height;
			originX = 0;
			originY = 0;
			if(pData.origin != null) {
				originX = pData.origin;
				originY = pData.origin;
			}
			if(pData.originX != null) { originX = pData.originX; }
			if(pData.originY != null) { originY = pData.originY; }
			_image = addChild( new $FenetreBase() ) as MovieClip;
			var tCornerPadding = 28;
			_image.scale9Grid = new Rectangle(tCornerPadding, tCornerPadding, 172-(tCornerPadding*2), 128-(tCornerPadding*2));
			
			_render();
		}
		public function move(pX:Number, pY:Number) : FrameBase { this.x = pX; this.y = pY; return this; }
		public function appendTo(pParent:Sprite): FrameBase { pParent.addChild(this); return this; }
		
		private function _render() : void {
			_image.x = 0 - (Width * originX);
			_image.y = 0 - (Height * originY);
			_image.scaleX = Width /_image.width;
			_image.scaleY = Height / _image.height;
		}
	}
}
