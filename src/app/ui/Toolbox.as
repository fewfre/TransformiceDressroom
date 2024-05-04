package app.ui
{
	import com.fewfre.display.ButtonBase;
	import com.fewfre.display.TextBase;
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
	
	public class Toolbox extends Sprite
	{
		// Storage
		private var _downloadTray	: FrameBase;
		private var _bg				: RoundedRectangle;
		private var _character		: Character;
		
		public var scaleSlider		: FancySlider;
		public var downloadButton	: ButtonBase;
		public var animateButton	: SpriteButton;
		public var imgurButton		: SpriteButton;
		
		private var _itemFilterBanner: RoundedRectangle;
		
		// Constructor
		// pData = { character:Character, onSave:Function, onAnimate:Function, onRandomize:Function, onTrash:Function, onShare:Function, onScale:Function, onItemFilterClosed:Function }
		public function Toolbox(pData:Object) {
			_character = pData.character;
			
			var btn:ButtonBase;
			
			_bg = addChild(new RoundedRectangle({ width:365, height:35, origin:0.5 })) as RoundedRectangle;
			_bg.drawAsTray();
			
			/********************
			* Download Button
			*********************/
			_downloadTray = addChild(new FrameBase({ x:-_bg.Width*0.5 + 33, y:9, width:66, height:66, origin:0.5 })) as FrameBase;
			/*_downloadTray.drawAsTray();*/
			
			downloadButton = _downloadTray.addChild(new SpriteButton({ width:46, height:46, obj:new $LargeDownload(), origin:0.5 })) as ButtonBase;
			downloadButton.addEventListener(ButtonBase.CLICK, pData.onSave);
			
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
			
			btn = tTray.addChild(new SpriteButton({ x:tX+tButtonXInc*tButtonsOnLeft, y:yy, width:tButtonSize, height:tButtonSize, obj_scale:0.45, obj:new $Link(), origin:0.5 })) as SpriteButton;
			btn.addEventListener(ButtonBase.CLICK, pData.onShare);
			tButtonsOnLeft++;
			
			if(!Fewf.isExternallyLoaded) {
				btn = imgurButton = tTray.addChild(new SpriteButton({ x:tX+tButtonXInc*tButtonsOnLeft, y:yy, width:tButtonSize, height:tButtonSize, obj_scale:0.45, obj:new $ImgurIcon(), origin:0.5 })) as SpriteButton;
				btn.addEventListener(ButtonBase.CLICK, function(e:*){
					ImgurApi.uploadImage(_character);
					imgurButton.disable();
				});
				tButtonsOnLeft++;
			} else {
				btn = imgurButton = tTray.addChild(new SpriteButton({ x:tX+tButtonXInc*tButtonsOnLeft, y:yy, width:tButtonSize, height:tButtonSize, obj_scale:0.415, obj:new $CopyIcon(), origin:0.5 })) as SpriteButton;
				btn.addEventListener(ButtonBase.CLICK, function(e:*){
					try {
						if(ConstantsApp.ANIMATION_DOWNLOAD_ENABLED && _character.animatePose) {
							FewfDisplayUtils.copyToClipboardAnimatedGif(_character.copy().outfit.pose, 1, function(){
								imgurButton.ChangeImage(new $No());
							})
						} {
							FewfDisplayUtils.copyToClipboard(_character);
							imgurButton.ChangeImage(new $Yes());
						}
					} catch(e) {
						imgurButton.ChangeImage(new $No());
					}
					setTimeout(function(){ imgurButton.ChangeImage(new $CopyIcon()); }, 750)
				});
				tButtonsOnLeft++;
			}
			
			// ### Right Side Buttons ###
			tX = tTrayWidth*0.5-(tButtonSize*0.5 + tButtonSizeSpace);

			btn = tTray.addChild(new SpriteButton({ x:tX-tButtonXInc*tButtonOnRight, y:yy, width:tButtonSize, height:tButtonSize, obj_scale:0.42, obj:new $Trash(), origin:0.5 })) as SpriteButton;
			btn.addEventListener(ButtonBase.CLICK, pData.onTrash);
			tButtonOnRight++;

			// Dice icon based on https://www.iconexperience.com/i_collection/icons/?icon=dice
			btn = tTray.addChild(new SpriteButton({ x:tX-tButtonXInc*tButtonOnRight, y:yy, width:tButtonSize, height:tButtonSize, obj_scale:1, obj:new $Dice(), origin:0.5 })) as SpriteButton;
			btn.addEventListener(ButtonBase.CLICK, pData.onRandomize);
			tButtonOnRight++;
			
			animateButton = tTray.addChild(new SpriteButton({ x:tX-tButtonXInc*tButtonOnRight, y:yy, width:tButtonSize, height:tButtonSize, obj_scale:0.5, obj:new Sprite(), origin:0.5 })) as SpriteButton;
			animateButton.addEventListener(ButtonBase.CLICK, pData.onAnimate);
			toggleAnimateButtonAsset(_character.animatePose);
			tButtonOnRight++;
			
			/********************
			* Scale slider
			*********************/
			var tTotalButtons:Number = tButtonsOnLeft+tButtonOnRight;
			var tSliderWidth:Number = tTrayWidth - tButtonXInc*(tTotalButtons) - 20;
			tX = -tSliderWidth*0.5+(tButtonXInc*((tButtonsOnLeft-tButtonOnRight)*0.5))-1;
			scaleSlider = new FancySlider(tSliderWidth).setXY(tX, yy)
				.setSliderParams(1, 8, _character.outfit.scaleX)
				.appendTo(tTray);
			scaleSlider.addEventListener(FancySlider.CHANGE, pData.onScale);
			
			
			/********************
			* Under Toolbox
			*********************/
			if(!ConstantsApp.CONFIG_TAB_ENABLED) {
				addChild(new PasteShareCodeInput({ x:18, y:33, onChange:pData.onShareCodeEntered }));
			}
			
			// Item Filter Banner
			var hh:Number = 30;
			_itemFilterBanner = new RoundedRectangle({ width:260, height:30 }).setXY(-112, 18).draw(0xDDDDFF, 4, 0x0000FF);
			yy = hh/2;
			new TextBase({ text:"share_filter_banner", x:10, y:yy, originX:0, color:0x111111 }).appendTo(_itemFilterBanner);
			new ScaleButton({ obj:new $No(), obj_scale:0.5 }).setXY(245, yy)
				.appendTo(_itemFilterBanner).on(ButtonBase.CLICK, pData.onItemFilterClosed);
			
			/********************
			* Events
			*********************/
			Fewf.dispatcher.addEventListener(ImgurApi.EVENT_DONE, _onImgurDone);
			
			pData = null;
		}
		public function setXY(pX:Number, pY:Number) : Toolbox { x = pX; y = pY; return this; }
		public function appendTo(target:Sprite): Toolbox { target.addChild(this); return this; }
		
		public function toggleAnimateButtonAsset(pOn:Boolean) : void {
			animateButton.ChangeImage(pOn ? new $PauseButton() : new $PlayButton());
		}
		
		public function showItemFilterBanner() : void {
			_itemFilterBanner.appendTo(this);
		}
		
		public function hideItemFilterBanner() : void {
			if(_itemFilterBanner.parent) _itemFilterBanner.parent.removeChild(_itemFilterBanner);
		}
		
		private function _onImgurDone(e:*) : void {
			imgurButton.enable();
		}
	}
}
