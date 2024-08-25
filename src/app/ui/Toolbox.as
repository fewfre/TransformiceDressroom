package app.ui
{
	import com.fewfre.display.TextTranslated;
	import com.fewfre.utils.Fewf;
	import app.data.ConstantsApp;
	import app.ui.buttons.*;
	import flash.display.Sprite;
	import flash.net.*;
	import ext.ParentApp;
	import com.fewfre.utils.FewfDisplayUtils;
	import app.world.elements.Character;
	import flash.utils.setTimeout;
	import flash.events.Event;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.display.RoundRectangle;
	import app.ui.common.FrameBase;
	import app.ui.common.FancySlider;
	
	public class Toolbox extends Sprite
	{
		// Constants
		public static const SAVE_CLICKED         = "save_clicked";
		
		public static const SHARE_CLICKED        = "share_clicked";
		public static const CLIPBOARD_CLICKED    = "clipboard_clicked";
		
		public static const SCALE_SLIDER_CHANGE  = "scale_slider_change";
		
		public static const ANIMATION_TOGGLED    = "animation_toggled";
		public static const RANDOM_CLICKED       = "random_clicked";
		public static const TRASH_CLICKED        = "trash_clicked";
		
		public static const FILTER_BANNER_CLOSED = "filter_banner_closed";
		
		// Storage
		public var scaleSlider       : FancySlider;
		private var _downloadButton  : SpriteButton;
		private var _animateButton   : PushButton;
		private var _clipboardButton : SpriteButton;
		
		private var _itemFilterBanner: Sprite;
		
		// Constructor
		// onShareCodeEntered: (code, (state:String)=>void)=>void
		public function Toolbox(pCharacter:Character, onShareCodeEntered:Function) {
			var bg:RoundRectangle = new RoundRectangle(365, 35).toOrigin(0.5).drawAsTray().appendTo(this);
			
			/********************
			* Download Button
			*********************/
			var tDownloadTray:FrameBase = new FrameBase({ x:-bg.width*0.5 + 33, y:9, width:66, height:66, origin:0.5 }).appendTo(this);
			
			_downloadButton = new SpriteButton({ size:46, obj:new $LargeDownload(), origin:0.5 })
				.onButtonClick(dispatchEventHandler(SAVE_CLICKED))
				.appendTo(tDownloadTray) as SpriteButton;
			
			/********************
			* Toolbar Buttons
			*********************/
			var tTray:Sprite = bg.addChild(new Sprite()) as Sprite;
			var tTrayWidth = bg.width - tDownloadTray.Width;
			tTray.x = -(bg.width*0.5) + (tTrayWidth*0.5) + (bg.width - tTrayWidth);
			
			var tButtonSize = 28, tButtonSizeSpace=5, tButtonXInc=tButtonSize+tButtonSizeSpace;
			var xx = 0, yy = 0, tButtonsOnLeft = 0, tButtonOnRight = 0;
			
			// ### Left Side Buttons ###
			xx = -tTrayWidth*0.5 + tButtonSize*0.5 + tButtonSizeSpace;
			
			new SpriteButton({ size:tButtonSize, obj_scale:0.45, obj:new $Link(), origin:0.5 }).appendTo(tTray)
				.move(xx+tButtonXInc*tButtonsOnLeft, yy)
				.onButtonClick(dispatchEventHandler(SHARE_CLICKED));
			tButtonsOnLeft++;
			
			if(Fewf.isExternallyLoaded) {
				_clipboardButton = new SpriteButton({ size:tButtonSize, obj_scale:0.415, obj:new $CopyIcon(), origin:0.5 })
					.move(xx+tButtonXInc*tButtonsOnLeft, yy)
					.onButtonClick(dispatchEventHandler(CLIPBOARD_CLICKED))
					.appendTo(tTray) as SpriteButton;
				tButtonsOnLeft++;
			}
			
			// ### Right Side Buttons ###
			xx = tTrayWidth*0.5-(tButtonSize*0.5 + tButtonSizeSpace);

			new SpriteButton({ size:tButtonSize, obj_scale:0.42, obj:new $Trash(), origin:0.5 }).appendTo(tTray)
				.move(xx-tButtonXInc*tButtonOnRight, yy)
				.onButtonClick(dispatchEventHandler(TRASH_CLICKED));
			tButtonOnRight++;

			// Dice icon based on https://www.iconexperience.com/i_collection/icons/?icon=dice
			new SpriteButton({ size:tButtonSize, obj_scale:1, obj:new $Dice(), origin:0.5 }).appendTo(tTray)
				.move(xx-tButtonXInc*tButtonOnRight, yy)
				.onButtonClick(dispatchEventHandler(RANDOM_CLICKED));
			tButtonOnRight++;
			
			_animateButton = new PushButton({ size:tButtonSize, obj_scale:0.65, obj:new $PlayButton(), origin:0.5 })
				.move(xx-tButtonXInc*tButtonOnRight, yy)
				.on(PushButton.TOGGLE, dispatchEventHandler(ANIMATION_TOGGLED))
				.on(PushButton.TOGGLE, function(e):void{
					var icon:Sprite = !_animateButton.pushed ? new $PlayButton() : newStopIcon();
					_animateButton.setImage(icon, 0.65);
				})
				.appendTo(tTray) as PushButton;
			tButtonOnRight++;
			
			/********************
			* Scale slider
			*********************/
			var tTotalButtons:Number = tButtonsOnLeft+tButtonOnRight;
			var tSliderWidth:Number = tTrayWidth - tButtonXInc*(tTotalButtons) - 20;
			xx = -tSliderWidth*0.5+(tButtonXInc*((tButtonsOnLeft-tButtonOnRight)*0.5))-1;
			scaleSlider = new FancySlider(tSliderWidth).move(xx, yy)
				.setSliderParams(1, 8, pCharacter.outfit.scaleX)
				.appendTo(tTray)
				.on(FancySlider.CHANGE, dispatchEventHandler(SCALE_SLIDER_CHANGE));
			
			/********************
			* Under Toolbox
			*********************/
			if(!ConstantsApp.CONFIG_TAB_ENABLED) {
				new PasteShareCodeInput().appendTo(this).move(18, 33)
					.on(PasteShareCodeInput.CHANGE, function(e:FewfEvent):void{ onShareCodeEntered(e.data.code, e.data.update); });
			}
			
			// Item Filter Banner
			// Don't addChild to anything until it should show up
			_itemFilterBanner = _newItemFilterBanner(-112, 33);
			_itemFilterBanner.addEventListener(Event.CLOSE, dispatchEventHandler(FILTER_BANNER_CLOSED));
		}
		public function move(pX:Number, pY:Number) : Toolbox { x = pX; y = pY; return this; }
		public function appendTo(pParent:Sprite): Toolbox { pParent.addChild(this); return this; }
		public function on(type:String, listener:Function): Toolbox { this.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): Toolbox { this.removeEventListener(type, listener); return this; }
		
		private function _newItemFilterBanner(pX:Number, pY:Number) : Sprite {
			var tray:Sprite = new Sprite(); tray.x = pX; tray.y = pY;
			
			var hh:Number = 28-2/*minus 2 because of extra border*/;
			new RoundRectangle(260, hh).toOrigin(0, 0.5).toRadius(4).drawSolid(0xDDDDFF, 0x0000FF, 2).appendTo(tray);
			new TextTranslated("share_filter_banner", { x:10, originX:0, originY:0.5, color:0x111111 }).appendToT(tray);
			ScaleButton.withObject(new $No(), 0.5).move(245, 0).appendTo(tray)
				.onButtonClick(function(e):void{ tray.dispatchEvent(new Event(Event.CLOSE)); });
				
			return tray;
		}
		
		///////////////////////
		// Public
		///////////////////////
		public function showItemFilterBanner() : void {
			addChild(_itemFilterBanner);
		}
		
		public function hideItemFilterBanner() : void {
			if(_itemFilterBanner.parent) _itemFilterBanner.parent.removeChild(_itemFilterBanner);
		}
		
		public function downloadButtonEnable(pOn:Boolean) : void {
			if(pOn) _downloadButton.enable(); else _downloadButton.disable();
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
