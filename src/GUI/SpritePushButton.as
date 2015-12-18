package GUI 
{
	import flash.display.*;
	import flash.events.MouseEvent;
	
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
			
			this.Image = pMC;
			this.Image.x = pWidth / 2;
			this.Image.y = pHeight / 2;
			this.Image.scaleX = 0.75;
			this.Image.scaleY = 0.75;
			addChild(this.Image);
			
			this.Unpressed();
			return;
		}

		public function Unpressed():*
		{
			this.draw(3952740, 7, 6126992, 1120028, 3952740);
		}

		public function Pressed():*
		{
			this.draw(3952740, 7, 1120028, 6126992, 3952740);
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
