package com.fewfre.utils
{
	import com.adobe.images.*;
	import flash.display.*;
	import flash.geom.*;
	import flash.net.*;
	
	public class FewfDisplayUtils
	{
		// Scale type: Contain
		public static function fitWithinBounds(pObj:DisplayObject, pMaxWidth:Number, pMaxHeight:Number, pMinWidth:Number=0, pMinHeight:Number=0) : DisplayObject {
			var tRect:flash.geom.Rectangle = pObj.getBounds(pObj);
			var tWidth = tRect.width * pObj.scaleX;
			var tHeight = tRect.height * pObj.scaleY;
			var tMultiX = 1;
			var tMultiY = 1;
			if(tWidth > pMaxWidth) {
				tMultiX = pMaxWidth / tWidth;
			}
			else if(tWidth < pMinWidth) {
				tMultiX = pMinWidth / tWidth;
			}
			
			if(tHeight > pMaxHeight) {
				tMultiY = pMaxHeight / tHeight;
			}
			else if(tHeight < pMinHeight) {
				tMultiY = pMinHeight / tHeight;
			}
			
			var tMulti = 1;
			if(tMultiX > 0 && tMultiY > 0) {
				tMulti = Math.min(tMultiX, tMultiY);
			}
			else if(tMultiX < 0 && tMultiY < 0) {
				tMulti = Math.max(tMultiX, tMultiY);
			}
			else {
				tMulti = Math.min(tMultiX, tMultiY);
			}
			
			pObj.scaleX *= tMulti;
			pObj.scaleY *= tMulti;
			return pObj;
		}
		
		// Converts the image to a PNG bitmap and prompts the user to save.
		public static function saveAsPNG(pObj:DisplayObject, pName:String, pScale:Number=1) : void {
			if(!pObj){ return; }

			var tRect:flash.geom.Rectangle = pObj.getBounds(pObj);
			var tBitmap:flash.display.BitmapData = new flash.display.BitmapData(tRect.width*pScale, tRect.height*pScale, true, 0xFFFFFF);

			var tMatrix:flash.geom.Matrix = new flash.geom.Matrix(1, 0, 0, 1, -tRect.left, -tRect.top);
			tMatrix.scale(pScale, pScale);

			tBitmap.draw(pObj, tMatrix);
			( new flash.net.FileReference() ).save( com.adobe.images.PNGEncoder.encode(tBitmap), pName+".png" );
		}
	}
}
