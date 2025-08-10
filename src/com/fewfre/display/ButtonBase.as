package com.fewfre.display
{
	import com.fewfre.events.FewfEvent;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class ButtonBase extends Sprite
	{
		// Button State
		public static const BUTTON_STATE_UP:String = "button_state_up";
		public static const BUTTON_STATE_DOWN:String = "button_state_down";
		public static const BUTTON_STATE_OVER:String = "button_state_over";
		//public static const BUTTON_STATE_CLICK:String = "button_state_click";
		
		// Button Events
		public static const UP:String = "button_up";
		public static const DOWN:String = "button_down";
		public static const OVER:String = "button_over";
		public static const OUT:String = "button_out";
		public static const CLICK:String = "button_click";
	
		// Storage
		protected var _state       : String;
		protected var _flagEnabled : Boolean;
		protected var _returnData  : Object;
		
		// Properties
		public function get data():Object { return _returnData; }
		public function get enabled():Boolean { return _flagEnabled; }
		
		public function get scale():Number { return this.scaleX; }
		public function set scale(pVal:Number):void { this.scaleX = this.scaleY = pVal; }
		
		// Constructor
		public function ButtonBase() {
			super();
			_state = BUTTON_STATE_UP;
			
			this.buttonMode = true;
			this.useHandCursor = true;
			this.mouseChildren = false;
			
			enable();
			
			_addEventListeners();
		}
		public function move(pX:Number, pY:Number) : ButtonBase { this.x = pX; this.y = pY; return this; }
		public function appendTo(pParent:Sprite): ButtonBase { pParent.addChild(this); return this; }
		public function on(type:String, listener:Function, useCapture:Boolean = false): ButtonBase { this.addEventListener(type, listener, useCapture); return this; }
		public function onButtonClick(listener:Function, useCapture:Boolean = false): ButtonBase { this.addEventListener(ButtonBase.CLICK, listener, useCapture); return this; }
		public function off(type:String, listener:Function, useCapture:Boolean = false): ButtonBase { this.removeEventListener(type, listener, useCapture); return this; }
		public function setData(pData:Object): ButtonBase { _returnData = pData; return this; }
		public function setAlpha(pAlpha:Number): ButtonBase { this.alpha = pAlpha; return this; }
		public function setVisible(pVisible:Boolean): ButtonBase { this.visible = pVisible; return this; }
		
		/****************************
		* Events
		*****************************/
		protected function _addEventListeners() : void {
			this.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			this.addEventListener(MouseEvent.CLICK, _onMouseUp);//MOUSE_UP
			this.addEventListener(MouseEvent.ROLL_OVER, _onMouseOver);
			this.addEventListener(MouseEvent.ROLL_OUT, _onMouseOut);
		}

		protected function _onMouseDown(pEvent:MouseEvent) : void {
			if(!_flagEnabled) { return; }
			_state = BUTTON_STATE_DOWN;
			_renderDown();
			_dispatch(DOWN);
		}

		protected function _onMouseUp(pEvent:MouseEvent) : void {
			if(!_flagEnabled) { return; }
			_state = BUTTON_STATE_UP;
			_renderUp();
			_dispatch(UP);
			_dispatch(CLICK);
		}

		protected function _onMouseOver(pEvent:MouseEvent) : void {
			if(!_flagEnabled) { return; }
			_state = BUTTON_STATE_OVER;
			_renderOver();
			_dispatch(OVER);
		}

		protected function _onMouseOut(pEvent:MouseEvent) : void {
			if(!_flagEnabled) { return; }
			_state = BUTTON_STATE_UP;
			_renderOut();
			_dispatch(OUT);
		}

		/****************************
		* Render
		*****************************/
		protected function _renderUp() : void {
			this.scale = 1;
		}
		
		protected function _renderDown() : void {
			this.scale = 0.9;
		}
		
		protected function _renderOver() : void {
			this.scale = 1.1;
		}
		
		protected function _renderOut() : void {
			_renderUp();
		}
		
		protected function _renderDisabled() : void {
			this.scale = 1;
		}

		/****************************
		* Methods
		*****************************/
		protected function _dispatch(pEvent:String) : void {
			this.dispatchEvent(new FewfEvent(pEvent, _returnData));
		}
		
		public function enable() : ButtonBase {
			_flagEnabled = true;
			_state = BUTTON_STATE_UP;
			_renderUp();
			return this;
		}

		public function disable() : ButtonBase {
			_flagEnabled = false;
			_renderDisabled();
			return this;
		}
		
		/**
		 * If nothing or "null" is passed in, it will flip the current state - otherwise treats it as a boolean and sets
		 * current enabled state based on that
		 */
		public function toggleEnabled(pOn:Object=null) : ButtonBase {
			var newStateOn = pOn == null ? !enabled : Boolean(pOn);
			return newStateOn ? enable() : disable();
		}
		
		public function removeSelf() : ButtonBase {
			if(this.parent) { this.parent.removeChild(this); }
			return this;
		}
	}
}
