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
	import flash.utils.Dictionary;
	import ext.ParentApp;
	
	public class ColorPickerTabPane extends TabPane
	{
		// Constants
		public static const EVENT_SWATCH_CHANGED	: String = "event_swatch_changed";
		public static const EVENT_DEFAULT_CLICKED	: String = "event_default_clicked";
		public static const EVENT_COLOR_PICKED		: String = "event_color_picked";
		public static const EVENT_EXIT				: String = "event_exit";
		
		private static var HISTORY					: Dictionary = new Dictionary();
		
		// Storage
		private var _colorSwatches         : Array;
		private var _selectedSwatch        : int=0;
		private var _psColorPick           : ColorPicker;
		
		private var _lastColorChangeValue  : int;
		private var _dontTrackNextRecentChange	: Boolean;
		
		private var _recentColorsDisplay   : RecentColorsListDisplay;
		private var _refreshButton         : SpriteButton;
		
		private var _historyTray          : Sprite;
		
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
			
			if(!pData.hide_default) {
				var defaults_btn:SpriteButton;
				defaults_btn = this.addItem( new SpriteButton({ text:"btn_color_defaults", x:6, y:15, width:100, height:22, obj:new MovieClip() }) ) as SpriteButton;
				defaults_btn.addEventListener(ButtonBase.CLICK, _onDefaultButtonClicked);
			}
			
			_refreshButton = this.addItem(new SpriteButton({ x:ConstantsApp.PANE_WIDTH - 24 - 11, y:14, width:24, height:24, obj_scale:0.8, obj:new $Dice() })) as SpriteButton;
			_refreshButton.addEventListener(ButtonBase.CLICK, function(){ _randomizeAllColors(); });
			
			_recentColorsDisplay = new RecentColorsListDisplay({ x:ConstantsApp.PANE_WIDTH/2, y:316+60+17 });
			_recentColorsDisplay.addEventListener(RecentColorsListDisplay.EVENT_COLOR_PICKED, _onRecentColorBtnClicked);
			addChild(_recentColorsDisplay);
			
			var historySize = 270;
			_historyTray = new Sprite();
			_historyTray.x = _psColorPick.x + 10 + historySize*0.5;
			_historyTray.y = _psColorPick.y + 40 + historySize*0.5;
			
			_historyTray.graphics.beginFill( 0x000000, 0.5 );
			_historyTray.graphics.drawRect( -historySize*0.5, -historySize*0.5, historySize, historySize );
			
			this.UpdatePane(false);
		}
		
		public override function open() : void {
			super.open();
			// Avoid colors being labeled as recent when just opened
			_untrackRecentColor();
			_dontTrackNextRecentChange = false;
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
				if(_getHistoryColors(i).length == 0) {
					_addHistory(pSwatches[i], i);
				}
				_showHistoryButtonIfValid(i);
				this.addItem(swatch);
				
				if (_selectedSwatch == i) {
					_psColorPick.setCursor(swatch.textValue);
				}
			}
			
			_selectSwatch(0, false);
			renderRecents();
		}
		
		public function renderRecents() : void {
			_recentColorsDisplay.render();
		}
		
		public function getAllColors() : Array {
			return _colorSwatches.map(function(swatch){ return swatch.intValue });
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
			
			swatch.historyButton.addEventListener(MouseEvent.CLICK, function(){ _showHistory(pNum); });
			swatch.lockIcon.addEventListener(MouseEvent.CLICK, function(){
				swatch.locked ? swatch.unlock() : swatch.lock();
			});
			
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
			// trace("changeColor()");
			_colorSwatches[_selectedSwatch].value = color;
			_trackRecentColor(color);
			dispatchEvent(new DataEvent(EVENT_COLOR_PICKED, false, false, color.toString()));
		}
		
		private function _trackRecentColor(color:uint) {
			// We always want to hide history in cases where a new color is added
			// - even if it's not tracked
			_hideHistory();
			// trace("_trackRecentColor "+color+" -- track: "+(_dontTrackNextRecentChange ? "no" : "yes"));
			if(!_dontTrackNextRecentChange) {
				_lastColorChangeValue = color;
			} else {
				_dontTrackNextRecentChange = false;
			}
		}
		
		private function _untrackRecentColor() {
			// trace("_untrackRecentColor");
			_lastColorChangeValue = -1;
		}
		
		private function _addRecentColor() {
			// We always want to hide history in cases where a new color is added
			// - even if it's not tracked
			_hideHistory();
			// trace("_addRecentColor -- "+(_lastColorChangeValue == -1 ? "false" : ("true - "+_lastColorChangeValue)));
			// Don't add to favorites unless we actually changed the color at some point
			if(_lastColorChangeValue == -1) { return; }
			_recentColorsDisplay.addColor(_lastColorChangeValue);
			_addHistory(_lastColorChangeValue, _selectedSwatch);
			_untrackRecentColor();
		}
		
		private function _randomizeAllColors() {
			for(var i = 0; i < _colorSwatches.length; i++) {
				_colorSwatches[i].unselect();
				if(_colorSwatches[i].locked == false) {
					var randomColor = uint(Math.random() * 0xFFFFFF);
					_colorSwatches[i].value = randomColor;
					_addHistory(randomColor, i);
				}
			}
			_colorSwatches[_selectedSwatch].select();
			// Set the cursor to match swatch's new color, but don't count it as a manual color change
			_lastColorChangeValue = -1;
			_dontTrackNextRecentChange = true;
			_psColorPick.setCursor(_colorSwatches[_selectedSwatch].textValue);
			// Sent number back as negative as an indicator that all swatches were randomized
			dispatchEvent(new DataEvent(EVENT_COLOR_PICKED, false, false, (-_colorSwatches[_selectedSwatch].intValue).toString()));
		}
		
		// Return a key unique to both this item and this swatch
		private function _getHistoryDictKey(swatchI:int) {
			return !infoBar.data ? ["misc", swatchI].join('_') : [infoBar.data.type, infoBar.data.id, swatchI].join('_');
		}
		private function _addHistory(color:int, swatchI:int) {
			var itemID = _getHistoryDictKey(swatchI);
			if(!HISTORY[itemID]) HISTORY[itemID] = [];
			var itemHistory = HISTORY[itemID];
			// Remove old value if there is one, and move it to front of the list
			if(itemHistory.indexOf(color) != -1) {
				itemHistory.splice(itemHistory.indexOf(color), 1);
			}
			itemHistory.unshift(color);
			_showHistoryButtonIfValid(swatchI);
		}
		private function _getHistoryColors(swatchI:int) {
			var itemID = _getHistoryDictKey(swatchI);
			if(!HISTORY[itemID]) HISTORY[itemID] = [];
			return HISTORY[itemID];
		}
		private function _showHistory(swatchI:int) {
			var colors = _getHistoryColors(swatchI);
			if(colors.length > 0) {
				_selectSwatch(swatchI, true, false);
				
				// Clear old history tray data
				while(_historyTray.numChildren){
					_historyTray.removeChildAt(0);
				}
				
				var length = Math.min(colors.length, 9);
				var btnSize = 70, spacing = 10, columns = 3,
				tX = -(btnSize+spacing) * (columns-1)/2, tY = -(btnSize+spacing) * (columns-1)/2;
				for(var i = 0; i < length; i++) {
					var color = colors[i];
					var btn = new ColorButton({ color:color, x:tX+((i%columns) * (btnSize+spacing)), y:tY+(Math.floor(i/columns)*(btnSize+spacing)), size:btnSize });
					btn.addEventListener(ButtonBase.CLICK, _onHistoryColorClicked);
					_historyTray.addChild(btn);
				}
				addItem(_historyTray);
			}
		}
		private function _onHistoryColorClicked(e:FewfEvent) {
			changeColor(uint(e.data));
			_addRecentColor();
		}
		private function _hideHistory() {
			if(containsItem(_historyTray)) removeItem(_historyTray);
		}
		private function _showHistoryButtonIfValid(swatchI:int) {
			if(_getHistoryColors(swatchI).length > 1) {
				_colorSwatches[swatchI].showHistoryButton();
			}
		}
		
		/****************************
		* Events
		*****************************/
		private function _onColorPickChanged(pEvent:DataEvent) : void {
			changeColor(uint(pEvent.data));
		}
		
		private function _onRecentColorBtnClicked(pEvent:DataEvent) : void {
			changeColor(uint(pEvent.data));
			_lastColorChangeValue = uint(pEvent.data);
			_dontTrackNextRecentChange = false;
			_addHistory(_lastColorChangeValue, _selectedSwatch);
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
