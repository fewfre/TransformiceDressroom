package app.ui.common
{
	import com.fewfre.utils.Fewf;
	import fl.controls.Slider;
	import fl.events.SliderEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class FancySlider
	{
		// Constants
		public static const CHANGE : String = "fancy_change";
		
		// Storage
		private var _slider : CustomSlider;
		public function get rootSlider() : Slider { return _slider; };
		
		public function get value() : Number { return _slider.value; };
		public function set value(pVal:Number) : void { _slider.value = pVal; };
		
		// Constructor
		public function FancySlider(pWidth:Number) {
			_slider = new CustomSlider(pWidth);
			
			_slider.direction = "horizontal";
			_slider.focusEnabled = false; // disables arrow keys moving slider (it eats inputs for grid traversal)
			
			_slider.addEventListener(SliderEvent.CHANGE, _onChanged);
			_slider.addEventListener(SliderEvent.THUMB_DRAG, _onChanged);
		}
		public function move(pX:Number, pY:Number) : FancySlider { _slider.x = pX; _slider.y = pY; return this; }
		public function appendTo(pParent:Sprite): FancySlider { pParent.addChild(_slider); return this; }
		public function on(type:String, listener:Function): FancySlider { _slider.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): FancySlider { _slider.removeEventListener(type, listener); return this; }
		
		public function updateViaMouseWheelDelta(pDelta) : void {
			_slider.value += pDelta * 0.02;
		}
		
		/**
		 * Convenience method to set the three main parameters in one shot.
		 * @param min The minimum value of the slider.
		 * @param max The maximum value of the slider.
		 * @param value The value of the slider.
		 * @param interval The snap interval of the slider.
		 */
		public function setSliderParams(min:Number, max:Number, value:Number, interval:Number=0.1) : FancySlider {
			_slider.minimum = min;
			_slider.maximum = max;
			_slider.snapInterval = interval;
			_slider.value = value; // Needs to be set last to avoid value being effected by previous settings
			return this;
		}
		
		/****************************************
		* Events
		*****************************************/
		private function _onChanged(pEvent:Event) : void {
			_slider.dispatchEvent(new Event(FancySlider.CHANGE));
		}
	}
}

import fl.controls.Slider;
import flash.events.MouseEvent;
class CustomSlider extends Slider {
	function CustomSlider(pWidth:Number) {
		super();
		this.width = pWidth;
		
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
	}
		
		// Force track click to behave lick a thumb click
		private function _onTrackMouseDown(e:MouseEvent) : void {
			this.thumb.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, e.localX, e.localY));
			this.doDrag(e);
		}
}