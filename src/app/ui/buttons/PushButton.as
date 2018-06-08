package app.ui.buttons
{
	import com.fewfre.display.*;
	import com.fewfre.utils.*;
	import app.data.*;
	import app.ui.*;
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.text.*;
	import flash.geom.*;
	
	public class PushButton extends GameButton
	{
		// Constants
		public static const STATE_CHANGED_BEFORE:String="state_changed_before";
		public static const STATE_CHANGED_AFTER:String="state_changed_after";
		
		// Storage
		public var id:int;
		public var pushed:Boolean;
		public var allowToggleOff:Boolean; // Only controls the behavior on internal click controls.
		public var Text:TextBase;
		public var Image:DisplayObject;
		
		// Constructor
		// pArgs = { x:Number, y:Number, width:Number, height:Number, ?obj:DisplayObject, ?obj_scale:Number, ?text:String, ?id:int, ?allowToggleOff:Boolean=true }
		public function PushButton(pArgs:Object)
		{
			super(pArgs);
			if(pArgs.id) { id = pArgs.id; }
			
			if(pArgs.text) {
				this.Text = addChild(new TextBase({ text:pArgs.text, x:pArgs.width*(0.5 - _bg.originX), y:pArgs.height*(0.5 - _bg.originY) })) as TextBase;
			}
			
			if(pArgs.obj) {
				var tBounds:Rectangle = pArgs.obj.getBounds(pArgs.obj);
				var tOffset:Point = tBounds.topLeft;
				
				var tScale:Number = pArgs.obj_scale ? pArgs.obj_scale : 1;
				this.Image = pArgs.obj;
				FewfDisplayUtils.fitWithinBounds(this.Image, pArgs.width * 0.9, pArgs.height * 0.9, pArgs.width * 0.5, pArgs.height * 0.5);
				this.Image.x = pArgs.width / 2 - (tBounds.width / 2 + tOffset.x)*tScale * this.Image.scaleX;
				this.Image.y = pArgs.height / 2 - (tBounds.height / 2 + tOffset.y)*tScale * this.Image.scaleY;
				this.Image.scaleX *= tScale;
				this.Image.scaleY *= tScale;
				addChild(this.Image);
			}
			
			this.allowToggleOff = pArgs.allowToggleOff == null ? true : pArgs.allowToggleOffs;
			this.pushed = false;
			_renderUnpressed();
		}
		
		protected function _renderUnpressed() : void
		{
			super._renderUp();
			if(this.Text) { this.Text.color = 0xC2C2DA; }
		}

		protected function _renderPressed() : void
		{
			_bg.draw(ConstantsApp.COLOR_BUTTON_MOUSE_DOWN, 7, 0x5D7A91, 0x5D7A91, 0x6C8DA8);
			if(this.Text) { this.Text.color = 0xFFD800; }
		}

		public function toggle(pOn=null, pFireEvent:Boolean=true) : void
		{
			if(pFireEvent) _dispatch(STATE_CHANGED_BEFORE);
			
			this.pushed = pOn != null ? pOn : !this.pushed;
			if(this.pushed) {
				_renderPressed();
			} else {
				_renderUnpressed();
			}
			
			if(pFireEvent) _dispatch(STATE_CHANGED_AFTER);
		}
		
		public function toggleOn(pFireEvent:Boolean=true) : void {
			toggle(true, pFireEvent);
		}

		public function toggleOff(pFireEvent:Boolean=false) : void {
			toggle(false, pFireEvent);
		}
		
		override protected function _onMouseUp(pEvent:MouseEvent) : void {
			if(!_flagEnabled || (!this.allowToggleOff && this.pushed)) { return; }
			toggle();
			super._onMouseUp(pEvent);
		}
		
		override protected function _renderUp() : void {
			if (this.pushed == false) {
				super._renderUp();
			}
		}
		
		override protected function _renderDown() : void {
			if (this.pushed == false) {
				if(this.Text) this.Text.color = 0xC2C2DA;
				super._renderDown();
			}
		}
		
		override protected function _renderOver() : void {
			if (this.pushed == false) {
				if(this.Text) this.Text.color = 0x012345;
				super._renderOver();
			}
		}
		
		override protected function _renderOut() : void {
			if(this.pushed == false) {
				if(this.Text) this.Text.color = 0xC2C2DA;
				super._renderOut();
			}
		}
	}
}
