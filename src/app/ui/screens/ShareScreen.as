package app.ui.screens
{
	import app.data.GameAssets;
	import app.ui.buttons.ScaleButton;
	import app.ui.common.FancyCopyField;
	import com.fewfre.display.RoundRectangle;
	import com.fewfre.display.TextTranslated;
	import com.fewfre.utils.Fewf;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class ShareScreen extends Sprite
	{
		// Storage
		private var _tfmCopyField  : FancyCopyField;
		private var _fewfCopyField : FancyCopyField;
		
		// Constructor
		public function ShareScreen() {
			// Center Screen
			this.x = Fewf.stage.stageWidth * 0.5;
			this.y = Fewf.stage.stageHeight * 0.5;
			
			GameAssets.createScreenBackdrop().appendTo(this).on(MouseEvent.CLICK, _onCloseClicked);
			
			var tWidth:Number = 500, tHeight:Number = 280, yy:Number = 0;
			// Background
			new RoundRectangle(tWidth, tHeight).toOrigin(0.5).drawAsTray().appendTo(this);
			
			// Header
			yy = -95;
			new TextTranslated("share_header", { size:25 }).setXY(0, yy).appendTo(this);

			// TFM Syntax - Selectable text field + Copy Button and message
			yy = -50;
			new TextTranslated("share_tfm_syntax", { size:15 }).setXY(0, yy).appendTo(this);
			_tfmCopyField = new FancyCopyField(tWidth-50).appendTo(this).centerOrigin().move(0, yy+40);
			
			// Fewf Syntax
			yy = 55;
			new TextTranslated("share_fewfre_syntax", { size:15 }).setXY(0, yy).appendTo(this);
			_fewfCopyField = new FancyCopyField(tWidth-50).appendTo(this).centerOrigin().move(0, yy+40);
			
			// Close Button
			ScaleButton.withObject(new $WhiteX()).setXY(tWidth/2 - 5, -tHeight/2 + 5).appendTo(this).onButtonClick(_onCloseClicked);
		}
		public function on(type:String, listener:Function): ShareScreen { this.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): ShareScreen { this.removeEventListener(type, listener); return this; }
		
		public function open(pURL:String, pTfmOfficialDressingCode:String) : void {
			_tfmCopyField.text = pTfmOfficialDressingCode;
			_fewfCopyField.text = pURL;
		}
		
		private function _onCloseClicked(e:Event) : void {
			dispatchEvent(new Event(Event.CLOSE));
		}
	}
}
