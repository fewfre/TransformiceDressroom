package app.ui
{
	import com.fewfre.display.*;
	import com.fewfre.utils.*;
	import com.adobe.images.*;
	import app.data.*;
	import app.ui.buttons.*;
	import app.ui.common.*;
	import app.world.data.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.text.*;
	import app.data.ConstantsApp;
	import app.data.ITEM;
	
	public class ShopInfoBar extends MovieClip
	{
		// Storage
		public var Width				: Number;
		public var data					: ItemData;
		
		private var _leftButtonsTray	: Sprite;
		private var _gridManagmentTray	: Sprite;
		
		public var Image				: MovieClip;
		private var _imageCont			: RoundedRectangle;
		public var removeItemOverlay	: Sprite;
		
		public var Text					: TextBase;
		public var colorWheel			: ScaleButton;
		public var eyeDropButton		: SpriteButton;
		
		public var downloadButton		: SpriteButton;
		
		public var randomizeButton		: SpriteButton;
		public var randomizeLockButton	: PushButton;
		public var reverseButton		: SpriteButton;
		public var leftItemButton		: SpriteButton;
		public var rightItemButton		: SpriteButton;
		
		private static const BTN_SIZE : int = 24;
		private static const BTN_Y : int = 26;
		
		// Properties
		public function get hasData() : Boolean { return data != null; }
		public function get isRefreshLocked() : Boolean { return randomizeLockButton.pushed; }
		
		// Constructor
		// pData = { ?showBackButton:Boolean = false, ?showGridManagementButtons:Boolean = false }
		public function ShopInfoBar(pData:Object=null) {
			super();
			pData = pData==null ? {} : pData;
			this.Width = ConstantsApp.PANE_WIDTH;
			data = null;
			
			/********************
			* Active Item
			*********************/
			_imageCont = addChild(new RoundedRectangle({ x:0, y:0, width:50, height:50 })) as RoundedRectangle;
			_imageCont.draw(0x6A7495, 15, 0x5d7d90, 0x11171c, 0x3c5064);
			
			_setNoItemImage();
			
			// Overlay that shows up when hovering over image
			removeItemOverlay = addChild(new Sprite()) as Sprite;
			removeItemOverlay.graphics.beginFill(0, 0);
			removeItemOverlay.graphics.drawRoundRect(0, 0, _imageCont.Width, _imageCont.Height, 15, 15);
			removeItemOverlay.graphics.endFill();
			
			var rioVisual:Sprite = removeItemOverlay.addChild(new Sprite()) as Sprite;
			rioVisual.x = rioVisual.y = _imageCont.Width*0.5;
			rioVisual.alpha = 0;
			
			var rioBackdrop:RoundedRectangle = rioVisual.addChild(new RoundedRectangle({ origin:0.5, width:50, height:50 })) as RoundedRectangle;
			rioBackdrop.draw(0x000000, 15, 0x000000);
			rioBackdrop.alpha = 0.1;
			
			var rioIcon:DisplayObject = rioVisual.addChild(new $No());
			rioIcon.alpha = 0.5;
			rioIcon.scaleX = rioIcon.scaleY = 0.75;
			
			removeItemOverlay.addEventListener(MouseEvent.MOUSE_OVER, function():void{
				if(hasData && GameAssets.skins[GameAssets.defaultSkinIndex] != data && GameAssets.poses[GameAssets.defaultPoseIndex]) {
					rioVisual.alpha = 1;
				}
			});
			removeItemOverlay.addEventListener(MouseEvent.MOUSE_OUT, function():void{ rioVisual.alpha = 0; });
			removeItemOverlay.addEventListener(MouseEvent.CLICK, function():void{ rioVisual.alpha = 0; });
			
			/********************
			* Color Wheel
			*********************/
			this.colorWheel = addChild(new ScaleButton({ x:80, y:24, obj:pData.showBackButton ? new $BackArrow() : new $ColorWheel() })) as ScaleButton;
			this.colorWheel.x = _imageCont.x + _imageCont.Width + this.colorWheel.Image.width*0.5 + 10;
			this.colorWheel.y = 25;
			// Add event listener in Main
			
			// setup left tray
			_leftButtonsTray = addChild(new Sprite()) as Sprite;
			showColorWheel(pData.showBackButton);
			
			/********************
			* Text
			*********************/
			this.Text = _leftButtonsTray.addChild(new TextBase({ text:"infobar_id", x:0, y:0, size:18, origin:0, alpha:0 })) as TextBase;
			if(pData.showBackButton) {
				this.Text.y = 13;
			}
			
			/********************
			* Image Buttons
			*********************/
			if(pData.showEyeDropButton) {
				eyeDropButton = _leftButtonsTray.addChild(new SpriteButton({ x:0, y:BTN_Y, width:BTN_SIZE, height:BTN_SIZE, obj_scale:0.45, obj:new $EyeDropper() })) as SpriteButton;
				eyeDropButton.disable().alpha = 0;
			}
			
			/********************
			* Grid Management Buttons
			*********************/
			if(pData.showGridManagementButtons) {
				var tX = 0, spacing = 2;
				
				var tray:Sprite = _gridManagmentTray = addChild(new Sprite()) as Sprite;
				tray.x = this.Width*0.5-20;
				
				// Randomization buttons
				randomizeButton = tray.addChild(new SpriteButton({ x:tX, y:BTN_Y, width:BTN_SIZE, height:BTN_SIZE, obj_scale:0.8, obj:new $Dice() })) as SpriteButton;
				tX += BTN_SIZE + spacing;
				
				randomizeLockButton = tray.addChild(new PushButton({ x:tX, y:BTN_Y, width:BTN_SIZE, height:BTN_SIZE, obj_scale:0.8, obj:new $Lock() })) as PushButton;
				randomizeLockButton.addEventListener(PushButton.STATE_CHANGED_AFTER, function():void{ isRefreshLocked ? randomizeButton.disable() : randomizeButton.enable(); });
				tX += BTN_SIZE + spacing;
				
				tX += 8; // Add larger gap
				
				// List reversal button
				reverseButton = tray.addChild(new SpriteButton({ x:tX, y:BTN_Y, width:BTN_SIZE, height:BTN_SIZE, obj_scale:0.7, obj:new $FlipIcon() })) as SpriteButton;
				tX += BTN_SIZE + spacing;
				
				tX += 8; // Add larger gap
				
				// Arrow buttons
				leftItemButton = tray.addChild(new SpriteButton({ x:tX, y:BTN_Y, width:BTN_SIZE, height:BTN_SIZE, obj_scale:0.45, obj:new $BackArrow() })) as SpriteButton;
				tX += BTN_SIZE + spacing;
				rightItemButton = tray.addChild(new SpriteButton({ x:tX, y:BTN_Y, width:BTN_SIZE, height:BTN_SIZE, obj_scale:0.45, obj:new $BackArrow() })) as SpriteButton;
				rightItemButton.Image.rotation = 180;
				tX += BTN_SIZE + spacing;
			}
			
			/********************
			* Right Side Buttons
			*********************/
			downloadButton = addChild(new SpriteButton({ x:this.Width-BTN_SIZE, y:BTN_Y, width:BTN_SIZE, height:BTN_SIZE, obj_scale:0.45, obj:new $SimpleDownload() })) as SpriteButton;
			downloadButton.addEventListener(ButtonBase.CLICK, saveSprite);
			downloadButton.disable().alpha = 0;
			
			// Line seperating infobar and contents below it.
			addChild( GameAssets.createHorizontalRule(5, 53, this.Width-10) );
		}

		public function ChangeImage(pMC:MovieClip) : void
		{
			if(this.Image != null) { _imageCont.removeChild(this.Image); }
			
			var tBounds:Rectangle = pMC.getBounds(pMC);
			var tOffset:Point = tBounds.topLeft;
			
			// Make sure it's always big enough before being fit to have to be scaled down (to avoid extra whitespace)
			pMC.scaleX *= 2; pMC.scaleY *= 2;
			this.Image = pMC;
			FewfDisplayUtils.fitWithinBounds(this.Image, _imageCont.Width, _imageCont.Height, _imageCont.Width * 0.5, _imageCont.Height * 0.5);
			this.Image.mouseEnabled = false;
			this.Image.scaleX *= 0.8;
			this.Image.scaleY *= 0.8;
			this.Image.x = _imageCont.Width / 2 - (tBounds.width / 2 + tOffset.x) * this.Image.scaleX;
			this.Image.y = _imageCont.Height / 2 - (tBounds.height / 2 + tOffset.y) * this.Image.scaleY;
			_imageCont.addChild(this.Image);
		}
		
		public function showColorWheel(pVal:Boolean=true) : void {
			if(pVal) {
				colorWheel.enable().alpha = 1;
				_leftButtonsTray.x = colorWheel.x + colorWheel.Image.width*0.5 + 12;
			} else {
				colorWheel.disable().alpha = 0;
				_leftButtonsTray.x = _imageCont.x + _imageCont.Width + 10;
			}
		}
		
		public function hideImageCont() : void {
			_imageCont.visible = false;
			removeItemOverlay.visible = false;
			colorWheel.x = colorWheel.Image.width*0.5 + 10;
			if(_gridManagmentTray) _gridManagmentTray.x = this.Width*0.5-(25*5 + 3*4 + 8*2)*0.5; // Center tray
		}
		
		private function _updateID() : void {
			var tText:String = data.id;
			if(data.type == ItemType.POSE) {
				tText = Fewf.i18n.getText(("pose_"+data.id).toLowerCase());
				if(tText == null) { tText = data.id; }
			}
			this.Text.setValues(tText);
		}
		
		public function addInfo(pData:ItemData, pMC:MovieClip) : void {
			if(pData == null) { return; }
			data = pData;
			if(data.type == ItemType.POSE || data.type == ItemType.SKIN) {
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
			_setNoItemImage();
			
			Text.alpha = 0;
			showColorWheel(false);
			downloadButton.disable().alpha = 0;
			if(eyeDropButton) eyeDropButton.disable().alpha = 0;
		}
		
		public function unlockRandomizeButton() : void {
			if(randomizeLockButton) randomizeLockButton.toggleOff(true);
		}
		
		private function _setNoItemImage() :void {
			ChangeImage(new $NoItem());
			this.Image.scaleX = this.Image.scaleY = 0.75;
		}
		
		internal function saveSprite(pEvent:Event) : void {
			if(!data) { return; }
			var tName:String = "shop-"+data.type+data.id;
			var tScale:int = ConstantsApp.ITEM_SAVE_SCALE;
			if(data.type == ItemType.CONTACTS) { tScale *= 2; }
			FewfDisplayUtils.saveAsPNG(GameAssets.getColoredItemImage(data), tName, tScale);
		}
	}
}
