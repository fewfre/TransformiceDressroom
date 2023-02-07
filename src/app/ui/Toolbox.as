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
		
		public var scaleSlider		: Object;//FancySlider;
		public var animateButton	: SpriteButton;
		public var imgurButton		: SpriteButton;
		public var curanimationFrameText: TextBase;
		
		// Constructor
		// pData = { x:Number, y:Number, character:Character, onSave:Function, onAnimate:Function, onRandomize:Function, onTrash:Function, onShare:Function, onScale:Function }
		public function Toolbox(pData:Object) {
			this.x = pData.x;
			this.y = pData.y;
			_character = pData.character;
			
			var btn:ButtonBase;
			
			_bg = addChild(new RoundedRectangle({ width:365, height:35, origin:0.5 })) as RoundedRectangle;
			_bg.drawSimpleGradient(ConstantsApp.COLOR_TRAY_GRADIENT, 15, ConstantsApp.COLOR_TRAY_B_1, ConstantsApp.COLOR_TRAY_B_2, ConstantsApp.COLOR_TRAY_B_3);
			
			/********************
			* Download Button
			*********************/
			_downloadTray = addChild(new FrameBase({ x:-_bg.Width*0.5 + 33, y:9, width:66, height:66, origin:0.5 })) as FrameBase;
			/*_downloadTray.drawSimpleGradient(ConstantsApp.COLOR_TRAY_GRADIENT, 15, ConstantsApp.COLOR_TRAY_B_1, ConstantsApp.COLOR_TRAY_B_2, ConstantsApp.COLOR_TRAY_B_3);*/
			
			btn = _downloadTray.addChild(new SpriteButton({ width:46, height:46, obj:new $LargeDownload(), origin:0.5 })) as ButtonBase;
			btn.addEventListener(ButtonBase.CLICK, pData.onSave);
			
			/********************
			* Toolbar Buttons
			*********************/
			var tTray:Sprite = _bg.addChild(new Sprite()) as Sprite;
			var tTrayWidth = _bg.Width - _downloadTray.Width;
			tTray.x = -(_bg.Width*0.5) + (tTrayWidth*0.5) + (_bg.Width - tTrayWidth);
			
			var tButtonSize = 28, tButtonSizeSpace=5, tButtonXInc=tButtonSize+tButtonSizeSpace;
			var tX = 0, tY = 0, tButtonsOnLeft = 0, tButtonOnRight = 0;
			
			// ### Left Side Buttons ###
			tX = -tTrayWidth*0.5 + tButtonSize*0.5 + tButtonSizeSpace;
			
			btn = tTray.addChild(new SpriteButton({ x:tX+tButtonXInc*tButtonsOnLeft, y:tY, width:tButtonSize, height:tButtonSize, obj_scale:0.45, obj:new $Link(), origin:0.5 })) as SpriteButton;
			btn.addEventListener(ButtonBase.CLICK, pData.onShare);
			tButtonsOnLeft++;
			
			if(!Fewf.isExternallyLoaded) {
				btn = imgurButton = tTray.addChild(new SpriteButton({ x:tX+tButtonXInc*tButtonsOnLeft, y:tY, width:tButtonSize, height:tButtonSize, obj_scale:0.45, obj:new $ImgurIcon(), origin:0.5 })) as SpriteButton;
				btn.addEventListener(ButtonBase.CLICK, function(e:*){
					ImgurApi.uploadImage(_character);
					imgurButton.disable();
				});
				tButtonsOnLeft++;
			} else {
				btn = imgurButton = tTray.addChild(new SpriteButton({ x:tX+tButtonXInc*tButtonsOnLeft, y:tY, width:tButtonSize, height:tButtonSize, obj_scale:0.415, obj:new $CopyIcon(), origin:0.5 })) as SpriteButton;
				btn.addEventListener(ButtonBase.CLICK, function(e:*){
					try {
						FewfDisplayUtils.copyToClipboard(_character);
						imgurButton.ChangeImage(new $Yes());
					} catch(e) {
						imgurButton.ChangeImage(new $No());
					}
					setTimeout(function(){ imgurButton.ChangeImage(new $CopyIcon()); }, 750)
				});
				tButtonsOnLeft++;
			}
			
			// ### Right Side Buttons ###
			tX = tTrayWidth*0.5-(tButtonSize*0.5 + tButtonSizeSpace);

			btn = tTray.addChild(new SpriteButton({ x:tX-tButtonXInc*tButtonOnRight, y:tY, width:tButtonSize, height:tButtonSize, obj_scale:0.42, obj:new $Trash(), origin:0.5 })) as SpriteButton;
			btn.addEventListener(ButtonBase.CLICK, pData.onTrash);
			tButtonOnRight++;

			// Dice icon based on https://www.iconexperience.com/i_collection/icons/?icon=dice
			btn = tTray.addChild(new SpriteButton({ x:tX-tButtonXInc*tButtonOnRight, y:tY, width:tButtonSize, height:tButtonSize, obj_scale:1, obj:new $Dice(), origin:0.5 })) as SpriteButton;
			btn.addEventListener(ButtonBase.CLICK, pData.onRandomize);
			tButtonOnRight++;
			
			animateButton = tTray.addChild(new SpriteButton({ x:tX-tButtonXInc*tButtonOnRight, y:tY, width:tButtonSize, height:tButtonSize, obj_scale:0.5, obj:new Sprite(), origin:0.5 })) as SpriteButton;
			animateButton.addEventListener(ButtonBase.CLICK, pData.onAnimate);
			toggleAnimateButtonAsset(_character.animatePose);
			tButtonOnRight++;
			
			if(ConstantsApp.ANIMATION_FRAME_BY_FRAME) {
				curanimationFrameText = tTray.addChild(new TextBase({ text:"loading_progress", originX:1, x:_bg.Width/2-50, y:35 })) as TextBase;
				curanimationFrameText.setValues( _character.outfit.poseCurrentFrame + "/" + _character.outfit.poseTotalFrames );
			}
			
			/********************
			* Scale slider
			*********************/
			var tTotalButtons = tButtonsOnLeft+tButtonOnRight;
			var tSliderWidth = tTrayWidth - tButtonXInc*(tTotalButtons) - 20;
			var sliderProps = {
				x:-tSliderWidth*0.5+(tButtonXInc*((tButtonsOnLeft-tButtonOnRight)*0.5))-1, y:tY,
				value: _character.outfit.scaleX*10, min:10, max:80, width:tSliderWidth
			};
			if(Fewf.isExternallyLoaded) {
				scaleSlider = tTray.addChild(ParentApp.newFancySlider(sliderProps));
				scaleSlider.addEventListener(FancySlider.CHANGE, pData.onScale);
			} else {
				scaleSlider = tTray.addChild(new FancySlider(sliderProps));
				scaleSlider.addEventListener(FancySlider.CHANGE, pData.onScale);
			}
			
			if(!ConstantsApp.CONFIG_TAB_ENABLED) {
				addChild(new PasteShareCodeInput({ x:18, y:33, onChange:pData.onShareCodeEntered }));
			}
			
			/********************
			* Events
			*********************/
			Fewf.dispatcher.addEventListener(ImgurApi.EVENT_DONE, _onImgurDone);
			
			pData = null;
		}
		
		public function toggleAnimateButtonAsset(pOn:Boolean) : void {
			animateButton.ChangeImage(pOn ? new $PauseButton() : new $PlayButton());
		}
		
		private function _onImgurDone(e:*) : void {
			imgurButton.enable();
		}
	}
}
