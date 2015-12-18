package GUI 
{
	import flash.display.*;
	import flash.display.Shape;
	import flash.events.*;
	
	public class ShopTabContainer extends RoundedRectangle
	{
		// Storage
		public var DefaultX:Number;
		public var DefaultY:Number;

		var headTab		: GUI.PushButton;
		var hairTab		: GUI.PushButton;
		var earsTab		: GUI.PushButton;
		var eyesTab		: GUI.PushButton;
		var mouthTab	: GUI.PushButton;
		var neckTab		: GUI.PushButton;
		var tailTab		: GUI.PushButton;
		var furTab		: GUI.PushButton;
		var otherTab	: GUI.PushButton;
		
		// Constants
		public static const TAB_HEAD_CLICK:String="tab1_click";
		public static const TAB_EYES_CLICK:String="tab2_click";
		public static const TAB_EARS_CLICK:String="tab3_click";
		public static const TAB_MOUTH_CLICK:String="tab4_click";
		public static const TAB_NECK_CLICK:String="tab5_click";
		public static const TAB_FUR_CLICK:String="tab6_click";
		public static const TAB_OTHER_CLICK:String="tab7_click";
		public static const TAB_TAIL_CLICK:String="tab8_click";
		public static const TAB_HAIR_CLICK:String="tab9_click";
		
		// Constructor
		public function ShopTabContainer(pX:Number, pY:Number, pWidth:Number, pHeight:Number)
		{
			super(pX, pY, pWidth, pHeight);
			this.DefaultX = pX;
			this.DefaultY = pY;
			
			this.drawSimpleGradient([ 0x112528, 0x1E3D42 ], 15, 6983586, 1120028, 3294800);
			
			// _drawLine(5, 29, this.Width);
			
			var tXSpacing:Number = 0;//55;
			var tX:Number = 5-tXSpacing;
			var tYSpacing:Number = 43;//0;
			var tY:Number = 10-tYSpacing;
			var tWidth:Number = 50;
			var tHeight:Number = 38;
			
			this.headTab = _addTab("Head", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, this.tabHeadClicked);
			this.hairTab = _addTab("Hair", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, this.tabHairClicked);
			this.earsTab = _addTab("Ears", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, this.tabEarsClicked);
			this.eyesTab = _addTab("Eyes", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, this.tabEyesClicked);
			this.mouthTab = _addTab("Mouth", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, this.tabMouthClicked);
			this.neckTab = _addTab("Neck", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, this.tabNeckClicked);
			this.tailTab = _addTab("Tail", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, this.tabTailClicked);
			this.furTab = _addTab("Furs", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, this.tabFursClicked);
			this.otherTab = _addTab("Other", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, this.tabOtherClicked);
			
			this.headTab.ToggleOn();
		}
		
		private function _addTab(pText:String, pX:Number, pY:Number, pWidth:Number, pHeight:Number, pEvent:Function) : GUI.PushButton {
			var tBttn:GUI.PushButton = new GUI.PushButton(pX, pY, pWidth, pHeight, pText);
			addChild(tBttn);
			tBttn.addEventListener("state_changed_before", pEvent, false, 0, true);
			return tBttn;
		}
		
		private function _drawLine(pX:Number, pY:Number, pWidth:Number) : void {
			var tLine:Shape = new Shape();
			tLine.x = pX;
			tLine.y = pY;
			addChild(tLine);
			
			tLine.graphics.lineStyle(1, 1120284, 1, true);
			tLine.graphics.moveTo(0, 0);
			tLine.graphics.lineTo(pWidth - 10, 0);
			
			tLine.graphics.lineStyle(1, 6325657, 1, true);
			tLine.graphics.moveTo(0, 1);
			tLine.graphics.lineTo(pWidth - 10, 1);
		}

		function tabHeadClicked(arg1:*) : void	{ untoggle(this.headTab, TAB_HEAD_CLICK); }
		function tabHairClicked(arg1:*) : void	{ untoggle(this.hairTab, TAB_HAIR_CLICK); }
		function tabEarsClicked(arg1:*) : void	{ untoggle(this.earsTab, TAB_EARS_CLICK); }
		function tabEyesClicked(arg1:*) : void	{ untoggle(this.eyesTab, TAB_EYES_CLICK); }
		function tabMouthClicked(arg1:*) : void	{ untoggle(this.mouthTab, TAB_MOUTH_CLICK); }
		function tabNeckClicked(arg1:*) : void	{ untoggle(this.neckTab, TAB_NECK_CLICK); }
		function tabTailClicked(arg1:*) : void	{ untoggle(this.tailTab, TAB_TAIL_CLICK); }
		function tabFursClicked(arg1:*) : void	{ untoggle(this.furTab, TAB_FUR_CLICK); }
		function tabOtherClicked(arg1:*) : void	{ untoggle(this.otherTab, TAB_OTHER_CLICK); }

		public function UnpressAll() : void {
			untoggle();
		}
		
		private function untoggle(pTab:GUI.PushButton=null, pEvent:String=null) : void {
			if (pTab != null && pTab.Pushed) { return; }
			
			if (this.headTab.Pushed && this.headTab != pTab) {
				this.headTab.ToggleOff();
			}
			if (this.eyesTab.Pushed && this.eyesTab != pTab) {
				this.eyesTab.ToggleOff();
			}
			if (this.earsTab.Pushed && this.earsTab != pTab) {
				this.earsTab.ToggleOff();
			}
			if (this.mouthTab.Pushed && this.mouthTab != pTab) {
				this.mouthTab.ToggleOff();
			}
			if (this.neckTab.Pushed && this.neckTab != pTab) {
				this.neckTab.ToggleOff();
			}
			if (this.furTab.Pushed && this.furTab != pTab) {
				this.furTab.ToggleOff();
			}
			if (this.otherTab.Pushed && this.otherTab != pTab) {
				this.otherTab.ToggleOff();
			}
			if (this.tailTab.Pushed && this.tailTab != pTab) {
				this.tailTab.ToggleOff();
			}
			if (this.hairTab.Pushed && this.hairTab != pTab) {
				this.hairTab.ToggleOff();
			}
			if(pEvent!=null) { dispatchEvent(new flash.events.Event(pEvent)); }
		}
	}
}
