package app
{
	import app.data.GameAssets;
	import app.ui.screens.ErrorScreen;
	import app.ui.screens.LoaderDisplay;
	import app.world.World;
	import com.fewfre.utils.*;
	import flash.display.*;
	import flash.events.*;
	import app.data.ConstantsApp;

	[SWF(backgroundColor="0x6A7495" , width="900" , height="425")]
	public class Main extends MovieClip
	{
		// Storage
		private var _loaderDisplay : LoaderDisplay;
		private var _errorScreen   : ErrorScreen;
		private var _world         : World;
		private var _config        : Object;
		private var _systemDetectedDefaultLang : String;
		
		// Constructor
		public function Main() {
			super();
			
			if (stage) {
				this._start();
			} else {
				addEventListener(Event.ADDED_TO_STAGE, this._start);
			}
		}
		
		private function _start(...args:*) {
			Fewf.init(stage, this.loaderInfo.parameters.swfUrlBase, 'transformice-dressroom');

			stage.align = StageAlign.TOP;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			stage.frameRate = 32;//16;

			BrowserMouseWheelPrevention.init(stage);

			_loaderDisplay = addChild( new LoaderDisplay(ConstantsApp.CENTER_X, ConstantsApp.CENTER_Y) ) as LoaderDisplay;
			
			_errorScreen = new ErrorScreen().on(Event.CLOSE, function(e){ removeChild(_errorScreen); });
			Fewf.dispatcher.addEventListener(ErrorEvent.ERROR, function(e:ErrorEvent){ addChild(_errorScreen); _errorScreen.open(e.text || 'Unknown Error'); });
			
			_startPreload();
		}
		
		private function _startPreload() : void {
			_load([
				Fewf.swfUrlBase+"resources/config.json",
			], String( new Date().getTime() ), _onPreloadComplete);
		}
		
		private function _onPreloadComplete() : void {
			_config = Fewf.assets.getData("config");
			_systemDetectedDefaultLang = Fewf.i18n.getSystemDetectedDefaultLangCodeOrFallback();
			
			if(_config) {
				if(_config.username_lookup_url) _config.username_lookup_url.replace("https://", Fewf.networkProtocol+"://");
				if(_config.spritesheet2gif_url) _config.spritesheet2gif_url.replace("https://", Fewf.networkProtocol+"://");
				if(_config.fetchpastebin_url) _config.fetchpastebin_url.replace("https://", Fewf.networkProtocol+"://");
				if(_config.createpastebin_url) _config.createpastebin_url.replace("https://", Fewf.networkProtocol+"://");
				if(_config.upload2imgur_url) _config.upload2imgur_url.replace("https://", Fewf.networkProtocol+"://");
			}
			
			// Some slight analytics
			Fewf.assets.lazyLoadImageUrlAsBitmap(Fewf.networkProtocol+"://fewfre.com/images/avatar.jpg?tag=tfmdress-swf&pref="+encodeURIComponent(JSON.stringify({
				source: Fewf.isExternallyLoaded ? 'app' : Fewf.isBrowserLoaded ? 'browser' : 'direct',
				lang: _systemDetectedDefaultLang
			})));
			
			_startInitialLoad();
		}
		
		private function _startInitialLoad() : void {
			var tLangCodes : Array = [ Fewf.i18n.getConfigDefaultLangCode() ];
			if(tLangCodes.indexOf(_systemDetectedDefaultLang) == -1) tLangCodes.push(_systemDetectedDefaultLang);
			Fewf.i18n.loadLanguagesIfNeededAndUseLastLang(tLangCodes, _onInitialLoadComplete);
		}
		
		private function _onInitialLoadComplete() : void {
			_startLoad();
		}
		
		// Start main load
		private function _startLoad() : void {
			var tPacks = [
				[Fewf.swfUrlBase+"resources/interface.swf", { useCurrentDomain:true }],
				Fewf.swfUrlBase+"resources/flags.swf"
			];
			
			var tPack:Array, prefix:String;
			if(Fewf.isExternallyLoaded && _config.packs_external) {
				tPack = _config.packs_external;
				prefix = "";
			} else {
				tPack = _config.packs.items.concat(_config.packs.parts);
				prefix = Fewf.swfUrlBase+"resources/";
			}
			for(var i:int = 0; i < tPack.length; i++) { tPacks.push(prefix+tPack[i]); }
			
			_load(tPacks, Fewf.assets.getData("config").cachebreaker, _onLoadComplete);
		}
		
		private function _onLoadComplete() : void {
			GameAssets.init(_onGameAssetsInitComplete);
		}
		
		private function _onGameAssetsInitComplete() : void {
			_loaderDisplay.destroy();
			removeChild( _loaderDisplay );
			_loaderDisplay = null;
			
			// Don't remove this reference as at least 1 webhook needs it
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
	}
}
