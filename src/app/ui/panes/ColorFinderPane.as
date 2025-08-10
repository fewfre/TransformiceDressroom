package app.ui.panes
{
	import app.data.ConstantsApp;
	import app.ui.buttons.*;
	import app.ui.common.*;
	import app.ui.panes.base.SidePaneWithInfobar;
	import app.ui.panes.colorpicker.RecentColorsListDisplay;
	import app.ui.panes.infobar.Infobar;
	import com.fewfre.display.RoundRectangle;
	import com.fewfre.utils.*;
	import ext.ParentApp;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	public class ColorFinderPane extends SidePaneWithInfobar
	{
		// Constants
		public static const EVENT_ITEM_ICON_CLICKED : String = "event_item_icon_clicked";
		
		// Storage
		private var _tray : MovieClip;
		private var _scrollbox : FancyScrollbox;
		
		private var _stageBitmap : BitmapData;
		private var _itemCont : MovieClip;
		private var _itemDragDrop : MovieClip;
		private var _item : MovieClip;
		private var _text : TextField;
		private var _textColorBox : RoundRectangle;
		private var _hoverText : TextField;
		private var _hoverColorBox : RoundRectangle;
		private var _recentColorsDisplay : RecentColorsListDisplay;
		private var _scaleSlider : FancySlider;
		
		private var _dragging : Boolean = false;
		private var _ignoreNextColorClick : Boolean = false;
		private var _dragStartMouseX : Boolean;
		private var _dragStartMouseY : Boolean;
		private var _dragBounds : Rectangle;
		
		private const _bitmapData:BitmapData = new BitmapData(1, 1);
		private const _matrix:Matrix = new Matrix();
		private const _clipRect:Rectangle = new Rectangle(0, 0, 1, 1);
		
		// Constructor
		public function ColorFinderPane() {
			super();
			this.addInfobar( new Infobar({ showBackButton:true }) )
				.on(Infobar.BACK_CLICKED, _onBackClicked)
				.on(Infobar.ITEM_PREVIEW_CLICKED, function(e){ dispatchEvent(new Event(EVENT_ITEM_ICON_CLICKED)); });
			
			/////////////////////////////
			// Infobar - Image file selector
			/////////////////////////////
			var fileRef : FileReference = new FileReference();
			fileRef.addEventListener(Event.SELECT, function(){ fileRef.load(); });
			fileRef.addEventListener(Event.COMPLETE, _onFileSelect);
			
			var folderBttn:ScaleButton = new ScaleButton(new $Folder(), 1.5).move(-25, 25)
				.onButtonClick(function(e){ fileRef.browse([new FileFilter("Images", "*.jpg;*.jpeg;*.gif;*.png")]); }) as ScaleButton;
			infobar.addCustomObjectToRightSideTray(folderBttn);
			
			/////////////////////////////
			// Content Area
			/////////////////////////////
			// Scrollbox used for lazy cropping of dragged around item
			_scrollbox = new FancyScrollbox(ConstantsApp.PANE_WIDTH, 390-60).move(5, 5+60);
			addChild(_scrollbox);
			
			_tray = addChild(new MovieClip()) as MovieClip;
			_tray.x = ConstantsApp.PANE_WIDTH * 0.5;
			_tray.y = 50 + (275 * 0.5);
			
			// https://stackoverflow.com/questions/78849/best-way-to-get-the-color-where-a-mouse-was-clicked-in-as3
			_stageBitmap = new BitmapData(ConstantsApp.APP_WIDTH, ConstantsApp.APP_HEIGHT);
			
			/********************
			* Item setup
			*********************/
			_itemCont = new MovieClip();//_tray.addChild(new MovieClip()) as MovieClip;
			_itemCont.x = _tray.x;
			_itemCont.y = _tray.y - 35;
			_itemCont.addEventListener(MouseEvent.CLICK, _onItemClicked);
			_itemCont.addEventListener(MouseEvent.MOUSE_MOVE, _onItemHoveredOver);
			_itemCont.addEventListener(MouseEvent.MOUSE_OUT, _onItemMouseOut);
			// THIS IS IMPORTANT JANKY CODE!
			// addItem (NOT addChild) adds this to the ScrollPane in the parent class
			// we then also hijack the scrollpane and turn off the scrollbars
			// this now lets the image be dragged around without it overflowing out of the container
			_scrollbox.add(_itemCont);
			_scrollbox.scrollPane.horizontalScrollPolicy = "off";
			_scrollbox.scrollPane.verticalScrollPolicy = "off";
			// Also steal the scrollpane's `contentBack` and size it to be full width/height
			// so we can use it to detect scroll event
			_scrollbox.contentHitbox.graphics.clear();
			_scrollbox.contentHitbox.graphics.beginFill(0, 0);
			_scrollbox.contentHitbox.graphics.drawRect(0, 0, _scrollbox.scrollPane.width, _scrollbox.scrollPane.height);
			_scrollbox.contentHitbox.graphics.endFill();
			
			var bPadding:Number = 8;
			_dragBounds = new Rectangle(-_itemCont.x - _itemCont.parent.x + bPadding*0.5, -_itemCont.y - _itemCont.parent.y + bPadding*0.5, _scrollbox.scrollPane.width - bPadding, _scrollbox.scrollPane.height - bPadding);
			_itemDragDrop = _itemCont.addChild(new MovieClip()) as MovieClip;
			_itemDragDrop.buttonMode = true;
			_itemDragDrop.addEventListener(MouseEvent.MOUSE_DOWN, function (e:MouseEvent) {
				_dragging = true;
				_ignoreNextColorClick = false;
				var bounds:Rectangle = _dragBounds.clone();
				bounds.x -= e.localX * _itemDragDrop.scaleX;
				bounds.y -= e.localY * _itemDragDrop.scaleY;
				_itemDragDrop.startDrag(false, bounds);
			});
			Fewf.stage.addEventListener(MouseEvent.MOUSE_UP, function () { _dragging = false; _itemDragDrop.stopDrag(); });
			
			_item = _itemDragDrop.addChild(new MovieClip()) as MovieClip;
			
			/********************
			* Scale slider
			*********************/
			var tSliderWidth = ConstantsApp.PANE_WIDTH * 0.4;
			_scaleSlider = new FancySlider(tSliderWidth)
				.move(-tSliderWidth*0.5, -110)
				.setSliderParams(1, 5, 1)
				.appendTo(_tray)
				.on(FancySlider.CHANGE, _onSliderChange);
			
			// Attach scroll event to back to detect scroll anywhere on pane
			// and also attach to item since it ignores the other scroll event if mouse over it
			_scrollbox.contentHitbox.addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
			_itemCont.addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
			
			/********************
			* Recent colors display
			*********************/
			_recentColorsDisplay = new RecentColorsListDisplay().move(ConstantsApp.PANE_WIDTH/2, 316+60+18).appendTo(this);
			
			/****************************
			* Selectable text field
			*****************************/
			var tTFWidth:Number = 65, tTFHeight:Number = 18, tTFPaddingX:Number = 5, tTFPaddingY:Number = 5;
			// So much easier than doing it with those darn native text field options which have no padding.
			var tTextBackground:RoundRectangle = new RoundRectangle(tTFWidth+tTFPaddingX*2, tTFHeight+tTFPaddingY*2).toOrigin(0.5)
				.move(15, 170).appendTo(_tray).toRadius(7).drawSolid(0xFFFFFF, 0x444444);
			
			_text = tTextBackground.addChild(new TextField()) as TextField;
			_text.type = TextFieldType.DYNAMIC;
			_text.multiline = false;
			_text.width = tTFWidth;
			_text.height = tTFHeight;
			_text.x = tTFPaddingX - tTextBackground.width*0.5;
			_text.y = tTFPaddingY - tTextBackground.height*0.5;
			_text.addEventListener(MouseEvent.CLICK, function(pEvent:Event){ _text.setSelection(0, _text.text.length); });
			
			var tSize = tTextBackground.height;
			_textColorBox = new RoundRectangle(tSize, tSize).toOrigin(0.5).toRadius(7).appendTo(_tray)
				.move(tTextBackground.x - (tTextBackground.width*0.5) - (tSize*0.5) - 5, tTextBackground.y);
			
			_hoverColorBox = new RoundRectangle(35, 35).toOrigin(0, 1).toRadius(7).appendTo(_tray);//.move(ConstantsApp.PANE_WIDTH*0.5-5, -122);
			_hoverColorBox.visible = false;
			// var tHoverTextBackground:RoundRectangle = new RoundRectangle(_hoverColorBox.width+8, 20, { originX:0.5, originY:1 }).move(-_hoverColorBox.width*0.5, _hoverColorBox.height+20).appendTo(_hoverColorBox.root);
			// tHoverTextBackground.toRadius(5).drawSolid(0xFFFFFF, 0xDDDDDD, 0xDDDDDD, 0xDDDDDD);
			// tHoverTextBackground.alpha = 0.75;
			// _hoverText = _hoverColorBox.addChild(new TextField());
			// _hoverText.type = TextFieldType.DYNAMIC;
			// _hoverText.defaultTextFormat.size = 10;
			// _hoverText.defaultTextFormat.align = "center";
			// _hoverText.selectable = false;
			// _hoverText.multiline = false;
			// _hoverText.width = tHoverTextBackground.width;
			// _hoverText.height = tHoverTextBackground.height;
			// _hoverText.x = tTFPaddingX - tHoverTextBackground.width + 2;
			// _hoverText.y = tTFPaddingY + tHoverTextBackground.height + 25;
			
			_setColorText(-1);
			_setHoverColor(-1);
		}
		
		public override function open() : void {
			super.open();
			_recentColorsDisplay.render();
		}
		
		public override function close() : void {
			super.close();
			_recentColorsDisplay.toggleOffDeleteMode();
		}
		
		/****************************
		* Public
		*****************************/
		public function setItem(pObj:DisplayObject) : void {
			_setColorText(-1);
			_setHoverColor(-1);
			_itemDragDrop.removeChild(_item);
			_itemDragDrop.stopDrag(); _dragging = false; _ignoreNextColorClick = false;
			_item = _itemDragDrop.addChild(pObj) as MovieClip;
			_item.scaleX = _item.scaleY = 5;
			_itemDragDrop.scaleX = _itemDragDrop.scaleY = 1;
			_scaleSlider.value = 1;
			_itemDragDrop.x = _itemDragDrop.y = 0;
			// Don't let the pose eat mouse input
			_item.mouseChildren = false;
			_item.mouseEnabled = false;
			
			var tPadding = 15, tBoundsWidth = ConstantsApp.PANE_WIDTH-(tPadding*2), tBoundsHeight = 250-(tPadding*2);
			FewfDisplayUtils.fitWithinBounds(_item, tBoundsWidth, tBoundsHeight, tBoundsWidth*0.7, tBoundsHeight*0.7);
			_centerImageOrigin(pObj);
			_stageBitmap.draw(Fewf.stage); // Take a snapshot of current stage.
		}
		// Center image (origin at center)
		private function _centerImageOrigin(pImage:DisplayObject, pX:Number=0, pY:Number=0) : DisplayObject {
			var tBounds:Rectangle = pImage.getBounds(pImage);
			var tOffset:Point = tBounds.topLeft;
			pImage.x = pX - (tBounds.width / 2 + tOffset.x) * pImage.scaleX;
			pImage.y = pY - (tBounds.height / 2 + tOffset.y) * pImage.scaleY;
			return pImage;
		}
		
		public function setItemFromUrl(url:String) : void {
			var loader:Loader = new Loader();
			loader.load(new URLRequest(url));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void{
				e.target.content.x = -e.target.content.width*0.5;
				e.target.content.y = -e.target.content.height*0.5;
				var mc = new MovieClip();
				mc.addChild(e.target.content);
				setItem(mc);
			});
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void{
				setItem(new $No());
			});
		}
		
		/****************************
		* Private
		*****************************/
		private function _setColorText(pColor:int) : void {
			if(pColor != -1) {
				_text.text = FewfUtils.lpad(pColor.toString(16).toUpperCase(), 6, "0");
				_textColorBox.drawSolid(pColor, 0x444444);
				_recentColorsDisplay.addColor(pColor);
			} else {
				_text.text = "000000";
				_textColorBox.drawSolid(0x000000, 0x444444);
			}
		}
		
		private function _setHoverColor(pColor:int) : void {
			if(pColor != -1) {
				/*_hoverText.text = FewfUtils.lpad(pColor.toString(16).toUpperCase(), 6, "0");*/
				_hoverColorBox.drawSolid(pColor, 0x444444);
			} else {
				/*_hoverText.text = "000000";*/
				_hoverColorBox.drawSolid(0x000000, 0x444444);
			}
		}
		
		private function _getColorAtMouseLocation() : uint {
			// return _getColorFromSpriteAtLocation(Fewf.stage, Fewf.stage.mouseX, Fewf.stage.mouseY);
			// Note: Setting it to `_item` causes wierd blended color values to be picked
			return _getColorFromSpriteAtLocation(_itemDragDrop, _itemDragDrop.mouseX, _itemDragDrop.mouseY);
		}
		// https://stackoverflow.com/a/8619705/1411473
		private function _getColorFromSpriteAtLocation(pDrawable:IBitmapDrawable, pX:Number, pY:Number) : uint {
			_matrix.setTo(1, 0, 0, 1, -pX, -pY)
			_bitmapData.draw(pDrawable, _matrix, null, null, _clipRect);
			return _bitmapData.getPixel(0, 0);
		}
		
		/****************************
		* Events
		*****************************/
		private function _onItemClicked(e:Event) : void {
			if(!_flagOpen) { return; }
			if(!_ignoreNextColorClick) {
				_setColorText(_getColorAtMouseLocation());
				_ignoreNextColorClick = false;
			}
		}
		
		private function _onItemHoveredOver(e:Event) : void {
			if(!_flagOpen) { return; }
			_hoverColorBox.visible = true;
			_setHoverColor(_getColorAtMouseLocation());
			_hoverColorBox.x = _tray.mouseX;
			_hoverColorBox.y = _tray.mouseY;
			
			if(_dragging) {
				_ignoreNextColorClick = true;
			}
		}
		
		private function _onItemMouseOut(e:Event) : void {
			if(!_flagOpen) { return; }
			_hoverColorBox.visible = false;
		}
		
		private function _onBackClicked(e:Event) : void {
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		private function _clampCoordsToSafeArea() : void {
			_itemDragDrop.x = Math.max(_dragBounds.x, Math.min(_dragBounds.right, _itemDragDrop.x));
			_itemDragDrop.y = Math.max(_dragBounds.y, Math.min(_dragBounds.bottom, _itemDragDrop.y));
		}
		
		private function _onSliderChange(e:Event) : void {
			_itemDragDrop.scaleX = _itemDragDrop.scaleY = _scaleSlider.value;
			_centerImageOrigin(_item);
			_clampCoordsToSafeArea();
		}

		private function _onMouseWheel(pEvent:MouseEvent) : void {
			_scaleSlider.updateViaMouseWheelDelta(pEvent.delta);
			_itemDragDrop.scaleX = _itemDragDrop.scaleY = _scaleSlider.value;
			_clampCoordsToSafeArea();
		}
		
		private function _onFileSelect(e:Event) : void {
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void{
				e.target.content.x = -e.target.content.width*0.5;
				e.target.content.y = -e.target.content.height*0.5;
				var mc = new MovieClip();
				mc.addChild(e.target.content);
				try {
					setItem(mc);
				} catch(e) {
					setItem(new $No());
				}
			});
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void{
				setItem(new $No());
			});
			// Start load
			loader.loadBytes(e.target.data);
			// loader.load(new URLRequest(url));
		}
	}
}
