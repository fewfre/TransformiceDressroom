package app.ui
{
	import com.fewfre.display.ButtonBase;
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import flash.display.*;
	import flash.net.*;
	
	public class Toolbox extends MovieClip
	{
		// Storage
		private var _downloadTray	: RoundedRectangle;
		private var _bg				: RoundedRectangle;
		public var scaleSlider		: FancySlider;
		public var animateButton	: SpriteButton;
		
		// Constructor
		// pData = { x:Number, y:Number, character:Character, onSave:Function, onAnimate:Function, onRandomize:Function, onShare:Function, onScale:Function }
		public function Toolbox(pData:Object) {
			this.x = pData.x;
			this.y = pData.y;
			
			var btn:ButtonBase;
			
			_bg = addChild(new RoundedRectangle({ width:365, height:35, origin:0.5 }));
			_bg.drawSimpleGradient(ConstantsApp.COLOR_TRAY_GRADIENT, 15, ConstantsApp.COLOR_TRAY_B_1, ConstantsApp.COLOR_TRAY_B_2, ConstantsApp.COLOR_TRAY_B_3);
			
			/********************
			* Download Button
			*********************/
			_downloadTray = addChild(new RoundedRectangle({ x:-_bg.Width*0.5 + 30, y:6, width:60, height:60, origin:0.5 }));
			_downloadTray.drawSimpleGradient(ConstantsApp.COLOR_TRAY_GRADIENT, 15, ConstantsApp.COLOR_TRAY_B_1, ConstantsApp.COLOR_TRAY_B_2, ConstantsApp.COLOR_TRAY_B_3);
			
			btn = _downloadTray.addChild(new SpriteButton({ x:1, y:1, width:47, height:47, obj_scale:0.8, obj:new $LargeDownload(), origin:0.5 }));
			btn.addEventListener(ButtonBase.CLICK, pData.onSave);
			
			/********************
			* Download Button
			*********************/
			var tTray = _bg.addChild(new MovieClip());
			var tTrayWidth = _bg.Width - _downloadTray.Width;
			tTray.x = -(_bg.Width*0.5) + (tTrayWidth*0.5) + (_bg.Width - tTrayWidth);
			
			/********************
			* Toolbar Button
			*********************/
			var tButtonSize = 28, tButtonSizeSpace=5, tButtonXInc=tButtonSize+tButtonSizeSpace;
			var tX = 0, tY = 0, tButtonsOnLeft = 0, tButtonOnRight = 0;
			
			// ### Left Side Buttons ###
			tX = -tTrayWidth*0.5 + tButtonSize*0.5 + tButtonSizeSpace;
			
			/*btn = tTray.addChild(new SpriteButton({ x:tX+tButtonXInc*tButtonsOnLeft, y:tY, width:tButtonSize, height:tButtonSize, obj_scale:0.45, obj:new $Link(), origin:0.5 }));
			btn.addEventListener(ButtonBase.CLICK, pData.onShare);
			tButtonsOnLeft++;*/
			
			// ### Right Side Buttons ###
			tX = tTrayWidth*0.5-(tButtonSize*0.5 + tButtonSizeSpace);

			btn = tTray.addChild(new SpriteButton({ x:tX-tButtonXInc*tButtonOnRight, y:tY, width:tButtonSize, height:tButtonSize, obj_scale:0.5, obj:new $Refresh(), origin:0.5 }));
			btn.addEventListener(ButtonBase.CLICK, pData.onRandomize);
			tButtonOnRight++;
			
			animateButton = tTray.addChild(new SpriteButton({ x:tX-tButtonXInc*tButtonOnRight, y:tY, width:tButtonSize, height:tButtonSize, obj_scale:0.5, obj:new MovieClip(), origin:0.5 }));
			animateButton.addEventListener(ButtonBase.CLICK, pData.onAnimate);
			toggleAnimateButtonAsset(pData.character.animatePose);
			tButtonOnRight++;
			
			/********************
			* Scale slider
			*********************/
			var tTotalButtons = tButtonsOnLeft+tButtonOnRight;
			var tSliderWidth = tTrayWidth - tButtonXInc*(tTotalButtons) - 20;
			scaleSlider = tTray.addChild(new FancySlider({
				x:-tSliderWidth*0.5+(tButtonXInc*((tButtonsOnLeft-tButtonOnRight)*0.5))-1, y:tY,
				value: pData.character.outfit.scaleX*10, min:10, max:40, width:tSliderWidth
			}));
			scaleSlider.addEventListener(FancySlider.CHANGE, pData.onScale);
			
			pData = null;
		}
		
		public function toggleAnimateButtonAsset(pOn:Boolean) : void {
			animateButton.ChangeImage(pOn ? new $PauseButton() : new $PlayButton());
		}
	}
}
