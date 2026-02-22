package app.ui.screens
{
	import flash.display.Sprite;
	import flash.display.Graphics;
	import app.data.GameAssets;
	import com.fewfre.display.RoundRectangle;
	import flash.events.MouseEvent;
	import app.ui.buttons.GameButton;
	import flash.events.Event;
	
	public class TrashConfirmScreen
	{
		// Constants
		public static const CONFIRM : String= "confirm_tray_screen";
		
		// Storage
		private var _root : Sprite;
		
		// Properties
		public function get root() : Sprite { return _root; }
		
		// Constructor
		public function TrashConfirmScreen() {
			_root = new Sprite();
			GameAssets.createScreenBackdrop().appendTo(_root).on(MouseEvent.CLICK, _onCloseClicked);
			
			var tWidth:Number = 66, tHeight:Number = 34;
			// Background
			new RoundRectangle(tWidth, tHeight).toOrigin(0.5).appendTo(_root).drawAsTray();
			
			/****************************
			* Buttons
			*****************************/
			var bsize:Number = 28, tButtonSpacing:Number=bsize*0.5+2;
			
			new GameButton(bsize).setImage(new $Yes(), 0.6).setOrigin(0.5).move(-tButtonSpacing, 0).appendTo(_root)
				.onButtonClick(_onConfirmClicked);
			
			new GameButton(bsize).setImage(new $No(), 0.6).setOrigin(0.5).move(tButtonSpacing, 0).appendTo(_root)
				.onButtonClick(_onCloseClicked);
		}
		public function move(pX:Number, pY:Number) : TrashConfirmScreen { _root.x = pX; _root.y = pY; return this; }
		public function appendTo(pParent:Sprite): TrashConfirmScreen { pParent.addChild(_root); return this; }
		public function removeSelf(): TrashConfirmScreen { if(_root.parent) { _root.parent.removeChild(_root); } return this; }
		public function on(type:String, listener:Function): TrashConfirmScreen { _root.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): TrashConfirmScreen { _root.removeEventListener(type, listener); return this; }
		public function onCloseRemoveSelf(): TrashConfirmScreen { this.on(Event.CLOSE, function(e:Event):void { removeSelf(); }); return this; }
		
		private function _onConfirmClicked(pEvent:Event) : void {
			_root.dispatchEvent(new Event(CONFIRM));
			_root.dispatchEvent(new Event(Event.CLOSE));
		}
		
		private function _onCloseClicked(pEvent:Event) : void {
			_root.dispatchEvent(new Event(Event.CLOSE));
		}
	}
}
