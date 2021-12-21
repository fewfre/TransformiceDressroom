package app.ui.panes
{
	import com.piterwilson.utils.*;
	import com.fewfre.display.*;
	import com.fewfre.events.FewfEvent;
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
		
		public static var RECENTS					: Array = [];
		
		// Storage
		private var _colorSwatches		: Array;
		private var _selectedSwatch		: int=0;
		private var _psColorPick		: ColorPicker;
		private var _recentColorButtons	: Array;
		private var _lastColorChangeValue	: int;
		private var _dontTrackNextRecentChange	: Boolean;
		
		// Properties
		public function get selectedSwatch():int { return _selectedSwatch; }
		
		// Constructor
		public function ColorPickerTabPane(pData:Object)
		{
			super();
			_setupColorPickerPane(pData);
		}
		
		public override function open() : void {
			super.open();
			// Avoid colors being labeled as recent when just opened
			_lastColorChangeValue = -1;
			_dontTrackNextRecentChange = true;
		}
		
		public override function close() : void {
			super.close();
			_addRecentColor(); // Add here since we're exiting, and thus change is finalized
		}
		
		/****************************
		* Public
		*****************************/
		public function setupSwatches(pSwatches:Array) : void {
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
			
			_selectSwatch(0, false);
			setupRecents();
		}
		
		public function setupRecents() : void {
			for each(var btn:ColorButton in _recentColorButtons) {
				removeChild(btn);
			}
			_recentColorButtons = [];
			
			var len = Math.min(RECENTS.length, 9);
			for(var i:int = 0; i < len; i++) {
				var color:int = RECENTS[i];
				
				var btn = addChild( addChild( new ColorButton({ x:116 + (i*30.5), y:316+60, width:24, height:16, color:color }) ) ) as ColorButton;
				btn.addEventListener(ButtonBase.CLICK, _onRecentColorBtnClicked);
				_recentColorButtons.push(btn);
			}
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
			
			_recentColorButtons = new Array();
			
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
			// Add here since we just changed what swatch we're on and current one is thus "finalized"
			if(pSetCursor) { _addRecentColor(); }
			
			for(var i = 0; i < _colorSwatches.length; i++) {
				_colorSwatches[i].unselect();
			}
			_selectedSwatch = pNum;
			_dontTrackNextRecentChange = true;
			_colorSwatches[pNum].select();
			if(pSetCursor) { _psColorPick.setCursor(_colorSwatches[pNum].textValue); }
		}
		
		private function changeColor(color:String) {
			_colorSwatches[_selectedSwatch].value = uint(color);
			if(!_dontTrackNextRecentChange) {
				_lastColorChangeValue = uint(color);
			} else {
				_dontTrackNextRecentChange = false;
			}
			dispatchEvent(new DataEvent(EVENT_COLOR_PICKED, false, false, color));
		}
		
		private function _addRecentColor() {
			// Don't add to favorites unless we actually changed the color at some point
			if(_lastColorChangeValue == -1) { return; }
			// Remove old value if there is one, and move it to front of the list
			if(RECENTS.indexOf(_lastColorChangeValue) != -1) {
				RECENTS.splice(RECENTS.indexOf(_lastColorChangeValue), 1);
			}
			RECENTS.unshift(_lastColorChangeValue);
			_lastColorChangeValue = -1;
			setupRecents();
		}
		
		/****************************
		* Events
		*****************************/
		private function _onColorPickChanged(pEvent:DataEvent) : void {
			changeColor(pEvent.data);
		}
		
		private function _onRecentColorBtnClicked(pEvent:FewfEvent) : void {
			changeColor(pEvent.data);
			// We just want to move the color in recents list to front when clicked
			_lastColorChangeValue = uint(pEvent.data)
			_dontTrackNextRecentChange = false;
			_addRecentColor();
		}
		
		private function _onDefaultButtonClicked(pEvent:Event) : void {
			dispatchEvent(new Event(EVENT_DEFAULT_CLICKED));
		}
		
		private function _onColorPickerBackClicked(pEvent:Event) : void {
			dispatchEvent(new Event(EVENT_EXIT));
		}
	}
}
