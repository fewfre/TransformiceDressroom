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
		private var _bg				: RoundedRectangle;
		public var scaleSlider		: FancySlider;
		public var animateButton	: SpriteButton;
		
		// Constructor
		// pData = { x:Number, y:Number, character:Character, onSave:Function, onAnimate:Function, onRandomize:Function, onShare:Function, onScale:Function }
		public function Toolbox(pData:Object) {
			this.x = pData.x;
			this.y = pData.y;
			
			_bg = addChild(new RoundedRectangle({ width:365, height:35, origin:0.5 }));
			_bg.drawSimpleGradient(ConstantsApp.COLOR_TRAY_GRADIENT, 15, ConstantsApp.COLOR_TRAY_B_1, ConstantsApp.COLOR_TRAY_B_2, ConstantsApp.COLOR_TRAY_B_3);
			
			var btn:ButtonBase, tButtonSize = 28, tButtonSizeSpace=5, tButtonXInc=tButtonSize+tButtonSizeSpace;
			var tX = -_bg.width*0.5 + tButtonSize*0.5 + tButtonSizeSpace, tY = 0, tButtonsOnLeft = 0, tButtonOnRight = 0;
			
			// Left Side Buttons
			btn = addChild(new SpriteButton({ x:tX, y:tY, width:tButtonSize, height:tButtonSize, obj_scale:0.4, obj:new $LargeDownload(), origin:0.5 }));
			btn.addEventListener(ButtonBase.CLICK, pData.onSave);
			tButtonsOnLeft++;
			
			animateButton = addChild(new SpriteButton({ x:tX+tButtonXInc+tButtonsOnLeft, y:tY, width:tButtonSize, height:tButtonSize, obj_scale:0.5, obj:new MovieClip(), origin:0.5 }));
			animateButton.addEventListener(ButtonBase.CLICK, pData.onAnimate);
			toggleAnimateButtonAsset(pData.character.animatePose);
			tButtonsOnLeft++;

			btn = addChild(new SpriteButton({ x:tX+tButtonXInc*tButtonsOnLeft, y:tY, width:tButtonSize, height:tButtonSize, obj_scale:0.5, obj:new $Refresh(), origin:0.5 }));
			btn.addEventListener(ButtonBase.CLICK, pData.onRandomize);
			tButtonsOnLeft++;

			/*btn = addChild(new SpriteButton({ x:tX+tButtonXInc*tButtonsOnLeft, y:tY, width:tButtonSize, height:tButtonSize, obj_scale:0.45, obj:new $Link(), origin:0.5 }));
			btn.addEventListener(ButtonBase.CLICK, pData.onShare);
			tButtonsOnLeft++;*/
			
			// Right Side Buttons
			btn = addChild(new SpriteButton({ x:_bg.width*0.5-(tButtonSize*0.5 + tButtonSizeSpace), y:tY, width:tButtonSize, height:tButtonSize, obj_scale:0.35, obj:new $GitHubIcon(), origin:0.5 }));
			btn.addEventListener(ButtonBase.CLICK, _onSourceClicked);
			tButtonOnRight++;
			
			// Character Scale
			var tSliderWidth = 315 - tButtonXInc*(tButtonsOnLeft+tButtonOnRight-0.5);//4.5;
			scaleSlider = addChild(new FancySlider({
				x:-tSliderWidth*0.5+(tButtonXInc*((tButtonsOnLeft-1)*0.5)), y:tY,
				value: pData.character.outfit.scaleX*10, min:10, max:40, width:tSliderWidth
			}));
			scaleSlider.addEventListener(FancySlider.CHANGE, pData.onScale);
			
			pData = null;
		}
		
		private function _onSourceClicked(pEvent:*) : void {
			navigateToURL(new URLRequest(ConstantsApp.SOURCE_URL), "_blank");
		}
		
		public function toggleAnimateButtonAsset(pOn:Boolean) : void {
			animateButton.ChangeImage(pOn ? new $PauseButton() : new $PlayButton());
		}
	}
}
