package app.ui.screens
{
	import flash.display.Sprite;
	import flash.display.Graphics;
	import app.data.GameAssets;
	import com.fewfre.display.RoundRectangle;
	import flash.events.MouseEvent;
	import app.ui.buttons.SpriteButton;
	import flash.events.Event;
	
	public class TrashConfirmScreen extends Sprite
	{
		// Constants
		public static const CONFIRM : String= "confirm_tray_screen";
		
		// Constructor
		public function TrashConfirmScreen() {
			GameAssets.createScreenBackdrop().appendTo(this).on(MouseEvent.CLICK, _onCloseClicked);
			
			var tWidth:Number = 66, tHeight:Number = 34;
			// Background
			new RoundRectangle(tWidth, tHeight).toOrigin(0.5).appendTo(this).drawAsTray();
			
			/****************************
			* Buttons
			*****************************/
			var bsize:Number = 28, tButtonSpacing:Number=bsize*0.5+2;
			
			SpriteButton.withObject(new $Yes(), 0.6, { x:-tButtonSpacing, size:bsize, origin:0.5 }).appendTo(this)
				.onButtonClick(_onConfirmClicked);
			
			SpriteButton.withObject(new $No(), 0.6, { x:tButtonSpacing, size:bsize, origin:0.5 }).appendTo(this)
				.onButtonClick(_onCloseClicked);
		}
		public function move(pX:Number, pY:Number) : TrashConfirmScreen { x = pX; y = pY; return this; }
		public function on(type:String, listener:Function): TrashConfirmScreen { this.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): TrashConfirmScreen { this.removeEventListener(type, listener); return this; }
		
		private function _onConfirmClicked(pEvent:Event) : void {
			dispatchEvent(new Event(CONFIRM));
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		private function _onCloseClicked(pEvent:Event) : void {
			dispatchEvent(new Event(Event.CLOSE));
		}
	}
}
