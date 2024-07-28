package app.ui.screens
{
	
	import flash.display.Sprite;
	import app.ui.common.RoundedRectangle;
	import com.fewfre.utils.Fewf;
	import app.data.GameAssets;
	import flash.events.MouseEvent;
	import app.ui.buttons.SpriteButton;
	import com.fewfre.display.ButtonBase;
	import app.ui.buttons.ScaleButton;
	import flash.events.Event;
	import com.fewfre.events.FewfEvent;
	import app.data.ConstantsApp;
	import com.fewfre.utils.AssetManager;

	public class LangScreen extends Sprite
	{
		// Storage
		private var _tray : RoundedRectangle;
		
		// Constructor
		public function LangScreen() {
			this.x = Fewf.stage.stageWidth * 0.5;
			this.y = Fewf.stage.stageHeight * 0.5;
			
			GameAssets.createScreenBackdrop().appendTo(this).on(MouseEvent.CLICK, _onCloseClicked);
			
			var tWidth:Number = 500, tHeight:Number = 200;
			// Background
			_tray = new RoundedRectangle(tWidth, tHeight, { origin:0.5 }).appendTo(this).drawAsTray();

			/****************************
			* Languages
			*****************************/
			var tLanguages:Array = Fewf.assets.getData("config").languages.list;
			
			var tFlagTray:Sprite = _tray.addChild(new Sprite()) as Sprite, tFlagRowTray:Sprite, xx:Number;
			var tBtn:SpriteButton, tLangData:Object, tColumns:int = 8, tRows:Number = 1+Math.floor((tLanguages.length-1) / tColumns), tColumnsInRow:int = tColumns;
			for(var i:int = 0; i < tLanguages.length; i++) { tLangData = tLanguages[i];
				if(i%tColumns == 0) {
					tColumnsInRow = i+tColumns > tLanguages.length ? tLanguages.length - i : tColumns;
					tFlagRowTray = tFlagTray.addChild(new Sprite()) as Sprite;
					tFlagRowTray.x += -(tColumnsInRow*55*0.5)+(55*0.5)+1;
					tFlagRowTray.y += Math.floor(i/tColumns)*55;
					xx = -55;
				}
				new SpriteButton({ x:xx+=55, width:50, height:50, obj_scale:0.3, obj:_getFlagImage(tLangData), data:tLangData, origin:0.5 })
				.appendTo(tFlagRowTray).on(ButtonBase.CLICK, _onLanguageClicked);
			}
			tFlagTray.y -= 55*(tRows-1)*0.5;
			
			// Close Button
			ScaleButton.withObject(new $WhiteX()).setXY(tWidth/2 - 5, -tHeight/2 + 5).appendTo(this).on(ButtonBase.CLICK, _onCloseClicked);
		}
		public function on(type:String, listener:Function): LangScreen { this.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): LangScreen { this.removeEventListener(type, listener); return this; }
		
		///////////////////////
		// Public
		///////////////////////
		public function open() : void {
			
		}
		
		///////////////////////
		// Private
		///////////////////////
		private function _onCloseClicked(pEvent:Event) : void { _close(); }
		private function _close() : void {
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		private function _getFlagImage(pLangData:Object) : Sprite {
			var tImage:Sprite = new Sprite();
			var tFlag:Sprite = tImage.addChild(Fewf.assets.getLoadedMovieClip(pLangData.flags_swf_linkage)) as Sprite;
			tFlag.x -= tFlag.width*0.5;
			tFlag.y -= tFlag.height*0.5;
			return tImage;
		}
		
		private function _onLanguageClicked(pEvent:FewfEvent) : void {
			var tLangData = pEvent.data;
			Fewf.sharedObjectGlobal.setData(ConstantsApp.SHARED_OBJECT_KEY_GLOBAL_LANG, tLangData.code);
			_close();
			if(Fewf.assets.getData(tLangData.code)) {
				Fewf.i18n.parseFile(tLangData.code, Fewf.assets.getData(tLangData.code));
				return;
			}
			
			var tLoaderDisplay:LoaderDisplay = addChild( new LoaderDisplay() ) as LoaderDisplay;
			Fewf.assets.load([ Fewf.swfUrlBase+"resources/i18n/"+tLangData.code+".json" ]);
			Fewf.assets.addEventListener(AssetManager.LOADING_FINISHED, function(e:Event){
				Fewf.assets.removeEventListener(AssetManager.LOADING_FINISHED, arguments.callee);
				tLoaderDisplay.destroy();
				removeChild( tLoaderDisplay );
				tLoaderDisplay = null;
				
				Fewf.i18n.parseFile(tLangData.code, Fewf.assets.getData(tLangData.code));
			});
		}
	}
}
