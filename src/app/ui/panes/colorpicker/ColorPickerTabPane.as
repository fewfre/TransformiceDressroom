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
	import app.ui.panes.base.GridSidePane;
	import app.ui.panes.infobar.Infobar;
	
	public class ColorPickerTabPane extends GridSidePane
	{
		// Constants
		public static const EVENT_SWATCH_CHANGED	: String = "event_swatch_changed";
		public static const EVENT_COLOR_PICKED		: String = "event_color_picked";
		public static const EVENT_PREVIEW_COLOR		: String = "event_preview_color";
		public static const EVENT_ITEM_ICON_CLICKED : String = "event_item_icon_clicked";
		
		// Storage
		private var _colorSwatches             : Vector.<ColorSwatch>;
		private var _selectedSwatch            : int=0;
		private var _psColorPick               : ColorPicker;
		
		private var _defaultColors             : Vector.<uint>;
		private var _lastColorChangeValue      : int;
		private var _dontTrackNextRecentChange : Boolean;
		
		private var _recentColorsDisplay       : RecentColorsListDisplay;
		private var _randomizeButton           : SpriteButton;
		
		private var _colorHistory              : ColorHistoryOverlay;
		
		private static const _lockHistory       : LockHistoryMap = new LockHistoryMap();
		
		// Properties
		public function get selectedSwatch():int { return _selectedSwatch; }
		
		// Constructor
		// pData = { hide_default:bool, hideItemPreview:bool }
		public function ColorPickerTabPane(pData:Object) {
			super(1);
			
			this.addInfoBar( new Infobar({ showBackButton:true, hideItemPreview:pData.hideItemPreview }) )
				.on(Infobar.BACK_CLICKED, _onColorPickerBackClicked)
				.on(Infobar.ITEM_PREVIEW_CLICKED, function(e){ dispatchEvent(new Event(EVENT_ITEM_ICON_CLICKED)); });
			
			var tClickOffDetector = addChildAt(new Sprite(), 0) as Sprite;
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
				defaults_btn.addEventListener(ButtonBase.CLICK, function(){ _defaultAllColors(); });
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
			
			// this.UpdatePane(false);
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
			_recentColorsDisplay.toggleOffDeleteMode();
			dispatchEvent(new FewfEvent(EVENT_PREVIEW_COLOR, null));
		}
		
		/****************************
		* Public
		*****************************/
		public function init(pId:String, pColors:Vector.<uint>, pDefaults:Vector.<uint>) : void {
			_lockHistory.init(pId, pColors.length);
			
			_setupSwatches(pColors);
			_defaultColors = pDefaults ? pDefaults.concat() : null;
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
		private function addItem(pItem:DisplayObject) : DisplayObject {
			return _scrollbox.add(pItem);
		}
		private function removeItem(pItem:DisplayObject) : DisplayObject {
			return _scrollbox.remove(pItem);
		}
		
		public function _setupSwatches(pSwatches:Vector.<uint>) : void {
			for each(var btn:ColorSwatch in _colorSwatches) {
				this.removeItem(btn);
			}
			_colorSwatches = new Vector.<ColorSwatch>;
			
			var swatch:ColorSwatch;
			for(var i:int = 0; i < pSwatches.length; i++) {
				swatch = _createColorSwatch(i, 5, 45 + (i * 27), _lockHistory.getLockHistory(i));
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
		
		private function _createColorSwatch(pNum:int, pX:int, pY:int, pLocked:Boolean=false) : ColorSwatch {
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
				if(!!infoBar.itemData) {
					dispatchEvent(new FewfEvent(EVENT_PREVIEW_COLOR, { type:infoBar.itemData.type, id:infoBar.itemData.id, colorI:pNum }));
				}
			});
			swatch.swatch.addEventListener(MouseEvent.MOUSE_OUT, function(){
				dispatchEvent(new FewfEvent(EVENT_PREVIEW_COLOR, null));
			});
			swatch.swatch.addEventListener(MouseEvent.MOUSE_DOWN, function(){
				if(!!infoBar.itemData) {
					dispatchEvent(new FewfEvent(EVENT_PREVIEW_COLOR, { type:infoBar.itemData.type, id:infoBar.itemData.id, colorI:pNum }));
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
				_updateLockHistoryFromCurrentState();
			});
			if(pLocked) {
				swatch.lock();
			}
			
			return swatch;
		}
		
		private function _selectSwatch(pNum:int) : void {
			for(var i = 0; i < _colorSwatches.length; i++) {
				_colorSwatches[i].unselect();
			}
			_selectedSwatch = pNum;
			_colorSwatches[pNum].select();
			
			_psColorPick.setCursor(_colorSwatches[pNum].color);
			_recentColorsDisplay.toggleOffDeleteMode();
		}
		
		private function changeColor(color:uint, pSkipColorSwatch:Boolean=false, pSkipSetSursor:Boolean=false) {
			// trace("changeColor()");
			if(!pSkipColorSwatch) _colorSwatches[_selectedSwatch].color = color;
			if(!pSkipSetSursor) _psColorPick.setCursor(color);
			_trackRecentColor(color);
			_dispatchColorUpdate(color, _selectedSwatch, false);
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
		
		private function _updateColors(pColors:Vector.<uint>, pRespectLocks:Boolean=true) : void {
			for(var i = 0; i < _colorSwatches.length; i++) {
				_colorSwatches[i].unselect();
				if(!pRespectLocks || _colorSwatches[i].locked == false) {
					_colorSwatches[i].color = pColors[i];
					_colorSwatches[i].padCodeIfNeeded();
					_addHistory(pColors[i], i);
				}
			}
			_colorSwatches[_selectedSwatch].select();
			_psColorPick.setCursor(_colorSwatches[_selectedSwatch].color);
		}
		
		private function _randomizeAllColors() {
			var newColors:Vector.<uint> = new Vector.<uint>(_colorSwatches.length).map(function(){ return uint(Math.random() * 0xFFFFFF) });
			_updateColors(newColors, true);
			
			_untrackRecentColor();
			_recentColorsDisplay.toggleOffDeleteMode();
			_dispatchColorUpdate(_colorSwatches[_selectedSwatch].color, _selectedSwatch, true);
		}
		
		private function _defaultAllColors() {
			_lockHistory.clearLockHistory();
			_updateLocksToMatchHistory();
			
			_updateColors(_defaultColors.concat(), true);
			
			_untrackRecentColor();
			_recentColorsDisplay.toggleOffDeleteMode();
			_dispatchColorUpdate(_colorSwatches[_selectedSwatch].color, _selectedSwatch, true);
		}
		
		/****************************
		* History
		*****************************/
		// Return a key unique to both this item and this swatch
		private function _getHistoryDictKey(swatchI:int) {
			return !infoBar.itemData ? ["misc", swatchI].join('_') : [infoBar.itemData.type, infoBar.itemData.id, swatchI].join('_');
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
			if(_scrollbox.contains(_colorHistory)) removeItem(_colorHistory);
		}
		private function _showHistoryButtonIfValid(swatchI:int) {
			if(_getHistoryColors(swatchI).length > 1) {
				_colorSwatches[swatchI].showHistoryButton();
			}
		}
		
		/****************************
		* Lock History
		*****************************/
		private function _updateLockHistoryFromCurrentState() : void {
			_lockHistory.clearLockHistory();
			for(var i:int = 0; i < _colorSwatches.length; i++) {
				_lockHistory.setLockHistory(i, _colorSwatches[i].locked);
			}
		}
		private function _updateLocksToMatchHistory() : void {
			for(var i:int = 0; i < _colorSwatches.length; i++) {
				var locked:Boolean = _lockHistory.getLockHistory(i);
				if(locked && !_colorSwatches[i].locked) _colorSwatches[i].lock();
				else if(!locked && _colorSwatches[i].locked) _colorSwatches[i].unlock();
			}
		}
		
		/****************************
		* Events
		*****************************/
		private function _onColorPickChanged(pEvent:DataEvent) : void {
			// Skip cursor set since otherwise the top color bar gets updated when just dragging cursor around
			changeColor(uint(pEvent.data), false, true);
			_recentColorsDisplay.toggleOffDeleteMode();
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
		
		private function _onColorPickerBackClicked(pEvent:Event) : void {
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		private function _dispatchColorUpdate(pColor:uint, pColorIndex:int, pAllUpdated:Boolean=false) : void {
			dispatchEvent(new FewfEvent(EVENT_COLOR_PICKED, {
				color: pColor,
				colorIndex: pColorIndex,
				allUpdated: pAllUpdated,
				allColors: getAllColors()
			}));
		}
	}
}
