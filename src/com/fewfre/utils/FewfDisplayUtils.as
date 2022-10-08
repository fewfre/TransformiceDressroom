package com.fewfre.utils
{
	import com.fewfre.display.TextBase;
	import com.adobe.images.*;
	import com.adobe.images.PNGEncoder;
	import flash.display.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.net.FileReference;
	import flash.utils.getDefinitionByName;
	import flash.utils.ByteArray;
	import ext.ParentAppSystem;
	// import flash.media.CameraRoll;
	// import flash.events.PermissionEvent;
	// import flash.permissions.PermissionStatus;
	// import flash.system.Capabilities;
	
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
		
		public static function handleErrorMessage(e:Error) {
			var text = new TextBase({ color:0xFF0000, x:Fewf.stage.stageWidth*0.25, y:Fewf.stage.stageHeight-25 });
			text.setUntranslatedText("["+e.name+":"+e.errorID+"] "+e.message);
			Fewf.stage.addChild(text);
		}
		
		// Converts the image to a PNG bitmap and prompts the user to save.
		public static function saveAsPNG(pObj:DisplayObject, pName:String, pScale:Number=1) : void {
			if(!pObj){ return; }

			var tRect:flash.geom.Rectangle = pObj.getBounds(pObj);
			var tBitmap:flash.display.BitmapData = new flash.display.BitmapData(tRect.width*pScale, tRect.height*pScale, true, 0xFFFFFF);

			var tMatrix:flash.geom.Matrix = new flash.geom.Matrix(1, 0, 0, 1, -tRect.left, -tRect.top);
			tMatrix.scale(pScale, pScale);

			// if(tBitmap.drawWithQuality) {
			// 	tBitmap.drawWithQuality(pObj, tMatrix, null, null, null, true, StageQuality.BEST);
			// } else {
				trace(Fewf.stage.quality);
				var defaultQuality = Fewf.stage.quality;
				Fewf.stage.quality = StageQuality.BEST;
				tBitmap.draw(pObj, tMatrix);
				Fewf.stage.quality = defaultQuality;
			// }
			
			try {
				var CameraRoll = ParentAppSystem.getCameraRollClass();
				if(!!CameraRoll && CameraRoll.supportsAddBitmapData) {
					( new CameraRoll() ).addBitmapData(tBitmap);
				// var File = ParentAppSystem.getFileClass();
				// if(!!File) {
					
					// var bytes = PNGEncoder.encode(tBitmap);
					// _saveAsFileStream(bytes, pName);
				} else {
					var bytes = PNGEncoder.encode(tBitmap);
					( new FileReference() ).save( bytes, pName+".png" );
				}
			}
			catch(e) {
				handleErrorMessage(e);
			}
					
			// try {
			// 	// Default picture saving - works for browser and desktop
			// 	if(!!getDefinitionByName('flash.net.FileReference')) {
			// 		( new FileReference() ).save( bytes, pName+".png" );
			// 	}
			// }
			// catch(e){
			// 		handleErrorMessage(e);
			// 	// try {
			// 	// 	var CameraRoll = ParentAppSystem.getCameraRollClass();
			// 	// 	// var PermissionStatus = ParentAppSystem.getPermissionStatusClass();
			// 	// 	if(!!CameraRoll && CameraRoll.supportsAddBitmapData && CameraRoll.permissionStatus == "granted") {
			// 	// 		( new CameraRoll() ).addBitmapData(tBitmap);
			// 	// 	}
			// 	// 	// else {
			// 	// 	// 	var File = ParentAppSystem.getFileClass();
			// 	// 	// 	var FileStream = ParentAppSystem.getFileStreamClass();
			// 	// 	// 	if(!!File && !FileStream && File.permissionStatus == "granted") {
			// 	// 	// 		var file:*/*File*/ = File.applicationStorageDirectory.resolvePath("MyDrawing.png");
			// 	// 	// 		var stream:*/*FileStream*/ = new FileStream();
			// 	// 	// 		stream.open(file, "write");//FileMode.WRITE);
			// 	// 	// 		stream.writeBytes(bytes, 0, bytes.length);
			// 	// 	// 		stream.close();
			// 	// 	// 	}
			// 	// 	// }
			// 	// }
			// 	// catch(e2) {
			// 	// 	handleErrorMessage(e2);
			// 	// }
			// }
		}
		
		// private static function _saveAsFileStream(bytes:ByteArray, pName:String) : void {
		// 	var File = ParentAppSystem.getFileClass();
		// 	var FileStream = ParentAppSystem.getFileStreamClass();
		// 	var PermissionStatus = ParentAppSystem.getPermissionStatusClass();
		// 	var PermissionEvent = ParentAppSystem.getPermissionEventClass();
			
		// 	var file:* = File.documentsDirectory.resolvePath(pName+".png");
		// 	if(File.permissionStatus == PermissionStatus.GRANTED || File.permissionStatus == PermissionStatus.ONLY_WHEN_IN_USE) {
		// 		var stream:* = new FileStream();
		// 		stream.open(file, "write");//FileMode.WRITE
		// 		stream.writeBytes(bytes, 0, bytes.length);
		// 		stream.close();
		// 	} else {
		// 		var permissionChanged:Function = function(e) : void{
		// 			if (e.status == PermissionStatus.GRANTED) {
		// 				//Permission was now granted by the user after prompting, run the command again now that it's allowed:
		// 				_saveAsFileStream(bytes, pName);
		// 			}
		// 			file.removeEventListener(PermissionEvent.PERMISSION_STATUS, permissionChanged);
		// 		};
		// 		file.addEventListener(PermissionEvent.PERMISSION_STATUS, permissionChanged);
				
		// 		file.requestPermission();
		// 	}
			
		// }
	}
}
