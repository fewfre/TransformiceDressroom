package app.ui.screens
{
	import app.data.ConstantsApp;
	import app.data.GameAssets;
	import app.ui.buttons.GameButton;
	import app.ui.buttons.ScaleButton;
	import app.ui.common.FancyInput;
	import com.fewfre.data.I18n;
	import com.fewfre.display.DisplayWrapper;
	import com.fewfre.display.RoundRectangle;
	import com.fewfre.display.TextTranslated;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.utils.Fewf;
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;

	public class AboutScreen
	{
		// Storage
		private var _root : Sprite;
		private var _translatedByText : TextTranslated;
		
		// Constructor
		public function AboutScreen() {
			_root = new Sprite();
			_root.x = ConstantsApp.CENTER_X;
			_root.y = ConstantsApp.CENTER_Y - 25;
			
			GameAssets.createScreenBackdrop().appendTo(_root).on(MouseEvent.CLICK, _onCloseClicked);
			
			var tWidth:Number = 400, tHeight:Number = 200;
			// Background
			new RoundRectangle(tWidth, tHeight).toOrigin(0.5).drawAsTray().appendTo(_root);

			var xx:Number = 0, yy:Number = 0;
			
			///////////////////////
			// Version Info / Acknowledgements
			///////////////////////
			xx = -tWidth*0.5 + 15; yy = -tHeight*0.5 + 20;
			new TextTranslated("version", { originX:0, values:ConstantsApp.VERSION }).move(xx, yy).appendTo(_root);
			yy += 20;
			_translatedByText = new TextTranslated("translated_by", { size:10, originX:0 }).moveT(xx, yy).appendToT(_root)
			_updateTranslatedByText();
			Fewf.dispatcher.addEventListener(I18n.FILE_UPDATED, _onFileUpdated);

			///////////////////////
			// Buttons
			///////////////////////
			var bsize:Number = 80;
			
			// Github / Changelog Button
			new GameButton(bsize).setImage(new $GitHubIcon()).setOrigin(0.5).appendTo(_root)
				.move(tWidth*0.5 - bsize/2 - 15, tHeight*0.5 - bsize/2 - 15)
				.onButtonClick(_onSourceClicked);
				
			// Discord Button
			new GameButton(bsize).setImage(new $DiscordLogo()).setOrigin(0.5).appendTo(_root)
				.move(-tWidth*0.5 + bsize/2 + 15, tHeight*0.5 - bsize/2 - 15)
				.onButtonClick(_onDiscordClicked);
		
			///////////////////////
			// Settings
			///////////////////////
			DisplayWrapper.wrap(_setupSettingsTray(), _root).move(0, tHeight/2 + 10);
		
			///////////////////////
			// Close Button
			///////////////////////
			new ScaleButton(new $WhiteX()).move(tWidth/2 - 5, -tHeight/2 + 5).appendTo(_root).onButtonClick(_onCloseClicked);
		}
		public function appendTo(pParent:Sprite): AboutScreen { pParent.addChild(_root); return this; }
		public function removeSelf(): AboutScreen { if(_root.parent){ _root.parent.removeChild(_root); } return this; }
		public function on(type:String, listener:Function): AboutScreen { _root.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): AboutScreen { _root.removeEventListener(type, listener); return this; }
		public function onCloseRemoveSelf(): AboutScreen { this.on(Event.CLOSE, function(e:Event):void { removeSelf(); }); return this; }
		
		private function _setupSettingsTray() : Sprite {
			var tTray:Sprite = new Sprite(), yy:Number = 4;
			var tBg:RoundRectangle = new RoundRectangle(150+250, 66).toOrigin(0.5, 0).drawAsTray().appendTo(tTray);
			
			// Hardcoded Save Scale Input
			yy += 28/2;
			new TextTranslated("setting_hardcoded_save_scale_label", { size:10, originX:0 }).moveT(-tBg.width/2+10, yy).appendToT(tTray);
			var hardcodedCanvasSaveScale:Object = Fewf.sharedObject.getData(ConstantsApp.SHARED_OBJECT_KEY_HARDCODED_SAVE_SCALE);
			new FancyInput({ width:210 }).setText((hardcodedCanvasSaveScale || "").toString()).setPlaceholderText("setting_hardcoded_save_scale_placeholder").move(75, yy).appendTo(tTray)
				.setRestrict("0-9\.")
				.on_field(Event.CHANGE, function(e:Event){
					var size:Number = parseFloat(e.target.text);
					Fewf.sharedObject.setData(ConstantsApp.SHARED_OBJECT_KEY_HARDCODED_SAVE_SCALE, !size || isNaN(size) ? null : size);
				});
			
			// Hardcoded Canvas Size Input
			yy += 28 + 2;
			new TextTranslated("setting_hardcoded_save_size_label", { size:10, originX:0 }).moveT(-tBg.width/2+10, yy).appendToT(tTray);
			var hardcodedCanvasSaveSize:Object = Fewf.sharedObject.getData(ConstantsApp.SHARED_OBJECT_KEY_HARDCODED_CANVAS_SAVE_SIZE);
			new FancyInput({ width:210 }).setText((hardcodedCanvasSaveSize || "").toString()).setPlaceholderText("setting_hardcoded_save_size_placeholder").move(75, yy).appendTo(tTray)
				.setRestrict("0-9")
				.on_field(Event.CHANGE, function(e:Event){
					var size:Number = parseInt(e.target.text);
					Fewf.sharedObject.setData(ConstantsApp.SHARED_OBJECT_KEY_HARDCODED_CANVAS_SAVE_SIZE, !size || isNaN(size) ? null : size);
				});
			
			return tTray;
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
			_root.dispatchEvent(new Event(Event.CLOSE));
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
