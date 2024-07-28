package app.ui.common
{
	import flash.display.*;
	import flash.geom.Matrix;
	import app.data.ConstantsApp;
	
	public class RoundedRectangle extends Sprite
	{
		// Storage
		public var Width:Number;
		public var Height:Number;
		public var originX:Number;
		public var originY:Number;
		
		// Constructor
		// pData = { x:Number, y:Number, ?origin:Number, ?originX:Number=0, ?originY:Number=0 }
		public function RoundedRectangle(pWidth:Number, pHeight:Number, pData:Object=null) {
			super();
			pData = pData || {};

			Width = pWidth;
			Height = pHeight;
			
			this.x = pData.x;
			this.y = pData.y;
			originX = 0;
			originY = 0;
			if(pData.origin != null) {
				originX = pData.origin;
				originY = pData.origin;
			}
			if(pData.originX != null) { originX = pData.originX; }
			if(pData.originY != null) { originY = pData.originY; }
		}
		public function setXY(pX:Number, pY:Number) : RoundedRectangle { x = pX; y = pY; return this; }
		public function appendTo(target:Sprite): RoundedRectangle { target.addChild(this); return this; }
		
		/****************************
		* Public
		*****************************/
		public function draw(pColor:uint, pRadius:Number, pLineColor1:uint, pLineColor2:int=-1, pLineColor3:int=-1) : RoundedRectangle {
			var xx:Number = 0 - (Width * originX);
			var yy:Number = 0 - (Height * originY);
			
			if(pLineColor2 == -1) pLineColor2 = pLineColor1;
			if(pLineColor3 == -1) pLineColor3 = pLineColor1;
			
			graphics.clear();
			graphics.moveTo(xx, yy);
			graphics.lineStyle(1, pLineColor1, 1, true);
			graphics.drawRoundRect(xx+0, yy+0, this.Width - 3, this.Height - 3, pRadius, pRadius);
			graphics.lineStyle(1, pLineColor2, 1, true);
			graphics.drawRoundRect(xx+2, yy+2, this.Width - 3, this.Height - 3, pRadius, pRadius);
			graphics.lineStyle(1, pLineColor3, 1, true);
			graphics.beginFill(pColor);
			graphics.drawRoundRect(xx+1, yy+1, this.Width - 3, this.Height - 3, pRadius, pRadius);
			graphics.endFill();
			return this;
		}
		
		public function drawThin(pRadius:Number, pColor:uint, pLineColor:uint) : RoundedRectangle {
			var xx:Number = -(Width * originX), yy:Number = -(Height * originY);
			
			graphics.clear();
			graphics.lineStyle(1, pLineColor, 1, true);
			graphics.beginFill(pColor);
			graphics.drawRoundRect(xx, yy, Width, Height, pRadius, pRadius);
			graphics.endFill();
			return this;
		}
		
		public function drawSimpleGradient(pColors:Array, pRadius:Number, pLineColor1:uint, pLineColor2:uint, pLineColor3:uint) : RoundedRectangle {
			var xx:Number = 0 - (Width * originX);
			var yy:Number = 0 - (Height * originY);
			
			graphics.clear();
			graphics.moveTo(xx, yy);
			graphics.lineStyle(1, pLineColor1, 1, true);
			graphics.drawRoundRect(xx+0, yy+0, this.Width - 3, this.Height - 3, pRadius, pRadius);
			graphics.lineStyle(1, pLineColor2, 1, true);
			graphics.drawRoundRect(xx+2, yy+2, this.Width - 3, this.Height - 3, pRadius, pRadius);
			
			// Draw gradient
			var type:String = GradientType.LINEAR;
			//var colors:Array = [0x00FF00, 0x000088];
			var alphas:Array = [1, 1];
			var ratios:Array = [0, 255];
			var spreadMethod:String = SpreadMethod.PAD;
			var interp:String = InterpolationMethod.LINEAR_RGB;
			var focalPtRatio:Number = 0;
			
			var matrix:Matrix = new Matrix();
			var boxWidth:Number = this.Width;
			var boxHeight:Number = this.Height;
			var boxRotation:Number = Math.PI/2; // 90°
			var tx:Number = xx;
			var ty:Number = yy-(this.Height)*0.1;
			matrix.createGradientBox(boxWidth, boxHeight, boxRotation, tx, ty);
			 
			this.graphics.beginGradientFill(
				type,
				pColors,
				alphas,
				ratios,
				matrix,
				spreadMethod,
				interp,
				focalPtRatio
			);
			//this.graphics.drawRect(0, 0, this.Width, this.Height);
			
			// Finish
			graphics.drawRoundRect(xx+1, yy+1, this.Width - 3, this.Height - 3, pRadius, pRadius);
			graphics.endFill();
			return this;
		}
		
		/****************************
		* Convience methods
		*****************************/
		public function drawAsTray() : RoundedRectangle {
			this.drawSimpleGradient(ConstantsApp.COLOR_TRAY_GRADIENT, 15, ConstantsApp.COLOR_TRAY_B_1, ConstantsApp.COLOR_TRAY_B_2, ConstantsApp.COLOR_TRAY_B_3);
			return this;
		}
	}
}
