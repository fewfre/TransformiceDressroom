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
		private var _hoverBtnRemoveRecent	: ScaleButton;
		
		// Properties
		public function get selectedSwatch():int { return _selectedSwatch; }
		
		// Constructor
		public function ColorPickerTabPane(pData:Object)
		{
			super();
			
			this.addInfoBar( new ShopInfoBar({ showBackButton:true, showRefreshButton:false }) );
			this.infoBar.colorWheel.addEventListener(MouseEvent.MOUSE_UP, _onColorPickerBackClicked);
			
			var tClickOffDetector = addChild(new Sprite()) as Sprite;
			tClickOffDetector.graphics.beginFill( 0xFFFFFF );
			tClickOffDetector.graphics.drawRect( 0, 0, 115, 325 );
			tClickOffDetector.alpha = 0;
			tClickOffDetector.x = 0;
			tClickOffDetector.y = 60;
			tClickOffDetector.addEventListener(MouseEvent.CLICK, function(e:Event){
				_addRecentColor();
			});
			
			_psColorPick = new ColorPicker();
			_psColorPick.x = 105;
			_psColorPick.y = 5;
			_psColorPick.addEventListener(ColorPicker.COLOR_PICKED, _onColorPickChanged);
			this.addItem(_psColorPick);
			
			_colorSwatches = new Array();
			_recentColorButtons = new Array();
			
			if(!pData.hide_default) {
				var defaults_btn:SpriteButton;
				defaults_btn = this.addItem( new SpriteButton({ text:"btn_color_defaults", x:6, y:10, width:100, height:22, obj:new MovieClip() }) ) as SpriteButton;
				defaults_btn.addEventListener(ButtonBase.CLICK, _onDefaultButtonClicked);
			}
			
			_hoverBtnRemoveRecent = new ScaleButton({ obj:new $Trash(), obj_scale:0.36, data:{ color:0 } });
			_hoverBtnRemoveRecent.addEventListener(ButtonBase.CLICK, function(e:Event){
				_deleteRecentColor(_hoverBtnRemoveRecent.data.color);
			});
			_hoverBtnRemoveRecent.addEventListener(ButtonBase.OVER, function(){
				addChild(_hoverBtnRemoveRecent);
			});
			_hoverBtnRemoveRecent.addEventListener(ButtonBase.OUT, function(){
				remove_hoverBtnRemoveRecent();
			});
			
			this.UpdatePane(false);
		}
		
		public override function open() : void {
			super.open();
			// Avoid colors being labeled as recent when just opened
			_untrackRecentColor();
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
			for each(var btn:ColorSwatch in _colorSwatches) {
				this.removeItem(btn);
			}
			_colorSwatches = [];
			
			var swatch:ColorSwatch;
			for(var i:int = 0; i < pSwatches.length; i++) {
				swatch = _createColorSwatch(i, 5, 45 + (i * 27));
				swatch.value = pSwatches[i];
				_colorSwatches.push(swatch);
				this.addItem(swatch);
				
				if (_selectedSwatch == i) {
					_psColorPick.setCursor(swatch.textValue);
				}
			}
			
			_selectSwatch(0, false);
			renderRecents();
		}
		
		public function renderRecents() : void {
			for each(var btn:ColorButton in _recentColorButtons) {
				removeChild(btn);
			}
			_recentColorButtons = [];
			
			var len = Math.min(RECENTS.length, 9);
			for(var i:int = 0; i < len; i++) {
				var color:int = RECENTS[i];
				
				var btn = addChild( addChild( new ColorButton({ x:116+15 + (i*30.5), y:316+60+8, width:24, height:16, origin:0.5, color:color }) ) ) as ColorButton;
				btn.addEventListener(ButtonBase.CLICK, _onRecentColorBtnClicked);
				_recentColorButtons.push(btn);
				
				(function(xx, yy, color){
					btn.addEventListener(ButtonBase.OVER, function(){
						_hoverBtnRemoveRecent.x = xx;
						_hoverBtnRemoveRecent.y = yy;
						_hoverBtnRemoveRecent.data.color = color;
						addChild(_hoverBtnRemoveRecent);
					});
					btn.addEventListener(ButtonBase.OUT, function(){
						remove_hoverBtnRemoveRecent();
					});
				})(btn.x, btn.y - 18, color);
			}
		}
		
		/****************************
		* Private
		*****************************/
		private function _createColorSwatch(pNum:int, pX:int, pY:int) : ColorSwatch {
			var swatch:ColorSwatch = new ColorSwatch();
			swatch.addEventListener(ColorSwatch.USER_MODIFIED_TEXT, function(){ _selectSwatch(pNum); });
			swatch.addEventListener(ColorSwatch.ENTER_PRESSED, function(){ _selectSwatch(pNum); _addRecentColor(); });
			swatch.addEventListener(ColorSwatch.BUTTON_CLICK, function(){
				// Add here since we just changed what swatch we're on and current one is thus "finalized"
				_addRecentColor();
				// don't track a change just from clicking a swatch, but do still set cursor/add a recent if needed
				_selectSwatch(pNum, true, false);
			});
			swatch.x = pX;
			swatch.y = pY;
			return swatch;
		}
		
		private function _selectSwatch(pNum:int, pSetCursor:Boolean=true, pAllowTrackRecentChange:Boolean=true) : void {
			for(var i = 0; i < _colorSwatches.length; i++) {
				_colorSwatches[i].unselect();
			}
			_selectedSwatch = pNum;
			_colorSwatches[pNum].select();
			if(pSetCursor) {
				_dontTrackNextRecentChange = !pAllowTrackRecentChange;
				_psColorPick.setCursor(_colorSwatches[pNum].textValue);
			}
		}
		
		private function changeColor(color:uint) {
			trace("changeColor()");
			_colorSwatches[_selectedSwatch].value = uint(color);
			_trackRecentColor(color);
			dispatchEvent(new DataEvent(EVENT_COLOR_PICKED, false, false, color));
		}
		
		private function _trackRecentColor(color:uint) {
			trace("_trackRecentColor "+color+" -- track: "+(_dontTrackNextRecentChange ? "no" : "yes"));
			if(!_dontTrackNextRecentChange) {
				_lastColorChangeValue = color;
			} else {
				_dontTrackNextRecentChange = false;
			}
		}
		
		private function _untrackRecentColor() {
			trace("_untrackRecentColor");
			_lastColorChangeValue = -1;
		}
		
		private function _addRecentColor() {
			trace("_addRecentColor -- "+(_lastColorChangeValue == -1 ? "false" : ("true - "+_lastColorChangeValue)));
			// Don't add to favorites unless we actually changed the color at some point
			if(_lastColorChangeValue == -1) { return; }
			// Remove old value if there is one, and move it to front of the list
			if(RECENTS.indexOf(_lastColorChangeValue) != -1) {
				RECENTS.splice(RECENTS.indexOf(_lastColorChangeValue), 1);
			}
			RECENTS.unshift(_lastColorChangeValue);
			_untrackRecentColor();
			renderRecents();
		}
		
		private function _deleteRecentColor(color:int) {
			if(RECENTS.indexOf(color) != -1) {
				RECENTS.splice(RECENTS.indexOf(color), 1);
			}
			renderRecents();
			remove_hoverBtnRemoveRecent();
		}
		
		private function remove_hoverBtnRemoveRecent() {
			if(_hoverBtnRemoveRecent.parent) removeChild(_hoverBtnRemoveRecent);
		}
		
		/****************************
		* Events
		*****************************/
		private function _onColorPickChanged(pEvent:DataEvent) : void {
			changeColor(uint(pEvent.data));
		}
		
		private function _onRecentColorBtnClicked(pEvent:FewfEvent) : void {
			changeColor(uint(pEvent.data));
			// We just want to move the color in recents list to front when clicked
			_lastColorChangeValue = uint(pEvent.data)
			_dontTrackNextRecentChange = false;
			_addRecentColor();
		}
		
		private function _onDefaultButtonClicked(pEvent:Event) : void {
			_untrackRecentColor();
			_dontTrackNextRecentChange = true;
			dispatchEvent(new Event(EVENT_DEFAULT_CLICKED));
		}
		
		private function _onColorPickerBackClicked(pEvent:Event) : void {
			dispatchEvent(new Event(EVENT_EXIT));
		}
	}
}
