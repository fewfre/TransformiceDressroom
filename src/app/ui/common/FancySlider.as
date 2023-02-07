package app.ui.common
{
	import flash.display.*;
	import flash.events.*;
	import fl.events.SliderEvent;
	import fl.controls.Slider;
	
	public class FancySlider extends Slider
	{
		// Storage
		public static const CHANGE : String = "fancy_change";
		
		// Constructor
		// pData = { x:Number, y:Number, value:int, max:int, width:Number }
		public function FancySlider(pData:Object)
		{
			super();
			
			try {
				this["componentInspectorSetting"] = true;
			}
			catch (e:Error) { };
			
			this.direction = "horizontal";
			this.enabled = true;
			this.liveDragging = false;
			this.minimum = 10;
			this.maximum = pData.max;
			this.snapInterval = 0;
			this.tickInterval = 0;
			this.value = pData.value;
			this.visible = true;
			
			try {
				this["componentInspectorSetting"] = false;
			}
			catch (e:Error) { };
			
			this.x = pData.x;
			this.y = pData.y;
			this.width = pData.width;
			
			this.addEventListener(SliderEvent.CHANGE, _onChanged);
			this.addEventListener(SliderEvent.THUMB_DRAG, _onChanged);
		}
		
		private function _onChanged(pEvent:Event) : void {
			dispatchEvent(new Event(FancySlider.CHANGE));
		}
		
		public function updateViaMouseWheelDelta(pDelta) : void {
			this.value += pDelta * 0.2;
		}
		
		public function getValueAsScale() : Number {
			return this.value * 0.1;
		}
	}
}
