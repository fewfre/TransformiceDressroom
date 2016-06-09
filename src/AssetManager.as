package
{
	import flash.display.*;
	import flash.display.MovieClip;
	import flash.geom.*;
	import flash.events.Event;
	import flash.net.*;
	
	public class AssetManager extends Sprite
	{
		public static const LOADING_FINISHED:String = "asset_loading_finished";
		
		internal var _loaders:Array;
		internal var _loadedData:Array;
		
		public function AssetManager() {
			super();
			_loadedData = [];
			_loaders = [];
		}
		
		/****************************
		* Loading
		*****************************/
			public function load(pURLs:Array) {
				for(var i = 0; i < pURLs.length; i++) {
					_loaders.push(_newAssetLoader(pURLs[i]));
				}
			}
			
			private function _newAssetLoader(pUrl:String) : Loader {
				var tLoader:Loader = new Loader();
				tLoader.contentLoaderInfo.addEventListener(Event.INIT, _onDataLoaded);
				tLoader.load(new flash.net.URLRequest(pUrl));
				return tLoader;
			}
			
			private function _onDataLoaded(event:Event) : void {
				_loadedData.push( MovieClip(event.target.content) );
				_checkIfLoadingDone();
			}
			
			private function _checkIfLoadingDone() {
				if(_loadedData.length >= _loaders.length) {
					trace("[AssetManager](_checkIfLoadingDone) resources loaded...");
					_onLoadingComplete();
					
					for(var i = 0; i < _loaders.length; i++) {
						_loaders[i].contentLoaderInfo.removeEventListener(Event.INIT, _onDataLoaded);
						_loaders[i] = null;
					}
					_loaders = null;
				}
			}
			
			private function _onLoadingComplete() {
				dispatchEvent(new Event(AssetManager.LOADING_FINISHED));
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
				if(pTrace) { trace("ERROR: No Linkage by name: "+pName); }
				return null;
			}
	}
}