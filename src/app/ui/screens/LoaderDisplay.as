package app.ui.screens
{
	import app.ui.common.LoadingSpinner;
	import com.fewfre.display.RoundRectangle;
	import com.fewfre.display.TextTranslated;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.utils.AssetManager;
	import com.fewfre.utils.Fewf;
	import flash.display.Sprite;
	import flash.events.ProgressEvent;

	public class LoaderDisplay
	{
		// Storage
		private var _root : Sprite;
		private var _loadingSpinner	: LoadingSpinner;
		private var _leftToLoadText	: TextTranslated;
		private var _loadProgressText: TextTranslated;
		
		// Constructor
		public function LoaderDisplay() {
			_root = new Sprite();
			new RoundRectangle(500, 200).toOrigin(0.5).drawAsTray().appendTo(_root);
			
			Fewf.assets.addEventListener(ProgressEvent.PROGRESS, _onLoadProgress);
			Fewf.assets.addEventListener(AssetManager.PACK_LOADED, _onPackLoaded);
			
			_loadingSpinner = new LoadingSpinner(2).move(0, -45).appendTo(_root);
			
			_leftToLoadText = new TextTranslated("loading", { values:"", size:18, x:0, y:10 }).appendToT(_root);
			_loadProgressText = new TextTranslated("loading_progress", { values:"", size:18, x:0, y:35 }).appendToT(_root);
		}
		public function move(pX:Number, pY:Number) : LoaderDisplay { _root.x = pX; _root.y = pY; return this; }
		public function appendTo(pParent:Sprite): LoaderDisplay { pParent.addChild(_root); return this; }
		public function removeSelf(): LoaderDisplay { if(_root.parent){ _root.parent.removeChild(_root); } return this; }
		
		public function destroy():void {
			Fewf.assets.removeEventListener(ProgressEvent.PROGRESS, _onLoadProgress);
			_loadingSpinner.removeSelf().destroy();
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
