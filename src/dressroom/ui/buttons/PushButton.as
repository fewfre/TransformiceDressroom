package dressroom.ui.buttons
{
	import com.fewfre.display.ButtonBase;
	import dressroom.data.*;
	import dressroom.ui.*;
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
		public var Text:flash.text.TextField;
		public var Image:flash.display.DisplayObject;
		
		// Constructor
		// pData = { x:Number, y:Number, width:Number, height:Number, ?obj:DisplayObject, ?obj_scale:Number, ?text:String, ?id:int, ?allowToggleOff:Boolean=true }
		public function PushButton(pData:Object)
		{
			super(pData);
			if(pData.id) { id = pData.id; }
			
			if(pData.text) {
				this.Text = new flash.text.TextField();
				this.Text.defaultTextFormat = new flash.text.TextFormat("Verdana", 11, 0xC2C2DA);
				this.Text.autoSize = flash.text.TextFieldAutoSize.CENTER;
				this.Text.text = pData.text;
				this.Text.x = (this.Width - this.Text.textWidth) / 2 - 2;
				this.Text.y = (this.Height - this.Text.textHeight) / 2 - 2;
				addChild(this.Text);
			}
			
			if(pData.obj) {
				var tBounds:Rectangle = pData.obj.getBounds(pData.obj);
				var tOffset:Point = tBounds.topLeft;
				
				var tScale:Number = pData.obj_scale ? pData.obj_scale : 1;
				this.Image = pData.obj;
				this.Image.x = pData.width / 2 - (tBounds.width / 2 + tOffset.x)*tScale * this.Image.scaleX;
				this.Image.y = pData.height / 2 - (tBounds.height / 2 + tOffset.y)*tScale * this.Image.scaleY;
				this.Image.scaleX *= tScale;
				this.Image.scaleY *= tScale;
				addChild(this.Image);
			}
			
			this.allowToggleOff = pData.allowToggleOff == null ? true : pData.allowToggleOffs;
			this.pushed = false;
			_renderUnpressed();
		}
		
		protected function _renderUnpressed() : void
		{
			super._renderUp();
			if(this.Text) { this.Text.textColor = 0xC2C2DA; }
		}

		protected function _renderPressed() : void
		{
			_bg.draw(ConstantsApp.COLOR_BUTTON_MOUSE_DOWN, 7, 0x5D7A91, 0x5D7A91, 0x6C8DA8);
			if(this.Text) { this.Text.textColor = 0xFFD800; }
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
				if(this.Text) this.Text.textColor = 0xC2C2DA;
				super._renderDown();
			}
		}
		
		override protected function _renderOver() : void {
			if (this.pushed == false) {
				if(this.Text) this.Text.textColor = 0x012345;
				super._renderOver();
			}
		}
		
		override protected function _renderOut() : void {
			if(this.pushed == false) {
				if(this.Text) this.Text.textColor = 0xC2C2DA;
				super._renderOut();
			}
		}
	}
}
