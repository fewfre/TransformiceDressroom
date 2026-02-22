package app.ui.screens
{	
	import app.data.ConstantsApp;
	import app.data.GameAssets;
	import app.ui.buttons.ScaleButton;
	import app.ui.buttons.GameButton;
	import com.fewfre.data.I18n;
	import com.fewfre.data.I18nLangData;
	import com.fewfre.display.RoundRectangle;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.utils.Fewf;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.events.MouseEvent;

	public class LangScreen
	{
		// Storage
		private var _root : Sprite;
		
		// Constructor
		public function LangScreen() {
			_root = new Sprite();
			_root.x = ConstantsApp.CENTER_X;
			_root.y = ConstantsApp.CENTER_Y;
			
			GameAssets.createScreenBackdrop().appendTo(_root).on(MouseEvent.CLICK, _onCloseClicked);
			
			var tWidth:Number = 500, tHeight:Number = 200;
			// Background
			new RoundRectangle(tWidth, tHeight).toOrigin(0.5).drawAsTray().appendTo(_root);

			/****************************
			* Languages
			*****************************/
			var tLanguages:Vector.<I18nLangData> = Fewf.i18n.supportedLanguages;
			
			var tFlagTray:Sprite = _root.addChild(new Sprite()) as Sprite, tFlagRowTray:Sprite, xx:Number;
			var tLangData:I18nLangData, tColumns:int = 8, tRows:Number = 1+Math.floor((tLanguages.length-1) / tColumns), tColumnsInRow:int = tColumns;
			for(var i:int = 0; i < tLanguages.length; i++) { tLangData = tLanguages[i];
				if(i%tColumns == 0) {
					tColumnsInRow = i+tColumns > tLanguages.length ? tLanguages.length - i : tColumns;
					tFlagRowTray = tFlagTray.addChild(new Sprite()) as Sprite;
					tFlagRowTray.x += -(tColumnsInRow*55*0.5)+(55*0.5)+1;
					tFlagRowTray.y += Math.floor(i/tColumns)*55;
					xx = -55;
				}
				new GameButton(50).setImage(tLangData.newFlagSprite(), 0.3).setOrigin(0.5).setData(tLangData)
					.move(xx+=55, 0).appendTo(tFlagRowTray).onButtonClick(_onLanguageClicked);
			}
			tFlagTray.y -= 55*(tRows-1)*0.5;
			
			// Close Button
			new ScaleButton(new $WhiteX()).move(tWidth/2 - 5, -tHeight/2 + 5).appendTo(_root).onButtonClick(_onCloseClicked);
		}
		public function appendTo(pParent:Sprite): LangScreen { pParent.addChild(_root); return this; }
		public function removeSelf(): LangScreen { if(_root.parent){ _root.parent.removeChild(_root); } return this; }
		public function on(type:String, listener:Function): LangScreen { _root.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): LangScreen { _root.removeEventListener(type, listener); return this; }
		public function onCloseRemoveSelf(): LangScreen { this.on(Event.CLOSE, function(e:Event):void { removeSelf(); }); return this; }
		
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
			_root.dispatchEvent(new Event(Event.CLOSE));
		}
		
		private function _onLanguageClicked(pEvent:FewfEvent) : void {
			var tLangData:I18nLangData = pEvent.data as I18nLangData;
			Fewf.sharedObjectGlobal.setData(ConstantsApp.SHARED_OBJECT_KEY_GLOBAL_LANG, tLangData.code);
			_close();
			
			var tLoaderDisplay:LoaderDisplay = new LoaderDisplay().appendTo(_root);
			Fewf.i18n.loadLanguagesIfNeededAndUseLastLang([ tLangData.code ], function():void{
				tLoaderDisplay.removeSelf().destroy();
				tLoaderDisplay = null;
			});
		}
		
		///////////////////////
		// Static
		///////////////////////
		public static function createLangButton(pWidth:Number, pHeight:Number) : GameButton {
			var bttn:GameButton = new GameButton(pWidth, pHeight).setOrigin(0.5);
			
			function _changeImageToCurrentLanguage() : void {
				bttn.setImage( Fewf.i18n.getConfigLangData().newFlagSprite(), 0.18 );
				bttn.Image.x += 0.5;
				bttn.Image.y += 0.5;
			}
			
			_changeImageToCurrentLanguage();
			Fewf.dispatcher.addEventListener(I18n.FILE_UPDATED, function(e):void{ _changeImageToCurrentLanguage(); });
			
			return bttn;
		}
	}
}
