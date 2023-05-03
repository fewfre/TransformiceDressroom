package app.ui.panes.colorpicker
{
	import com.piterwilson.utils.*;
	import com.fewfre.display.*;
	import com.fewfre.events.FewfEvent;
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.Dictionary;
	import ext.ParentApp;
	import app.ui.panes.TabPane;
	
	public class ColorPickerTabPane extends TabPane
	{
		// Constants
		public static const EVENT_SWATCH_CHANGED	: String = "event_swatch_changed";
		public static const EVENT_DEFAULT_CLICKED	: String = "event_default_clicked";
		public static const EVENT_COLOR_PICKED		: String = "event_color_picked";
		public static const EVENT_PREVIEW_COLOR		: String = "event_preview_color";
		public static const EVENT_EXIT				: String = "event_exit";
		
		// Storage
		private var _colorSwatches             : Vector.<ColorSwatch>;
		private var _selectedSwatch            : int=0;
		private var _psColorPick               : ColorPicker;
		
		private var _lastColorChangeValue      : int;
		private var _dontTrackNextRecentChange : Boolean;
		
		private var _recentColorsDisplay       : RecentColorsListDisplay;
		private var _randomizeButton           : SpriteButton;
		
		private var _colorHistory              : ColorHistoryOverlay;
		
		// Properties
		public function get selectedSwatch():int { return _selectedSwatch; }
		
		// Constructor
		public function ColorPickerTabPane(pData:Object)
		{
			super();
			
			this.addInfoBar( new ShopInfoBar({ showBackButton:true }) );
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
			
			_psColorPick = this.addItem(new ColorPicker()) as ColorPicker;
			_psColorPick.x = 105;
			_psColorPick.y = 5;
			_psColorPick.addEventListener(ColorPicker.COLOR_PICKED, _onColorPickChanged);
			
			_colorSwatches = new Vector.<ColorSwatch>();
			
			if(!pData.hide_default) {
				var defaults_btn:SpriteButton;
				defaults_btn = this.addItem( new SpriteButton({ text:"btn_color_defaults", x:6, y:15, width:100, height:22, obj:new MovieClip() }) ) as SpriteButton;
				defaults_btn.addEventListener(ButtonBase.CLICK, _onDefaultButtonClicked);
			}
			
			_randomizeButton = this.addItem(new SpriteButton({ x:ConstantsApp.PANE_WIDTH - 24 - 11, y:14, width:24, height:24, obj_scale:0.8, obj:new $Dice() })) as SpriteButton;
			_randomizeButton.addEventListener(ButtonBase.CLICK, function(){ _randomizeAllColors(); });
			
			_recentColorsDisplay = new RecentColorsListDisplay({ x:ConstantsApp.PANE_WIDTH/2, y:316+60+17 });
			_recentColorsDisplay.addEventListener(RecentColorsListDisplay.EVENT_COLOR_PICKED, _onRecentColorBtnClicked);
			addChild(_recentColorsDisplay);
			
			var historySize = 270;
			_colorHistory = new ColorHistoryOverlay(historySize);
			_colorHistory.x = _psColorPick.x + 10 + historySize*0.5;
			_colorHistory.y = _psColorPick.y + 40 + historySize*0.5;
			_colorHistory.addEventListener(ColorHistoryOverlay.EVENT_COLOR_PICKED, _onHistoryColorClicked);
			
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
			dispatchEvent(new FewfEvent(EVENT_PREVIEW_COLOR, null));
		}
		
		/****************************
		* Public
		*****************************/
		public function setupSwatches(pSwatches:Vector.<uint>) : void {
			for each(var btn:ColorSwatch in _colorSwatches) {
				this.removeItem(btn);
			}
			_colorSwatches = new Vector.<ColorSwatch>;
			
			var swatch:ColorSwatch;
			for(var i:int = 0; i < pSwatches.length; i++) {
				swatch = _createColorSwatch(i, 5, 45 + (i * 27));
				swatch.color = pSwatches[i];
				_colorSwatches.push(swatch);
				if(_getHistoryColors(i).length == 0) {
					_addHistory(pSwatches[i], i);
				}
				_showHistoryButtonIfValid(i);
				this.addItem(swatch);
				
				if (_selectedSwatch == i) {
					_psColorPick.setCursor(swatch.color);
				}
			}
			
			_selectSwatch(0);
			renderRecents();
		}
		
		public function renderRecents() : void {
			_recentColorsDisplay.render();
		}
		
		public function getAllColors() : Vector.<uint> {
			var colors:Vector.<uint> = new Vector.<uint>();
			for(var i:int = 0; i < _colorSwatches.length; i++){
				colors.push( _colorSwatches[i].color );
			}
			return colors;
		}
		
		public function nextSwatch(pForward:Boolean=true) : void {
			var newSwatchI:int = _selectedSwatch + (pForward ? 1 : -1);
			// Force index to loop in both directions
			newSwatchI = (newSwatchI + _colorSwatches.length) % _colorSwatches.length;
			_selectSwatch(newSwatchI);
		}
		
		/****************************
		* Private
		*****************************/
		private function _createColorSwatch(pNum:int, pX:int, pY:int) : ColorSwatch {
			var swatch:ColorSwatch = new ColorSwatch();
			swatch.addEventListener(ColorSwatch.USER_MODIFIED_TEXT, function(){
				_selectSwatch(pNum);
				changeColor(swatch.color, true);
			});
			swatch.addEventListener(ColorSwatch.ENTER_PRESSED, function(){
				_selectSwatch(pNum);
				_addRecentColor();
			});
			swatch.addEventListener(ColorSwatch.BUTTON_CLICK, function(){
				// Add here since we just changed what swatch we're on and current one is thus "finalized"
				_addRecentColor();
				// don't track a change just from clicking a swatch, but do still set cursor/add a recent if needed
				_selectSwatch(pNum);
			});
			swatch.swatch.addEventListener(MouseEvent.MOUSE_OVER, function(){
				if(!!infoBar.data) {
					dispatchEvent(new FewfEvent(EVENT_PREVIEW_COLOR, { type:infoBar.data.type, id:infoBar.data.id, colorI:pNum }));
				}
			});
			swatch.swatch.addEventListener(MouseEvent.MOUSE_OUT, function(){
				dispatchEvent(new FewfEvent(EVENT_PREVIEW_COLOR, null));
			});
			swatch.swatch.addEventListener(MouseEvent.MOUSE_DOWN, function(){
				if(!!infoBar.data) {
					dispatchEvent(new FewfEvent(EVENT_PREVIEW_COLOR, { type:infoBar.data.type, id:infoBar.data.id, colorI:pNum }));
				}
			});
			swatch.swatch.addEventListener(MouseEvent.MOUSE_UP, function(){
				dispatchEvent(new FewfEvent(EVENT_PREVIEW_COLOR, null));
			});
			swatch.x = pX;
			swatch.y = pY;
			
			swatch.historyButton.addEventListener(MouseEvent.CLICK, function(){ _showHistory(pNum); });
			swatch.lockIcon.addEventListener(MouseEvent.CLICK, function(){
				swatch.locked ? swatch.unlock() : swatch.lock();
			});
			
			return swatch;
		}
		
		private function _selectSwatch(pNum:int) : void {
			for(var i = 0; i < _colorSwatches.length; i++) {
				_colorSwatches[i].unselect();
			}
			_selectedSwatch = pNum;
			_colorSwatches[pNum].select();
			
			_psColorPick.setCursor(_colorSwatches[pNum].color);
		}
		
		private function changeColor(color:uint, pSkipColorSwatch:Boolean=false, pSkipSetSursor:Boolean=false) {
			// trace("changeColor()");
			if(!pSkipColorSwatch) _colorSwatches[_selectedSwatch].color = color;
			if(!pSkipSetSursor) _psColorPick.setCursor(color);
			_trackRecentColor(color);
			dispatchEvent(new FewfEvent(EVENT_COLOR_PICKED, { color:color }));
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
			_colorSwatches[_selectedSwatch].padCodeIfNeeded();
			_untrackRecentColor();
		}
		
		private function _randomizeAllColors() {
			for(var i = 0; i < _colorSwatches.length; i++) {
				_colorSwatches[i].unselect();
				if(_colorSwatches[i].locked == false) {
					var randomColor = uint(Math.random() * 0xFFFFFF);
					_colorSwatches[i].color = randomColor;
					_colorSwatches[i].padCodeIfNeeded();
					_addHistory(randomColor, i);
				}
			}
			_colorSwatches[_selectedSwatch].select();
			_psColorPick.setCursor(_colorSwatches[_selectedSwatch].color);
			_untrackRecentColor();
			dispatchEvent(new FewfEvent(EVENT_COLOR_PICKED, { randomizedAll:true, color:_colorSwatches[_selectedSwatch].color }));
		}
		
		/****************************
		* History
		*****************************/
		// Return a key unique to both this item and this swatch
		private function _getHistoryDictKey(swatchI:int) {
			return !infoBar.data ? ["misc", swatchI].join('_') : [infoBar.data.type, infoBar.data.id, swatchI].join('_');
		}
		private function _addHistory(color:int, swatchI:int) {
			var itemID = _getHistoryDictKey(swatchI);
			_colorHistory.addHistory(itemID, color)
			_showHistoryButtonIfValid(swatchI);
		}
		private function _getHistoryColors(swatchI:int) {
			var itemID = _getHistoryDictKey(swatchI);
			return _colorHistory.getHistoryColors(itemID);
		}
		private function _showHistory(swatchI:int) {
			// Also select the swatch related to history, and submit any tracked recent color
			_selectSwatch(swatchI);
			_addRecentColor();
			
			var itemID = _getHistoryDictKey(swatchI);
			_colorHistory.renderHistory(itemID);
			addItem(_colorHistory);
		}
		private function _hideHistory() {
			if(containsItem(_colorHistory)) removeItem(_colorHistory);
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
			// Skip cursor set since otherwise the top color bar gets updated when just dragging cursor around
			changeColor(uint(pEvent.data), false, true);
		}
		
		private function _onRecentColorBtnClicked(pEvent:FewfEvent) : void {
			changeColor(uint(pEvent.data));
			_lastColorChangeValue = uint(pEvent.data);
			_dontTrackNextRecentChange = false;
			_addHistory(_lastColorChangeValue, _selectedSwatch);
		}
		
		private function _onHistoryColorClicked(e:FewfEvent) {
			changeColor(uint(e.data));
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
