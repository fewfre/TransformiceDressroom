package com.fewfre.loaders
{
	import com.fewfre.events.FewfEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;
	import flash.display.Loader;
	import flash.net.*;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	import flash.utils.ByteArray;
	import flash.events.HTTPStatusEvent;

	public class SimpleUrlLoader
	{
		// Storage
		private var _urlLoader: URLLoader;
		private var _urlRequest: URLRequest;

		// Constructer
		public function SimpleUrlLoader(pUrl:String = null) {
			_urlLoader = new URLLoader();
			_urlRequest = new URLRequest(pUrl);
		}
		
		///////////////////////
		// Public - URLRequest
		///////////////////////
		public function setUrl(pUrl:String) : SimpleUrlLoader { _urlRequest.url = pUrl; return this; }
		public function setMethod(pMethod:String/*URLRequestMethod*/) : SimpleUrlLoader { _urlRequest.method = pMethod; return this; }
		public function setToPost() : SimpleUrlLoader { return setMethod(URLRequestMethod.POST); }
		
		public function addHeader(name:String = "", value:String = "") : SimpleUrlLoader {
			_urlRequest.requestHeaders.push(new URLRequestHeader(name, value));
			return this;
		}
		public function addFormDataHeader() : SimpleUrlLoader { return addHeader("enctype", "multipart/form-data"); }
		public function addNoCacheHeader() : SimpleUrlLoader { return addHeader("pragma", "no-cache"); }
		
		public function addData(name:String = "", value:String = "") : SimpleUrlLoader {
			if(!_urlRequest.data) _urlRequest.data = new URLVariables();
			_urlRequest.data[name] = value;
			return this;
		}
		
		///////////////////////
		// Public - URLLoader
		///////////////////////
		// All event listeners added with a weak reference by default for easy garbage collection
		public function on(type:String, listener:Function): SimpleUrlLoader { _urlLoader.addEventListener(type, listener, false, 0, true); return this; }
		public function off(type:String, listener:Function): SimpleUrlLoader { _urlLoader.removeEventListener(type, listener, false); return this; }
		
		public function setDataFormat(pVal:String) : SimpleUrlLoader { _urlLoader.dataFormat = pVal; return this; }
		
		// pCallback = (response:*, e:Event)=>void;
		public function onComplete(pCallback:Function) : SimpleUrlLoader { return this.on(Event.COMPLETE, function(e:Event):void{
			pCallback(e.target.data, e);
		}); }
		
		// pCallback = (err:Error)=>void
		public function onError(pCallback:Function) : SimpleUrlLoader {
			this.on(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent){ pCallback(new Error(e.text, e.errorID)); });
			
			var status:int = 500;
			this.on(HTTPStatusEvent.HTTP_STATUS, function(e:HTTPStatusEvent):void{ status = e.status; });
			this.on(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent){
				pCallback(new Error("[HTTP Error] "+(e.target.data || "Error connecting api - make sure internet is connected"), status));
			});
			
			return this;
		}
		
		///////////////////////
		// Public
		///////////////////////
		public function load() : void {
			_urlLoader.load(_urlRequest);
		}
	}
}