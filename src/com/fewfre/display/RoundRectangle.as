package com.fewfre.display
{
	import app.data.ConstantsApp;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.InterpolationMethod;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.display.DisplayObject;
	
	public class RoundRectangle
	{
		// Constants
		private static const TYPE_SOLID_BORDER:String = 'solid_border';
		private static const TYPE_3D_BORDER:String = '3d_border';
		private static const TYPE_GRADIENT_WITH_3D_BORDER:String = 'gradient_with_3d_border';
		
		// Storage
		private var _root : Sprite;
		
		private var _width   : Number;
		private var _height  : Number;
		private var _originX : Number = 0;
		private var _originY : Number = 0;
		
		// Storage - render values
		private var _type : String = null;
		private var _radius : Number = 7; // Default value; should still set manually before rendering
		private var _bgColor : uint = 0;
		private var _bgGradientColors : Array;
		private var _borderColor : uint = 0;
		private var _borderColor2 : uint = 0;
		private var _borderColor3 : uint = 0;
		private var _borderThickness : Number = 1;
		
		// Properties
		public function get root() : Sprite { return _root; }
		
		// Properties - general
		public function get width() : Number { return _width; }
		public function set width(pVal:Number) : void { _width = pVal; _render(); }
		public function get height() : Number { return _height; }
		public function set height(pVal:Number) : void { _height = pVal; _render(); }
		public function get originX() : Number { return _originX; }
		public function set originX(pVal:Number) : void { _originX = pVal; _render(); }
		public function get originY() : Number { return _originY; }
		public function set originY(pVal:Number) : void { _originY = pVal; _render(); }
		
		// Properties - render values
		public function get radius() : Number { return _radius; }
		public function set radius(pVal:Number) : void { _radius = pVal; _render(); }
		
		// Properties - _root convience methods
		public function get x() : Number { return _root.x; }
		public function set x(pVal:Number) : void { _root.x = pVal; }
		public function get y() : Number { return _root.y; }
		public function set y(pVal:Number) : void { _root.y = pVal; }
		public function get alpha() : Number { return _root.alpha; }
		public function set alpha(pVal:Number) : void { _root.alpha = pVal; }
		public function get visible() : Boolean { return _root.visible; }
		public function set visible(pVal:Boolean) : void { _root.visible = pVal; }
		public function get scale() : Number { return _root.scaleX; } // This assumed both scales are the same
		public function set scale(pVal:Number) : void { _root.scaleX = _root.scaleY = pVal; }
		
		// Constructor
		// pData = { x:Number, y:Number, ?origin:Number, ?originX:Number=0, ?originY:Number=0, ?radius:Number }
		public function RoundRectangle(pWidth:Number, pHeight:Number, pProps:Object=null) {
			super();
			_root = new Sprite();
			_width = pWidth;
			_height = pHeight;
			
			pProps = pProps || {};
			if(pProps.x !== null) this.x = pProps.x;
			if(pProps.y !== null) this.y = pProps.y;
			
			if(pProps.origin != null) { _originX = _originY = pProps.origin; }
			if(pProps.originX != null) { _originX = pProps.originX; }
			if(pProps.originY != null) { _originY = pProps.originY; }
			
			if(pProps.radius != null) { _radius = pProps.radius; }
		}
		
		/////////////////////////////
		// Update methods
		/////////////////////////////
		public function appendTo(pParent:Sprite): RoundRectangle { pParent.addChild(_root); return this; }
		public function move(pX:Number, pY:Number) : RoundRectangle { this.x = pX; this.y = pY; return this; }
		public function resize(pWidth:Number, pHeight:Object=null) : RoundRectangle {
			_width = pWidth; _height = pHeight != null ? pHeight as Number : pWidth; // if no height, then set both to width value
			_render();
			return this;
		}
		public function toOrigin(pX:Number, pY:Object=null) : RoundRectangle {
			_originX = pX; _originY = pY != null ? pY as Number : pX; // if no originY, then set both to originX value
			_render();
			return this;
		}
		public function toAlpha(pVal:Number) : RoundRectangle { this.alpha = pVal; return this; }
		public function toVisible(pVal:Boolean) : RoundRectangle { this.visible = pVal; return this; }
		public function toScale(pVal:Number) : RoundRectangle { this.scale = pVal; return this; }
		
		// render values
		public function toRadius(pRadius:Number) : RoundRectangle { this.radius = pRadius; return this; }
		
		public function addChild(child:DisplayObject) : DisplayObject { return _root.addChild(child); }
		public function removeChild(child:DisplayObject) : DisplayObject { return _root.removeChild(child); }
		
		/////////////////////////////
		// Public
		/////////////////////////////
		public function drawSolid(pColor:uint, pLineColor:uint, pBorderThickness:Number=1) : RoundRectangle {
			_type = TYPE_SOLID_BORDER;
			_bgColor = pColor;
			_borderColor = _borderColor2 = _borderColor3 = pLineColor;
			_borderThickness = pBorderThickness;
			_render();
			return this;
		}
		
		public function draw3d(pColor:uint, pLineColor1:uint, pLineColor2:int=-1, pLineColor3:int=-1) : RoundRectangle {
			_type = TYPE_3D_BORDER;
			_bgColor = pColor;
			_borderColor = pLineColor1;
			_borderColor2 = pLineColor2 > -1 ? pLineColor2 : pLineColor1;
			_borderColor3 = pLineColor3 > -1 ? pLineColor3 : pLineColor1;
			_borderThickness = 1; // We currently always want this to be 1 due to how 3d effect works
			_render();
			return this;
		}
		
		public function drawGradient3d(pColors:Array, pLineColor1:uint, pLineColor2:int=-1, pLineColor3:int=-1) : RoundRectangle {
			_type = TYPE_GRADIENT_WITH_3D_BORDER;
			_bgGradientColors = pColors;
			_borderColor = pLineColor1;
			_borderColor2 = pLineColor2 > -1 ? pLineColor2 : pLineColor1;
			_borderColor3 = pLineColor3 > -1 ? pLineColor3 : pLineColor1;
			_borderThickness = 1; // We currently always want this to be 1 due to how 3d effect works
			_render();
			return this;
		}
		
		/////////////////////////////
		// Convience methods
		/////////////////////////////
		public function drawAsTray() : RoundRectangle {
			return toRadius(15).drawGradient3d(ConstantsApp.COLOR_TRAY_GRADIENT, ConstantsApp.COLOR_TRAY_B_1, ConstantsApp.COLOR_TRAY_B_2, ConstantsApp.COLOR_TRAY_B_3);
		}
		
		/////////////////////////////
		// Render
		/////////////////////////////
		private function get graphics() : Graphics { return _root.graphics; }
		private function _getRenderX() : Number { return -(_width * _originX); };
		private function _getRenderY() : Number { return -(_height * _originY); };
		
		private function _render() : void {
			switch(_type) {
				case TYPE_SOLID_BORDER: _render_Simple_SolidBorder(_radius, _bgColor, _borderColor); break;
				case TYPE_3D_BORDER: _render_3dBorder(_radius, _bgColor, _borderColor, _borderColor2, _borderColor3); break;
				case TYPE_GRADIENT_WITH_3D_BORDER: _render_Gradient_3dBorder(_radius, _bgGradientColors, _borderColor, _borderColor2, _borderColor3); break;
			}
		}
		
		private function _render_Simple_SolidBorder(pRadius:Number, pColor:uint, pLineColor:uint) : void {
			var xx:Number = _getRenderX(), yy:Number = _getRenderY();
			
			graphics.clear();
			graphics.lineStyle(_borderThickness, pLineColor, 1, true);
			graphics.beginFill(pColor);
			graphics.drawRoundRect(xx, yy, _width, _height, pRadius, pRadius);
			graphics.endFill();
		}
		
		private function _render_3dBorder(pRadius:Number, pColor:uint, pLineColor1:uint, pLineColor2:uint, pLineColor3:uint) : void {
			var xx:Number = _getRenderX(), yy:Number = _getRenderY();
			var tInnerWidth:Number = _width - 2, tInnerHeight:Number = _height - 2;
			
			graphics.clear();
			// Top left 3D border
			graphics.lineStyle(1, pLineColor1, 1, true);
			graphics.drawRoundRect(xx+0, yy+0, tInnerWidth, tInnerHeight, pRadius, pRadius);
			// Bottom right 3D border
			graphics.lineStyle(1, pLineColor2, 1, true);
			graphics.drawRoundRect(xx+2, yy+2, tInnerWidth, tInnerHeight, pRadius, pRadius);
			// Actual rectangle box, which appears over the 3D borders
			// Since the 3D borders effectively add an extra 2px padding around it, we have to offset it by one and
			// use the inner width which has the padding subtracted
			graphics.lineStyle(1, pLineColor3, 1, true);
			graphics.beginFill(pColor);
			graphics.drawRoundRect(xx+1, yy+1, tInnerWidth, tInnerHeight, pRadius, pRadius);
			graphics.endFill();
		}
		
		private static const GRADIENT_ROTATION:Number = Math.PI/2; // 90°
		private function _render_Gradient_3dBorder(pRadius:Number, pColors:Array, pLineColor1:uint, pLineColor2:uint, pLineColor3:uint) : void {
			var xx:Number = _getRenderX(), yy:Number = _getRenderY();
			var tInnerWidth:Number = _width - 2, tInnerHeight:Number = _height - 2;
			
			graphics.clear();
			// Top left 3D border
			graphics.lineStyle(1, pLineColor1, 1, true);
			graphics.drawRoundRect(xx+0, yy+0, tInnerWidth, tInnerHeight, pRadius, pRadius);
			// Bottom right 3D border
			graphics.lineStyle(1, pLineColor2, 1, true);
			graphics.drawRoundRect(xx+2, yy+2, tInnerWidth, tInnerHeight, pRadius, pRadius);
			// Actual rectangle box, which appears over the 3D borders
			// Since the 3D borders effectively add an extra 2px padding around it, we have to offset it by one and
			// use the inner width which has the padding subtracted
			_doGradientFill(pColors);
			graphics.drawRoundRect(xx+1, yy+1, tInnerWidth, tInnerHeight, pRadius, pRadius);
			graphics.endFill();
		}
		
		/////////////////////////////
		// Render - helpers
		/////////////////////////////
		private function _doGradientFill(pColors:Array) : void {
			var xx:Number = _getRenderX(), yy:Number = _getRenderY();
			
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(_width, _height, GRADIENT_ROTATION, xx, yy);
			graphics.beginGradientFill(
				GradientType.LINEAR,
				pColors,
				[1, 1], // Alphas
				[0, 0xFF], // Ratios
				matrix
			);
		}
		
		/////////////////////////////
		// Static
		/////////////////////////////
		public static function square(pSize:Number, pData:Object=null) : RoundRectangle {
			return new RoundRectangle(pSize, pSize, pData);
		}
	}
}
