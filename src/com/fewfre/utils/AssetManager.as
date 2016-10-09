package com.fewfre.utils
{
	import com.fewfre.events.FewfEvent;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.utils.setTimeout;
	
	public class AssetManager extends Sprite
	{
		// Constants
		public static const LOADING_FINISHED:String = "asset_loading_finished";
		public static const PACK_LOADED:String = "asset_pack_loaded";
		
		// Storage
		internal var _urlsToLoad:Array;
		internal var _loadedData:Array;
		
		// Properties
		public function get itemsLeftToLoad():int { return _urlsToLoad.length; }
		
		public function AssetManager() {
			super();
			_loadedData = [];
		}
		
		/****************************
		* Loading
		*****************************/
			public function load(pURLs:Array) : void {
				_urlsToLoad = pURLs;
				_newAssetLoader( _urlsToLoad.shift() );
			}
			
			private function _newAssetLoader(pUrl:String) : Loader {
				var tLoader:Loader = new Loader();
				tLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onDataLoaded);
				tLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _onLoadError);
				tLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, _onProgress);
				tLoader.load(new URLRequest(pUrl));
				return tLoader;
			}
			
			private function _destroyAssetLoader(pLoader:Loader) : void {
				pLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, _onDataLoaded);
				pLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, _onLoadError);
				pLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, _onProgress);
			}
			
			private function _onDataLoaded(e:Event) : void {
				_loadedData.push( MovieClip(e.target.content) );
				_destroyAssetLoader(e.target.loader);
				_checkIfLoadingDone();
			}
			
			private function _onLoadError(e:IOErrorEvent) : void {
				trace("[AssetManager](_onLoadError) ERROR("+e.errorID+"): Was not able to load url: "+e.target.url);
				_destroyAssetLoader(e.target.loader);
				_checkIfLoadingDone();
			}
			
			private function _onProgress(e:ProgressEvent) : void {
				dispatchEvent(e);
				//trace("Loading: "+String(Math.floor(e.bytesLoaded/1024))+" KB of "+String(Math.floor(e.bytesTotal/1024))+" KB.");
			}
			
			private function _checkIfLoadingDone() : void {
				dispatchEvent(new FewfEvent(PACK_LOADED, { itemsLeftToLoad:itemsLeftToLoad }));
				if(_urlsToLoad.length > 0) {
					_newAssetLoader( _urlsToLoad.shift() );
				} else {
					trace("[AssetManager](_checkIfLoadingDone) All resources loaded.");
					setTimeout(function(){ dispatchEvent(new Event(AssetManager.LOADING_FINISHED)); }, 0);
				}
			}
		
		/****************************
		* Access Assets
		*****************************/
			public function getLoadedClass(pName:String, pTrace:Boolean=false) : Class {
				for(var i = 0; i < _loadedData.length; i++) {
					if(_loadedData[i].loaderInfo.applicationDomain.hasDefinition(pName)) {
						return _loadedData[i].loaderInfo.applicationDomain.getDefinition( pName ) as Class;
					}
				}
				if(pTrace) { trace("[AssetManager](getLoadedClass) ERROR: No Linkage by name: "+pName); }
				return null;
			}
	}
}