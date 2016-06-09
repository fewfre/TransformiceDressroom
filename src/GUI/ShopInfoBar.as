package GUI
{
	import com.adobe.images.*;
	import flash.display.*;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.text.*;
	
	public class ShopInfoBar extends MovieClip
	{
		// Storage
		public var Width			: Number;
		public var data				: ShopItemData;
		
		public var Image			: MovieClip;
		public var imageCont		: GUI.RoundedRectangle;
		public var colorWheel		: GUI.ScaleButton;
		public var Text				: flash.text.TextField;
		public var downloadButton	: SpriteButton;
		
		public var colorWheelEnabled: Boolean = true;
		
		public function get hasData() : Boolean { return data != null; }
		public function get colorWheelActive() : Boolean { return colorWheel.alpha != 0; }
		public function set colorWheelActive(pVal:Boolean) { colorWheelEnabled = pVal; colorWheel.alpha = pVal ? 1 : 0; }
		
		// Constructor
		public function ShopInfoBar(pParams:Object=null) {
			super();
			pParams = pParams==null ? {} : pParams;
			this.Width = ConstantsApp.PANE_WIDTH;
			data = null;
			
			imageCont = new GUI.RoundedRectangle(0, 0, 50, 50);
			imageCont.draw(0x6A7495, 15, 0x5d7d90, 0x11171c, 0x3c5064);
			addChild( imageCont );
			
			ChangeImage( new $NoItem() );
			
			this.colorWheel = new GUI.ScaleButton(80, 24, pParams.showBackButton ? new $BackArrow() : new $ColorWheel());
			this.colorWheel.x = 80;
			this.colorWheel.y = 24;
			addChild(this.colorWheel);
			this.colorWheel.alpha = 0;
			// Add event listener in Main
			
			this.Text = new flash.text.TextField();
			this.Text.x = 115;
			this.Text.y = 13;
			this.Text.defaultTextFormat = new flash.text.TextFormat("Verdana", 18, 0xc2c2da);
			this.Text.autoSize = flash.text.TextFieldAutoSize.LEFT;
			this.Text.text = "ID: ";
			this.Text.alpha = 0;
			addChild(this.Text);
			
			downloadButton = new SpriteButton(this.Width - 50, 0, 50, 50, new $SimpleDownload(), 1);
			//downloadButton.x = this.Width - 50;
			//downloadButton.y = 12;
			//downloadButton.addChild( new $SimpleDownload() );
			addChild(downloadButton);
			downloadButton.addEventListener(flash.events.MouseEvent.MOUSE_UP, saveSprite);
			downloadButton.alpha = 0;
			
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
			this.Image.x = 50 / 2 - (tBounds.width / 2 + tOffset.x)* 0.75;
			this.Image.y = 50 / 2 - (tBounds.height / 2 + tOffset.y)* 0.75;
			this.Image.scaleX = 0.75;
			this.Image.scaleY = 0.75;
			imageCont.addChild(this.Image);
		}
		
		private function _updateID() : void {
			this.Text.text = "ID: "+data.id;
		}
		
		public function addInfo(pData:ShopItemData, pMC:MovieClip) : void {
			if(pData == null) { return; }
			data = pData;
			ChangeImage(pMC);
			_updateID();
			
			colorWheelActive = colorWheelEnabled;
			Text.alpha = 1;
			downloadButton.alpha = 1;
		}
		
		public function removeInfo() : void {
			data = null;
			ChangeImage(new $NoItem());
			
			colorWheel.alpha = 0;
			Text.alpha = 0;
			this.Text.text = "ID: ";
			downloadButton.alpha = 0;
		}
		
		internal function saveSprite(pEvent:flash.events.Event) : void
		{
			if(hasData == false) { return; }
			var pElem:MovieClip = ( data.type==ItemType.FUR||data.type==ItemType.COLOR ? new Fur(data as FurData) : Main.costumes.copyColor(Image, new data.itemClass()) );
			pName = "shop-"+data.type+data.id+".png";
			
			var tRect:flash.geom.Rectangle = pElem.getBounds(pElem);
			var tBitmap:flash.display.BitmapData = new flash.display.BitmapData(pElem.width*ConstantsApp.ITEM_SAVE_SCALE, pElem.height*ConstantsApp.ITEM_SAVE_SCALE, true, 16777215);
			var tMatrix:flash.geom.Matrix = new flash.geom.Matrix(1, 0, 0, 1, -tRect.left, -tRect.top);
			tMatrix.scale(ConstantsApp.ITEM_SAVE_SCALE, ConstantsApp.ITEM_SAVE_SCALE);
			tBitmap.draw(pElem, tMatrix);
			( new flash.net.FileReference() ).save( com.adobe.images.PNGEncoder.encode(tBitmap), pName );
		}
	}
}