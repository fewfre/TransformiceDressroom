package app
{
	import app.data.*;
	import app.ui.screens.LoaderDisplay;
	import app.world.World;
	
	import com.fewfre.utils.*;

	import flash.display.*;
	import flash.events.*;
	import flash.system.Capabilities;
	import app.data.ConstantsApp;

	[SWF(backgroundColor="0x6A7495" , width="900" , height="425")]
	public class Main extends MovieClip
	{
		// Storage
		private var _loaderDisplay	: LoaderDisplay;
		private var _world			: World;
		private var _config			: Object;
		private var _defaultLang	: String;
		
		// Constructor
		public function Main() {
			super();
			Fewf.init(stage);

			stage.align = StageAlign.TOP;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 16;

			// TODO
			// BrowserMouseWheelPrevention.init(stage);

			_loaderDisplay = addChild( new LoaderDisplay({ x:stage.stageWidth * 0.5, y:stage.stageHeight * 0.5 }) ) as LoaderDisplay;
			
			_startPreload();
		}
		
		private function _startPreload() : void {
			_load([
				"resources/config.json",
			], String( new Date().getTime() ), _onPreloadComplete);
		}
		
		private function _onPreloadComplete() : void {
			_config = Fewf.assets.getData("config");
			_defaultLang = _getDefaultLang(_config.languages["default"]);
			if(_config.resourcesBaseUrl) {
				ConstantsApp.resourcesBaseUrl = _config.resourcesBaseUrl;
			}
			
			_startInitialLoad();
		}
		
		private function _startInitialLoad() : void {
			var now:Date = new Date();
			var cb = [now.getFullYear(), now.getMonth(), now.getDate(), now.getHours(), now.getMinutes()].join("-");
			_load([
				ConstantsApp.resourcesBaseUrl+"/i18n/"+_defaultLang+".json",
				_config.manifestUrl,
				_config.updateUrl,
			], cb, _onInitialLoadComplete);
		}
		
		private function _onInitialLoadComplete() : void {
			Fewf.i18n.parseFile(_defaultLang, Fewf.assets.getData(_defaultLang));
			
			_startLoad();
		}
		
		// Start main load
		private function _startLoad() : void {
			var tPacks = [
				["resources/interface.swf", { useCurrentDomain:true }],
				"resources/flags.swf"
			];
			
			var manifest = Fewf.assets.getData("manifest");
			var manifestData = _mergeArray(manifest.packs.items, manifest.packs.parts);
			// tPacks = tPacks.concat(manifestData.map(function(fileName){ return ConstantsApp.resourcesBaseUrl+"/"+fileName; }));
			tPacks = tPacks.concat(manifestData);
			
			var now:Date = new Date();
			var cb = [now.getFullYear(), now.getMonth(), now.getDate(), now.getHours(), now.getMinutes()].join("-");
			// var cb = _config.cachebreaker;
			_load(tPacks, cb, _onLoadComplete);
		}
		
		private function _onLoadComplete() : void {
			_loaderDisplay.destroy();
			removeChild( _loaderDisplay );
			_loaderDisplay = null;
			
			_world = addChild(new World(stage)) as World;
		}
		
		/***************************
		* Helper Methods
		****************************/
		private function _load(pPacks:Array, pCacheBreaker:String, pCallback:Function) : void {
			Fewf.assets.load(pPacks, pCacheBreaker);
			var tFunc = function(event:Event){
				Fewf.assets.removeEventListener(AssetManager.LOADING_FINISHED, tFunc);
				pCallback();
				tFunc = null; pCallback = null;
			};
			Fewf.assets.addEventListener(AssetManager.LOADING_FINISHED, tFunc);
		}
		
		private function _mergeArray(...arrays):Array {
			var result:Array = [];
			for(var i:int=0;i<arrays.length;i++){
				result = result.concat(arrays[i]);
			}
			return result;
		}
		
		private function _getDefaultLang(pConfigLang:String) : String {
			var tFlagDefaultLangExists:Boolean = false;
			// http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/system/Capabilities.html#language
			if(Capabilities.language) {
				var tLanguages:Array = _config.languages.list;
				for(var i:Object in tLanguages) {
					if(Capabilities.language == tLanguages[i].code || Capabilities.language == tLanguages[i].code.split("-")[0]) {
						return tLanguages[i].code;
					}
					if(pConfigLang == tLanguages[i].code) {
						tFlagDefaultLangExists = true;
					}
				}
			}
			return tFlagDefaultLangExists ? pConfigLang : "en";
		}
	}
}
