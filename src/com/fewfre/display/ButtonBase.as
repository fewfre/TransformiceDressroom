package com.fewfre.display
{
	import com.fewfre.events.FewfEvent;
	import flash.display.*;
	import flash.events.*;
	
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
		protected var _state		: String;
		protected var _flagEnabled	: Boolean;
		protected var _returnData	: Object;
		
		// Properties
		public function get data():Object { return _returnData; }
		
		// Constructor
		// pArgs = { x:Number, y:Number, ?data:* }
		public function ButtonBase(pArgs:Object)
		{
			super();
			_state = BUTTON_STATE_UP;
			
			this.x = pArgs.x != null ? pArgs.x : 0;
			this.y = pArgs.y != null ? pArgs.y : 0;
			
			_returnData = pArgs.data;
			
			buttonMode = true;
			useHandCursor = true;
			mouseChildren = false;
			
			enable();
			
			_addEventListeners();
		}
		public function setXY(pX:Number, pY:Number) : ButtonBase { x = pX; y = pY; return this; }
		public function appendTo(target:Sprite): ButtonBase { target.addChild(this); return this; }
		public function on(type:String, listener:Function, useCapture:Boolean = false): ButtonBase { this.addEventListener(type, listener, useCapture); return this; }
		public function off(type:String, listener:Function, useCapture:Boolean = false): ButtonBase { this.removeEventListener(type, listener, useCapture); return this; }
		
		/****************************
		* Events
		*****************************/
		protected function _addEventListeners() : void {
			addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			addEventListener(MouseEvent.CLICK, _onMouseUp);//MOUSE_UP
			addEventListener(MouseEvent.ROLL_OVER, _onMouseOver);
			addEventListener(MouseEvent.ROLL_OUT, _onMouseOut);
		}

		protected function _onMouseDown(pEvent:MouseEvent) : void
		{
			if(!_flagEnabled) { return; }
			_state = BUTTON_STATE_DOWN;
			_renderDown();
			_dispatch(DOWN);
		}

		protected function _onMouseUp(pEvent:MouseEvent) : void
		{
			if(!_flagEnabled) { return; }
			_state = BUTTON_STATE_UP;
			_renderUp();
			_dispatch(UP);
			_dispatch(CLICK);
		}

		protected function _onMouseOver(pEvent:MouseEvent) : void
		{
			if(!_flagEnabled) { return; }
			_state = BUTTON_STATE_OVER;
			_renderOver();
			_dispatch(OVER);
		}

		protected function _onMouseOut(pEvent:MouseEvent) : void
		{
			if(!_flagEnabled) { return; }
			_state = BUTTON_STATE_UP;
			_renderOut();
			_dispatch(OUT);
		}

		/****************************
		* Render
		*****************************/
		protected function _renderUp() : void {
			this.scaleX = this.scaleY = 1;
		}
		
		protected function _renderDown() : void
		{
			this.scaleX = this.scaleY = 0.9;
		}
		
		protected function _renderOver() : void {
			this.scaleX = this.scaleY = 1.1;
		}
		
		protected function _renderOut() : void {
			_renderUp();
		}
		
		protected function _renderDisabled() : void {
			this.scaleX = this.scaleY = 1;
		}

		/****************************
		* Methods
		*****************************/
		public function _dispatch(pEvent:String) : void {
			if(!_returnData) { dispatchEvent(new Event(pEvent)); }
			else {
				dispatchEvent(new FewfEvent(pEvent, _returnData));
			}
		}
		
		public function enable() : ButtonBase {
			_flagEnabled = true;
			_state = BUTTON_STATE_UP;
			_renderUp();
			return this;
		}

		/**********************************************************
		@description
		 **********************************************************/
		public function disable() : ButtonBase {
			_flagEnabled = false;
			_renderDisabled();
			return this;
		}
	}
}
