package app.ui.screens
{
	import com.fewfre.display.*;
	import app.ui.buttons.*;
	import app.ui.common.*;
	import flash.display.Sprite;
	import flash.events.*;
	
	public class TrashConfirmScreen extends Sprite
	{
		// Constants
		public static const CONFIRM : String= "confirm_tray_screen";
		
		// Storage
		private var _bg				: RoundedRectangle;
		
		// Constructor
		// pData = { x:Number, y:Number }
		public function TrashConfirmScreen(pData:Object) {
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
			var tWidth:Number = 66, tHeight:Number = 34;
			_bg = new RoundedRectangle(tWidth, tHeight, { origin:0.5 }).appendTo(this).drawAsTray();
			
			/****************************
			* Buttons
			*****************************/
			var btn, tButtonSize = 28, tButtonSpacing=tButtonSize*0.5+2;
			
			btn = this.addChild(new SpriteButton({ x:-tButtonSpacing, width:tButtonSize, height:tButtonSize, obj_scale:0.6, obj:new $Yes(), origin:0.5 }));
			btn.addEventListener(ButtonBase.CLICK, _onConfirmClicked);
			
			btn = this.addChild(new SpriteButton({ x:tButtonSpacing, width:tButtonSize, height:tButtonSize, obj_scale:0.6, obj:new $No(), origin:0.5 }));
			btn.addEventListener(ButtonBase.CLICK, _onCloseClicked);
		}
		
		private function _onConfirmClicked(pEvent:Event) : void {
			dispatchEvent(new Event(CONFIRM));
		}
		
		private function _onCloseClicked(pEvent:Event) : void {
			dispatchEvent(new Event(Event.CLOSE));
		}
	}
}
