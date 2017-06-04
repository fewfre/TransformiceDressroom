package app.ui
{
	import flash.display.*;
	import flash.geom.Matrix;
	
	public class RoundedRectangle extends Sprite
	{
		// Storage
		public var Width:Number;
		public var Height:Number;
		public var originX:Number;
		public var originY:Number;
		
		// Constructor
		// pData = { x:Number, y:Number, width:Number, height:Number, ?origin:Number, ?originX:Number=0, ?originY:Number=0 }
		public function RoundedRectangle(pData:Object)
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
		}
		
		public function draw(pColor:Number, pRadius:Number, pLineColor1:Number, pLineColor2:Number, pLineColor3:Number) : void {
			var tX:Number = 0 - (Width * originX);
			var tY:Number = 0 - (Height * originY);
			
			graphics.clear();
			graphics.moveTo(tX, tY);
			graphics.lineStyle(1, pLineColor1, 1, true);
			graphics.drawRoundRect(tX+0, tY+0, this.Width - 3, this.Height - 3, pRadius, pRadius);
			graphics.lineStyle(1, pLineColor2, 1, true);
			graphics.drawRoundRect(tX+2, tY+2, this.Width - 3, this.Height - 3, pRadius, pRadius);
			graphics.lineStyle(1, pLineColor3, 1, true);
			graphics.beginFill(pColor);
			graphics.drawRoundRect(tX+1, tY+1, this.Width - 3, this.Height - 3, pRadius, pRadius);
			graphics.endFill();
		}
		
		public function drawSimpleGradient(pColors:Array, pRadius:Number, pLineColor1:Number, pLineColor2:Number, pLineColor3:Number) : void {
			var tX:Number = 0 - (Width * originX);
			var tY:Number = 0 - (Height * originY);
			
			graphics.clear();
			graphics.moveTo(tX, tY);
			graphics.lineStyle(1, pLineColor1, 1, true);
			graphics.drawRoundRect(tX+0, tY+0, this.Width - 3, this.Height - 3, pRadius, pRadius);
			graphics.lineStyle(1, pLineColor2, 1, true);
			graphics.drawRoundRect(tX+2, tY+2, this.Width - 3, this.Height - 3, pRadius, pRadius);
			
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
			var tx:Number = tX;
			var ty:Number = tY-(this.Height)*0.1;
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
			graphics.drawRoundRect(tX+1, tY+1, this.Width - 3, this.Height - 3, pRadius, pRadius);
			graphics.endFill();
		}
	}
}
