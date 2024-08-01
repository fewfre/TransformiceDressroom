package app.ui.screens
{
	import app.data.ConstantsApp;
	import app.data.GameAssets;
	import app.ui.buttons.ScaleButton;
	import app.ui.buttons.SpriteButton;
	import com.fewfre.display.DisplayWrapper;
	import com.fewfre.display.RoundRectangle;
	import com.fewfre.display.TextTranslated;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.utils.Fewf;
	import com.fewfre.utils.I18n;
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;

	public class AboutScreen extends Sprite
	{
		// Storage
		private var _translatedByText : TextTranslated;
		
		// Constructor
		public function AboutScreen() {
			// Center Screen
			this.x = Fewf.stage.stageWidth * 0.5;
			this.y = Fewf.stage.stageHeight * 0.5;
			
			GameAssets.createScreenBackdrop().appendTo(this).on(MouseEvent.CLICK, _onCloseClicked);
			
			var tWidth:Number = 400, tHeight:Number = 200;
			// Background
			new RoundRectangle(tWidth, tHeight).toOrigin(0.5).drawAsTray().appendTo(this);

			var xx:Number = 0, yy:Number = 0;
			
			///////////////////////
			// Version Info / Acknowledgements
			///////////////////////
			xx = -tWidth*0.5 + 15; yy = -tHeight*0.5 + 20;
			new TextTranslated("version", { originX:0, values:ConstantsApp.VERSION }).setXY(xx, yy).appendTo(this);
			yy += 20;
			_translatedByText = new TextTranslated("translated_by", { size:10, originX:0 }).setXYT(xx, yy).appendToT(this)
			_updateTranslatedByText();
			Fewf.dispatcher.addEventListener(I18n.FILE_UPDATED, _onFileUpdated);

			///////////////////////
			// Buttons
			///////////////////////
			var bsize:Number = 80;
			
			// Github / Changelog Button
			SpriteButton.withObject(new $GitHubIcon(), 1, { size:bsize, origin:0.5 }).appendTo(this)
				.setXY(tWidth*0.5 - bsize/2 - 15, tHeight*0.5 - bsize/2 - 15)
				.onButtonClick(_onSourceClicked);
				
			// Discord Button
			SpriteButton.withObject(new $DiscordLogo(), 1, { size:bsize, origin:0.5 }).appendTo(this)
				.setXY(-tWidth*0.5 + bsize/2 + 15, tHeight*0.5 - bsize/2 - 15)
				.onButtonClick(_onDiscordClicked);
		
			///////////////////////
			// Close Button
			///////////////////////
			ScaleButton.withObject(new $WhiteX()).setXY(tWidth/2 - 5, -tHeight/2 + 5).appendTo(this).onButtonClick(_onCloseClicked);
		}
		public function on(type:String, listener:Function): AboutScreen { this.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): AboutScreen { this.removeEventListener(type, listener); return this; }
		
		///////////////////////
		// Public
		///////////////////////
		public function open() : void {
			
		}
		
		///////////////////////
		// Private
		///////////////////////
		private function _updateTranslatedByText() : void {
			_translatedByText.visible = Fewf.i18n.lang != "en" && Fewf.i18n.getText("translated_by");
		}
		
		///////////////////////
		// Events
		///////////////////////
		private function _onCloseClicked(e:Event) : void {
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		private function _onSourceClicked(pEvent:*) : void {
			navigateToURL(new URLRequest(ConstantsApp.SOURCE_URL), "_blank");
		}
		
		private function _onDiscordClicked(pEvent:*) : void {
			navigateToURL(new URLRequest(ConstantsApp.DISCORD_URL), "_blank");
		}
		
		// Refresh text to new value.
		protected function _onFileUpdated(e:FewfEvent) : void {
			// Since some text is hidden on "en", has to be re-added each time language changes.
			_updateTranslatedByText();
		}
	}
}
