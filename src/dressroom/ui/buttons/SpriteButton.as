package dressroom.ui.buttons
{
	import com.fewfre.display.ButtonBase;
	import dressroom.ui.*;
	import flash.display.*;
	import flash.text.*;
	import flash.events.MouseEvent;
	
	public class SpriteButton extends GameButton
	{
		// Storage
		public var id:int;
		public var Image:flash.display.DisplayObject;
		public var Text:flash.text.TextField;
		
		// Constructor
		// pData = { x:Number, y:Number, width:Number, height:Number, ?obj:DisplayObject, ?obj_scale:Number, ?id:int, ?text:String }
		public function SpriteButton(pData:Object)
		{
			super(pData);
			if(pData.id) { id = pData.id; }
			
			if(pData.obj) {
				ChangeImage(pData.obj);
				if(pData.obj_scale) {
					this.Image.scaleX = pData.obj_scale ? pData.obj_scale : 0.75;
					this.Image.scaleY = pData.obj_scale ? pData.obj_scale : 0.75;
				}
			}
			
			if(pData.text) {
				this.Text = new flash.text.TextField();
				this.Text.defaultTextFormat = new flash.text.TextFormat("Verdana", 11, 0xC2C2DA);
				this.Text.autoSize = flash.text.TextFieldAutoSize.CENTER;
				this.Text.text = pData.text;
				this.Text.x = (this.Width - this.Text.textWidth) * 0.5 - 2;
				this.Text.y = (this.Height - this.Text.textHeight) * 0.5 - 2;
				addChild(this.Text);
			}
		}

		public function ChangeImage(pMC:DisplayObject) : void
		{
			var tScale:Number = 1;
			if(this.Image != null) { tScale = this.Image.scaleX; removeChild(this.Image); }
			this.Image = addChild( pMC );
			this.Image.x = this.Width * 0.5;
			this.Image.y = this.Height * 0.5;
			this.Image.scaleX = this.Image.scaleY = tScale;
		}
		
		override protected function _renderDown() : void {
			if(this.Text) this.Text.textColor = 0xC2C2DA;
			super._renderDown();
		}
		
		override protected function _renderOver() : void {
			if(this.Text) this.Text.textColor = 0x012345;
			super._renderOver();
		}
		
		override protected function _renderOut() : void {
			if(this.Text) this.Text.textColor = 0xC2C2DA;
			super._renderOut();
		}
	}
}
