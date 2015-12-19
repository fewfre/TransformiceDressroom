package GUI 
{
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	public class SpritePushButton extends RoundedRectangle
	{
		// Storage
		public var id:int;
		public var Pushed:Boolean;
		public var Image:flash.display.MovieClip;
		
		// Constants
		public static const STATE_CHANGED_BEFORE:String="state_changed_before";
		public static const STATE_CHANGED_AFTER:String="state_changed_after";
		
		// Constructor
		public function SpritePushButton(pX:Number, pY:Number, pWidth:Number, pHeight:Number, pMC:flash.display.MovieClip, pID:int)
		{
			super(pX, pY, pWidth, pHeight);
			buttonMode = true;
			useHandCursor = true;
			mouseChildren = false;
			
			this.Pushed = false;
			this.id = pID;
			addEventListener(MouseEvent.CLICK, this.Mouse_Click);
			addEventListener(MouseEvent.ROLL_OVER, this.Mouse_Over);
			addEventListener(MouseEvent.ROLL_OUT, this.Mouse_Out);
			
			var tBounds:Rectangle = pMC.getBounds(pMC);
			var tOffset:Point = tBounds.topLeft;
			
			this.Image = pMC;
			this.Image.x = pWidth / 2 - (tBounds.width / 2 + tOffset.x);
			this.Image.y = pHeight / 2 - (tBounds.height / 2 + tOffset.y);
			this.Image.scaleX = 1;
			this.Image.scaleY = 1;
			addChild(this.Image);
			
			this.Unpressed();
			return;
		}

		public function Unpressed():*
		{
			this.draw(ConstantsApp.COLOR_BUTTON_BLUE, 7, ConstantsApp.COLOR_BUTTON_OUTSET_TOP, ConstantsApp.COLOR_BUTTON_OUTSET_BOTTOM, ConstantsApp.COLOR_BUTTON_BLUE);
		}

		public function Pressed():*
		{
			this.draw(ConstantsApp.COLOR_BUTTON_DOWN, 7, ConstantsApp.COLOR_BUTTON_OUTSET_BOTTOM, ConstantsApp.COLOR_BUTTON_BLUE, ConstantsApp.COLOR_BUTTON_DOWN);
		}

		public function Toggle():*
		{
			this.Pushed = !this.Pushed;
			if (this.Pushed) {
				this.Pressed();
			} else {
				this.Unpressed();
			}
			dispatchEvent( new flash.events.Event(STATE_CHANGED_AFTER) );
		}

		public function ToggleOn():*
		{
			this.Pushed = true;
			this.Pressed();
		}

		public function ToggleOff():*
		{
			this.Pushed = false;
			this.Unpressed();
		}

		internal function Mouse_Click(pEvent:MouseEvent):*
		{
			dispatchEvent(new flash.events.Event(STATE_CHANGED_BEFORE));
			Toggle();
		}

		internal function Mouse_Over(pEvent:MouseEvent):*
		{
			return;
		}

		internal function Mouse_Out(pEvent:MouseEvent):*
		{
			return;
		}
	}
}
