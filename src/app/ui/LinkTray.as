package app.ui
{
	import com.fewfre.display.*;
	import com.adobe.images.*;
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import app.world.data.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.text.*;
	import flash.system.System;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	
	public class LinkTray extends MovieClip
	{
		// Constants
		public static const CLOSE : String= "close_link_tray";
		
		// Storage
		private var _bg				: RoundedRectangle;
		public var _text			: TextField;
		public var _textCopiedMessage: TextBase;
		public var _textCopyTween	: Tween;
		
		// Constructor
		// pData = { x:Number, y:Number }
		public function LinkTray(pData:Object) {
			this.x = pData.x;
			this.y = pData.y;
			
			/****************************
			* Click Tray
			*****************************/
			var tClickTray = addChild(new Sprite());
			tClickTray.x = -5000;
			tClickTray.y = -5000;
			tClickTray.graphics.beginFill(0x000000, 0.2);
			tClickTray.graphics.drawRect(0, 0, -tClickTray.x*2, -tClickTray.y*2);
			tClickTray.graphics.endFill();
			tClickTray.addEventListener(MouseEvent.CLICK, _onCloseClicked);
			
			/****************************
			* Background
			*****************************/
			var tWidth:Number = 500, tHeight:Number = 200;
			_bg = addChild(new RoundedRectangle({ x:0, y:0, width:tWidth, height:tHeight, origin:0.5 }));
			_bg.drawSimpleGradient(ConstantsApp.COLOR_TRAY_GRADIENT, 15, ConstantsApp.COLOR_TRAY_B_1, ConstantsApp.COLOR_TRAY_B_2, ConstantsApp.COLOR_TRAY_B_3);
			
			/****************************
			* Header
			*****************************/
			addChild(new TextBase({ text:"share_header", size:25, y:-63 }));
			
			/****************************
			* Selectable text field
			*****************************/
			var tTFWidth:Number = tWidth-50, tTFHeight:Number = 18, tTFPaddingX:Number = 5, tTFPaddingY:Number = 5;
			// So much easier than doing it with those darn native text field options which have no padding.
			var tTextBackground:RoundedRectangle = addChild(new RoundedRectangle({ x:0, y:0, width:tTFWidth+tTFPaddingX*2, height:tTFHeight+tTFPaddingY*2, origin:0.5 }));
			tTextBackground.draw(0xFFFFFF, 7, 0x444444, 0x444444, 0x444444);
			
			_text = tTextBackground.addChild(new TextField());
			_text.type = TextFieldType.DYNAMIC;
			_text.multiline = false;
			_text.width = tTFWidth;
			_text.height = tTFHeight;
			_text.x = tTFPaddingX - tTextBackground.Width*0.5;
			_text.y = tTFPaddingY - tTextBackground.Height*0.5;
			_text.addEventListener(MouseEvent.CLICK, function(pEvent:Event){ _text.setSelection(0, _text.text.length); });
			
			/****************************
			* Copy Button and message
			*****************************/
			var tCopyButton:SpriteButton = addChild(new SpriteButton({ x:tWidth*0.5-75+25, y:52, text:"share_copy", width:50, height:25, origin:0.5 }));
			tCopyButton.addEventListener(ButtonBase.CLICK, function(){ _copyToClipboard(); });
			
			_textCopiedMessage = addChild(new TextBase({ text:"share_link_copied", size:17, originX:1, x:tCopyButton.x - 40, y:tCopyButton.y, alpha:0 }));
			
			/****************************
			* Close Button
			*****************************/
			var tCloseButton:ScaleButton = addChild(new ScaleButton({ x:tWidth*0.5 - 5, y:-tHeight*0.5 + 5, obj:new MovieClip() }));
			tCloseButton.addEventListener(ButtonBase.CLICK, _onCloseClicked);
			
			var tSize:Number = 10;
			tCloseButton.Image.graphics.beginFill(0x000000, 0);
			tCloseButton.Image.graphics.drawRect(-tSize*2, -tSize*2, tSize*4, tSize*4);
			tCloseButton.Image.graphics.endFill();
			tCloseButton.Image.graphics.lineStyle(8, 0xFFFFFF, 1, true);
			tCloseButton.Image.graphics.moveTo(-tSize, -tSize);
			tCloseButton.Image.graphics.lineTo(tSize, tSize);
			tCloseButton.Image.graphics.moveTo(tSize, -tSize);
			tCloseButton.Image.graphics.lineTo(-tSize, tSize);
		}
		
		public function open(pURL:String) : void {
			_text.text = pURL;
			_textCopiedMessage.alpha = 0;
		}
		
		private function _onCloseClicked(pEvent:Event) : void {
			dispatchEvent(new Event(CLOSE));
		}
		
		private function _copyToClipboard() : void {
			_text.setSelection(0, _text.text.length)
			System.setClipboard(_text.text);
			_textCopiedMessage.alpha = 0;
			if(_textCopyTween) _textCopyTween.start(); else _textCopyTween = new Tween(_textCopiedMessage, "alpha", Elastic.easeOut, 0, 1, 1, true);
		}
	}
}
