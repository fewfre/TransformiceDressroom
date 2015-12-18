package GUI 
{
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.text.*;
	
	public class PushButton extends RoundedRectangle
	{
		// Storage
		public var Pushed:Boolean;
		var Text:flash.text.TextField;
		
		// Constants
		public static const STATE_CHANGED_BEFORE:String="state_changed_before";
		public static const STATE_CHANGED_AFTER:String="state_changed_after";
		
		// Constructor
		public function PushButton(pX:Number, pY:Number, pWidth:Number, pHeight:Number, pText:String)
		{
			super(pX, pY, pWidth, pHeight);
			buttonMode = true;
			useHandCursor = true;
			mouseChildren = false;
			
			addEventListener(MouseEvent.CLICK, this.Mouse_Click);
			addEventListener(MouseEvent.ROLL_OVER, this.Mouse_Over);
			addEventListener(MouseEvent.ROLL_OUT, this.Mouse_Out);
			
			this.Text = new flash.text.TextField();
			this.Text.defaultTextFormat = new flash.text.TextFormat("Verdana", 11, 12763866);
			this.Text.autoSize = flash.text.TextFieldAutoSize.CENTER;
			this.Text.text = pText;
			addChild(this.Text);
			
			this.Pushed = false;
			this.Unpressed();
		}

		public function Unpressed():*
		{
			this.draw(3952740, 7, 6126992, 1120028, 3952740);
			
			this.Text.x = (this.Width - this.Text.textWidth) / 2 - 2;
			this.Text.y = (this.Height - this.Text.textHeight) / 2 - 2;
		}

		public function Pressed():*
		{
			this.draw(3952740, 7, 1120028, 6126992, 3952740);
			
			this.Text.x = (this.Width - this.Text.textWidth) / 2;
			this.Text.y = (this.Height - this.Text.textHeight) / 2;
		}

		public function Toggle():*
		{
			dispatchEvent( new flash.events.Event(STATE_CHANGED_BEFORE) );
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
			this.Text.textColor = 16766976;
		}

		public function ToggleOff():*
		{
			this.Pushed = false;
			this.Unpressed();
			this.Text.textColor = 12763866;
		}

		internal function Mouse_Click(pEvent:MouseEvent):*
		{
			dispatchEvent( new flash.events.Event(STATE_CHANGED_BEFORE) );
			if (this.Pushed == false) {
				this.ToggleOn();
			}
			dispatchEvent( new flash.events.Event(STATE_CHANGED_AFTER) );
		}

		internal function Mouse_Over(pEvent:MouseEvent):*
		{
			if (this.Pushed == false) {
				this.Text.textColor = 74565;
			}
		}

		internal function Mouse_Out(pEvent:MouseEvent):*
		{
			this.Text.textColor = this.Pushed ? 16766976 : 12763866;
		}
	}
}
