package GUI 
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class ScaleButton extends MovieClip
	{
		// Storage
		public var id:int;
		public var Image:flash.display.MovieClip;
		public var doMouseover:Boolean=false;
		
		// Constants
		public static const MOUSE_DOWN:String="sb_mouse_down";
		public static const MOUSE_UP:String="sb_mouse_up";
		
		// Constructor
		public function ScaleButton(pX:Number, pY:Number, pMC:MovieClip)
		{
			super();
			buttonMode = true;
			useHandCursor = true;
			mouseChildren = false;
			
			this.x = pX;
			this.y = pY;
			
			addEventListener(MouseEvent.MOUSE_DOWN, this.Mouse_Down);
			addEventListener(MouseEvent.MOUSE_UP, this.Mouse_Up);
			addEventListener(MouseEvent.ROLL_OVER, this.Mouse_Over);
			addEventListener(MouseEvent.ROLL_OUT, this.Mouse_Out);
			
			ChangeImage(pMC);
		}

		public function ChangeImage(pMC:MovieClip) : void
		{
			if(this.Image != null) { removeChild(this.Image); }
			this.Image = pMC;
			addChild(this.Image);
		}

		internal function Mouse_Down(pEvent:MouseEvent) : void
		{
			this.scaleX = this.scaleY = 0.9;
		}

		internal function Mouse_Up(pEvent:MouseEvent) : void
		{
			this.scaleX = this.scaleY = 1;
		}

		internal function Mouse_Over(pEvent:MouseEvent) : void
		{
			this.scaleX = this.scaleY = 1.1;
		}

		internal function Mouse_Out(pEvent:MouseEvent) : void
		{
			this.scaleX = this.scaleY = 1;
		}
	}
}
