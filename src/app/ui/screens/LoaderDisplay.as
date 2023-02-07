package app.ui.screens
{
	import com.fewfre.display.*;
	import com.fewfre.utils.*;
	import com.fewfre.events.FewfEvent;
	import app.data.*;
	import app.ui.common.*;
	import flash.display.*;
	import flash.events.*
	import flash.text.*;
	import flash.display.MovieClip;
	
	public class LoaderDisplay extends RoundedRectangle
	{
		private var _loadingSpinner	: LoadingSpinner;
		private var _leftToLoadText	: TextBase;
		private var _loadProgressText: TextBase;
		
		// Constructor
		// pData = { x:Number, y:Number }
		public function LoaderDisplay(pData:Object)
		{
			pData.width = 500;
			pData.height = 200;
			pData.origin = 0.5;
			super(pData);
			this.drawAsTray();
			
			Fewf.assets.addEventListener(ProgressEvent.PROGRESS, _onLoadProgress);
			Fewf.assets.addEventListener(AssetManager.PACK_LOADED, _onPackLoaded);
			
			_loadingSpinner = addChild(new LoadingSpinner({ y:-45, scale:2 })) as LoadingSpinner;
			
			_leftToLoadText = addChild(new TextBase({ text:"loading", values:"", size:18, x:0, y:10 })) as TextBase;
			_loadProgressText = addChild(new TextBase({ text:"loading_progress", values:"", size:18, x:0, y:35 })) as TextBase;
		}
		
		public function destroy():void {
			Fewf.assets.removeEventListener(ProgressEvent.PROGRESS, _onLoadProgress);
			_loadingSpinner.destroy();
		}
		
		private function _onPackLoaded(e:FewfEvent) : void {
			_leftToLoadText.setText("loading", e.data.itemsLeftToLoad);
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
