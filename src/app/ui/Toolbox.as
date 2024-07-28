package app.ui
{
	import com.fewfre.display.ButtonBase;
	import com.fewfre.display.TextTranslated;
	import com.fewfre.utils.Fewf;
	import com.fewfre.utils.ImgurApi;
	import app.data.ConstantsApp;
	import app.ui.buttons.*;
	import app.ui.common.*;
	import flash.display.Sprite;
	import flash.net.*;
	import ext.ParentApp;
	import com.fewfre.utils.FewfDisplayUtils;
	import app.world.elements.Character;
	import flash.utils.setTimeout;
	import flash.events.Event;
	import com.fewfre.events.FewfEvent;
	
	public class Toolbox extends Sprite
	{
		// Constants
		public static const SAVE_CLICKED         = "save_clicked";
		
		public static const SHARE_CLICKED        = "share_clicked";
		public static const CLIPBOARD_CLICKED    = "clipboard_clicked";
		public static const IMGUR_CLICKED        = "imgur_clicked";
		
		public static const SCALE_SLIDER_CHANGE  = "scale_slider_change";
		
		public static const ANIMATION_TOGGLED    = "animation_toggled";
		public static const RANDOM_CLICKED       = "random_clicked";
		public static const TRASH_CLICKED        = "trash_clicked";
		
		public static const FILTER_BANNER_CLOSED = "filter_banner_closed";
		
		// Storage
		private var _downloadTray    : FrameBase;
		private var _bg              : RoundedRectangle;
		
		public var scaleSlider       : FancySlider;
		private var _downloadButton  : ButtonBase;
		private var _animateButton   : PushButton;
		private var _imgurButton     : SpriteButton;
		private var _clipboardButton : SpriteButton;
		
		private var _itemFilterBanner: RoundedRectangle;
		
		// Constructor
		// onShareCodeEntered: (code, (state:String)=>void)=>void
		public function Toolbox(pCharacter:Character, onShareCodeEntered:Function) {
			_bg = new RoundedRectangle(365, 35, { origin:0.5 }).drawAsTray().appendTo(this);
			
			/********************
			* Download Button
			*********************/
			_downloadTray = addChild(new FrameBase({ x:-_bg.Width*0.5 + 33, y:9, width:66, height:66, origin:0.5 })) as FrameBase;
			
			_downloadButton = new SpriteButton({ size:46, obj:new $LargeDownload(), origin:0.5 })
				.on(ButtonBase.CLICK, dispatchEventHandler(SAVE_CLICKED))
				.appendTo(_downloadTray);
			
			/********************
			* Toolbar Buttons
			*********************/
			var tTray:Sprite = _bg.addChild(new Sprite()) as Sprite;
			var tTrayWidth = _bg.Width - _downloadTray.Width;
			tTray.x = -(_bg.Width*0.5) + (tTrayWidth*0.5) + (_bg.Width - tTrayWidth);
			
			var tButtonSize = 28, tButtonSizeSpace=5, tButtonXInc=tButtonSize+tButtonSizeSpace;
			var tX = 0, yy = 0, tButtonsOnLeft = 0, tButtonOnRight = 0;
			
			// ### Left Side Buttons ###
			tX = -tTrayWidth*0.5 + tButtonSize*0.5 + tButtonSizeSpace;
			
			new SpriteButton({ size:tButtonSize, obj_scale:0.45, obj:new $Link(), origin:0.5 }).appendTo(tTray)
				.setXY(tX+tButtonXInc*tButtonsOnLeft, yy)
				.on(ButtonBase.CLICK, dispatchEventHandler(SHARE_CLICKED));
			tButtonsOnLeft++;
			
			if(!Fewf.isExternallyLoaded) {
				_imgurButton = new SpriteButton({ size:tButtonSize, obj_scale:0.45, obj:new $ImgurIcon(), origin:0.5 })
					.setXY(tX+tButtonXInc*tButtonsOnLeft, yy)
					.on(ButtonBase.CLICK, dispatchEventHandler(IMGUR_CLICKED))
					.appendTo(tTray) as SpriteButton;
				tButtonsOnLeft++;
			} else {
				_clipboardButton = new SpriteButton({ size:tButtonSize, obj_scale:0.415, obj:new $CopyIcon(), origin:0.5 })
					.setXY(tX+tButtonXInc*tButtonsOnLeft, yy)
					.on(ButtonBase.CLICK, dispatchEventHandler(CLIPBOARD_CLICKED))
					.appendTo(tTray) as SpriteButton;
				tButtonsOnLeft++;
			}
			
			// ### Right Side Buttons ###
			tX = tTrayWidth*0.5-(tButtonSize*0.5 + tButtonSizeSpace);

			new SpriteButton({ size:tButtonSize, obj_scale:0.42, obj:new $Trash(), origin:0.5 }).appendTo(tTray)
				.setXY(tX-tButtonXInc*tButtonOnRight, yy)
				.on(ButtonBase.CLICK, dispatchEventHandler(TRASH_CLICKED));
			tButtonOnRight++;

			// Dice icon based on https://www.iconexperience.com/i_collection/icons/?icon=dice
			new SpriteButton({ size:tButtonSize, obj_scale:1, obj:new $Dice(), origin:0.5 }).appendTo(tTray)
				.setXY(tX-tButtonXInc*tButtonOnRight, yy)
				.on(ButtonBase.CLICK, dispatchEventHandler(RANDOM_CLICKED));
			tButtonOnRight++;
			
			_animateButton = new PushButton({ size:tButtonSize, obj_scale:0.65, obj:new $PlayButton(), origin:0.5 })
				.setXY(tX-tButtonXInc*tButtonOnRight, yy)
				.on(PushButton.STATE_CHANGED_AFTER, dispatchEventHandler(ANIMATION_TOGGLED))
				.on(PushButton.STATE_CHANGED_AFTER, function(e):void{
					var icon:Sprite = !_animateButton.pushed ? new $PlayButton() : newStopIcon();
					_animateButton.ChangeImage(icon, 0.65);
				})
				.appendTo(tTray) as PushButton;
			tButtonOnRight++;
			
			/********************
			* Scale slider
			*********************/
			var tTotalButtons:Number = tButtonsOnLeft+tButtonOnRight;
			var tSliderWidth:Number = tTrayWidth - tButtonXInc*(tTotalButtons) - 20;
			tX = -tSliderWidth*0.5+(tButtonXInc*((tButtonsOnLeft-tButtonOnRight)*0.5))-1;
			scaleSlider = new FancySlider(tSliderWidth).setXY(tX, yy)
				.setSliderParams(1, 8, pCharacter.outfit.scaleX)
				.appendTo(tTray);
			scaleSlider.addEventListener(FancySlider.CHANGE, dispatchEventHandler(SCALE_SLIDER_CHANGE));
			
			
			/********************
			* Under Toolbox
			*********************/
			if(!ConstantsApp.CONFIG_TAB_ENABLED) {
				new PasteShareCodeInput().appendTo(this).move(18, 33)
					.on(PasteShareCodeInput.CHANGE, function(e:FewfEvent):void{ onShareCodeEntered(e.data.code, e.data.update); });
			}
			
			// Item Filter Banner
			// Don't append to anything until it should show up
			_itemFilterBanner = _newItemFilterBanner().setXY(-112, 18)
			_itemFilterBanner.addEventListener(Event.CLOSE, dispatchEventHandler(FILTER_BANNER_CLOSED));
		}
		public function setXY(pX:Number, pY:Number) : Toolbox { x = pX; y = pY; return this; }
		public function appendTo(pParent:Sprite): Toolbox { pParent.addChild(this); return this; }
		public function on(type:String, listener:Function): Toolbox { this.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): Toolbox { this.removeEventListener(type, listener); return this; }
		
		private function _newItemFilterBanner() : RoundedRectangle {
			var hh:Number = 30, yy:Number = hh/2;
			// Don't append to anything until it should show up
			var tray : RoundedRectangle = new RoundedRectangle(260, 30).draw(0xDDDDFF, 4, 0x0000FF);
			new TextTranslated("share_filter_banner", { x:10, y:yy, originX:0, color:0x111111 }).appendToT(tray);
			new ScaleButton({ obj:new $No(), obj_scale:0.5 }).setXY(245, yy).appendTo(tray)
				.on(ButtonBase.CLICK, function(e):void{ tray.dispatchEvent(new Event(Event.CLOSE)); });
				
			return tray;
		}
		
		///////////////////////
		// Public
		///////////////////////
		public function showItemFilterBanner() : void {
			_itemFilterBanner.appendTo(this);
		}
		
		public function hideItemFilterBanner() : void {
			if(_itemFilterBanner.parent) _itemFilterBanner.parent.removeChild(_itemFilterBanner);
		}
		
		public function downloadButtonEnable(pOn:Boolean) : void {
			if(pOn) _downloadButton.enable(); else _downloadButton.disable();
		}
		
		public function imgurButtonEnable(pOn:Boolean) : void {
			if(pOn) _imgurButton.enable(); else _imgurButton.disable();
		}
		
		public function toggleAnimationButtonOffWithEvent() : void {
			_animateButton.toggleOff(true);
		}
		
		public function updateClipboardButton(normal:Boolean, elseYes:Boolean=true) : void {
			if(!_clipboardButton) return;
			_clipboardButton.ChangeImage(normal ? new $CopyIcon() : elseYes ? new $Yes() : new $No());
		}
		
		///////////////////////
		// Private
		///////////////////////
		private function dispatchEventHandler(pEventName:String) : Function {
			return function(e):void{ dispatchEvent(new Event(pEventName)); };
		}
		private function newStopIcon() : Sprite {
			var icon:Sprite = new Sprite();
			icon.graphics.beginFill(0xFFFFFF);
			icon.graphics.lineStyle(2, 0);
			icon.graphics.drawRect(-18/2, -18/2, 18, 18);
			icon.graphics.endFill();
			return icon;
		}
	}
}
