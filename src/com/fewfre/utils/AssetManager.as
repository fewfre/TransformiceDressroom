package com.fewfre.utils
{
	import com.fewfre.events.FewfEvent;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	public class AssetManager extends Sprite
	{
		// Constants
		public static const LOADING_FINISHED:String = "asset_loading_finished";
		public static const PACK_LOADED:String = "asset_pack_loaded";
		
		// Storage
		internal var _urlsToLoad:Array;
		internal var _loadedAssetData:Array;
		internal var _loadedData:Dictionary;
		
		// Properties
		public function get itemsLeftToLoad():int { return _urlsToLoad.length; }
		
		public function AssetManager() {
			super();
			_loadedAssetData = [];
			_loadedData = new Dictionary();
		}
		
		/****************************
		* Loading
		*****************************/
			public function load(pURLs:Array) : void {
				_urlsToLoad = pURLs;
				_newLoader( _urlsToLoad.shift() );
			}
			
			private function _newLoader(pUrl:String) : void {
				var tUrlParts = pUrl.split("/").pop().split("."), tName = tUrlParts[0], tType = tUrlParts[1];
				switch(tType) {
					case "swf":
					case "swc":
						var tLoader:Loader = new Loader();
						tLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onAssetsLoaded);
						tLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _onLoadError);
						tLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, _onProgress);
						tLoader.load(new URLRequest(pUrl));
						break;
					case "json":
						var tUrlLoader:URLLoader = new URLLoader();
						tUrlLoader.addEventListener(Event.COMPLETE, function(e:Event){ _onJsonLoaded(e, tName, arguments.callee); });
						tUrlLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event){ _onURLLoadError(e, pUrl, arguments.callee); });
						tUrlLoader.addEventListener(ProgressEvent.PROGRESS, _onProgress);
						tUrlLoader.load(new URLRequest(pUrl));
						break;
					default:
						trace("[AssetManager](_newLoader) Unknown file type: "+tType);
						break;
				}
			}
			
			private function _destroyAssetLoader(pLoader:Loader) : void {
				pLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, _onAssetsLoaded);
				pLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, _onLoadError);
				pLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, _onProgress);
			}
			
			private function _destroyURLLoader(pLoader:URLLoader, pOnComplete) : void {
				pLoader.removeEventListener(Event.COMPLETE, pOnComplete);
				pLoader.removeEventListener(IOErrorEvent.IO_ERROR, _onURLLoadError);
				pLoader.removeEventListener(ProgressEvent.PROGRESS, _onProgress);
			}
			
			private function _onAssetsLoaded(e:Event) : void {
				_loadedAssetData.push( MovieClip(e.target.content) );
				_destroyAssetLoader(e.target.loader);
				_checkIfLoadingDone();
			}
			
			private function _onJsonLoaded(e:Event, pKey:String, pOnComplete) : void {
				_loadedData[pKey] = JSON.parse(e.target.data);
				_destroyURLLoader(e.target, pOnComplete);
				_checkIfLoadingDone();
			}
			
			private function _onLoadError(e:IOErrorEvent) : void {
				trace("[AssetManager](_onLoadError) ERROR("+e.errorID+"): Was not able to load url: "+e.target.url);
				_destroyAssetLoader(e.target.loader);
				_checkIfLoadingDone();
			}
			
			private function _onURLLoadError(e:IOErrorEvent, pUrl:String, pOnComplete) : void {
				trace("[AssetManager](_onLoadError) ERROR("+e.errorID+"): Was not able to load url: "+pUrl);
				_destroyURLLoader(e.target, pOnComplete);
				_checkIfLoadingDone();
			}
			
			private function _onProgress(e:ProgressEvent) : void {
				dispatchEvent(e);
				//trace("Loading: "+String(Math.floor(e.bytesLoaded/1024))+" KB of "+String(Math.floor(e.bytesTotal/1024))+" KB.");
			}
			
			private function _checkIfLoadingDone() : void {
				dispatchEvent(new FewfEvent(PACK_LOADED, { itemsLeftToLoad:itemsLeftToLoad }));
				if(_urlsToLoad.length > 0) {
					_newLoader( _urlsToLoad.shift() );
				} else {
					trace("[AssetManager](_checkIfLoadingDone) All resources loaded.");
					setTimeout(function(){ dispatchEvent(new Event(AssetManager.LOADING_FINISHED)); }, 0);
				}
			}
		
		/****************************
		* Access Assets
		*****************************/
			public function getData(pKey:String) : * {
				return _loadedData[pKey];
			}
			
			public function getLoadedClass(pName:String, pTrace:Boolean=false) : Class {
				for(var i = 0; i < _loadedAssetData.length; i++) {
					if(_loadedAssetData[i].loaderInfo.applicationDomain.hasDefinition(pName)) {
						return _loadedAssetData[i].loaderInfo.applicationDomain.getDefinition( pName ) as Class;
					}
				}
				if(pTrace) { trace("[AssetManager](getLoadedClass) ERROR: No Linkage by name: "+pName); }
				return null;
			}
	}
}
