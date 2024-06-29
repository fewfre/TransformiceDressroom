package app.ui.buttons
{
	import app.ui.*;
	import com.fewfre.display.ButtonBase;
	import com.fewfre.display.TextTranslated;
	import com.fewfre.utils.FewfDisplayUtils;
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.*;
	
	public class SpriteButton extends GameButton
	{
		// Storage
		public var id:int;
		public var Image:flash.display.DisplayObject;
		public var Text:TextTranslated;
		
		// Constructor
		// pData = { x:Number, y:Number, (width:Number, height:Number OR size:Number), ?obj:DisplayObject, ?obj_scale:Number, ?id:int, ?text:String, ?origin:Number, ?originX:Number, ?originY:Number }
		public function SpriteButton(pData:Object)
		{
			super(pData);
			if(pData.id) { id = pData.id; }
			
			if(pData.obj) {
				if(pData.obj_scale == "auto") {
					ChangeImageScaleToFit(pData.obj);
				} else {
					ChangeImage(pData.obj);
					if(pData.obj_scale) {
						this.Image.scaleX = pData.obj_scale ? pData.obj_scale : 0.75;
						this.Image.scaleY = pData.obj_scale ? pData.obj_scale : 0.75;
					}
				}
			}
			
			if(pData.text) {
				this.Text = new TextTranslated(pData.text, { size:11, x:this.Width * (0.5 - _bg.originX) - 2, y:this.Height * (0.5 - _bg.originY) - 2 }).appendToT(this);
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

		public function ChangeImageScaleToFit(pMC:DisplayObject, pScale:Number=-1) : void
		{
			if(this.Image != null) { removeChild(this.Image); }
			pScale = pScale >= 0 ? pScale : 1;
			
			var tBounds:Rectangle = pMC.getBounds(pMC);
			var tOffset:Point = tBounds.topLeft;
			
			FewfDisplayUtils.fitWithinBounds(pMC, this.Width * 0.9, this.Height * 0.9, this.Width * 0.5, this.Height * 0.5);
			pMC.x = this.Width * (0.5 - _bg.originX) - (tBounds.width / 2 + tOffset.x)*pScale * pMC.scaleX;
			pMC.y = this.Height * (0.5 - _bg.originY) - (tBounds.height / 2 + tOffset.y)*pScale * pMC.scaleY;
			pMC.scaleX *= pScale;
			pMC.scaleY *= pScale;
			addChild(this.Image = pMC);
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
