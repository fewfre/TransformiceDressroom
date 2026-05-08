package app
{
	import app.data.Config;
	import app.data.ConstantsApp;
	import app.data.GameAssets;
	import app.ui.screens.ErrorScreen;
	import app.ui.screens.LoaderDisplay;
	import app.world.World;
	import com.fewfre.loaders.SpriteSheetToGifLoader;
	import com.fewfre.utils.*;
	import flash.display.*;
	import flash.events.*;
	import app.data.ItemInfo;

	[SWF(backgroundColor="0x6A7495" , width="900" , height="425")]
	public class Main extends MovieClip
	{
		// Storage
		private var _loaderDisplay : LoaderDisplay;
		private var _errorScreen   : ErrorScreen;
		private var _worldLayer    : Sprite; // Need layer defined to ensure error/loading screen remains on top
		private var _worldManager  : WorldManager;
		private var _world         : World;
		
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

			addChild(_worldLayer = new Sprite());
			_loaderDisplay = new LoaderDisplay().move(ConstantsApp.CENTER_X, ConstantsApp.CENTER_Y).appendTo(this);
			
			_errorScreen = new ErrorScreen().onCloseRemoveSelf();
			Fewf.dispatcher.addEventListener(ErrorEvent.ERROR, function(e:ErrorEvent){ addChild(_errorScreen.root); _errorScreen.open(e.text || 'Unknown Error'); });
			
			_startPreload();
		}
		
		private function _startPreload() : void {
			_load([
				Fewf.swfUrlBase+"resources/config.json",
			], String( new Date().getTime() ), _onPreloadComplete);
		}
		
		private function _onPreloadComplete() : void {
			Fewf.i18n.initConfigData(Config.languagesObject, Config.cacheBreaker);
			SpriteSheetToGifLoader.init(Config.spriteSheetToGifUrl);
			_systemDetectedDefaultLang = Fewf.i18n.getSystemDetectedDefaultLangCodeOrFallback();
			
			// Some slight analytics
			Fewf.assets.lazyLoadImageUrlAsBitmap(Fewf.networkProtocol+"://fewfre.com/images/avatar.jpg?tag=tfmdress-swf&pref="+encodeURIComponent(JSON.stringify({
				source: Fewf.isExternallyLoaded ? 'app' : Fewf.isBrowserLoaded ? 'browser' : 'direct',
				lang: _systemDetectedDefaultLang
			})));
			
			_startInitialLoad();
		}
		
		private function _startInitialLoad() : void {
			var tLangCodes : Array = [ Fewf.i18n.configDefaultLangCode ];
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
				Fewf.swfUrlBase+"resources/flags.swf",
				Fewf.swfUrlBase+"resources/item-info.json",
			];
			
			var tPack:Array, prefix:String;
			if(Fewf.isExternallyLoaded && Config.packsExternal) {
				tPack = Config.packsExternal;
				prefix = "";
			} else {
				tPack = Config.packs.items.concat(Config.packs.parts);
				prefix = Fewf.swfUrlBase+"resources/";
			}
			for(var i:int = 0; i < tPack.length; i++) { tPacks.push(prefix+tPack[i]); }
			
			_load(tPacks, Config.cacheBreaker, _onLoadComplete);
		}
		
		private function _onLoadComplete() : void {
			ItemInfo.init();
			GameAssets.init(_onGameAssetsInitComplete);
		}
		
		private function _onGameAssetsInitComplete() : void {
			_loaderDisplay.removeSelf().destroy();
			_loaderDisplay = null;
			
			_worldManager = new WorldManager(_worldLayer, stage);
			// Don't remove this `_world` reference as at least 1 webhook needs it
			_world = _worldManager.mainWorld;
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
