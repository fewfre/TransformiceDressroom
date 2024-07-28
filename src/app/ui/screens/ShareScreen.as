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
	import app.ui.common.FancyCopyField;

	public class ShareScreen extends Sprite
	{
		// Storage
		private var _bg           : RoundedRectangle;
		
		public var _tfmCopyField  : FancyCopyField;
		public var _fewfCopyField : FancyCopyField;
		
		// Constructor
		public function ShareScreen() {
			// Center Screen
			this.x = Fewf.stage.stageWidth * 0.5;
			this.y = Fewf.stage.stageHeight * 0.5;
			
			GameAssets.createScreenBackdrop().appendTo(this).on(MouseEvent.CLICK, _onCloseClicked);
			
			var tWidth:Number = 500, tHeight:Number = 280, yy:Number = 0;
			// Background
			_bg = new RoundedRectangle(tWidth, tHeight, { origin:0.5 }).appendTo(this).drawAsTray();
			
			// Header
			yy = -95;
			new TextTranslated("share_header", { size:25 }).setXY(0, yy).appendTo(this);

			// TFM Syntax - Selectable text field + Copy Button and message
			yy = -50;
			new TextTranslated("share_tfm_syntax", { size:15 }).setXY(0, yy).appendTo(this);
			_tfmCopyField = new FancyCopyField(_bg.width-50).appendTo(this).centerOrigin().move(0, yy+40);
			
			// Fewf Syntax
			yy = 55;
			new TextTranslated("share_fewfre_syntax", { size:15 }).setXY(0, yy).appendTo(this);
			_fewfCopyField = new FancyCopyField(_bg.width-50).appendTo(this).centerOrigin().move(0, yy+40);
			
			// Close Button
			ScaleButton.withObject(new $WhiteX()).setXY(tWidth/2 - 5, -tHeight/2 + 5).appendTo(this).on(ButtonBase.CLICK, _onCloseClicked);
		}
		public function on(type:String, listener:Function): ShareScreen { this.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): ShareScreen { this.removeEventListener(type, listener); return this; }
		
		public function open(pURL:String, pTfmOfficialDressingCode:String) : void {
			_tfmCopyField.text = pTfmOfficialDressingCode;
			_fewfCopyField.text = pURL;
		}
		
		private function _onCloseClicked(pEvent:Event) : void {
			dispatchEvent(new Event(Event.CLOSE));
		}
	}
}
