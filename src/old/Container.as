package GUI 
{
	import flash.display.*;
	import flash.events.*;
	
	public class Container extends RoundedRectangle
	{
		// Storage
		public var DefaultX:Number;
		public var DefaultY:Number;

		public var tab1Butt:GUI.SpriteButton;
		public var tab2Butt:GUI.SpriteButton;
		public var tab3Butt:GUI.SpriteButton;
		public var tab4Butt:GUI.SpriteButton;
		public var tab5Butt:GUI.SpriteButton;
		public var tab6Butt:GUI.SpriteButton;
		public var tab7Butt:GUI.SpriteButton;
		
		// Constants
		public static const TAB_HEAD_CLICK:String="tab1_click";
		public static const TAB2_CLICK:String="tab2_click";
		public static const TAB3_CLICK:String="tab3_click";
		public static const TAB4_CLICK:String="tab4_click";
		public static const TAB5_CLICK:String="tab5_click";
		public static const TAB6_CLICK:String="tab6_click";
		public static const TAB7_CLICK:String="tab7_click";
		
		// Constructor
		public function Container(pX:Number, pY:Number, pWidth:Number, pHeight:Number)
		{
			super(pX, pY, pWidth, pHeight);
			this.DefaultX = pX;
			this.DefaultY = pY;
			
			this.draw(3294800, 15, 6983586, 1120028, 3294800);
			
			var tYStart:Number = 10;
			var tYSpacing:Number = 55;
			var tY:Number = 0;
			
			this.tab1Butt = new GUI.SpriteButton(5, tYStart + tY, 50, 50, new $Cadeau(), 0);
			addChild(this.tab1Butt);
			this.tab1Butt.addEventListener(GUI.SpriteButton.MOUSE_UP, this.tabClickedBefore, false, 0, true);
			
			tY += tYSpacing;
			this.tab2Butt = new GUI.SpriteButton(5, tYStart + tY, 50, 50, new $Cadeau(), 1);
			addChild(this.tab2Butt);
			this.tab2Butt.addEventListener(GUI.SpriteButton.MOUSE_UP, this.tab2ClickedBefore, false, 0, true);
			
			tY += tYSpacing;
			this.tab3Butt = new GUI.SpriteButton(5, tYStart + tY, 50, 50, new $Cadeau(), 2);
			addChild(this.tab3Butt);
			this.tab3Butt.addEventListener(GUI.SpriteButton.MOUSE_UP, this.tab3ClickedBefore, false, 0, true);
			
			tY += tYSpacing;
			this.tab4Butt = new GUI.SpriteButton(5, tYStart + tY, 50, 50, new $Cadeau(), 3);
			addChild(this.tab4Butt);
			this.tab4Butt.addEventListener(GUI.SpriteButton.MOUSE_UP, this.tab4ClickedBefore, false, 0, true);
			
			tY += tYSpacing;
			this.tab5Butt = new GUI.SpriteButton(5, tYStart + tY, 50, 50, new $Cadeau(), 4);
			addChild(this.tab5Butt);
			this.tab5Butt.addEventListener(GUI.SpriteButton.MOUSE_UP, this.tab5Clicked, false, 0, true);
			
			tY += tYSpacing;
			this.tab6Butt = new GUI.SpriteButton(5, tYStart + tY, 50, 50, new $Cadeau(), 5);
			addChild(this.tab6Butt);
			this.tab6Butt.addEventListener(GUI.SpriteButton.MOUSE_UP, this.tab6Clicked, false, 0, true);
			
			tY += tYSpacing;
			this.tab7Butt = new GUI.SpriteButton(5, tYStart + tY, 50, 50, new $Cadeau(), 6);
			addChild(this.tab7Butt);
			this.tab7Butt.addEventListener(GUI.SpriteButton.MOUSE_UP, this.tab7Clicked, false, 0, true);
		}

		function tabClickedBefore(arg1:*) : void {
			dispatchEvent(new flash.events.Event(TAB_HEAD_CLICK));
		}

		function tab2ClickedBefore(arg1:*) : void {
			dispatchEvent(new flash.events.Event(TAB2_CLICK));
		}

		function tab3ClickedBefore(arg1:*) : void {
			dispatchEvent(new flash.events.Event(TAB3_CLICK));
		}

		function tab4ClickedBefore(arg1:*) : void {
			dispatchEvent(new flash.events.Event(TAB4_CLICK));
		}

		function tab5Clicked(arg1:*) : void {
			dispatchEvent(new flash.events.Event(TAB5_CLICK));
		}

		function tab6Clicked(arg1:*) : void {
			dispatchEvent(new flash.events.Event(TAB6_CLICK));
		}

		function tab7Clicked(arg1:*) : void {
			dispatchEvent(new flash.events.Event(TAB7_CLICK));
		}
	}
}
