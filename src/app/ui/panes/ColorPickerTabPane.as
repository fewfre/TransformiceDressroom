package app.ui.panes
{
	import com.piterwilson.utils.*;
	import com.fewfre.display.*;
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import fl.containers.*;
	import flash.display.*;
	import flash.events.*;
	
	public class ColorPickerTabPane extends TabPane
	{
		// Constants
		public static const EVENT_SWATCH_CHANGED	: String = "event_swatch_changed";
		public static const EVENT_DEFAULT_CLICKED	: String = "event_default_clicked";
		public static const EVENT_COLOR_PICKED		: String = "event_color_picked";
		public static const EVENT_EXIT				: String = "event_exit";
		
		public static const _MAX_SWATCHES			: int = 10;
		
		// Storage
		private var _colorSwatches	: Array;
		private var _selectedSwatch	: int=0;
		private var _psColorPick	: ColorPicker;
		
		// Properties
		public function get selectedSwatch():int { return _selectedSwatch; }
		
		// Constructor
		public function ColorPickerTabPane(pData:Object)
		{
			super();
			_setupColorPickerPane(pData);
		}
		
		/****************************
		* Public
		*****************************/
		public function setupSwatches(pSwatches:Array):*
		{
			var tLength:int = pSwatches.length;
			
			for(var i = 0; i < _colorSwatches.length; i++) {
				_colorSwatches[i].alpha = 0;
				
				if (tLength > i) {
					_colorSwatches[i].alpha = 1;
					_colorSwatches[i].value = pSwatches[i];
					if (_selectedSwatch == i) {
						_psColorPick.setCursor(_colorSwatches[i].textValue);
					}
				}
			}
			if (tLength > _MAX_SWATCHES) {
				trace("!!! more than "+_MAX_SWATCHES+" colors !!!");
			}
			
			_selectSwatch(0, false)
		}
		
		/****************************
		* Private
		*****************************/
		private function _setupColorPickerPane(pData:Object) : void {
			this.addInfoBar( new ShopInfoBar({ showBackButton:true, showRefreshButton:false }) );
			this.infoBar.colorWheel.addEventListener(MouseEvent.MOUSE_UP, _onColorPickerBackClicked);
			
			_psColorPick = new ColorPicker();
			_psColorPick.x = 105;
			_psColorPick.y = 5;
			_psColorPick.addEventListener(ColorPicker.COLOR_PICKED, _onColorPickChanged);
			this.addItem(_psColorPick);
			
			_colorSwatches = new Array();
			var swatch:ColorSwatch;
			for(var i:int = 0; i < _MAX_SWATCHES; i++) {
				swatch = _createColorSwatch(i, 5, 45 + (i * 27));
				_colorSwatches.push(swatch);
				this.addItem(_colorSwatches[i]);
			}
			
			if(!pData.hide_default) {
				var defaults_btn:SpriteButton;
				defaults_btn = this.addItem( new SpriteButton({ text:"btn_color_defaults", x:6, y:10, width:100, height:22, obj:new MovieClip() }) ) as SpriteButton;
				defaults_btn.addEventListener(ButtonBase.CLICK, _onDefaultButtonClicked);
			}
			
			this.UpdatePane(false);
		}
		
		private function _createColorSwatch(pNum:int, pX:int, pY:int) : ColorSwatch {
			var swatch:ColorSwatch = new ColorSwatch();
			swatch.addEventListener(ColorSwatch.ENTER_PRESSED, function(){ _selectSwatch(pNum); });
			swatch.addEventListener(ColorSwatch.BUTTON_CLICK, function(){ _selectSwatch(pNum); });
			swatch.x = pX;
			swatch.y = pY;
			return swatch;
		}
		
		private function _selectSwatch(pNum:int, pSetCursor:Boolean=true) : void {
			for(var i = 0; i < _colorSwatches.length; i++) {
				_colorSwatches[i].unselect();
			}
			_selectedSwatch = pNum;
			_colorSwatches[pNum].select();
			if(pSetCursor) { _psColorPick.setCursor(_colorSwatches[pNum].textValue); }
		}
		
		/****************************
		* Events
		*****************************/
		private function _onColorPickChanged(pEvent:DataEvent) : void {
			_colorSwatches[_selectedSwatch].value = uint(pEvent.data);
			dispatchEvent(new DataEvent(EVENT_COLOR_PICKED, false, false, pEvent.data));
		}
		
		private function _onDefaultButtonClicked(pEvent:Event) : void {
			dispatchEvent(new Event(EVENT_DEFAULT_CLICKED));
		}
		
		private function _onColorPickerBackClicked(pEvent:Event) : void {
			dispatchEvent(new Event(EVENT_EXIT));
		}
	}
}
