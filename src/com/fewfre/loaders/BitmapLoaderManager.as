package com.fewfre.loaders
{
	import com.fewfre.events.FewfEvent;
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
	import com.fewfre.utils.Fewf;
	
	public class BitmapLoaderManager extends EventDispatcher
	{
		/****************************
		* Bitmap Loader
		*****************************/
		private const _DICT_getLoadedBitmapFromUrl:Dictionary = new Dictionary();
		private const _DICT_bitmapsNeedingToBeDrawnAfterImageLoaded:Dictionary = new Dictionary();
		
		public function lazyLoad(pFilePath:String) : Bitmap {
			var url:String = pFilePath.indexOf("http") == 0 ? pFilePath : Fewf.swfUrlBase+pFilePath;
			var key:String = url; // NOTE: future me, remember that key=url only works if not using cache breaker
			var tBitmap:Bitmap = new Bitmap();
			if(_DICT_getLoadedBitmapFromUrl[key]) {
				tBitmap.bitmapData = _DICT_getLoadedBitmapFromUrl[key];
			} else {
				if(_DICT_bitmapsNeedingToBeDrawnAfterImageLoaded[key]) {
					_DICT_bitmapsNeedingToBeDrawnAfterImageLoaded[key].push(tBitmap);
				} else {
					_DICT_bitmapsNeedingToBeDrawnAfterImageLoaded[key] = new Array(tBitmap);
					_createBitmapLoader(url, key);
				}
			}
			return tBitmap;
		}
		
		private function _createBitmapLoader(pUrl:String, pKey:String) : void {
			try {
				var tLoader:Loader = new Loader();
				tLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event){ _onBitmapLazyLoaded(e, pKey); });
				// tLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _onError_bitmapLazyLoader);
				tLoader.load(new URLRequest(pUrl));
			} catch(err:Error) {}
		}
		
		private function _onBitmapLazyLoaded(e:Event, pKey:String) : void {
			try {
				var tLoader:Loader = null;
				tLoader = (e.currentTarget as LoaderInfo).loader;
				var tBitmapData:BitmapData = Bitmap(tLoader.content).bitmapData;
				_DICT_getLoadedBitmapFromUrl[pKey] = tBitmapData;
				// trace('loader url', (e.currentTarget as LoaderInfo).url);
				
				var tBitmapsNeedingDrawing:Array = _DICT_bitmapsNeedingToBeDrawnAfterImageLoaded[pKey];
				if(tBitmapsNeedingDrawing) {
					delete _DICT_bitmapsNeedingToBeDrawnAfterImageLoaded[pKey];
					for each(var bitmap:Bitmap in tBitmapsNeedingDrawing) {
						bitmap.bitmapData = tBitmapData;
						bitmap.dispatchEvent(new Event(Event.COMPLETE));
					}
				}
			} catch(err:Error) {}
		}
	}
}