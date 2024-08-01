package app.ui.common
{
	import com.fewfre.utils.Fewf;
	import fl.controls.Slider;
	import fl.events.SliderEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class FancySlider extends Slider
	{
		// Storage
		public static const CHANGE : String = "fancy_change";
		
		// Constructor
		public function FancySlider(pWidth:Number)
		{
			super();
			
			this.width = pWidth;
			
			this.direction = "horizontal";
			this.focusEnabled = false; // disables arrow keys moving slider (it eats inputs for grid traversal)
			
			// Manually set the classes so they display properly when this swf is loaded in AIR app
			this.setStyle('thumbUpSkin', SliderThumb_upSkin);
			this.setStyle('thumbOverSkin', SliderThumb_overSkin);
            this.setStyle('thumbDownSkin', SliderThumb_downSkin);
            this.setStyle('thumbDisabledSkin', SliderThumb_disabledSkin);
            this.setStyle('sliderTrackSkin', SliderTrack_skin);
            this.setStyle('sliderTrackDisabledSkin', SliderTrack_disabledSkin);
            this.setStyle('tickSkin', SliderTick_skin);
			
			// Increase hit area
			this.track.graphics.beginFill(0, 0);
			this.track.graphics.drawRect(0, -22/2, this.width, 22);
			this.track.graphics.endFill();
			this.track.addEventListener(MouseEvent.MOUSE_DOWN, _onTrackMouseDown);
			
			this.addEventListener(SliderEvent.CHANGE, _onChanged);
			this.addEventListener(SliderEvent.THUMB_DRAG, _onChanged);
		}
		public function moveSelf(pX:Number, pY:Number) : FancySlider { x = pX; y = pY; return this; }
		public function appendTo(pParent:Sprite): FancySlider { pParent.addChild(this); return this; }
		
		public function updateViaMouseWheelDelta(pDelta) : void {
			this.value += pDelta * 0.02;
		}
		
		/**
		 * Convenience method to set the three main parameters in one shot.
		 * @param min The minimum value of the slider.
		 * @param max The maximum value of the slider.
		 * @param value The value of the slider.
		 * @param interval The snap interval of the slider.
		 */
		public function setSliderParams(min:Number, max:Number, value:Number, interval:Number=0.1) : FancySlider {
			this.minimum = min;
			this.maximum = max;
			this.value = value;
			this.snapInterval = interval;
			return this;
		}
		
		/****************************************
		* Events
		*****************************************/
		private function _onChanged(pEvent:Event) : void {
			dispatchEvent(new Event(FancySlider.CHANGE));
		}
		
		// Force track click to behave lick a thumb click
		private function _onTrackMouseDown(e:MouseEvent) : void {
			thumb.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, e.localX, e.localY));
			doDrag(e);
		}
	}
}
