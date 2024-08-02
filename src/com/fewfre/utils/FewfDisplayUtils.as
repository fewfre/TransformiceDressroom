package com.fewfre.utils
{
	import com.fewfre.display.TextBase;
	import com.adobe.images.*;
	import com.adobe.images.PNGEncoder;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.net.FileReference;
	import flash.utils.getDefinitionByName;
	import flash.utils.ByteArray;
	import ext.ParentAppSystem;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.utils.setTimeout;
	// import flash.media.CameraRoll;
	// import flash.events.PermissionEvent;
	// import flash.permissions.PermissionStatus;
	// import flash.system.Capabilities;
	
	public class FewfDisplayUtils
	{
		// Scale type: Contain
		public static function fitWithinBounds(pObj:DisplayObject, pMaxWidth:Number, pMaxHeight:Number, pMinWidth:Number=0, pMinHeight:Number=0) : DisplayObject {
			var tRect:Rectangle = pObj.getBounds(pObj);
			var tWidth:Number = tRect.width * pObj.scaleX;
			var tHeight:Number = tRect.height * pObj.scaleY;
			var tMultiX:Number = 1;
			var tMultiY:Number = 1;
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
			
			var tMulti:Number = 1;
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
		
		/**
		 * If an origin is set to null, it won't be touched
		 */
		public static function alignChildrenAroundAnchor(pSprite:Sprite, originX:Object=0.5, originY:Object=0.5, pDrawScaffolding:Boolean=false) : Sprite {
			var rect:Rectangle = pSprite.getBounds(pSprite);
			var offsetX:Number = originX != null ? -rect.width*(originX as Number) - rect.x : 0;
			var offsetY:Number = originY != null ? -rect.height*(originY as Number) - rect.y : 0;
			
			for(var i:int = 0; i < pSprite.numChildren; i++) {
				if(originX) pSprite.getChildAt(i).x += offsetX;
				if(originY) pSprite.getChildAt(i).y += offsetY;
			}
			
			if(pDrawScaffolding) {
				trace(rect.toString());
				pSprite.graphics.beginFill(0xFFFFFF);
				pSprite.graphics.lineStyle(1, 0xFFFFFF)
				pSprite.graphics.drawCircle(0, 0, 4);
				pSprite.graphics.moveTo(0, -32); pSprite.graphics.lineTo(0, 32);
				pSprite.graphics.moveTo(-32, 0); pSprite.graphics.lineTo(32, 0);
				pSprite.graphics.endFill();
			}
			
			return pSprite;
		}
		
		public static function handleErrorMessage(e:Error) : void {
			// var text:TextBase = new TextBase({ color:0xFF0000, x:Fewf.stage.stageWidth*0.25, y:Fewf.stage.stageHeight-25 });
			// text.setUntranslatedText("["+e.name+":"+e.errorID+"] "+e.message);
			// Fewf.stage.addChild(text);
			Fewf.dispatcher.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "["+e.name+":"+e.errorID+"] "+e.message));
		}
		
		// because BitmapData's `drawWithQuality` function has had issues, this does the same thing
		public static function bitmapDataDrawBestQuality(pBitmap:BitmapData, source:IBitmapDrawable, matric:Matrix) : BitmapData {
			// if(tBitmap.drawWithQuality) {
			// 	tBitmap.drawWithQuality(pObj, tMatrix, null, null, null, true, StageQuality.BEST);
			// } else {
				// trace(Fewf.stage.quality);
				var defaultQuality = Fewf.stage.quality;
				Fewf.stage.quality = StageQuality.BEST;
				pBitmap.draw(source, matric, null, null, null, true);
				Fewf.stage.quality = defaultQuality;
			// }
			return pBitmap;
		}
		
		/**
		 * Only works in AIR app due to saving bitmap data not being supported on web
		 * https://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/desktop/Clipboard.html#setData()
		 */
		public static function copyToClipboard(pObj:DisplayObject, pScale:Number=1) : void {
			if(!pObj){ return; }

			var tRect:Rectangle = pObj.getBounds(pObj);
			var tBitmap:BitmapData = new BitmapData(tRect.width*pScale, tRect.height*pScale, true, 0xFFFFFF);

			var tMatrix:Matrix = new Matrix(1, 0, 0, 1, -tRect.left, -tRect.top);
			tMatrix.scale(pScale, pScale);
			tBitmap.draw(pObj, tMatrix);
			
			Clipboard.generalClipboard.setData(ClipboardFormats.BITMAP_FORMAT, tBitmap);
		}
		public static function copyToClipboardAnimatedGif(mc:MovieClip, scale:Number=1, pFinished:Function=null) {
			// _fetchGif(mc, scale, function(data:*, error:Error){
			// 	if(error) { handleErrorMessage(error); pFinished && pFinished(); return; }
				
			// 	Clipboard.generalClipboard.setData(ClipboardFormats.BITMAP_FORMAT, data);
			// });
			handleErrorMessage(new Error("Sorry, animated GIFs cannot be saved to the clipboard - please download image or disable animation to copy as a still image."));
			pFinished();
		}
		
		private static function _deviceUsesCameraRoll() : Boolean {
			try {
				var CameraRoll = ParentAppSystem.getCameraRollClass();
				return !!CameraRoll && CameraRoll.supportsAddBitmapData;
			} catch(e) {}
			return false;
		}
		
		public static function saveImageDataToDevice(data:*, pName:String, pExt:String) : void {
			try {
				var CameraRoll = ParentAppSystem.getCameraRollClass();
				if(!!CameraRoll && CameraRoll.supportsAddBitmapData) {
					if(data is BitmapData) {
						( new CameraRoll() ).addBitmapData(data);
					} else {
						handleErrorMessage(new Error("Sorry, this image type cannot be saved to mobile camera roll."));
					}
				// var File = ParentAppSystem.getFileClass();
				// if(!!File) {
					
					// var bytes = PNGEncoder.encode(pBitmap);
					// _saveAsFileStream(bytes, pName);
				} else {
					if(pExt == "png") {
						// data = Bitmap
						var bytes = PNGEncoder.encode(data);
						( new FileReference() ).save( bytes, pName+"."+pExt );
					} else {
						// data = ByteArray
						( new FileReference() ).save( data, pName+"."+pExt );
					}
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
			// 	// 		( new CameraRoll() ).addBitmapData(pBitmap);
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
		
		// Converts the image to a PNG bitmap and prompts the user to save.
		public static function saveAsPNG(pObj:DisplayObject, pName:String, pScale:Number=1) : void {
			if(!pObj){ return; }

			var tRect:Rectangle = pObj.getBounds(pObj);
			var tBitmap:BitmapData = new BitmapData(tRect.width*pScale, tRect.height*pScale, true, 0xFFFFFF);

			var tMatrix:Matrix = new Matrix(1, 0, 0, 1, -tRect.left, -tRect.top);
			tMatrix.scale(pScale, pScale);

			bitmapDataDrawBestQuality(tBitmap, pObj, tMatrix);
			
			saveImageDataToDevice(tBitmap, pName, 'png');
		}
		
		public static function convertMovieClipToSpriteSheet(mc:MovieClip, scale:Number=1, bg:int=-1) : SpritesheetData {
			var tOrigScale = mc.scaleX;
			mc.scaleX = mc.scaleY = scale;
			
			var totalFrames:int = mc.totalFrames;
			// Get bounds across all frames - https://stackoverflow.com/a/13750049
			var lifetimeBounds:Rectangle = new Rectangle(), tempRect:Rectangle;
			mc.gotoAndStop(1);
			for(var i:int = 0; i < totalFrames; i++) {
				tempRect = mc.getBounds(mc);
				lifetimeBounds.top = Math.min(lifetimeBounds.top, tempRect.top);
				lifetimeBounds.left = Math.min(lifetimeBounds.left, tempRect.left);
				lifetimeBounds.bottom = Math.max(lifetimeBounds.bottom, tempRect.bottom);
				lifetimeBounds.right = Math.max(lifetimeBounds.right, tempRect.right);
				mc.nextFrame();
			}
			var rect:Rectangle = lifetimeBounds;
			
			var tWidth = Math.ceil(rect.width*scale), tHeight = Math.ceil(rect.height*scale);
			
			// trace('lifetimeBounds', tWidth, tHeight, 'totalFrames', totalFrames);
			
			var maxSpriteWidth:Number = 1024*4;
			
			var columns:uint = totalFrames*tWidth > maxSpriteWidth ? Math.floor(maxSpriteWidth / tWidth) : totalFrames,
				rows:uint = Math.ceil(totalFrames/columns);
			var tBitmap:BitmapData = new BitmapData(tWidth*columns, tHeight*rows, bg == -1, bg >= 0 ? bg : 0xFFFFFF);
			// trace("rect", rect.x, rect.y, rect.right, rect.bottom, rect.width, rect.height);
			
			var tFrameBitmap:BitmapData, tFrameMatrix:Matrix;
			mc.gotoAndStop(1);
			for(var j:int = 0; j < totalFrames; j++) {
				// tempRect = mc.getBounds(mc);
				// // var tMatrix:Matrix = new Matrix(1, 0, 0, 1, j*tWidth + -tempRect.left + (tWidth-tempRect.width)/2, -tempRect.top + (tHeight-tempRect.height)/2);
				// // var tMatrix:Matrix = new Matrix(1, 0, 0, 1, j*tWidth - rect.x + tempRect.x, -rect.y + tempRect.y);
				// var tMatrix:Matrix = new Matrix(1, 0, 0, 1, j*tWidth*(1/scale) - rect.x, 0 - rect.y);
				// tMatrix.scale(scale, scale);

				// tBitmap.draw(mc, tMatrix, null, null, null, true);
				// mc.nextFrame();
				
				// Drawing to a smaller bitmap and then drawing that bitmap onto the other ones solves some wierd visual issues
				tFrameBitmap = new BitmapData(tWidth, tHeight, true, 0xFFFFFF);
				tFrameMatrix = new Matrix(1, 0, 0, 1, -rect.x, -rect.y);
				tFrameMatrix.scale(scale, scale);
				bitmapDataDrawBestQuality(tFrameBitmap, mc, tFrameMatrix);
				
				var tMatrix:Matrix = new Matrix(1, 0, 0, 1, (j%columns)*tWidth, Math.floor(j/columns)*tHeight);
				tMatrix.scale(1, 1);
				bitmapDataDrawBestQuality(tBitmap, tFrameBitmap, tMatrix);
			
				mc.nextFrame();
			}
			tFrameBitmap = null; tFrameMatrix = null;
			
			mc.scaleX = mc.scaleY = tOrigScale;

			return new SpritesheetData(tBitmap, tWidth, tHeight, totalFrames);
		}
		
		public static function saveAsSpriteSheet(mc:MovieClip, pName:String, scale:Number=1) {
			var sheetData = convertMovieClipToSpriteSheet(mc, scale);
			saveImageDataToDevice(sheetData.bitmapData, pName+"_"+sheetData.frameWidth+"x"+sheetData.frameHeight+"_"+sheetData.framesCount+"frames", 'png');
		}
		
		// Converts the image to a PNG bitmap and prompts the user to save.
		public static function saveAsAnimatedGif(mc:MovieClip, pName:String, scale:Number=1, pFormat:String=null, pFinished:Function=null) {
			if(_deviceUsesCameraRoll()) {
				handleErrorMessage(new Error("Sorry, animated GIFs cannot be saved to mobile camera roll - please use desktop app or disable animation to copy as a still image"));
				pFinished && pFinished();
				return;
			}
			_fetchGif(mc, scale, pFormat, function(data:*, error:Error){
				if(error) { handleErrorMessage(error); pFinished && pFinished(); return; }
				
				saveImageDataToDevice(data, pName, pFormat ? pFormat : 'gif');
				pFinished && pFinished();
			});
		}
		private static function _fetchGif(mc:MovieClip, scale:Number, pFormat:String, pCallback:Function) {
			var sheetData:SpritesheetData = convertMovieClipToSpriteSheet(mc, scale, -1);//pFormat && pFormat != "gif" ? -1 : 0x6A7495); // give it a bg color since gifs don't support partial opacity
			var tPNG:ByteArray = PNGEncoder.encode(sheetData.bitmapData);
			
			var url = Fewf.assets.getData("config").spritesheet2gif_url;
			if(!url) {
				handleErrorMessage(new Error("GIF generation api not found.", 1));
				return;
			}
			
			var request:URLRequest = new URLRequest(url);
			request.method = URLRequestMethod.POST;
			// request.requestHeaders.push(new URLRequestHeader("Content-type", "application/octet-stream"));
			request.requestHeaders.push(new URLRequestHeader("enctype", "multipart/form-data"));
			
			var requestVars:URLVariables = new URLVariables();
			// requestVars.sheet = tPNG;
			requestVars.sheet_base64 = encodeByteArrayAsString(tPNG);
			requestVars.width = sheetData.frameWidth;
			requestVars.height = sheetData.frameHeight;
			requestVars.framescount = sheetData.framesCount;
			requestVars.delay = (1 / Fewf.stage.frameRate) * 100; // 100 gif ticks in a second
			if(pFormat) requestVars.format = pFormat;
			
			request.data = requestVars;
			
 
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.addEventListener(Event.COMPLETE, function tOnComplete(e:Event):void{
				urlLoader.removeEventListener(Event.COMPLETE, tOnComplete);
				// trace('complete', e.target.data);
				pCallback(e.target.data, null);
			});
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent){ pCallback(null, new SecurityError(e.text, e.errorID)); }, false, 0, true);
			var status:int = 500;
			urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, function(e:HTTPStatusEvent):void{
				trace('status', e, e.target);
				status = e.status;
				// if(e.status >= 400) {
				// 	handleErrorMessage(new Error("[HTTP Error]", e.status));
				// }
			}, false, 0, true);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent){
				pCallback(null, new Error("[HTTP Error] "+(e.target.data || "Error connecting to GIF api - make sure internet is connected"), status));
			}, false, 0, true);

			try {
				urlLoader.load(request);
			} catch (e:Error) { pCallback(null, e); }
		}
		
		// https://stackoverflow.com/a/24896808/1411473
		private static const ENCODE_CHARS : String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
		public static function encodeByteArrayAsString(bytes:ByteArray):String{
			var encodeChars:Array = ENCODE_CHARS.split("");
			var out:Array = [];
			var i:int = 0;
			var j:int = 0;
			var r:int = bytes.length % 3;
			var len:int = bytes.length - r;
			var c:int;
			while (i < len) {
				c = bytes[i++] << 16 | bytes[i++] << 8 | bytes[i++];
				out[j++] = encodeChars[c >> 18] + encodeChars[c >> 12 & 0x3f] + encodeChars[c >> 6 & 0x3f] + encodeChars[c & 0x3f];
			}
			if (r == 1) {
				c = bytes[i++];
				out[j++] = encodeChars[c >> 2] + encodeChars[(c & 0x03) << 4] + "==";
			}
			else if (r == 2) {
				c = bytes[i++] << 8 | bytes[i++];
				out[j++] = encodeChars[c >> 10] + encodeChars[c >> 4 & 0x3f] + encodeChars[(c & 0x0f) << 2] + "=";
			}
			return out.join('');
		}
	}
}

class SpritesheetData {
	public var bitmapData: *;
	public var frameWidth: Number;
	public var frameHeight: Number;
	public var framesCount: uint;
	public function SpritesheetData(bitmapData: *, frameWidth: Number, frameHeight: Number, framesCount: uint) {
		this.bitmapData = bitmapData; this.frameWidth = frameWidth; this.frameHeight = frameHeight; this.framesCount = framesCount;
	}
}