package app.ui.buttons
{	
	import app.data.ConstantsApp;
	import com.fewfre.display.TextTranslated;
	import com.fewfre.utils.FewfDisplayUtils;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class PushButton extends GameButton
	{
		// Constants
		public static const TOGGLE:String="state_changed_after";
		
		// Storage
		protected var _pushed:Boolean;
		protected var _allowToggleOff:Boolean; // Only controls the behavior on internal click controls.
		
		// Properties
		public function get pushed() : Boolean { return _pushed; }
		public function get allowToggleOff() : Boolean { return _allowToggleOff; }
		
		// Constructor
		// pArgs = { x:Number, y:Number, (width:Number, height:Number OR size:Number), ?obj:DisplayObject, ?obj_scale:Number, ?text:String, ?allowToggleOff:Boolean=true }
		public function PushButton(pArgs:Object) {
			super(pArgs);
			
			if(pArgs.text) { setText(pArgs.text); }
			if(pArgs.obj) {
				setImage(pArgs.obj, pArgs.obj_scale || NaN);
			}
			
			_allowToggleOff = pArgs.allowToggleOff == null ? true : pArgs.allowToggleOff;
			_pushed = false;
			_renderUnpressed();
		}
		public function setAllowToggleOff(pVal:Boolean) : PushButton { _allowToggleOff = pVal; return this; }
		public function onToggle(listener:Function, useCapture:Boolean = false): PushButton { return this.on(PushButton.TOGGLE, listener, useCapture) as PushButton; }
		
		protected function _renderUnpressed() : void {
			super._renderUp();
			if(_text) { _text.color = 0xC2C2DA; }
		}

		protected function _renderPressed() : void {
			_bg.draw3d(ConstantsApp.COLOR_BUTTON_MOUSE_DOWN, 0x5D7A91, 0x5D7A91, 0x6C8DA8);
			if(_text) { _text.color = 0xFFD800; }
		}

		public function toggle(pOn:*=null, pFireEvent:Boolean=true) : PushButton {
			_pushed = pOn != null ? pOn : !_pushed;
			if(_pushed) _renderPressed();
			else _renderUnpressed();
			
			if(pFireEvent) _dispatch(TOGGLE);
			return this;
		}
		
		public function toggleOn(pFireEvent:Boolean=true) : PushButton {
			return toggle(true, pFireEvent);
		}

		public function toggleOff(pFireEvent:Boolean=false) : PushButton {
			return toggle(false, pFireEvent);
		}
		
		override protected function _onMouseUp(pEvent:MouseEvent) : void {
			if(!_flagEnabled) { return; }
			var pOn = null;
			// if toggle off enabled, then still allow clicking the button again to refire event
			if(!_allowToggleOff && _pushed) { pOn = true; }
			toggle(pOn);
			super._onMouseUp(pEvent);
		}
		
		override protected function _renderUp() : void {
			if (_pushed == false) {
				super._renderUp();
			}
		}
		
		override protected function _renderDown() : void {
			if (_pushed == false) {
				super._renderDown();
			}
		}
		
		override protected function _renderOver() : void {
			if (_pushed == false) {
				super._renderOver();
			}
		}
		
		override protected function _renderOut() : void {
			if(_pushed == false) {
				super._renderOut();
			}
		}
		
		/////////////////////////////
		// Static
		/////////////////////////////
		public static function withObject(pObj:DisplayObject, pScale:Object=null, pData:Object=null) : PushButton {
			pData = pData || {};
			pData.obj = pObj;
			pData.obj_scale = pScale;
			return new PushButton(pData);
		}
		// Convience method to deal with PushButtons that can only have 1 of each selected (todo: create a manager or something for this?)
		// Doesn't fire event, as this is just to update the visual states
		public static function untoggleAll(pList:Vector.<PushButton>, pActiveButtonToSkip:PushButton=null) : void {
			for(var i:int = 0; i < pList.length; i++) {
				if (pList[i].pushed && pList[i] != pActiveButtonToSkip) {
					pList[i].toggleOff(false);
				}
			}
		}
		
		public static function square(pSize:Number) : PushButton {
			return new PushButton({ size:pSize });
		}
		public static function rect(pWidth:Number, pHeight:Number) : PushButton {
			return new PushButton({ width:pWidth, height:pHeight });
		}
	}
}
