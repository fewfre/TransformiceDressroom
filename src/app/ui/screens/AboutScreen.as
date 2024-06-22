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
	import com.fewfre.display.TextBase;
	import com.fewfre.utils.I18n;
	import com.fewfre.events.FewfEvent;
	import flash.display.Bitmap;

	public class AboutScreen extends Sprite
	{
		// Storage
		private var _translatedByText : TextBase;
		
		// Constructor
		public function AboutScreen() {
			// Center Screen
			this.x = Fewf.stage.stageWidth * 0.5;
			this.y = Fewf.stage.stageHeight * 0.5;
			
			addChild(_newScreenBacking()).addEventListener(MouseEvent.CLICK, _onCloseClicked);
			var bg:RoundedRectangle = new RoundedRectangle({ width:400, height:200, origin:0.5 }).drawAsTray().appendTo(this);

			var xx:Number = 0, yy:Number = 0;
			
			///////////////////////
			// Version Info / Acknowledgements
			///////////////////////
			xx = -bg.Width*0.5 + 15; yy = -bg.Height*0.5 + 20;
			new TextBase({ text:"version", originX:0, values:ConstantsApp.VERSION }).setXY(xx, yy).appendTo(this);
			yy += 20;
			_translatedByText = new TextBase({ text:"translated_by", size:10, originX:0 }).setXY(xx, yy).appendTo(this)
			_updateTranslatedByText();
			Fewf.dispatcher.addEventListener(I18n.FILE_UPDATED, _onFileUpdated);

			///////////////////////
			// Buttons
			///////////////////////
			var bsize:Number = 80;
			
			// Github / Changelog Button
			new SpriteButton({ size:bsize, obj_scale:1, obj:new $GitHubIcon(), origin:0.5 }).appendTo(this)
				.setXY(bg.Width*0.5 - bsize/2 - 15, bg.Height*0.5 - bsize/2 - 15)
				.on(ButtonBase.CLICK, _onSourceClicked);
				
			// Discord Button
			var discordButton:ButtonBase = new SpriteButton({ size:bsize, origin:0.5 }).appendTo(this)
				.setXY(-bg.Width*0.5 + bsize/2 + 15, bg.Height*0.5 - bsize/2 - 15)
				.on(ButtonBase.CLICK, _onDiscordClicked);
			var bitmap:Bitmap = Fewf.assets.lazyLoadImageUrlAsBitmap('resources/discord-logo.png');
			bitmap.addEventListener(Event.COMPLETE, function(e):void{
				bitmap.x = -bitmap.width/2;
				bitmap.y = -bitmap.height/2;
			})
			discordButton.addChild(bitmap);
		
			///////////////////////
			// Close Button
			///////////////////////
			new ScaleButton({ x:bg.Width*0.5 - 5, y:-bg.Height*0.5 + 5, obj:new $WhiteX() }).appendTo(this)
				.on(ButtonBase.CLICK, _onCloseClicked);
		}
		
		private function _newScreenBacking() : Sprite {
			var backing:Sprite = new Sprite(), size:Number = 10000;
			backing.x = -size/2;
			backing.y = -size/2;
			backing.graphics.beginFill(0x000000, 0.2);
			backing.graphics.drawRect(0, 0, size, size);
			backing.graphics.endFill();
			return backing;
		}
		
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
