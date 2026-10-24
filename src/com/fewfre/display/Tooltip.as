package com.fewfre.display
{
	import com.fewfre.data.I18n;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.utils.Fewf;

	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	public class Tooltip
	{
		// Constants
		public static const TOP:String = "top";
		public static const BOTTOM:String = "bottom";
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";
		private static const VALID_PLACEMENTS:Array = [TOP, BOTTOM, LEFT, RIGHT];

		// Storage
		private var _root:Sprite;
		private var _target:InteractiveObject;
		private var _label:TextTranslated;
		private var _textKey:String;
		
		private var _showTimeout:Number;
		private var _touchPointID:int = -1;
		private var _touchStage:Stage;
		private var _previousCursor:String;
		
		// Storage - settings
		private var _delay:Number = 350;
		private var _placement:String = TOP;
		private var _gap:Number = 8;
		private var _screenPadding:Number = 6;
		
		private var _maxWidth:Number;
		private var _padding:Number;
		private var _backgroundColor:uint;
		private var _backgroundAlpha:Number;
		private var _borderColor:uint;
		private var _cornerRadius:Number;
		private var _shadowColor:uint;
		private var _shadowAlpha:Number;
		private var _shadowBlur:Number;
		private var _shadowStrength:Number;

		// Constructor
		/** pOptions: {
		 *   padding:Number=7, maxWidth:Number=240, font:String, fontSize:Number=12, textColor:uint=0xFFFFFF,
		 *   backgroundColor:uint=0x252A32, backgroundAlpha:Number=0.96, borderColor:uint=0x454B55, cornerRadius:Number=5,
		 *   shadowColor:uint=borderColor, shadowAlpha:Number=0.35, shadowBlur:Number=8, shadowStrength:Number=1 }
		 */
		public function Tooltip(pTarget:InteractiveObject, pText:String, pOptions:Object=null) {
			_root = new Sprite();
			pOptions = pOptions || {};
			_target = pTarget;
			_textKey = pText;
			_padding = pOptions.padding != null ? pOptions.padding : 7;
			_maxWidth = pOptions.maxWidth != null ? pOptions.maxWidth : 240;
			_backgroundColor = pOptions.backgroundColor != null ? pOptions.backgroundColor : 0x252A32;
			_backgroundAlpha = pOptions.backgroundAlpha != null ? pOptions.backgroundAlpha : 0.96;
			_borderColor = pOptions.borderColor != null ? pOptions.borderColor : 0x454B55;
			_cornerRadius = pOptions.cornerRadius != null ? pOptions.cornerRadius : 5;
			_shadowColor = pOptions.shadowColor != null ? pOptions.shadowColor : _borderColor;
			_shadowAlpha = pOptions.shadowAlpha != null ? pOptions.shadowAlpha : 0.35;
			_shadowBlur = pOptions.shadowBlur != null ? pOptions.shadowBlur : 7.5;
			_shadowStrength = pOptions.shadowStrength != null ? pOptions.shadowStrength : 3.5;

			_label = new TextTranslated(pText, {
				font:pOptions.font,
				size:pOptions.fontSize != null ? pOptions.fontSize : 12,
				color:pOptions.textColor != null ? pOptions.textColor : 0xFFFFFF,
				align:TextFormatAlign.LEFT,
				originX:0,
				originY:0
			});
			_label.x = _padding + 2;
			_label.y = _padding + 2;
			_root.addChild(_label);
			_render();
			Fewf.dispatcher.addEventListener(I18n.FILE_UPDATED, _onLanguageUpdated);
			_root.mouseEnabled = false;
			_root.mouseChildren = false;
			_root.visible = false;

			if(_target) {
				_target.addEventListener(MouseEvent.ROLL_OVER, _onMouseOver);
				_target.addEventListener(MouseEvent.ROLL_OUT, _onMouseOut);
				_target.addEventListener(TouchEvent.TOUCH_BEGIN, _onTouchBegin);
				_target.addEventListener(Event.REMOVED_FROM_STAGE, _onTargetRemoved);
			}
		}
		public function setPlacement(pPlacement:String) : Tooltip { _placement = VALID_PLACEMENTS.indexOf(pPlacement) > -1 ? pPlacement : TOP; return this; }
		public function setDelay(pDelay:Number) : Tooltip { _delay = Math.max(0, pDelay); return this; }
		public function setGap(pGap:Number) : Tooltip { _gap = Math.max(0, pGap); return this; }
		public function setScreenPadding(pScreenPadding:Number) : Tooltip { _screenPadding = Math.max(0, pScreenPadding); return this; }
		public function setMaxWidth(pMaxWidth:Number) : Tooltip { _maxWidth = Math.max(1, pMaxWidth); _render(); return this; }
		
		/////////////////////////////
		//#region Public
		/////////////////////////////
		public function show() : void {
			_clearShowTimeout();
			_show();
		}

		public function hide() : void {
			_clearShowTimeout();
			_removeTouchListeners();
			_root.visible = false;
			if(_root.parent) _root.parent.removeChild(_root);
		}
		
		/////////////////////////////
		//#region Private
		/////////////////////////////
		private function _render() : void {
			_label.field.wordWrap = false;
			_label.setText(_textKey);
			if(_label.field.textWidth > _maxWidth) _label.enableWordWrapUsingWidth(_maxWidth);

			var width:Number = _label.width + _padding * 2;
			var height:Number = _label.height + _padding * 2;
			_root.graphics.clear();
			_root.graphics.lineStyle(1, _borderColor);
			_root.graphics.beginFill(_backgroundColor, _backgroundAlpha);
			_root.graphics.drawRoundRect(0.5, 0.5, width - 1, height - 1, _cornerRadius, _cornerRadius);
			_root.graphics.endFill();
			_root.filters = [new DropShadowFilter(0, 0, _shadowColor, _shadowAlpha, _shadowBlur, _shadowBlur, _shadowStrength, 2)];
		}

		private function _onLanguageUpdated(e:FewfEvent) : void {
			_render();
			if(_root.visible && _target && _target.stage) _positionOnStage(_target.stage);
		}

		private function _scheduleShow() : void {
			_clearShowTimeout();
			_showTimeout = setTimeout(_show, _delay);
		}

		private function _show() : void {
			_showTimeout = 0;
			if(!_target || !_target.stage) return;
			var stage:Stage = _target.stage;
			if(_root.parent != stage) stage.addChild(_root);
			_positionOnStage(stage);
			_root.visible = true;
		}

		private function _positionOnStage(stage:Stage) : void {
			var targetBounds:Rectangle = (_target as DisplayObject).getBounds(stage);
			var tooltipWidth:Number = _root.width;
			var tooltipHeight:Number = _root.height;
			var stageWidth:Number = stage.stageWidth;
			var stageHeight:Number = stage.stageHeight;
			var placement:String = _placement;
			var nextPlacement:String = _oppositePlacement(placement);
			var position:Point = _getPosition(placement, targetBounds, tooltipWidth, tooltipHeight);
			if(!_fits(position, tooltipWidth, tooltipHeight, stageWidth, stageHeight) && _fits(_getPosition(nextPlacement, targetBounds, tooltipWidth, tooltipHeight), tooltipWidth, tooltipHeight, stageWidth, stageHeight)) {
				position = _getPosition(nextPlacement, targetBounds, tooltipWidth, tooltipHeight);
			}
			_root.x = Math.max(_screenPadding, Math.min(stageWidth - tooltipWidth - _screenPadding, position.x));
			_root.y = Math.max(_screenPadding, Math.min(stageHeight - tooltipHeight - _screenPadding, position.y));
		}

		private function _getPosition(placement:String, bounds:Rectangle, tooltipWidth:Number, tooltipHeight:Number) : Point {
			if(placement == BOTTOM) return new Point(bounds.x + (bounds.width - tooltipWidth) / 2, bounds.bottom + _gap);
			if(placement == LEFT) return new Point(bounds.left - tooltipWidth - _gap, bounds.y + (bounds.height - tooltipHeight) / 2);
			if(placement == RIGHT) return new Point(bounds.right + _gap, bounds.y + (bounds.height - tooltipHeight) / 2);
			return new Point(bounds.x + (bounds.width - tooltipWidth) / 2, bounds.top - tooltipHeight - _gap);
		}

		private function _fits(position:Point, tooltipWidth:Number, tooltipHeight:Number, stageWidth:Number, stageHeight:Number) : Boolean {
			return position.x >= _screenPadding && position.y >= _screenPadding
				&& position.x + tooltipWidth <= stageWidth - _screenPadding
				&& position.y + tooltipHeight <= stageHeight - _screenPadding;
		}

		private function _oppositePlacement(placement:String) : String {
			if(placement == TOP) return BOTTOM;
			if(placement == BOTTOM) return TOP;
			if(placement == LEFT) return RIGHT;
			return LEFT;
		}

		private function _clearShowTimeout() : void {
			if(_showTimeout) {
				clearTimeout(_showTimeout);
				_showTimeout = 0;
			}
		}

		private function _restoreCursor() : void {
			if(Mouse.cursor == MouseCursor.HAND) {
				Mouse.cursor = _previousCursor || MouseCursor.AUTO;
			}
			_previousCursor = null;
		}
		
		/////////////////////////////
		//#region Events
		/////////////////////////////
		private function _onMouseOver(e:MouseEvent) : void {
			_previousCursor = Mouse.cursor;
			Mouse.cursor = MouseCursor.HAND;
			_scheduleShow();
		}
		private function _onMouseOut(e:MouseEvent) : void {
			_restoreCursor();
			if(_touchPointID < 0) hide();
		}

		private function _onTouchBegin(e:TouchEvent) : void {
			hide();
			_touchPointID = e.touchPointID;
			_touchStage = _target ? _target.stage : null;
			if(_touchStage) {
				_touchStage.addEventListener(TouchEvent.TOUCH_END, _onTouchEnd);
				_touchStage.addEventListener(TouchEvent.TOUCH_MOVE, _onTouchMove);
			}
			_scheduleShow();
		}

		private function _onTouchEnd(e:TouchEvent) : void {
			if(e.touchPointID == _touchPointID) hide();
		}

		private function _onTouchMove(e:TouchEvent) : void {
			if(e.touchPointID != _touchPointID || !_target || !_target.stage) return;
			var bounds:Rectangle = (_target as DisplayObject).getBounds(_target.stage);
			if(!bounds.contains(e.stageX, e.stageY)) hide();
		}

		private function _onTargetRemoved(e:Event) : void {
			hide();
			_restoreCursor();
		}
		
		/////////////////////////////
		//#region Cleanup
		/////////////////////////////
		public function dispose() : void {
			hide();
			_restoreCursor();
			Fewf.dispatcher.removeEventListener(I18n.FILE_UPDATED, _onLanguageUpdated);
			if(_target) {
				_target.removeEventListener(MouseEvent.ROLL_OVER, _onMouseOver);
				_target.removeEventListener(MouseEvent.ROLL_OUT, _onMouseOut);
				_target.removeEventListener(TouchEvent.TOUCH_BEGIN, _onTouchBegin);
				_target.removeEventListener(Event.REMOVED_FROM_STAGE, _onTargetRemoved);
				_target = null;
			}
		}

		private function _removeTouchListeners() : void {
			if(_touchStage) {
				_touchStage.removeEventListener(TouchEvent.TOUCH_END, _onTouchEnd);
				_touchStage.removeEventListener(TouchEvent.TOUCH_MOVE, _onTouchMove);
			}
			_touchStage = null;
			_touchPointID = -1;
		}
	}
}
