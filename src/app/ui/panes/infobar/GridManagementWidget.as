package app.ui.panes.infobar
{
	import flash.display.Sprite;
	import app.ui.buttons.GameButton;
	import app.ui.buttons.PushButton;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import com.fewfre.events.FewfEvent;

	public class GridManagementWidget extends Sprite
	{
		// Constants
		public static const RANDOMIZE_CLICKED : String = "randomize_clicked";
		public static const RANDOMIZE_LOCK_CLICKED : String = "randomize_lock_clicked"; // FewfEvent<{ locked:bool }>
		public static const REVERSE_CLICKED : String = "reverse_clicked";
		public static const LEFT_ARROW_CLICKED : String = "left_arrow_clicked";
		public static const RIGHT_ARROW_CLICKED : String = "right_arrow_clicked";
		
		// Storage
		private var _randomizeButton     : GameButton;
		private var _randomizeLockButton : PushButton;
		private var _reverseButton       : GameButton;
		private var _leftItemButton      : GameButton;
		private var _rightItemButton     : GameButton;
		
		public function get isRefreshLocked() : Boolean { return !!_randomizeLockButton && _randomizeLockButton.pushed; }
		
		// Constructor
		// pData = { hideRandomize:bool=false, hideRandomizeLock:bool=false, hideReverse:bool=false, hideArrows:bool=false }
		public function GridManagementWidget(pData:Object) {
			super();
			var xx:Number = 0, yy:Number = 0, spacing:Number = 2, bsize:Number = 24;
			
			if(!pData.hideRandomize) {
				// Randomization buttons
				_randomizeButton = new GameButton(bsize).setImage(new $Dice(), 0.8).move(xx, yy).appendTo(this) as GameButton;
				_randomizeButton.onButtonClick(dispatchEventHandler(RANDOMIZE_CLICKED));
				xx += bsize + spacing;
				
				if(!pData.hideRandomizeLock) {
					_randomizeLockButton = new PushButton(bsize).setImage(new $Lock(), 0.8).move(xx, yy).appendTo(this) as PushButton;
					_randomizeLockButton.on(PushButton.TOGGLE, function():void{
						isRefreshLocked ? _randomizeButton.disable() : _randomizeButton.enable();
						dispatchEvent(new FewfEvent(RANDOMIZE_LOCK_CLICKED, { locked:isRefreshLocked }));
					});
					xx += bsize + spacing;
				}
			}
			
			if(!pData.hideReverse) {
				xx += 8; // Add larger gap
				
				// List reversal button
				_reverseButton = new GameButton(bsize).setImage(new $FlipIcon(), 0.7).move(xx, yy).appendTo(this) as GameButton;
				_reverseButton.onButtonClick(dispatchEventHandler(REVERSE_CLICKED));
				xx += bsize + spacing;
			}
			
			if(!pData.hideArrows) {
				xx += 8; // Add larger gap
				
				// Arrow buttons
				_leftItemButton = new GameButton(bsize).setImage(new $BackArrow(), 0.45).move(xx, yy).appendTo(this) as GameButton;
				_leftItemButton.onButtonClick(dispatchEventHandler(LEFT_ARROW_CLICKED));
				xx += bsize + spacing;
				_rightItemButton = new GameButton(bsize).setImage(new $BackArrow(), 0.45).move(xx, yy).appendTo(this) as GameButton;
				_rightItemButton.onButtonClick(dispatchEventHandler(RIGHT_ARROW_CLICKED));
				_rightItemButton.Image.rotation = 180;
				xx += bsize + spacing;
			}
		}
		public function move(pX:Number, pY:Number) : GridManagementWidget { x = pX; y = pY; return this; }
		public function appendTo(pParent:Sprite): GridManagementWidget { pParent.addChild(this); return this; }
		public function on(type:String, listener:Function): GridManagementWidget { this.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): GridManagementWidget { this.removeEventListener(type, listener); return this; }
		
		///////////////////////
		// Public
		///////////////////////
		public function unlockRandomizeButton() : void {
			if(_randomizeLockButton) _randomizeLockButton.toggleOff(true);
		}
		
		///////////////////////
		// Private
		///////////////////////
		private function dispatchEventHandler(pEventName:String) : Function {
			return function(e):void{ dispatchEvent(new Event(pEventName)); };
		}
	}
}