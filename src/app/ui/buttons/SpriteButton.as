package app.ui.buttons
{
	import com.fewfre.display.ButtonBase;
	import com.fewfre.display.TextBase;
	import app.ui.*;
	import flash.display.*;
	import flash.text.*;
	import flash.events.MouseEvent;
	
	public class SpriteButton extends GameButton
	{
		// Storage
		public var id:int;
		public var Image:flash.display.DisplayObject;
		public var Text:TextBase;
		
		// Constructor
		// pData = { x:Number, y:Number, (width:Number, height:Number OR size:Number), ?obj:DisplayObject, ?obj_scale:Number, ?id:int, ?text:String, ?origin:Number, ?originX:Number, ?originY:Number }
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
				this.Text = addChild(new TextBase({ text:pData.text, size:11, x:this.Width * (0.5 - _bg.originX) - 2, y:this.Height * (0.5 - _bg.originY) - 2 })) as TextBase;
			}
		}

		public function ChangeImage(pMC:DisplayObject) : void
		{
			var tScale:Number = 1;
			if(this.Image != null) { tScale = this.Image.scaleX; removeChild(this.Image); }
			this.Image = addChild( pMC );
			this.Image.x = this.Width * (0.5 - _bg.originX);
			this.Image.y = this.Height * (0.5 - _bg.originY);
			this.Image.scaleX = this.Image.scaleY = tScale;
		}
		
		override protected function _renderDown() : void {
			if(this.Text) this.Text.color = 0xC2C2DA;
			super._renderDown();
		}
		
		override protected function _renderOver() : void {
			if(this.Text) this.Text.color = 0x012345;
			super._renderOver();
		}
		
		override protected function _renderOut() : void {
			if(this.Text) this.Text.color = 0xC2C2DA;
			super._renderOut();
		}
	}
}
