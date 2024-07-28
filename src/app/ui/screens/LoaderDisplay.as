package app.ui.screens
{
	import app.ui.common.RoundedRectangle;
	import com.fewfre.display.TextTranslated;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.utils.AssetManager;
	import com.fewfre.utils.Fewf;
	import flash.events.ProgressEvent;

	public class LoaderDisplay extends RoundedRectangle
	{
		private var _loadingSpinner	: LoadingSpinner;
		private var _leftToLoadText	: TextTranslated;
		private var _loadProgressText: TextTranslated;
		
		// Constructor
		// pData = { x:Number, y:Number }
		public function LoaderDisplay(pData:Object=null) {
			pData = pData || {};
			pData.origin = 0.5;
			super(500, 200, pData);
			this.drawAsTray();
			
			Fewf.assets.addEventListener(ProgressEvent.PROGRESS, _onLoadProgress);
			Fewf.assets.addEventListener(AssetManager.PACK_LOADED, _onPackLoaded);
			
			_loadingSpinner = addChild(new LoadingSpinner({ y:-45, scale:2 })) as LoadingSpinner;
			
			_leftToLoadText = new TextTranslated("loading", { values:"", size:18, x:0, y:10 }).appendToT(this);
			_loadProgressText = new TextTranslated("loading_progress", { values:"", size:18, x:0, y:35 }).appendToT(this);
		}
		
		public function destroy():void {
			Fewf.assets.removeEventListener(ProgressEvent.PROGRESS, _onLoadProgress);
			_loadingSpinner.destroy();
		}
		
		private function _onPackLoaded(e:FewfEvent) : void {
			_leftToLoadText.setTextWithValues("loading", e.data.itemsLeftToLoad);
			if(e.data.itemsLeftToLoad <= 0) {
				_leftToLoadText.text = "loading_finished";
				_loadProgressText.text = "";
			}
		}
		
		private function _onLoadProgress(e:ProgressEvent) : void {
			//_loadingSpinner.rotation += 10;
			//trace("Loading: "+String(Math.floor(e.bytesLoaded/1024))+" KB of "+String(Math.floor(e.bytesTotal/1024))+" KB.");
			_loadProgressText.setValues(String(Math.floor(e.bytesLoaded/1024))+" KB / "+String(Math.floor(e.bytesTotal/1024))+" KB");
		}
	}
}
