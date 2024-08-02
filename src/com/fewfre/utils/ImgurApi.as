package com.fewfre.utils
{
	import com.adobe.images.PNGEncoder;
	import com.fewfre.utils.Fewf;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import flash.external.ExternalInterface;
	
	/*import flash.events.SecurityErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.system.Security;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;*/
	
	public class ImgurApi
	{
		public static const EVENT_DONE			: String = "ImgurApi:done";
		private static const _CLIENT_ID			: String = "c62a11c2af9173b";
		private static var _flagInited			: Boolean = false;
		/*private static var _loader:URLLoader;*/
		
		// Does not return success or failure
		public static function uploadImage(pObj:DisplayObject) : void {
			if( !ExternalInterface.available ) { return; }
			if(!_flagInited) { _init(); }
			
			var uri:String = _convertDisplayObjectToURI(pObj);
			_sendDataToApi(uri);
		}
		
		private static function _init() : void {
			_flagInited = true;
			if( ExternalInterface.available ) {
				var id:String = 'as3imgurapi_' + Math.floor(Math.random()*1000000);
				ExternalInterface.addCallback(id, function():void{});
				ExternalInterface.call(JAVASCRIPT_CODE);
				ExternalInterface.call("as3imgurapi.init", id);
				ExternalInterface.addCallback('imgurApiSuccess', _onAjaxSuccess);
			}
			/*_loader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, _onUploadComplete);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, _onUploadError);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _onSecurityError);*/
		}
		
		private static function _convertDisplayObjectToURI(pObj:DisplayObject) : String {
			var tRect:Rectangle = pObj.getBounds(pObj);
			var bmd:BitmapData = new BitmapData(tRect.width, tRect.height, true, 0xFFFFFF);
			var tMatrix:Matrix = new Matrix(1, 0, 0, 1, -tRect.left, -tRect.top);
			bmd.draw(pObj, tMatrix);
			// Encode and then convert byte array to string.
			var uri:String = FewfDisplayUtils.encodeByteArrayAsString( PNGEncoder.encode(bmd) );
			return uri;
		}
		
		private static function _sendDataToApi(pImage:String) : void {
			// https://apidocs.imgur.com/#4b8da0b3-3e73-13f0-d60b-2ff715e8394f
			ExternalInterface.call("as3imgurapi.ajax", {
				//"async": true,
				//"crossDomain": true,
				"url": "https://api.imgur.com/3/image",
				"method": "POST",
				"headers": {
					"authorization": "Client-ID "+_CLIENT_ID
				},
				//"processData": false,
				//"contentType": false,
				//"mimeType": "multipart/form-data",
				"data": {
					"image": pImage
				}
			});
		}
		
		private static function _onAjaxSuccess(pData:Object) : void {
			navigateToURL(new URLRequest(pData.data.link), "_blank");
			Fewf.dispatcher.dispatchEvent(new Event(EVENT_DONE));
		}
		
		private static const JAVASCRIPT_CODE : XML =
		<script><![CDATA[//]
			function() {
				window.as3imgurapi = {
					id: null, // Gets set by init
					swf: null, // Gets set by init
					
					init: function(pID){
						// Save ID
						as3imgurapi.id = pID;
						// Use ID to find SWF
						var data = document.querySelectorAll("object, embed");
						for(var i = 0; i < data.length; i++) {
							if(typeof data[i][as3imgurapi.id] != "undefined") {
								as3imgurapi.swf = data[i];
								break;
							}
						}
					},
					
					ajax: function(pSettings){
						var fd = new FormData();
						as3imgurapi._objForEach(pSettings.data||{}, function(pVal, pKey){
							fd.append(pKey, pVal);
						});
						var xhr = new XMLHttpRequest();
						xhr.open(pSettings.method, pSettings.url, true);
						as3imgurapi._objForEach(pSettings.headers||{}, function(pVal, pKey){
							xhr.setRequestHeader(pKey, pVal);
						});
						xhr.onreadystatechange = function(){
							if (xhr.readyState === 4) {
								if (xhr.status === 200) {
									as3imgurapi._doSuccess(JSON.parse(xhr.responseText), xhr);
								} else {
									/*as3imgurapi._doFail(JSON.parse(xhr.responseText), xhr);*/
								}
							}
						};
						xhr.send(fd);
					},
					
					_doSuccess: function(pData, pXhr){
						as3imgurapi.swf.imgurApiSuccess(pData);
						/*window.open(pData.data.link, '_blank');*/
					},
					
					/*_doFail: function(pData, pXhr){
						console.log(pData);
					},*/
					
					_objForEach: function(pObj, pCallback) {
						for (var key in pObj) {
							if (pObj.hasOwnProperty(key)) {
								pCallback(pObj[key], key, pObj);
							}
						}
					},
				};
				
				/*var form = new FormData();
				form.append("image", "{{uri}}");
				
				var settings = {
					"async": true,
					"crossDomain": true,
					"url": "https://api.imgur.com/3/image",
					"method": "POST",
					"headers": {
						"authorization": "Client-ID {{clientId}}"
					},
					"processData": false,
					"contentType": false,
					"mimeType": "multipart/form-data",
					"data": form
				}
				
				$.ajax(settings).done(function (response) {
					var tData = JSON.parse(response).data;
					console.log(tData.link, tData);
				}).fail(function(resp){
					console.log(resp.statusText, JSON.parse(resp.responseText), resp);
				});*/
			}
		]]></script>;
		
		/*private static function _sendDataToApiUrlRequest(pImage:String) : void {
			// Setup security stuff
			Security.allowInsecureDomain("*");
			Security.allowDomain("*");
			Security.loadPolicyFile("https://api.imgur.com/crossdomain.xml");
			
			// Create request
			var request:URLRequest = new URLRequest("https://api.imgur.com/3/image");
			request.method = URLRequestMethod.POST;
			request.data = uri;
			request.requestHeaders.push(new URLRequestHeader("authorization", "Client-ID "+_CLIENT_ID));
			
			_loader.dataFormat = URLLoaderDataFormat.TEXT; //don't know if this is really needed
			_loader.load(request);
		}
		
		private static function _onUploadComplete(e:Event):void {
			var tData = JSON.parse(_loader.data).data;
			navigateToURL(new URLRequest(tData.link), "_blank");
		}
		
		private static function _onUploadError(e:IOErrorEvent):void {
			_errorMsg("load error: "+e.text);
		}
		
		private static function _onSecurityError(e:SecurityErrorEvent):void {
			_errorMsg(10, 85, "security error: "+e.text);
		}
		
		private static function _errorMsg(pX:Number, pY:Number, pMessage:String) : void {
			var foo = com.fewfre.utils.Fewf.stage.addChild(new com.fewfre.display.TextBase({ x:pX, y:pY, originX:0, text:"loading_progress", values:pMessage }));
			foo.field.wordWrap = true;
			foo.field.width = 400;
		}*/
	}
}
