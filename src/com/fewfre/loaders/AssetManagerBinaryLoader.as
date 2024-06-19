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

	[Event(name="complete", type="flash.events.Event")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	public class AssetManagerBinaryLoader extends EventDispatcher
	{
		// Storage
		private var _loading: Boolean;
		private var _url: String;
		private var _useCurrentDomain: Boolean;
		public function get loading(): Boolean { return _loading; }
		public function get url(): String { return _url; }

		private var _urlLoader: URLLoader;
		private var _bytesLoader: Loader;

		private var _applicationDomain: ApplicationDomain;
		public function get applicationDomain(): ApplicationDomain { return _applicationDomain; }

		// Constructer
		public function AssetManagerBinaryLoader() {
			super();
			_loading = false;
		}

		/****************************
		 * Loading
		 *****************************/
		public function load(pUrl:String, pUseCurrentDomain:Boolean = false) : void {
			_loading = true;
			_url = pUrl;
			_useCurrentDomain = pUseCurrentDomain;
			_loadAsBinary(_url);
		}
		private function _loadAsBinary(pUrl:String) : void {
			try {
				_urlLoader = new URLLoader();
				_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
				_urlLoader.addEventListener(Event.COMPLETE, _onBinaryLoadingComplete);
				_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _onURLLoadError);
				_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, _onURLLoadError);
				_urlLoader.addEventListener(ProgressEvent.PROGRESS, _onProgress);
				var tRequest:URLRequest = new URLRequest(pUrl);
				tRequest.requestHeaders.push(new URLRequestHeader("pragma", "no-cache"));
				_urlLoader.load(tRequest);
			} catch(err:Error) {
				_destroyURLLoader(_urlLoader, _onBinaryLoadingComplete);
				_loadAsBinary(pUrl);
			}
		}
		
		private function _onBinaryLoadingComplete(e:Event) : void {
			_handleBinaryData(_urlLoader.data as ByteArray);
		}
		
		private function _handleBinaryData(pBytes:ByteArray) : void {
			try {
				_bytesLoader = new Loader();
				_bytesLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onLoadBytesComplete);
				_bytesLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _onLoadError);
				_bytesLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _onLoadError);
				
				var tLoaderContext:LoaderContext = new LoaderContext();
				tLoaderContext.allowCodeImport = true;
				_applicationDomain = _useCurrentDomain ? ApplicationDomain.currentDomain : new ApplicationDomain();
				tLoaderContext.applicationDomain = _applicationDomain;
				
				_bytesLoader.loadBytes(pBytes, tLoaderContext);
			}
			catch(err:Error) {
				done();
			}
		}
		
		private function _onLoadBytesComplete(e:Event) : void {
			done();
		}

		private function _onURLLoadError(e:ErrorEvent) : void {
			dispatchEvent(e);
			done();
		}

		private function _onLoadError(e:ErrorEvent) : void {
			dispatchEvent(e);
			done();
		}

		private function _onProgress(e:ProgressEvent) : void {
			dispatchEvent(e);
		}

		private function done() : void {
			_loading = false;
			dispatchEvent(new Event(Event.COMPLETE));
		}

		// ///////////////////////////
		// Cleanup
		// ///////////////////////////
		public function destroy() : void {
			_destroyURLLoader(_urlLoader, _onBinaryLoadingComplete);
			_destroyLoader(_bytesLoader, _onLoadBytesComplete);
		}

		private function _destroyURLLoader(pLoader:URLLoader, pOnComplete:Function) : void {
			pLoader.removeEventListener(Event.COMPLETE, pOnComplete);
			pLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _onURLLoadError);
			pLoader.removeEventListener(IOErrorEvent.IO_ERROR, _onURLLoadError);
			pLoader.removeEventListener(ProgressEvent.PROGRESS, _onProgress);
		}

		private function _destroyLoader(pLoader:Loader, pOnComplete:Function) : void {
			pLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, pOnComplete); // _onAssetsLoaded);
			pLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, _onLoadError);
			pLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, _onProgress);
		}
	}
}