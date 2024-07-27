package app.ui.screens
{
	import app.ui.buttons.ScaleButton;
	import app.ui.common.RoundedRectangle;
	import com.fewfre.display.ButtonBase;
	import com.fewfre.utils.Fewf;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import app.ui.buttons.SpriteButton;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import app.data.ConstantsApp;
	import com.fewfre.display.TextTranslated;
	import com.fewfre.utils.I18n;
	import com.fewfre.events.FewfEvent;
	import flash.display.Bitmap;
	import com.fewfre.display.DisplayWrapper;
	import flash.display.Graphics;
	import app.data.GameAssets;

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
			var bg:RoundedRectangle = new RoundedRectangle(400, 200, { origin:0.5 }).drawAsTray().appendTo(this);

			var xx:Number = 0, yy:Number = 0;
			
			///////////////////////
			// Version Info / Acknowledgements
			///////////////////////
			xx = -bg.Width*0.5 + 15; yy = -bg.Height*0.5 + 20;
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
				.setXY(bg.Width*0.5 - bsize/2 - 15, bg.Height*0.5 - bsize/2 - 15)
				.on(ButtonBase.CLICK, _onSourceClicked);
				
			// Discord Button
			SpriteButton.withObject(new $DiscordLogo(), 1, { size:bsize, origin:0.5 }).appendTo(this)
				.setXY(-bg.Width*0.5 + bsize/2 + 15, bg.Height*0.5 - bsize/2 - 15)
				.on(ButtonBase.CLICK, _onDiscordClicked);
		
			///////////////////////
			// Close Button
			///////////////////////
			ScaleButton.withObject(new $WhiteX()).setXY(bg.Width/2 - 5, -bg.Height/2 + 5).appendTo(this).on(ButtonBase.CLICK, _onCloseClicked);
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
