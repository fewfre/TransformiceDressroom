package app
{
	import app.data.*;
	import app.ui.LoaderDisplay;
	import app.world.World;
	
	import com.fewfre.utils.*;

	import flash.display.*;
	import flash.events.*;
	import flash.system.Capabilities;

	public class Main extends MovieClip
	{
		// Storage
		private const _LOAD_LOCAL:Boolean = true;
		private var _loaderDisplay	: LoaderDisplay;
		private var _world			: World;
		private var _defaultLang	: String;
		
		// Constructor
		public function Main() {
			super();
			Fewf.init(stage);

			stage.align = StageAlign.TOP;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 16;

			BrowserMouseWheelPrevention.init(stage);
			
			// Start preload
			Fewf.assets.load([
				"resources/config.json",
			]);
			Fewf.assets.addEventListener(AssetManager.LOADING_FINISHED, _onPreloadComplete);

			_loaderDisplay = addChild( new LoaderDisplay({ x:stage.stageWidth * 0.5, y:stage.stageHeight * 0.5 }) );
		}
		
		internal function _onPreloadComplete(event:Event) : void {
			Fewf.assets.removeEventListener(AssetManager.LOADING_FINISHED, _onPreloadComplete);
			_defaultLang = _getDefaultLang(Fewf.assets.getData("config").languages.default);
			
			// Start main load
			Fewf.assets.load([
				["resources/interface.swf", { useCurrentDomain:true }],
				_LOAD_LOCAL ? "resources/x_meli_costumes.swf" : "http://www.transformice.com/images/x_bibliotheques/x_meli_costumes.swf",
				_LOAD_LOCAL ? "resources/x_fourrures.swf" : "http://www.transformice.com/images/x_bibliotheques/x_fourrures.swf",
				_LOAD_LOCAL ? "resources/x_fourrures2.swf" : "http://www.transformice.com/images/x_bibliotheques/x_fourrures2.swf",
				_LOAD_LOCAL ? "resources/x_fourrures3.swf" : "http://www.transformice.com/images/x_bibliotheques/x_fourrures3.swf",
				"resources/poses.swf",
				"resources/flags.swf",
				"resources/i18n/"+_defaultLang+".json",
			]);
			Fewf.assets.addEventListener(AssetManager.LOADING_FINISHED, _onLoadComplete);
		}
		
		internal function _onLoadComplete(event:Event) : void {
			Fewf.assets.removeEventListener(AssetManager.LOADING_FINISHED, _onLoadComplete);
			_loaderDisplay.destroy();
			removeChild( _loaderDisplay );
			_loaderDisplay = null;
			
			Fewf.i18n.parseFile(_defaultLang, Fewf.assets.getData(_defaultLang));
			
			_world = addChild(new World(stage));
		}
		
		private function _getDefaultLang(pConfigLang:String) : String {
			var tFlagDefaultLangExists = false;
			// http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/system/Capabilities.html#language
			if(Capabilities.lang) {
				var tLanguages = Fewf.assets.getData("config").languages.list;
				for(var tLang in tLanguages) {
					if(Capabilities.lang == tLang.code || Capabilities.lang == tLang.code.split("-")[0]) {
						return tLang.code;
					}
					if(pConfigLang == tLang.code) {
						tFlagDefaultLangExists = true;
					}
				}
			}
			return tFlagDefaultLangExists ? pConfigLang : "en";
		}
	}
}
