package app.ui
{
	import app.ui.buttons.*;
	import app.data.*;
	import com.fewfre.display.*;
	import com.fewfre.events.*;
	import com.fewfre.utils.*;
	import flash.display.*;
	import flash.net.*;
	import ext.ParentApp;

	public class AppInfoBox extends Sprite
	{
		// Storage
		private var _textTray:Sprite;

		// Constructor
		public function AppInfoBox() {
			var btn:ButtonBase, tButtonSize:Number = 25;
			
			btn = addChild(new SpriteButton({ width:tButtonSize, height:tButtonSize, obj_scale:0.35, obj:new $GitHubIcon(), origin:0.5 })) as SpriteButton;
			btn.addEventListener(ButtonBase.CLICK, _onSourceClicked);
			
			_setupTextTray();
			
			if(!!(ParentApp.reopenSelectionLauncher())) {
				btn = addChild(new ScaleButton({ x:-30, y:-28, obj_scale:0.5, obj:new $BackArrow(), origin:0.5 })) as ScaleButton;
				btn.addEventListener(ButtonBase.CLICK, function():void{ ParentApp.reopenSelectionLauncher()(); });
			}
			
			_addEventListeners();
		}
		public function setXY(pX:Number, pY:Number) : AppInfoBox { x = pX; y = pY; return this; }
		public function appendTo(target:Sprite): AppInfoBox { target.addChild(this); return this; }
		
		private function _setupTextTray() : void {
			_textTray = addChild(new Sprite()) as Sprite;
			_textTray.x = 25*0.5 + 4;
			if(Fewf.i18n.lang == "en" || !Fewf.i18n.getText("translated_by")) {
				_textTray.addChild(new TextBase({ text:"version", originX:0, values:ConstantsApp.VERSION }));
			} else {
				_textTray.addChild(new TextBase({ text:"version", y:-6, size:10, originX:0, values:ConstantsApp.VERSION }));
				_textTray.addChild(new TextBase({ text:"translated_by", y:6, size:10, originX:0, values:ConstantsApp.VERSION }));
			}
		}
		
		private function _onSourceClicked(pEvent:*) : void {
			navigateToURL(new URLRequest(ConstantsApp.SOURCE_URL), "_blank");
		}

		/****************************
		* Events
		*****************************/
		protected function _addEventListeners() : void {
			Fewf.dispatcher.addEventListener(I18n.FILE_UPDATED, _onFileUpdated);
		}
		
		// Refresh text to new value.
		protected function _onFileUpdated(e:FewfEvent) : void {
			// Since some text is hidden on "en", has to be re-added each time language changes.
			removeChild(_textTray);
			_setupTextTray();
		}
	}
}
