package app.ui.screens
{	
	import app.data.ConstantsApp;
	import app.data.GameAssets;
	import app.ui.buttons.ScaleButton;
	import app.ui.buttons.SpriteButton;
	import com.fewfre.data.I18n;
	import com.fewfre.data.I18nLangData;
	import com.fewfre.display.RoundRectangle;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.utils.AssetManager;
	import com.fewfre.utils.Fewf;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class LangScreen extends Sprite
	{
		// Constructor
		public function LangScreen() {
			this.x = Fewf.stage.stageWidth * 0.5;
			this.y = Fewf.stage.stageHeight * 0.5;
			
			GameAssets.createScreenBackdrop().appendTo(this).on(MouseEvent.CLICK, _onCloseClicked);
			
			var tWidth:Number = 500, tHeight:Number = 200;
			// Background
			new RoundRectangle(tWidth, tHeight).toOrigin(0.5).drawAsTray().appendTo(this);

			/****************************
			* Languages
			*****************************/
			var tLanguages:Vector.<I18nLangData> = Fewf.i18n.getLanguagesList();
			
			var tFlagTray:Sprite = addChild(new Sprite()) as Sprite, tFlagRowTray:Sprite, xx:Number;
			var tBtn:SpriteButton, tLangData:I18nLangData, tColumns:int = 8, tRows:Number = 1+Math.floor((tLanguages.length-1) / tColumns), tColumnsInRow:int = tColumns;
			for(var i:int = 0; i < tLanguages.length; i++) { tLangData = tLanguages[i];
				if(i%tColumns == 0) {
					tColumnsInRow = i+tColumns > tLanguages.length ? tLanguages.length - i : tColumns;
					tFlagRowTray = tFlagTray.addChild(new Sprite()) as Sprite;
					tFlagRowTray.x += -(tColumnsInRow*55*0.5)+(55*0.5)+1;
					tFlagRowTray.y += Math.floor(i/tColumns)*55;
					xx = -55;
				}
				SpriteButton.withObject(tLangData.newFlagSprite(), 0.3, { size:50, data:tLangData, origin:0.5 })
					.move(xx+=55, 0).appendTo(tFlagRowTray).onButtonClick(_onLanguageClicked);
			}
			tFlagTray.y -= 55*(tRows-1)*0.5;
			
			// Close Button
			ScaleButton.withObject(new $WhiteX()).move(tWidth/2 - 5, -tHeight/2 + 5).appendTo(this).onButtonClick(_onCloseClicked);
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
		
		private function _onLanguageClicked(pEvent:FewfEvent) : void {
			var tLangData:I18nLangData = pEvent.data as I18nLangData;
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
		
		///////////////////////
		// Static
		///////////////////////
		public static function createLangButton(pProps:Object) : SpriteButton {
			var bttn:SpriteButton = SpriteButton.withObject(new Sprite(), 0.18, pProps);
			
			function _changeImageToCurrentLanguage() : void {
				bttn.ChangeImage( Fewf.i18n.getConfigLangData().newFlagSprite() );
			}
			
			_changeImageToCurrentLanguage();
			Fewf.dispatcher.addEventListener(I18n.FILE_UPDATED, function(e):void{ _changeImageToCurrentLanguage(); });
			
			return bttn;
		}
	}
}
