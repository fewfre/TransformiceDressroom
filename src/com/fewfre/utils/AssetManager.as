package com.fewfre.utils
{
	import com.fewfre.events.FewfEvent;
	import com.fewfre.loaders.*;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;
	import flash.net.*;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.LoaderInfo;
	import flash.display.BitmapData;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	import flash.external.ExternalInterface;
	
	public class AssetManager extends EventDispatcher
	{
		// Constants
		public static const LOADING_FINISHED:String = "asset_loading_finished";
		public static const PACK_LOADED:String = "asset_pack_loaded";
		
		// Storage
		internal var _cacheBreaker:String;
		
		internal var _urlsToLoad:Array;
		internal var _loadedStuffCallbacks:Array; // Store all loaded stuff in here to allow async loading, but still force loading in specified order.
		internal var _itemsLeftToLoad:Number;
		
		internal var _applicationDomains:Array;
		internal var _loadedData:Dictionary;
		
		// Properties
		public function get itemsLeftToLoad():int { return _itemsLeftToLoad; }//_urlsToLoad.length; }
		
		public function AssetManager() {
			super();
			_applicationDomains = [];
			_loadedData = new Dictionary();
			_cacheBreaker = null;
		}
		
		//////////////////////////////
		// Loading - Start
		//////////////////////////////
		
		// options ?= { cacheBreaker?:Boolean }
		public function loadWithCallback(pURLs:Array, pCallback:Function, options:Object=null) : void {
			options = options || {};
			load(pURLs, options.cacheBreaker);
			addEventListener(AssetManager.LOADING_FINISHED, function fDone(event:Event){
				removeEventListener(AssetManager.LOADING_FINISHED, fDone);
				pCallback(null);
			});
			addEventListener(ErrorEvent.ERROR, function fDone(event:ErrorEvent){
				removeEventListener(AssetManager.LOADING_FINISHED, fDone);
				pCallback("error");
			});
		}
		
		public function load(pURLs:Array, pCacheBreaker:String=null) : void {
			_urlsToLoad = pURLs;
			_itemsLeftToLoad = _urlsToLoad.length;
			_loadedStuffCallbacks = [];
			_cacheBreaker = pCacheBreaker;
			var i = -1, tItem:* = null;
			while(_urlsToLoad.length > 0) { i++;
				_loadedStuffCallbacks.push(null);
				tItem = _urlsToLoad.shift();
				if(!(tItem is Array)) {
					_newLoader( i, tItem );
				} else {
					_newLoader( i, tItem[0], tItem[1] );
				}
			}
		}
		
		private function _newLoader(pIndex:int, pUrl:String, pOptions:Object=null) : void {
			pOptions = pOptions || {};
			
			var tFileNameSplit:Array = pUrl.split("/").pop().split(".");
			var tName:String = pOptions.name || tFileNameSplit[0];
			var tType:String = pOptions.type || tFileNameSplit[1];
			
			if(_cacheBreaker && (Fewf.isExternallyLoaded || Fewf.isBrowserLoaded)) {
				pUrl += "?cb="+_cacheBreaker;
			}
			switch(tType) {
				case "swf":
				case "swc":
					_newBinaryLoader(pIndex, pUrl, pOptions.useCurrentDomain);
					break;
				case "txt":
				case "json":
					_newTextLoader(pIndex, pUrl, tName, tType);
					break;
				default:
					trace("[AssetManager](_newLoader) Unknown file type: "+tType);
					break;
			}
		}
		
		//////////////////////////////
		// Loading - Binary
		//////////////////////////////
		private function _newBinaryLoader(pIndex:int, pUrl:String, pUseCurrentDomain:Boolean) : void {
			new AssetManagerBinaryLoader()
				.on(Event.COMPLETE, function(e:Event):void{ _onAssetsLoaded(pIndex, e.target as AssetManagerBinaryLoader, arguments.callee); })
				.on(IOErrorEvent.IO_ERROR, _onLoadError)
				.on(ProgressEvent.PROGRESS, _onProgress)
				.load(pUrl, pUseCurrentDomain);
		}
		
		// private function _destroyAssetLoader(pLoader:Loader, pOnComplete) : void {
		// 	pLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, pOnComplete);//_onAssetsLoaded);
		// 	pLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, _onLoadError);
		// 	pLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, _onProgress);
		// }
		
		private function _onLoadError(e:ErrorEvent) : void {
			try {
				trace("[AssetManager](_onLoadError) ERROR("+e.errorID+"): Was not able to load url: "+e.target.url);
				Fewf.dispatcher.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "["+e.type+":"+e.errorID+"] "+e.text));
			} catch(err:Error) {}
			// _destroyAssetLoader(e.target.loader, pOnComplete);
			_markItemLoadedAndCheckIfLoadingDone();
		}
		
		private function _onAssetsLoaded(pIndex:int, l:AssetManagerBinaryLoader, pOnComplete) : void {
			_loadedStuffCallbacks[pIndex] = function():void{
				_applicationDomains.push( l.applicationDomain );
				l.destroy();
			};
			_markItemLoadedAndCheckIfLoadingDone();
		}
		
		//////////////////////////////
		// Loading - Text
		//////////////////////////////
		private function _newTextLoader(pIndex:int, pUrl:String, pName:String, pType:String) : void {
			var tUrlLoader:URLLoader = new URLLoader();
			tUrlLoader.addEventListener(Event.COMPLETE, function(e:Event):void{ _onTextLoaded(pIndex, e.target.data, e.target as URLLoader, pName, pType, arguments.callee); });
			tUrlLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void{ _onUrlLoadError(e as IOErrorEvent, pUrl, arguments.callee); });
			tUrlLoader.addEventListener(ProgressEvent.PROGRESS, _onProgress);
			var tRequest2:URLRequest = new URLRequest(pUrl);
			// if(Fewf.isExternallyLoaded || Fewf.isBrowserLoaded) tRequest2.data = new URLVariables("cache=no+cache");
			tRequest2.requestHeaders.push(new URLRequestHeader("pragma", "no-cache"));
			tUrlLoader.load(tRequest2);
		}
		
		private function _destroyURLLoader(pLoader:URLLoader, pOnComplete) : void {
			pLoader.removeEventListener(Event.COMPLETE, pOnComplete);
			pLoader.removeEventListener(IOErrorEvent.IO_ERROR, _onUrlLoadError);
			pLoader.removeEventListener(ProgressEvent.PROGRESS, _onProgress);
		}
		
		private function _onUrlLoadError(e:IOErrorEvent, pUrl:String, pOnComplete) : void {
			try {
				trace("[AssetManager](_onUrlLoadError) ERROR("+e.errorID+"): Was not able to load url: "+pUrl);
				_destroyURLLoader(e.target as URLLoader, pOnComplete);
			} catch(err:Error) {}
			_markItemLoadedAndCheckIfLoadingDone();
		}
		
		private function _onTextLoaded(pIndex:int, pTextData:*, pLoader:URLLoader, pKey:String, pType:String, pOnComplete) : void {
			_loadedStuffCallbacks[pIndex] = function():void{
				_loadedData[pKey] = pType === "json" ? JSON.parse(pTextData) : pTextData;
				_destroyURLLoader(pLoader, pOnComplete);
			};
			_markItemLoadedAndCheckIfLoadingDone();
		}
		
		//////////////////////////////
		// Loading - End
		//////////////////////////////
		private function _onProgress(e:ProgressEvent) : void {
			dispatchEvent(e);
			//trace("Loading: "+String(Math.floor(e.bytesLoaded/1024))+" KB of "+String(Math.floor(e.bytesTotal/1024))+" KB.");
		}
		
		private function _markItemLoadedAndCheckIfLoadingDone() : void {
			_itemsLeftToLoad--;
			dispatchEvent(new FewfEvent(PACK_LOADED, { itemsLeftToLoad:itemsLeftToLoad }));
			if(itemsLeftToLoad <= 0) {
				trace("[AssetManager](_checkIfLoadingDone) All resources loaded.");
				for each(var pCallback:Function in _loadedStuffCallbacks) {
					if(pCallback != null) { pCallback(); }
				}
				_loadedStuffCallbacks = null;
				trace("[AssetManager](_checkIfLoadingDone) All resources stored.");
				setTimeout(function():void{ dispatchEvent(new Event(AssetManager.LOADING_FINISHED)); }, 0);
			}
		}
		
		//////////////////////////////
		// Access Assets
		//////////////////////////////
		public function getData(pKey:String) : * {
			return _loadedData[pKey];
		}
		
		public function getLoadedClass(pName:String, pTrace:Boolean=false) : Class {
			for(var i:int = 0; i < _applicationDomains.length; i++) {
				if(_applicationDomains[i].hasDefinition(pName)) {
					return _applicationDomains[i].getDefinition( pName ) as Class;
				}
			}
			if(pTrace) { trace("[AssetManager](getLoadedClass) ERROR: No Linkage by name: "+pName); }
			return null;
		}
		public function getLoadedMovieClip(pName:String, pDontReturnNull:Boolean=false, pTrace:Boolean=false) : MovieClip {
			var tClass:Class = getLoadedClass(pName, pTrace);
			return tClass ? new tClass() : (pDontReturnNull ? new MovieClip() : null);
		}
		
		//////////////////////////////
		// Bitmap Loader
		//////////////////////////////
		private const _bitmapLoaderManager:BitmapLoaderManager = new BitmapLoaderManager();
		
		public function lazyLoadImageUrlAsBitmap(pFilePath:String) : Bitmap {
			return _bitmapLoaderManager.lazyLoad(pFilePath);
		}
		
	}
}