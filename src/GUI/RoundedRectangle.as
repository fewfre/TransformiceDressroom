package GUI 
{
	import flash.display.*;
	import flash.display.Shape;
	import flash.display.GradientType;
	import flash.geom.Matrix;
	
	public class RoundedRectangle extends flash.display.Sprite
	{
		// Storage
		public var Width:Number;
		public var Height:Number;
		
		// Constructor
		public function RoundedRectangle(pX:Number, pY:Number, pWidth:Number, pHeight:Number)
		{
			super();
			
			this.x = pX;
			this.y = pY;
			Width = pWidth;
			Height = pHeight;
		}
		
		public function draw(pColor:Number, pRadius:Number, pLineColor1:Number, pLineColor2:Number, pLineColor3:Number) : void {
			graphics.clear();
			graphics.moveTo(0, 0);
			graphics.lineStyle(1, pLineColor1, 1, true);
			graphics.drawRoundRect(0, 0, this.Width - 3, this.Height - 3, pRadius, pRadius);
			graphics.lineStyle(1, pLineColor2, 1, true);
			graphics.drawRoundRect(2, 2, this.Width - 3, this.Height - 3, pRadius, pRadius);
			graphics.lineStyle(1, pLineColor3, 1, true);
			graphics.beginFill(pColor);
			graphics.drawRoundRect(1, 1, this.Width - 3, this.Height - 3, pRadius, pRadius);
			graphics.endFill();
		}
		
		public function drawSimpleGradient(pColors:Array, pRadius:Number, pLineColor1:Number, pLineColor2:Number, pLineColor3:Number) : void {
			graphics.clear();
			graphics.moveTo(0, 0);
			graphics.lineStyle(1, pLineColor1, 1, true);
			graphics.drawRoundRect(0, 0, this.Width - 3, this.Height - 3, pRadius, pRadius);
			graphics.lineStyle(1, pLineColor2, 1, true);
			graphics.drawRoundRect(2, 2, this.Width - 3, this.Height - 3, pRadius, pRadius);
			
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
			var tx:Number = 0;
			var ty:Number = -(this.Height)*0.1;
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
			graphics.drawRoundRect(1, 1, this.Width - 3, this.Height - 3, pRadius, pRadius);
			graphics.endFill();
		}
	}
}
