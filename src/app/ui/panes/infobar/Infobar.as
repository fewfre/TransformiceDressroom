package app.ui.panes.infobar
{
	import app.data.ConstantsApp;
	import app.data.FavoriteItemsLocalStorageManager;
	import app.data.GameAssets;
	import app.data.ItemType;
	import app.ui.buttons.ScaleButton;
	import app.ui.buttons.GameButton;
	import app.ui.panes.infobar.GridManagementWidget;
	import app.world.data.ItemData;
	import app.world.events.ItemDataEvent;
	import com.fewfre.display.DisplayWrapper;
	import com.fewfre.display.RoundRectangle;
	import com.fewfre.display.TextTranslated;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.utils.Fewf;
	import com.fewfre.utils.FewfDisplayUtils;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Infobar extends Sprite
	{
		// Constants
		public static const BACK_CLICKED            : String = "back_clicked";
		public static const ITEM_PREVIEW_CLICKED    : String = "item_preview_clicked";
		public static const COLOR_WHEEL_CLICKED     : String = "color_wheel_clicked";
		public static const EYE_DROPPER_CLICKED     : String = "eye_dropper_clicked";
		public static const FAVORITE_CLICKED        : String = "favorite_clicked"; // FewfEvent<{ pushed:bool }>
		
		// Storage
		public var Width                 : Number;
		public var _itemData             : ItemData;
		
		
		public var Image                 : MovieClip;
		private var _imageCont           : RoundRectangle;
		private var _removeItemOverlay   : Sprite;
		
		private var _backButton          : ScaleButton;
		private var _colorWheel          : ScaleButton;
		private var _leftButtonsTray     : Sprite;
		private var _idText              : TextTranslated;
		private var _eyeDropperButton    : GameButton;
		private var _favoriteButton      : GameButton;
		
		private var _rightSideTray       : Sprite;
		private var _downloadButton      : GameButton;
		
		private var _gridManagementWidget : GridManagementWidget;
		
		private static const BTN_SIZE : int = 24;
		private static const BTN_Y : int = 25;
		
		// Properties
		public function get hasData() : Boolean { return _itemData != null; }
		public function get itemData() : ItemData { return _itemData; }
		public function get isRefreshLocked() : Boolean { return !!_gridManagementWidget && _gridManagementWidget.isRefreshLocked; }
		public function get colorWheelEnabled() : Boolean { return !!_colorWheel && _colorWheel.enabled; }
		
		// Constructor
		// pData = { ?showBackButton:bool=false, ?hideItemPreview:bool=false, ?showEyeDropper:bool=false,
		//           ?showFavorites:bool=false, ?showDownload:bool=false, ?gridManagement:(bool|{})=false }
		public function Infobar(pData:Object=null) {
			super();
			pData = pData || {};
			this.Width = ConstantsApp.PANE_WIDTH;
			
			/********************
			* Active Item
			*********************/
			// 0x5d7d90, 0x11171c, 0x3c5064
			_imageCont = RoundRectangle.square(50).toRadius(15).drawSolid(ConstantsApp.APP_BG_COLOR, 0x3c5064, 1.25).appendTo(this);
			
			_setNoItemImage();
			
			// Hitbox that detects mouse events over image - not visible
			_removeItemOverlay = addChild(new Sprite()) as Sprite;
			RoundRectangle.square(50).toAlpha(0).toRadius(15).drawSolid(0, 0).appendTo(_removeItemOverlay); // Only needed for a hitbox - has to be a child since alpha:0 messes up hover events unless it's a child element
			_removeItemOverlay.buttonMode = true;
			_removeItemOverlay.useHandCursor = true;
			
			// Contains what's actually shown on hover for _removeItemOverlay
			var rioVisual:Sprite = DisplayWrapper.wrap(new Sprite(), _removeItemOverlay)
				.toAlpha(0).move(_imageCont.width*0.5, _imageCont.height*0.5).asSprite;
			RoundRectangle.square(50).toOrigin(0.5).toAlpha(0.1).toRadius(15).drawSolid(0x000000, 0x000000, 1.25).appendTo(rioVisual);
			DisplayWrapper.wrap(new $No(), rioVisual).toAlpha(0.5).toScale(0.75);
			
			_removeItemOverlay.addEventListener(MouseEvent.MOUSE_OVER, function():void{
				if(hasData && !GameAssets.doesItemDataMatchDefaultOfTypeIfAny(_itemData)) {
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
				_colorWheel = new ScaleButton(new $ColorWheel()).appendTo(this) as ScaleButton;
				_colorWheel.move(_imageCont.x + _imageCont.width + _colorWheel.image.width*0.5 + 10, 25)
					.onButtonClick(dispatchEventHandler(COLOR_WHEEL_CLICKED));
				showColorWheel(false);
			} else {
				_backButton = new ScaleButton(new $BackArrow()).appendTo(this) as ScaleButton;
				_backButton.move(_imageCont.x + _imageCont.width + _backButton.image.width*0.5 + 10, 25)
					.on(MouseEvent.MOUSE_UP, dispatchEventHandler(BACK_CLICKED));
				_rearrangeLeftButtonsTray();
			}
			
			/********************
			* Text
			*********************/
			_idText = new TextTranslated("infobar_id", { x:0, y:-1, size:18, origin:0, alpha:0 }).appendToT(_leftButtonsTray);
			if(pData.showBackButton && (!pData.showEyeDropper && !pData.showFavorites && !pData.gridManagement)) {
				_idText.y = 13;
			}
			
			/********************
			* Image Buttons
			*********************/
			if(pData.showEyeDropper) {
				_eyeDropperButton = new GameButton(BTN_SIZE).setImage(new $EyeDropper(), 0.45).move(0, BTN_Y).appendTo(_leftButtonsTray) as GameButton;
				_eyeDropperButton.onButtonClick(dispatchEventHandler(EYE_DROPPER_CLICKED));
				_eyeDropperButton.disable().setAlpha(0);
			}
			if(pData.showFavorites) {
				(_favoriteButton = new GameButton(BTN_SIZE)).setImage(new $HeartEmpty(), 1).setData({ pushed:false });
				_favoriteButton.move(pData.showEyeDropper ? BTN_SIZE+3 : 0, BTN_Y).appendTo(_leftButtonsTray)
					.onButtonClick(function(e):void{
						_updateFavoriteButton(!_favoriteButton.data.pushed);
						dispatchEvent(new FewfEvent(FAVORITE_CLICKED, { pushed:_favoriteButton.data.pushed }));
					});
				_favoriteButton.disable().setAlpha(0);
				// This event handler is needed to update the button encase it's unfavorited from FavoritesPane while it's selected
				Fewf.dispatcher.addEventListener(ConstantsApp.FAVORITE_ADDED_OR_REMOVED, function(e:FewfEvent):void{
					if(!!_itemData && e.data.itemType == _itemData.type) {
						_updateFavoriteButton( FavoriteItemsLocalStorageManager.has(_itemData) );
					}
				});
			}
			
			/********************
			* Grid Management Buttons
			*********************/
			if(pData.gridManagement) {
				var widgetProps:Object = pData.gridManagement is Boolean ? {} : pData.gridManagement; // If a boolean ("true") use defaults
				_gridManagementWidget = new GridManagementWidget(widgetProps).move(this.Width*0.5-20+(144/2), BTN_Y).appendTo(this);
				_gridManagementWidget.on(GridManagementWidget.RANDOMIZE_CLICKED, function(e):void{ dispatchEvent(e); })
				_gridManagementWidget.on(GridManagementWidget.RANDOMIZE_LOCK_CLICKED, function(e):void{ dispatchEvent(e); })
				_gridManagementWidget.on(GridManagementWidget.REVERSE_CLICKED, function(e):void{ dispatchEvent(e); })
				_gridManagementWidget.on(GridManagementWidget.LEFT_ARROW_CLICKED, function(e):void{ dispatchEvent(e); })
				_gridManagementWidget.on(GridManagementWidget.RIGHT_ARROW_CLICKED, function(e):void{ dispatchEvent(e); });
				FewfDisplayUtils.alignChildrenAroundAnchor(_gridManagementWidget, 0.5, null);
			}
			
			/********************
			* Right Side Buttons
			*********************/
			_rightSideTray = DisplayWrapper.wrap(new Sprite(), this).move(this.Width, 0).asSprite;
			if(pData.showDownload) {
				(_downloadButton = new GameButton(BTN_SIZE)).setImage(new $SimpleDownload(), 0.45).move(-BTN_SIZE, BTN_Y).appendTo(_rightSideTray);
				_downloadButton.onButtonClick(_onDownloadClicked);
				_downloadButton.disable().setAlpha(0);
			}
			
			// Line seperating infobar and contents below it.
			GameAssets.createHorizontalRule(5, 53, this.Width-10).appendTo(this);
			
			if(pData.hideItemPreview) {
				hideImageCont();
			}
			
			_repositionGridManagementWidget();
		}
		public function move(pX:Number, pY:Number) : Infobar { x = pX; y = pY; return this; }
		public function appendTo(pParent:Sprite): Infobar { pParent.addChild(this); return this; }
		public function on(type:String, listener:Function): Infobar { this.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): Infobar { this.removeEventListener(type, listener); return this; }

		public function changeImage(pMC:MovieClip) : void {
			if(this.Image != null) { _imageCont.removeChild(this.Image); }
			
			var tBounds:Rectangle = pMC.getBounds(pMC);
			var tOffset:Point = tBounds.topLeft;
			
			// Make sure it's always big enough before being fit to have to be scaled down (to avoid extra whitespace)
			pMC.scaleX *= 2; pMC.scaleY *= 2;
			this.Image = pMC;
			FewfDisplayUtils.fitWithinBounds(this.Image, _imageCont.width, _imageCont.height, _imageCont.width * 0.5, _imageCont.height * 0.5);
			this.Image.mouseEnabled = false;
			this.Image.scaleX *= 0.8;
			this.Image.scaleY *= 0.8;
			this.Image.x = _imageCont.width / 2 - (tBounds.width / 2 + tOffset.x) * this.Image.scaleX;
			this.Image.y = _imageCont.height / 2 - (tBounds.height / 2 + tOffset.y) * this.Image.scaleY;
			_imageCont.addChild(this.Image);
		}
		
		public function showColorWheel(pShow:Boolean=true) : void {
			if(_colorWheel) {
				_colorWheel.toggleEnabled(pShow).setAlpha(pShow ? 1 : 0).setVisible(pShow);
			}
			_rearrangeLeftButtonsTray();
			_repositionGridManagementWidget();
		}
		
		public function addCustomObjectToRightSideTray(pObj:DisplayObject) : void {
			_rightSideTray.addChild(pObj);
			_repositionGridManagementWidget();
		}
		
		public function _rearrangeLeftButtonsTray() : void {
			var btn:ScaleButton = _colorWheel || _backButton;
			if(btn.visible && btn.alpha > 0) {
				_leftButtonsTray.x = btn.x + btn.image.width*0.5 + 12;
			} else {
				_leftButtonsTray.x = _imageCont.x + _imageCont.width + 10;
			}
		}
		
		public function _repositionGridManagementWidget() : void {
			if(_gridManagementWidget) {
				var ll:Number = 0, rr:Number = _rightSideTray.x - _rightSideTray.width;//_rightSideTray.getRect(this).left; <-- this was return a huge number for filter selection screens; idk why
				// Find left most x that's that has empty space - note that in most cases we need to assume it's there even
				// if invisible, since that means it can be toggled on, and we don't want it shifting
				if(_imageCont && _imageCont.visible) ll += _imageCont.width; // In this case invisible is the same as not existing
				if(_colorWheel) ll += _colorWheel.image.width + 10;
				if(_backButton) ll += _backButton.image.width + 10;
				if(_eyeDropperButton) ll += _eyeDropperButton.width + 10;
				if(_favoriteButton) ll += _favoriteButton.width + 3;
				// Apply
				_gridManagementWidget.x = ll + (rr - ll) / 2;
				// new RoundRectangle(1, 10).move(ll, 0).appendTo(this).drawSolid(0, 0x0000FF);
				// new RoundRectangle(1, 10).move(rr, 0).appendTo(this).drawSolid(0, 0xFF0000);
			}
		}
		
		public function hideImageCont() : void {
			_imageCont.visible = false;
			_removeItemOverlay.visible = false;
			if(_colorWheel) _colorWheel.x = _colorWheel.image.width*0.5 + 10;
			if(_backButton) _backButton.x = _backButton.image.width*0.5 + 10;
			_repositionGridManagementWidget();
		}
		
		private function _updateID() : void {
			var tText:String = _itemData.id;
			if(_itemData.type == ItemType.POSE) {
				tText = Fewf.i18n.getText(("pose_"+_itemData.id).toLowerCase(), true);
				if(tText == null) { tText = _itemData.id; }
			}
			_idText.setValues(tText);
		}
		
		public function refreshItemImageUsingCurrentItemData() : void {
			if(!_itemData) return;
			changeImage(GameAssets.getColoredItemImage(_itemData));
		}
		
		public function addInfo(pData:ItemData, pMC:MovieClip) : void {
			if(pData == null) { return; }
			_itemData = pData;
			changeImage(pMC);
			_updateID();
			
			_idText.alpha = 1;
			if(_downloadButton) _downloadButton.enable().setAlpha(1);
			if(_eyeDropperButton) _eyeDropperButton.enable().setAlpha(1);
			if(_favoriteButton) {
				_favoriteButton.enable().setAlpha(1);
				var on:Boolean = FavoriteItemsLocalStorageManager.has(pData);
				_updateFavoriteButton(on);
			}
		}
		
		public function removeInfo() : void {
			_itemData = null;
			_setNoItemImage();
			
			_idText.alpha = 0;
			showColorWheel(false);
			if(_downloadButton) _downloadButton.disable().setAlpha(0);
			if(_eyeDropperButton) _eyeDropperButton.disable().setAlpha(0);
			if(_favoriteButton) _favoriteButton.disable().setAlpha(0);
		}
		
		public function unlockRandomizeButton() : void {
			if(_gridManagementWidget) _gridManagementWidget.unlockRandomizeButton();
		}
		
		private function _setNoItemImage() :void {
			changeImage(new $NoItem());
			this.Image.scaleX = this.Image.scaleY = 0.75;
		}
		
		private function _updateFavoriteButton(pOn:Boolean) : void {
			_favoriteButton.data.pushed = pOn;
			_favoriteButton.setImage(pOn ? new $HeartFull() : new $HeartEmpty());
		}
		
		private function dispatchEventHandler(pEventName:String) : Function {
			return function(e):void{ dispatchEvent(new Event(pEventName)); };
		}
		
		private function _onDownloadClicked(e:Event) : void {
			if(!_itemData) { return; }
			Fewf.dispatcher.dispatchEvent(new ItemDataEvent(ConstantsApp.DOWNLOAD_ITEM_DATA_IMAGE, _itemData));
		}
	}
}
