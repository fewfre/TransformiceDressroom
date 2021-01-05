package app.ui.panes
{
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import com.fewfre.display.*;
	import com.fewfre.utils.*;
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.*;
	
	public class ColorFinderPane extends TabPane
	{
		// Constants
		public static const EVENT_SWATCH_CHANGED	: String = "event_swatch_changed";
		public static const EVENT_DEFAULT_CLICKED	: String = "event_default_clicked";
		public static const EVENT_COLOR_PICKED		: String = "event_color_picked";
		public static const EVENT_EXIT				: String = "event_exit";
		
		// Storage
		private var _tray : MovieClip;
		private var _stageBitmap : BitmapData;
		private var _itemCont : MovieClip;
		private var _item : MovieClip;
		private var _text : TextField;
		private var _textColorBox : RoundedRectangle;
		private var _hoverText : TextField;
		private var _hoverColorBox : RoundedRectangle;
		
		private const _bitmapData:BitmapData = new BitmapData(1, 1);
		private const _matrix:Matrix = new Matrix();
		private const _clipRect:Rectangle = new Rectangle(0, 0, 1, 1);
		
		// Properties
		// public function get selectedSwatch():int { return _selectedSwatch; }
		
		// Constructor
		public function ColorFinderPane(pData:Object)
		{
			super();
			this.addInfoBar( new ShopInfoBar({ showBackButton:true, showRefreshButton:false }) );
			this.infoBar.colorWheel.addEventListener(MouseEvent.MOUSE_UP, _onBackClicked);
			this.UpdatePane(false);
			
			_tray = addChild(new MovieClip()) as MovieClip;
			_tray.x = ConstantsApp.PANE_WIDTH * 0.5;
			_tray.y = 50 + (275 * 0.5);
			
			// https://stackoverflow.com/questions/78849/best-way-to-get-the-color-where-a-mouse-was-clicked-in-as3
			_stageBitmap = new BitmapData(Fewf.stage.stageWidth, Fewf.stage.stageHeight);
			
			_itemCont = _tray.addChild(new MovieClip()) as MovieClip;
			_itemCont.y = 10;
			_itemCont.addEventListener(MouseEvent.CLICK, _onItemClicked);
			_itemCont.addEventListener(MouseEvent.MOUSE_MOVE, _onItemHoveredOver);
			_itemCont.addEventListener(MouseEvent.MOUSE_OUT, _onItemMouseOut);
			_item = _itemCont.addChild(new MovieClip()) as MovieClip;
			
			/****************************
			* Selectable text field
			*****************************/
			var tTFWidth:Number = 65, tTFHeight:Number = 18, tTFPaddingX:Number = 5, tTFPaddingY:Number = 5;
			// So much easier than doing it with those darn native text field options which have no padding.
			var tTextBackground:RoundedRectangle = _tray.addChild(new RoundedRectangle({ x:15, y:170, width:tTFWidth+tTFPaddingX*2, height:tTFHeight+tTFPaddingY*2, origin:0.5 })) as RoundedRectangle;
			tTextBackground.draw(0xFFFFFF, 7, 0x444444, 0x444444, 0x444444);
			
			_text = tTextBackground.addChild(new TextField()) as TextField;
			_text.type = TextFieldType.DYNAMIC;
			_text.multiline = false;
			_text.width = tTFWidth;
			_text.height = tTFHeight;
			_text.x = tTFPaddingX - tTextBackground.Width*0.5;
			_text.y = tTFPaddingY - tTextBackground.Height*0.5;
			_text.addEventListener(MouseEvent.CLICK, function(pEvent:Event){ _text.setSelection(0, _text.text.length); });
			
			var tSize = tTextBackground.Height;
			_textColorBox = _tray.addChild(new RoundedRectangle({
				x:tTextBackground.x - (tTextBackground.Width*0.5) - (tSize*0.5) - 5,
				y:tTextBackground.y, width: tSize, height: tSize, origin:0.5
			})) as RoundedRectangle;
			
			_hoverColorBox = _tray.addChild(new RoundedRectangle({
				/*x:ConstantsApp.PANE_WIDTH*0.5-5, y:-122,*/ width:35, height:35, originX:0, originY:1
			})) as RoundedRectangle;
			_hoverColorBox.visible = false;
			/*var tHoverTextBackground = _hoverColorBox.addChild(new RoundedRectangle({ x:-_hoverColorBox.Width*0.5, y:_hoverColorBox.Height+20,
				width:_hoverColorBox.Width+8, height:20, originX:0.5, originY:1 }));
			tHoverTextBackground.draw(0xFFFFFF, 5, 0xDDDDDD, 0xDDDDDD, 0xDDDDDD);
			tHoverTextBackground.alpha = 0.75;
			_hoverText = _hoverColorBox.addChild(new TextField());
			_hoverText.type = TextFieldType.DYNAMIC;
			_hoverText.defaultTextFormat.size = 10;
			_hoverText.defaultTextFormat.align = "center";
			_hoverText.selectable = false;
			_hoverText.multiline = false;
			_hoverText.width = tHoverTextBackground.Width;
			_hoverText.height = tHoverTextBackground.Height;
			_hoverText.x = tTFPaddingX - tHoverTextBackground.Width + 2;
			_hoverText.y = tTFPaddingY + tHoverTextBackground.Height + 25;*/
			
			_setColorText(-1);
			_setHoverColor(-1);
		}
		
		/****************************
		* Public
		*****************************/
		public function setItem(pObj:DisplayObject) : void {
			_setColorText(-1);
			_setHoverColor(-1);
			_itemCont.removeChild(_item);
			_item = _itemCont.addChild(pObj) as MovieClip;
			_item.scaleX = _item.scaleY = 5;
			// Don't let the pose eat mouse input
			_item.mouseChildren = false;
			_item.mouseEnabled = false;
			
			var tPadding = 15, tBoundsWidth = ConstantsApp.PANE_WIDTH-(tPadding*2), tBoundsHeight = 250-(tPadding*2);
			FewfDisplayUtils.fitWithinBounds(_item, tBoundsWidth, tBoundsHeight, tBoundsWidth*0.7, tBoundsHeight*0.7);
			_centerImageOrigin(_item);
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
		
		/****************************
		* Private
		*****************************/
		private function _setColorText(pColor:int) : void {
			if(pColor != -1) {
				_text.text = FewfUtils.lpad(pColor.toString(16).toUpperCase(), 6, "0");
				_textColorBox.draw(pColor, 7, 0x444444, 0x444444, 0x444444);
			} else {
				_text.text = "000000";
				_textColorBox.draw(0x000000, 7, 0x444444, 0x444444, 0x444444);
			}
		}
		
		private function _setHoverColor(pColor:int) : void {
			if(pColor != -1) {
				/*_hoverText.text = FewfUtils.lpad(pColor.toString(16).toUpperCase(), 6, "0");*/
				_hoverColorBox.draw(pColor, 7, 0x444444, 0x444444, 0x444444);
			} else {
				/*_hoverText.text = "000000";*/
				_hoverColorBox.draw(0x000000, 7, 0x444444, 0x444444, 0x444444);
			}
		}
		
		private function _getColorAtMouseLocation() : uint {
			return _getColorFromSpriteAtLocation(Fewf.stage, Fewf.stage.mouseX, Fewf.stage.mouseY);
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
			_setColorText(_getColorAtMouseLocation());
		}
		
		private function _onItemHoveredOver(e:Event) : void {
			if(!_flagOpen) { return; }
			_hoverColorBox.visible = true;
			_setHoverColor(_getColorAtMouseLocation());
			_hoverColorBox.x = _tray.mouseX;
			_hoverColorBox.y = _tray.mouseY;
		}
		
		private function _onItemMouseOut(e:Event) : void {
			if(!_flagOpen) { return; }
			_hoverColorBox.visible = false;
		}
		
		private function _onBackClicked(e:Event) : void {
			dispatchEvent(new Event(EVENT_EXIT));
		}
	}
}
