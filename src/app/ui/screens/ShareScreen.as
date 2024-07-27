package app.ui.screens
{
	import app.ui.buttons.ScaleButton;
	import app.ui.buttons.SpriteButton;
	import app.ui.common.RoundedRectangle;
	import com.fewfre.display.ButtonBase;
	import com.fewfre.display.TextTranslated;
	import com.fewfre.utils.Fewf;
	import fl.transitions.easing.Elastic;
	import fl.transitions.Tween;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import app.data.GameAssets;

	public class ShareScreen extends Sprite
	{
		// Storage
		private var _bg					: RoundedRectangle;
		
		public var _text				: TextField;
		public var _textCopiedMessage	: TextTranslated;
		public var _textCopyTween		: Tween;
		
		public var _text2				: TextField;
		public var _textCopiedMessage2	: TextTranslated;
		public var _textCopyTween2		: Tween;
		
		// Constructor
		public function ShareScreen() {
			// Center Screen
			this.x = Fewf.stage.stageWidth * 0.5;
			this.y = Fewf.stage.stageHeight * 0.5;
			
			GameAssets.createScreenBackdrop().appendTo(this).on(MouseEvent.CLICK, _onCloseClicked);
			
			/****************************
			* Background
			*****************************/
			var tWidth:Number = 500, tHeight:Number = 300;
			_bg = new RoundedRectangle(tWidth, tHeight, { origin:0.5 }).appendTo(this).drawAsTray();
			
			/****************************
			* Header
			*****************************/
			new TextTranslated("share_header", { size:25, y:-110 }).appendToT(this);
			
			/****************************
			* #1 - Selectable text field + Copy Button and message
			*****************************/
			var tY:Number = 80;
			
			new TextTranslated("share_fewfre_syntax", { size:15, y:tY-30 }).appendToT(this);
			
			_text = _newCopyInput({ x:0, y:tY }, this);
			
			var tCopyButton:SpriteButton = new SpriteButton({ x:tWidth*0.5-(80/2)-20, y:tY+39, text:"share_copy", width:80, height:25, origin:0.5 }).appendTo(this)
				.on(ButtonBase.CLICK, function():void{ _copyToClipboard(); }) as SpriteButton;
			
			_textCopiedMessage = new TextTranslated("share_link_copied", { size:17, originX:1, x:tCopyButton.x - tCopyButton.Width/2 - 10, y:tCopyButton.y, alpha:0 }).appendToT(this);
			
			/****************************
			* #2 - Selectable text field + Copy Button and message
			*****************************/
			tY = -35;
			
			new TextTranslated("share_tfm_syntax", { size:15, y:tY-30 }).appendTo(this);
			
			_text2 = _newCopyInput({ x:0, y:tY }, this);
			
			var tCopyButton2:SpriteButton = new SpriteButton({ x:tWidth*0.5-(80/2)-20, y:tY+39, text:"share_copy", width:80, height:25, origin:0.5 }).appendTo(this)
				.on(ButtonBase.CLICK, function():void{ _copyToClipboard2(); }) as SpriteButton;
			
			_textCopiedMessage2 = new TextTranslated("share_link_copied", { size:17, originX:1, x:tCopyButton2.x - tCopyButton2.Width/2 - 10, y:tCopyButton2.y, alpha:0 }).appendToT(this);
			
			/****************************
			* Close Button
			*****************************/
			ScaleButton.withObject(new $WhiteX()).setXY(tWidth/2 - 5, -tHeight/2 + 5).appendTo(this).on(ButtonBase.CLICK, _onCloseClicked);
		}
		public function on(type:String, listener:Function): ShareScreen { this.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): ShareScreen { this.removeEventListener(type, listener); return this; }
		
		public function open(pURL:String, pTfmOfficialDressingCode:String) : void {
			_text.text = pURL;
			_text2.text = pTfmOfficialDressingCode;
			_clearCopiedMessages();
		}
		
		private function _onCloseClicked(pEvent:Event) : void {
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		private function _clearCopiedMessages() : void {
			if(_textCopyTween) _textCopyTween.stop();
			if(_textCopyTween2) _textCopyTween2.stop();
			_textCopiedMessage.alpha = 0;
			_textCopiedMessage2.alpha = 0;
		}
		
		private function _copyToClipboard() : void {
			_clearCopiedMessages();
			_text.setSelection(0, _text.text.length)
			System.setClipboard(_text.text);
			_textCopiedMessage.alpha = 0;
			if(_textCopyTween) _textCopyTween.start(); else _textCopyTween = new Tween(_textCopiedMessage, "alpha", Elastic.easeOut, 0, 1, 1, true);
		}
		
		private function _copyToClipboard2() : void {
			_clearCopiedMessages();
			_text2.setSelection(0, _text2.text.length)
			System.setClipboard(_text2.text);
			_textCopiedMessage2.alpha = 0;
			if(_textCopyTween2) _textCopyTween2.start(); else _textCopyTween2 = new Tween(_textCopiedMessage2, "alpha", Elastic.easeOut, 0, 1, 1, true);
		}
		
		private function _newCopyInput(pData:Object, pParent:Sprite) : TextField {
			var tTFWidth:Number = _bg.width-50, tTFHeight:Number = 18, tTFPaddingX:Number = 5, tTFPaddingY:Number = 5;
			var tTextBackground:RoundedRectangle = new RoundedRectangle(tTFWidth+tTFPaddingX*2, tTFHeight+tTFPaddingY*2, { origin:0.5 }).setXY(pData.x, pData.y)
				.appendTo(pParent).draw(0xFFFFFF, 7, 0x444444);
			
			var tTextField:TextField = tTextBackground.addChild(new TextField()) as TextField;
			tTextField.type = TextFieldType.DYNAMIC;
			tTextField.multiline = false;
			tTextField.width = tTFWidth;
			tTextField.height = tTFHeight;
			tTextField.x = tTFPaddingX - tTextBackground.Width*0.5;
			tTextField.y = tTFPaddingY - tTextBackground.Height*0.5;
			tTextField.addEventListener(MouseEvent.CLICK, function(pEvent:Event):void{
				_clearCopiedMessages();
				tTextField.setSelection(0, tTextField.text.length);
			});
			return tTextField;
		}
	}
}
