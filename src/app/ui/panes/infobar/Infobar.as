package app.ui.panes.infobar
{
	import app.data.ConstantsApp;
	import app.data.GameAssets;
	import app.data.ItemType;
	import app.ui.buttons.ScaleButton;
	import app.ui.buttons.SpriteButton;
	import app.ui.common.RoundedRectangle;
	import app.ui.panes.infobar.GridManagementWidget;
	import app.world.data.ItemData;
	import com.fewfre.display.ButtonBase;
	import com.fewfre.display.TextTranslated;
	import com.fewfre.utils.Fewf;
	import com.fewfre.utils.FewfDisplayUtils;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import com.fewfre.events.FewfEvent;

	public class Infobar extends Sprite
	{
		// Constants
		public static const BACK_CLICKED          : String = "back_clicked";
		public static const ITEM_PREVIEW_CLICKED  : String = "item_preview_clicked";
		public static const COLOR_WHEEL_CLICKED   : String = "color_wheel_clicked";
		public static const EYE_DROPPER_CLICKED   : String = "eye_dropper_clicked";
		
		// Storage
		public var Width                 : Number;
		public var _itemData             : ItemData;
		
		
		public var Image                 : MovieClip;
		private var _imageCont           : RoundedRectangle;
		private var _removeItemOverlay   : Sprite;
		
		private var _backButton          : ScaleButton;
		private var _colorWheel          : ScaleButton;
		private var _leftButtonsTray     : Sprite;
		private var _idText              : TextTranslated;
		private var _eyeDropperButton    : SpriteButton;
		
		private var _downloadButton      : SpriteButton;
		
		public var _gridManagementWidget : GridManagementWidget;
		
		private static const BTN_SIZE : int = 24;
		private static const BTN_Y : int = 26;
		
		// Properties
		public function get hasData() : Boolean { return _itemData != null; }
		public function get itemData() : ItemData { return _itemData; }
		public function get isRefreshLocked() : Boolean { return !!_gridManagementWidget && _gridManagementWidget.isRefreshLocked; }
		public function get colorWheelEnabled() : Boolean { return !!_colorWheel && _colorWheel.enabled; }
		
		// Constructor
		// pData = { ?showBackButton:bool=false, ?hideItemPreview:bool=false, ?showEyeDropper:bool=false,
		//           ?gridManagement:(bool|{})=false }
		public function Infobar(pData:Object=null) {
			super();
			pData = pData || {};
			this.Width = ConstantsApp.PANE_WIDTH;
			
			/********************
			* Active Item
			*********************/
			_imageCont = new RoundedRectangle(50, 50).appendTo(this)
				.draw(ConstantsApp.APP_BG_COLOR, 15, 0x5d7d90, 0x11171c, 0x3c5064);
			
			_setNoItemImage();
			
			// Overlay that shows up when hovering over image
			_removeItemOverlay = addChild(new Sprite()) as Sprite;
			_removeItemOverlay.graphics.beginFill(0, 0);
			_removeItemOverlay.graphics.drawRoundRect(0, 0, _imageCont.Width, _imageCont.Height, 15, 15);
			_removeItemOverlay.graphics.endFill();
			_removeItemOverlay.buttonMode = true;
			_removeItemOverlay.useHandCursor = true;
			
			var rioVisual:Sprite = _removeItemOverlay.addChild(new Sprite()) as Sprite;
			rioVisual.x = rioVisual.y = _imageCont.Width*0.5;
			rioVisual.alpha = 0;
			
			var rioBackdrop:RoundedRectangle = new RoundedRectangle(50, 50, { origin:0.5 }).appendTo(rioVisual);
			rioBackdrop.draw(0x000000, 15, 0x000000);
			rioBackdrop.alpha = 0.1;
			
			var rioIcon:DisplayObject = rioVisual.addChild(new $No());
			rioIcon.alpha = 0.5;
			rioIcon.scaleX = rioIcon.scaleY = 0.75;
			
			_removeItemOverlay.addEventListener(MouseEvent.MOUSE_OVER, function():void{
				if(hasData && !GameAssets.defaultSkin.matches(_itemData) && GameAssets.defaultPose.matches(_itemData)) {
					rioVisual.alpha = 1;
				}
			});
			_removeItemOverlay.addEventListener(MouseEvent.MOUSE_OUT, function():void{ rioVisual.alpha = 0; });
			_removeItemOverlay.addEventListener(MouseEvent.CLICK, function():void{ rioVisual.alpha = 0;
				dispatchEvent(new Event(ITEM_PREVIEW_CLICKED));
			});
			
			/********************
			* Color Wheel / Back Button
			*********************/
			// setup left tray - need to defined before color wheel show/hide since the function moves it
			_leftButtonsTray = addChild(new Sprite()) as Sprite;
			
			if(!pData.showBackButton) {
				_colorWheel = new ScaleButton({ x:80, y:24, obj:new $ColorWheel() }).appendTo(this) as ScaleButton;
				_colorWheel.setXY(_imageCont.x + _imageCont.Width + _colorWheel.Image.width*0.5 + 10, 25)
					.on(ButtonBase.CLICK, function(e):void{ dispatchEvent(new Event(COLOR_WHEEL_CLICKED)); });
				showColorWheel(false);
			} else {
				_backButton = new ScaleButton({ x:80, y:24, obj:new $BackArrow() }).appendTo(this) as ScaleButton;
				_backButton.setXY(_imageCont.x + _imageCont.Width + _backButton.Image.width*0.5 + 10, 25)
					.on(MouseEvent.MOUSE_UP, function(e):void{ dispatchEvent(new Event(BACK_CLICKED)); });
				_rearrangeLeftButtonsTray();
			}
			
			/********************
			* Text
			*********************/
			_idText = new TextTranslated("infobar_id", { x:0, y:0, size:18, origin:0, alpha:0 }).appendToT(_leftButtonsTray);
			if(pData.showBackButton) {
				_idText.y = 13;
			}
			
			/********************
			* Image Buttons
			*********************/
			if(pData.showEyeDropper) {
				_eyeDropperButton = new SpriteButton({ width:BTN_SIZE, height:BTN_SIZE, obj_scale:0.45, obj:new $EyeDropper() })
					.setXY(0, BTN_Y).appendTo(_leftButtonsTray) as SpriteButton;
				_eyeDropperButton.on(ButtonBase.CLICK, function(e):void{ dispatchEvent(new Event(EYE_DROPPER_CLICKED)); })
				_eyeDropperButton.disable().alpha = 0;
			}
			
			/********************
			* Grid Management Buttons
			*********************/
			if(pData.gridManagement) {
				var widgetProps:Object = pData.gridManagement is Boolean ? {} : pData.gridManagement; // If a boolean ("true") use defaults
				_gridManagementWidget = new GridManagementWidget(widgetProps).setXY(this.Width*0.5-20+(144/2), BTN_Y).appendTo(this);
				_gridManagementWidget.on(GridManagementWidget.RANDOMIZE_CLICKED, function(e):void{ dispatchEvent(e); })
				_gridManagementWidget.on(GridManagementWidget.REVERSE_CLICKED, function(e):void{ dispatchEvent(e); })
				_gridManagementWidget.on(GridManagementWidget.LEFT_ARROW_CLICKED, function(e):void{ dispatchEvent(e); })
				_gridManagementWidget.on(GridManagementWidget.RIGHT_ARROW_CLICKED, function(e):void{ dispatchEvent(e); });
				FewfDisplayUtils.alignChildrenAroundAnchor(_gridManagementWidget, 0.5, null);
			}
			
			/********************
			* Right Side Buttons
			*********************/
			_downloadButton = new SpriteButton({ x:this.Width-BTN_SIZE, y:BTN_Y, width:BTN_SIZE, height:BTN_SIZE, obj_scale:0.45, obj:new $SimpleDownload() }).appendTo(this) as SpriteButton;
			_downloadButton.addEventListener(ButtonBase.CLICK, _onDownloadClicked);
			_downloadButton.disable().alpha = 0;
			
			// Line seperating infobar and contents below it.
			addChild( GameAssets.createHorizontalRule(5, 53, this.Width-10) );
			
			if(pData.hideItemPreview) {
				hideImageCont();
			}
		}
		public function setXY(pX:Number, pY:Number) : Infobar { x = pX; y = pY; return this; }
		public function appendTo(target:Sprite): Infobar { target.addChild(this); return this; }
		public function on(type:String, listener:Function): Infobar { this.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): Infobar { this.removeEventListener(type, listener); return this; }

		public function ChangeImage(pMC:MovieClip) : void {
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
		
		public function showColorWheel(pShow:Boolean=true) : void {
			_colorWheel.enableToggle(pShow).alpha = pShow ? 1 : 0;
			_colorWheel.visible = pShow;
			_rearrangeLeftButtonsTray();
		}
		
		public function _rearrangeLeftButtonsTray() : void {
			var btn:ScaleButton = _colorWheel || _backButton;
			if(btn.visible && btn.alpha > 0) {
				_leftButtonsTray.x = btn.x + btn.Image.width*0.5 + 12;
			} else {
				_leftButtonsTray.x = _imageCont.x + _imageCont.Width + 10;
			}
		}
		
		public function hideImageCont() : void {
			_imageCont.visible = false;
			_removeItemOverlay.visible = false;
			if(_colorWheel) _colorWheel.x = _colorWheel.Image.width*0.5 + 10;
			if(_backButton) _backButton.x = _backButton.Image.width*0.5 + 10;
			if(_gridManagementWidget) _gridManagementWidget.x = this.Width*0.5; // Center tray
		}
		
		private function _updateID() : void {
			var tText:String = _itemData.id;
			if(_itemData.type == ItemType.POSE) {
				tText = Fewf.i18n.getText(("pose_"+_itemData.id).toLowerCase(), true);
				if(tText == null) { tText = _itemData.id; }
			}
			_idText.setValues(tText);
		}
		
		public function addInfo(pData:ItemData, pMC:MovieClip) : void {
			if(pData == null) { return; }
			_itemData = pData;
			if(_itemData.type == ItemType.POSE || _itemData.type == ItemType.SKIN) {
				pMC.scaleX = pMC.scaleY = 1;
			}
			ChangeImage(pMC);
			_updateID();
			
			_idText.alpha = 1;
			_downloadButton.enable().alpha = 1;
			if(_eyeDropperButton) _eyeDropperButton.enable().alpha = 1;
		}
		
		public function removeInfo() : void {
			_itemData = null;
			_setNoItemImage();
			
			_idText.alpha = 0;
			showColorWheel(false);
			_downloadButton.disable().alpha = 0;
			if(_eyeDropperButton) _eyeDropperButton.disable().alpha = 0;
		}
		
		public function unlockRandomizeButton() : void {
			if(_gridManagementWidget) _gridManagementWidget.unlockRandomizeButton();
		}
		
		private function _setNoItemImage() :void {
			ChangeImage(new $NoItem());
			this.Image.scaleX = this.Image.scaleY = 0.75;
		}
		
		private function _onDownloadClicked(e:Event) : void {
			if(!_itemData) { return; }
			Fewf.dispatcher.dispatchEvent(new FewfEvent(ConstantsApp.DOWNLOAD_ITEM_DATA_IMAGE, _itemData));
		}
	}
}
