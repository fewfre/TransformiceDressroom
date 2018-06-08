package app.ui
{
	import com.fewfre.display.*;
	import com.fewfre.utils.*;
	import com.adobe.images.*;
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import app.world.data.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.text.*;
	
	public class ShopInfoBar extends MovieClip
	{
		// Storage
		public var Width			: Number;
		public var data				: ItemData;
		
		public var Image			: MovieClip;
		public var imageCont		: RoundedRectangle;
		
		public var Text				: TextBase;
		public var colorWheel		: ScaleButton;
		public var downloadButton	: SpriteButton;
		public var refreshButton	: SpriteButton;
		public var refreshLockButton: PushButton;
		public var eyeDropButton	: SpriteButton;
		
		// Properties
		public function get hasData() : Boolean { return data != null; }
		public function get isRefreshLocked() : Boolean { return refreshLockButton.pushed; }
		
		// Constructor
		// pData = { ?showBackButton:Boolean = false, ?showRefreshButton:Boolean = true }
		public function ShopInfoBar(pData:Object=null) {
			super();
			pData = pData==null ? {} : pData;
			this.Width = ConstantsApp.PANE_WIDTH;
			data = null;
			
			imageCont = addChild(new RoundedRectangle({ x:0, y:0, width:50, height:50 })) as RoundedRectangle;
			imageCont.draw(0x6A7495, 15, 0x5d7d90, 0x11171c, 0x3c5064);
			
			ChangeImage( new $NoItem() );
			
			this.colorWheel = addChild(new ScaleButton({ x:80, y:24, obj:pData.showBackButton ? new $BackArrow() : new $ColorWheel() })) as ScaleButton;
			this.colorWheel.x = 80;
			this.colorWheel.y = 24;
			// Add event listener in Main
			
			this.Text = addChild(new TextBase({ text:"infobar_id", x:115, y:13, size:18, origin:0, alpha:0 })) as TextBase;
			
			showColorWheel(pData.showBackButton);
			
			/********************
			* Right Side Buttons
			*********************/
			var tX = this.Width;
			if(pData.showRefreshButton == null || pData.showRefreshButton) {
				refreshButton = addChild(new SpriteButton({ x:tX - 24, y:0, width:24, height:24, obj_scale:0.5, obj:new $Refresh() })) as SpriteButton;
				refreshLockButton = addChild(new PushButton({ x:tX - 24, y:26, width:24, height:24, obj_scale:0.8, obj:new $Lock() })) as PushButton;
				tX -= refreshButton.Width + 2;
			}
			
			downloadButton = addChild(new SpriteButton({ x:tX - 25, y:0, width:24, height:24, obj_scale:0.45, obj:new $SimpleDownload() })) as SpriteButton;
			downloadButton.addEventListener(ButtonBase.CLICK, saveSprite);
			downloadButton.disable().alpha = 0;
			
			if(pData.showEyeDropButton) {
				eyeDropButton = addChild(new SpriteButton({ x:tX - 25, y:26, width:25, height:25, obj_scale:0.45, obj:new $EyeDropper() })) as SpriteButton;
				eyeDropButton.disable().alpha = 0;
			}
			
			// Line seperating infobar and contents below it.
			_drawLine(5, 53, this.Width);
		}
		
		private function _drawLine(pX:Number, pY:Number, pWidth:Number) : void {
			var tLine:Shape = new Shape();
			tLine.x = pX;
			tLine.y = pY;
			addChild(tLine);
			
			tLine.graphics.lineStyle(1, 0x11181c, 1, true);
			tLine.graphics.moveTo(0, 0);
			tLine.graphics.lineTo(pWidth - 10, 0);
			
			tLine.graphics.lineStyle(1, 0x608599, 1, true);
			tLine.graphics.moveTo(0, 1);
			tLine.graphics.lineTo(pWidth - 10, 1);
		}

		public function ChangeImage(pMC:MovieClip) : void
		{
			if(this.Image != null) { imageCont.removeChild(this.Image); }
			
			var tBounds:Rectangle = pMC.getBounds(pMC);
			var tOffset:Point = tBounds.topLeft;
			
			this.Image = pMC;
			FewfDisplayUtils.fitWithinBounds(this.Image, imageCont.Width, imageCont.Height, imageCont.Width * 0.5, imageCont.Height * 0.5);
			this.Image.mouseEnabled = false;
			this.Image.x = 50 / 2 - (tBounds.width / 2 + tOffset.x)* 0.75 * this.Image.scaleX;
			this.Image.y = 50 / 2 - (tBounds.height / 2 + tOffset.y)* 0.75 * this.Image.scaleY;
			this.Image.scaleX *= 0.75;
			this.Image.scaleY *= 0.75;
			imageCont.addChild(this.Image);
		}
		
		public function showColorWheel(pVal:Boolean=true) : void {
			if(pVal) {
				colorWheel.enable().alpha = 1;
				this.Text.x = 115;
			} else {
				colorWheel.disable().alpha = 0;
				this.Text.x = 65;
			}
		}
		
		private function _updateID() : void {
			var tText = data.id;
			if(data.type == ITEM.POSE) {
				tText = Fewf.i18n.getText(("pose_"+data.id).toLowerCase());
				if(tText == null) { tText = data.id; }
			}
			this.Text.setValues(tText);
		}
		
		public function addInfo(pData:ItemData, pMC:MovieClip) : void {
			if(pData == null) { return; }
			data = pData;
			if(data.type == ITEM.POSE || data.type == ITEM.SKIN) {
				pMC.scaleX = pMC.scaleY = 1;
			}
			ChangeImage(pMC);
			_updateID();
			
			Text.alpha = 1;
			downloadButton.enable().alpha = 1;
			if(eyeDropButton) eyeDropButton.enable().alpha = 1;
		}
		
		public function removeInfo() : void {
			data = null;
			ChangeImage(new $NoItem());
			
			Text.alpha = 0;
			showColorWheel(false);
			downloadButton.disable().alpha = 0;
			if(eyeDropButton) eyeDropButton.disable().alpha = 0;
		}
		
		internal function saveSprite(pEvent:Event) : void
		{
			if(!data) { return; }
			var tName = "shop-"+data.type+data.id;
			FewfDisplayUtils.saveAsPNG(GameAssets.getColoredItemImage(data), tName, ConstantsApp.ITEM_SAVE_SCALE);
		}
	}
}
