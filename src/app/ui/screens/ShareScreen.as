package app.ui.screens
{
	import app.data.ConstantsApp;
	import app.data.GameAssets;
	import app.ui.buttons.GameButton;
	import app.ui.buttons.ScaleButton;
	import app.ui.common.FancyCopyField;
	import com.adobe.images.PNGEncoder;
	import com.fewfre.display.DisplayWrapper;
	import com.fewfre.display.RoundRectangle;
	import com.fewfre.display.TextTranslated;
	import com.fewfre.loaders.SimpleUrlLoader;
	import com.fewfre.utils.Fewf;
	import com.fewfre.utils.FewfDisplayUtils;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.ByteArray;

	public class ShareScreen extends Sprite
	{
		// Storage
		private var _tfmCopyField  : FancyCopyField;
		private var _fewfCopyField : FancyCopyField;
		
		private var _imgurSpriteToUpload : Sprite;
		private var _imgurButton : GameButton;
		private var _imgurTray : Sprite;
		private var _imgurCopyField : FancyCopyField;
		
		// Constructor
		public function ShareScreen() {
			this.x = ConstantsApp.CENTER_X;
			this.y = ConstantsApp.CENTER_Y;
			
			GameAssets.createScreenBackdrop().appendTo(this).on(MouseEvent.CLICK, _onCloseClicked);
			
			var tWidth:Number = 500, tHeight:Number = 280, xx:Number = 0, yy:Number = 0;
			// Background
			new RoundRectangle(tWidth, tHeight).toOrigin(0.5).drawAsTray().appendTo(this);
			
			// Header
			yy = -95;
			new TextTranslated("share_header", { size:25 }).move(0, yy).appendTo(this);

			// TFM Syntax - Selectable text field + Copy Button and message
			yy = -50;
			new TextTranslated("share_tfm_syntax", { size:15 }).move(0, yy).appendTo(this);
			_tfmCopyField = new FancyCopyField(tWidth-50).appendTo(this).centerOrigin().move(0, yy+40);
			
			// Fewf Syntax
			yy = 55;
			new TextTranslated("share_fewfre_syntax", { size:15 }).move(0, yy).appendTo(this);
			_fewfCopyField = new FancyCopyField(tWidth-50).appendTo(this).centerOrigin().move(0, yy+40);
			
			// if(!!_getCreatePastebinUrl()) {
			// 	new GameButton(24).setTextUntranslated("🌐").toOrigin(0.5).move(tWidth/2 + 20, yy+40).appendTo(this)
			// 	.onButtonClick(function(e){
			// 		_createPastebin(_fewfCopyField.text, function(pResp, err:String=null):void{
			// 			trace('aa', pResp);
			// 			_fewfCopyField.text = pResp || err;
			// 		});
			// 	});
			// }
			
			// Imgur
			if(!!_getImgurUploadUrl()) {
				_imgurButton = new GameButton(28).setImage(new $ImgurIcon(), 0.45).setOrigin(0.5)
						.move(-tWidth/2 + 20, -tHeight/2 + 20)
						.onButtonClick(_onImgurButtonClicked)
						.appendTo(this) as GameButton;
				
				_imgurTray = DisplayWrapper.wrap(new Sprite(), this).move(0, -tHeight/2 - 35).asSprite;
				var ibg:RoundRectangle = new RoundRectangle(tWidth-50+20, 56).toOrigin(0.5).drawAsTray().appendTo(_imgurTray);
				xx = -ibg.width/2 + 16 + 15; // left + tray padding + icon margin
				DisplayWrapper.wrap(new $ImgurIcon(), _imgurTray).move(xx, 0).toScale(0.7);
				xx = ibg.width/2 - 16 - (tWidth-100)/2; // right side + tray padding + copyfield right align
				_imgurCopyField = new FancyCopyField(tWidth-100).appendTo(_imgurTray).centerOrigin().move(25, 0);
			}
			
			// Close Button
			new ScaleButton(new $WhiteX()).move(tWidth/2 - 5, -tHeight/2 + 5).appendTo(this).onButtonClick(_onCloseClicked);
		}
		public function on(type:String, listener:Function): ShareScreen { this.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): ShareScreen { this.removeEventListener(type, listener); return this; }
		
		public function open(pURL:String, pTfmOfficialDressingCode:String, pImgurTarget:Sprite) : void {
			_tfmCopyField.text = pTfmOfficialDressingCode;
			_fewfCopyField.text = pURL;
			
			_imgurSpriteToUpload = pImgurTarget;
			if(_imgurTray) {
				_imgurTray.visible = false;
			}
		}
		
		private function _onCloseClicked(e:Event) : void {
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		///////////////////////
		// Imgur
		///////////////////////
		private function _getImgurUploadUrl() : String { return Fewf.assets.getData("config").upload2imgur_url; }
		
		private function _onImgurButtonClicked(e:Event) : void {
			_imgurTray.visible = true;
			_imgurButton.disable();
			_imgurCopyField.text = "⏳ ...";
			_uploadToImgur(_imgurSpriteToUpload, function(pResp, err:String=null):void{
				_imgurButton.enable();
				if(pResp) {
					try {
						pResp = JSON.parse(pResp);
						_imgurCopyField.text = (pResp && pResp.data && pResp.data.link) || "Error: No link returned"
					} catch(err:Error) { _imgurCopyField.text = err.message || 'Unknown error' }
				} else {
					_imgurCopyField.text = err || "Error: No data returned";
				}
			});
		}
		
		private function _uploadToImgur(img:Sprite, pCallback:Function) : void {
			var tPNG:ByteArray = PNGEncoder.encode(FewfDisplayUtils.displayObjectToBitmapData(img, img.scaleX));
			new SimpleUrlLoader(_getImgurUploadUrl()).setToPost().addFormDataHeader()
				.addData("base64", FewfDisplayUtils.encodeByteArrayAsString(tPNG))
				.onComplete(function(resp){ pCallback(resp); })
				.onError(function(err:Error){ pCallback(null, "["+err.name+":"+err.errorID+"] "+err.message); })
				.load();
		}
		
		///////////////////////
		// Pastebin
		///////////////////////
		private function _getCreatePastebinUrl() : String { return Fewf.assets.getData("config").createpastebin_url; }
		
		private function _createPastebin(pPaste:String, pCallback:Function) : void {
			new SimpleUrlLoader(_getCreatePastebinUrl()).setToPost().addFormDataHeader()
				.addData("paste", pPaste)
				.onComplete(function(resp){ pCallback(resp); })
				.onError(function(err:Error){ pCallback(null, "["+err.name+":"+err.errorID+"] "+err.message); })
				.load();
		}
	}
}
