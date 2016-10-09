package dressroom.ui 
{
	import com.fewfre.utils.AssetManager;
	import com.fewfre.events.FewfEvent;
	import dressroom.data.*;
	import flash.display.*;
	import flash.events.*
	import flash.text.*;
	
	public class LoaderDisplay extends RoundedRectangle
	{
		private var assets			: AssetManager;
		private var _loadingSpinner	: MovieClip;
		private var _leftToLoadText	: TextField;
		private var _loadProgressText: TextField;
		
		// Constructor
		// pData = { x:Number, y:Number, assetManager:AssetManager }
		public function LoaderDisplay(pData:Object)
		{
			pData.width = 500;
			pData.height = 200;
			pData.origin = 0.5;
			super(pData);
			this.drawSimpleGradient(ConstantsApp.COLOR_TRAY_GRADIENT, 15, ConstantsApp.COLOR_TRAY_B_1, ConstantsApp.COLOR_TRAY_B_2, ConstantsApp.COLOR_TRAY_B_3);
			
			assets = pData.assetManager;
			assets.addEventListener(ProgressEvent.PROGRESS, _onLoadProgress);
			assets.addEventListener(AssetManager.PACK_LOADED, _onPackLoaded);
			
			_loadingSpinner = addChild( new $Loader() );
			_loadingSpinner.y -= 45;
			_loadingSpinner.scaleX = 2;
			_loadingSpinner.scaleY = 2;
			
			_leftToLoadText = addChild( new TextField() );
			_leftToLoadText.defaultTextFormat = new flash.text.TextFormat("Verdana", 18, 0xc2c2da);
			_leftToLoadText.autoSize = flash.text.TextFieldAutoSize.CENTER;
			_leftToLoadText.x = -_leftToLoadText.textWidth * 0.5 - 2;
			_leftToLoadText.y = 10;
			_leftToLoadText.text = "Items left to load: "+(assets.itemsLeftToLoad+1);
			
			_loadProgressText = addChild( new TextField() );
			_loadProgressText.defaultTextFormat = new flash.text.TextFormat("Verdana", 18, 0xc2c2da);
			_loadProgressText.autoSize = flash.text.TextFieldAutoSize.CENTER;
			_loadProgressText.x = -_loadProgressText.textWidth * 0.5 - 2;
			_loadProgressText.y = 35;
		}
		
		public function destroy() {
			assets.removeEventListener(ProgressEvent.PROGRESS, _onLoadProgress);
			
			assets = null;
			_loadingSpinner = null;
		}
		
		public function update(dt:Number):void
		{
			if(_loadingSpinner != null) {
				_loadingSpinner.rotation += 360 * dt;
			}
		}
		
		function _onPackLoaded(e:FewfEvent) : void {
			_leftToLoadText.text = "Items left to load: "+e.data.itemsLeftToLoad;
			if(e.data.itemsLeftToLoad <= 0) {
				_leftToLoadText.text = "Loading complete. Initializing...";
				_loadProgressText.text = "";
			}
		}
		
		function _onLoadProgress(e:ProgressEvent) : void {
			//_loadingSpinner.rotation += 10;
			//trace("Loading: "+String(Math.floor(e.bytesLoaded/1024))+" KB of "+String(Math.floor(e.bytesTotal/1024))+" KB.");
			_loadProgressText.text = String(Math.floor(e.bytesLoaded/1024))+" KB / "+String(Math.floor(e.bytesTotal/1024))+" KB";
		}
	}
}
