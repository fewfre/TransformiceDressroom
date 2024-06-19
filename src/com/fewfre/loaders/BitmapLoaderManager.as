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
		public static const _DICT_getLoadedBitmapFromUrl:Dictionary = new Dictionary();
		public static const _DICT_bitmapsNeedingToBeDrawnAfterImageLoaded:Dictionary = new Dictionary();
		
		public function lazyLoad(pFilePath:String) : Bitmap {
			var url:String = pFilePath.indexOf("http") == 0 ? pFilePath : ((Fewf.swfUrlBase || "https://projects.fewfre.com/a801/transformice/dressroom/")+"resources/" + pFilePath);
			var tBitmap:Bitmap = new Bitmap();
			if(_DICT_getLoadedBitmapFromUrl[url]) {
				tBitmap.bitmapData = _DICT_getLoadedBitmapFromUrl[url];
			} else {
				if(_DICT_bitmapsNeedingToBeDrawnAfterImageLoaded[url]) {
					_DICT_bitmapsNeedingToBeDrawnAfterImageLoaded[url].push(tBitmap);
				} else {
					_DICT_bitmapsNeedingToBeDrawnAfterImageLoaded[url] = new Array(tBitmap);
					_createBitmapLoader(url);
				}
			}
			return tBitmap;
		}
		
		private function _createBitmapLoader(pUrl:String) : void {
			try {
				var tLoader:Loader = new Loader();
				tLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onBitmapLazyLoaded);
				// tLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _onError_bitmapLazyLoader);
				tLoader.load(new URLRequest(pUrl));
			} catch(err:Error) {}
		}
		
		private function _onBitmapLazyLoaded(e:Event) : void {
			try {
				var tLoader:Loader = null;
				tLoader = (e.currentTarget as LoaderInfo).loader;
				var tBitmapData:BitmapData = Bitmap(tLoader.content).bitmapData;
				var tUrl:String = (e.currentTarget as LoaderInfo).url; // NOTE: future me, remember that this only works if not using cache breaker
				_DICT_getLoadedBitmapFromUrl[tUrl] = tBitmapData;
				
				var tBitmapsNeedingDrawing:Array = _DICT_bitmapsNeedingToBeDrawnAfterImageLoaded[tUrl];
				if(tBitmapsNeedingDrawing) {
					delete _DICT_bitmapsNeedingToBeDrawnAfterImageLoaded[tUrl];
					for(var i:int = 0; i < tBitmapsNeedingDrawing.length; i++) {
						(tBitmapsNeedingDrawing[i] as Bitmap).bitmapData = tBitmapData;
						(tBitmapsNeedingDrawing[i] as Bitmap).dispatchEvent(new Event(Event.COMPLETE));
					}
				}
			} catch(err:Error) {}
		}
	}
}