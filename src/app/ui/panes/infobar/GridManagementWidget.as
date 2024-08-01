package app.ui.panes.infobar
{
	import flash.display.Sprite;
	import app.ui.buttons.SpriteButton;
	import app.ui.buttons.PushButton;
	import com.fewfre.display.ButtonBase;
	import flash.events.Event;
	import flash.geom.Rectangle;

	public class GridManagementWidget extends Sprite
	{
		// Constants
		public static const RANDOMIZE_CLICKED : String = "randomize_clicked";
		public static const REVERSE_CLICKED : String = "reverse_clicked";
		public static const LEFT_ARROW_CLICKED : String = "left_arrow_clicked";
		public static const RIGHT_ARROW_CLICKED : String = "right_arrow_clicked";
		
		// Storage
		private var _randomizeButton     : SpriteButton;
		private var _randomizeLockButton : PushButton;
		private var _reverseButton       : SpriteButton;
		private var _leftItemButton      : SpriteButton;
		private var _rightItemButton     : SpriteButton;
		
		public function get isRefreshLocked() : Boolean { return !!_randomizeLockButton && _randomizeLockButton.pushed; }
		
		// Constructor
		// pData = { hideRandomize:bool=false, hideRandomizeLock:bool=false, hideReverse:bool=false, hideArrows:bool=false }
		public function GridManagementWidget(pData:Object) {
			super();
			var xx:Number = 0, yy:Number = 0, spacing:Number = 2, bsize:Number = 24;
			
			if(!pData.hideRandomize) {
				// Randomization buttons
				_randomizeButton = new SpriteButton({ x:xx, y:yy, size:bsize, obj_scale:0.8, obj:new $Dice() }).appendTo(this) as SpriteButton;
				_randomizeButton.on(ButtonBase.CLICK, dispatchEventHandler(RANDOMIZE_CLICKED));
				xx += bsize + spacing;
				
				if(!pData.hideRandomizeLock) {
					_randomizeLockButton = new PushButton({ x:xx, y:yy, size:bsize, obj_scale:0.8, obj:new $Lock() }).appendTo(this) as PushButton;
					_randomizeLockButton.addEventListener(PushButton.TOGGLE, function():void{ isRefreshLocked ? _randomizeButton.disable() : _randomizeButton.enable(); });
					xx += bsize + spacing;
				}
			}
			
			if(!pData.hideReverse) {
				xx += 8; // Add larger gap
				
				// List reversal button
				_reverseButton = new SpriteButton({ x:xx, y:yy, size:bsize, obj_scale:0.7, obj:new $FlipIcon() }).appendTo(this) as SpriteButton;
				_reverseButton.on(ButtonBase.CLICK, dispatchEventHandler(REVERSE_CLICKED));
				xx += bsize + spacing;
			}
			
			if(!pData.hideArrows) {
				xx += 8; // Add larger gap
				
				// Arrow buttons
				_leftItemButton = new SpriteButton({ x:xx, y:yy, size:bsize, obj_scale:0.45, obj:new $BackArrow() }).appendTo(this) as SpriteButton;
				_leftItemButton.on(ButtonBase.CLICK, dispatchEventHandler(LEFT_ARROW_CLICKED));
				xx += bsize + spacing;
				_rightItemButton = new SpriteButton({ x:xx, y:yy, size:bsize, obj_scale:0.45, obj:new $BackArrow() }).appendTo(this) as SpriteButton;
				_rightItemButton.on(ButtonBase.CLICK, dispatchEventHandler(RIGHT_ARROW_CLICKED));
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