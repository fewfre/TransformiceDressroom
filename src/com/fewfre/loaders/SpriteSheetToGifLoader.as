package com.fewfre.loaders
{
	import com.fewfre.utils.Fewf;
	import com.fewfre.utils.FewfDisplayUtils;

	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;

	public class SpriteSheetToGifLoader
	{
		// Storage
		private static var _apiUrl : String;
		public static function get supported() : Boolean { return !!_apiUrl; };
		
		public static function init(pSpriteSheetToGifUrl:String) : void {
			_apiUrl = pSpriteSheetToGifUrl;
		};
		
		public static function triggerApiToConvertSpritesheetToGif(pngByteArray:ByteArray, frameWidth:Number, frameHeight:Number, framesCount:Number, pFormat:String, pCallback:Function) {
			if(!supported) {
				throw new Error("GIF generation api not found.", 1);
				return;
			}
			
			var request:URLRequest = new URLRequest(_apiUrl);
			request.method = URLRequestMethod.POST;
			// request.requestHeaders.push(new URLRequestHeader("Content-type", "application/octet-stream"));
			request.requestHeaders.push(new URLRequestHeader("enctype", "multipart/form-data"));
			
			var requestVars:URLVariables = new URLVariables();
			// requestVars.sheet = pngByteArray;
			requestVars.sheet_base64 = FewfDisplayUtils.encodeByteArrayAsString(pngByteArray);
			requestVars.width = frameWidth;
			requestVars.height = frameHeight;
			requestVars.framescount = framesCount;
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
	}
}