package app.ui
{
	import com.fewfre.display.ButtonBase;
	import com.fewfre.display.TextBase;
	import com.fewfre.utils.Fewf;
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import flash.display.*;
	import flash.net.*;
	import flash.text.*;
	import flash.events.*;
	import flash.events.Event;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import fl.managers.FocusManager;
	import flash.display.MovieClip;
	
	public class Toolbox extends MovieClip
	{
		// Storage
		private var _downloadTray	: FrameBase;
		private var _bg				: RoundedRectangle;
		public var scaleSlider		: FancySlider;
		public var animateButton	: SpriteButton;
		public var imgurButton		: SpriteButton;
		public var curanimationFrameText: TextBase;
		
		// Constructor
		// pData = { x:Number, y:Number, character:Character, onSave:Function, onAnimate:Function, onRandomize:Function, onTrash:Function, onShare:Function, onScale:Function }
		public function Toolbox(pData:Object) {
			this.x = pData.x;
			this.y = pData.y;
			
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
			var tTray = _bg.addChild(new MovieClip());
			var tTrayWidth = _bg.Width - _downloadTray.Width;
			tTray.x = -(_bg.Width*0.5) + (tTrayWidth*0.5) + (_bg.Width - tTrayWidth);
			
			var tButtonSize = 28, tButtonSizeSpace=5, tButtonXInc=tButtonSize+tButtonSizeSpace;
			var tX = 0, tY = 0, tButtonsOnLeft = 0, tButtonOnRight = 0;
			
			// ### Left Side Buttons ###
			tX = -tTrayWidth*0.5 + tButtonSize*0.5 + tButtonSizeSpace;
			
			btn = tTray.addChild(new SpriteButton({ x:tX+tButtonXInc*tButtonsOnLeft, y:tY, width:tButtonSize, height:tButtonSize, obj_scale:0.45, obj:new $Link(), origin:0.5 }));
			btn.addEventListener(ButtonBase.CLICK, pData.onShare);
			tButtonsOnLeft++;
			
			// btn = imgurButton = tTray.addChild(new SpriteButton({ x:tX+tButtonXInc*tButtonsOnLeft, y:tY, width:tButtonSize, height:tButtonSize, obj_scale:0.45, obj:new $ImgurIcon(), origin:0.5 })) as SpriteButton;
			// var tCharacter = pData.character;
			// btn.addEventListener(ButtonBase.CLICK, function(e:*){
			// 	// TODO
			// 	// ImgurApi.uploadImage(tCharacter);
			// 	imgurButton.disable();
			// });
			// tButtonsOnLeft++;
			
			// ### Right Side Buttons ###
			tX = tTrayWidth*0.5-(tButtonSize*0.5 + tButtonSizeSpace);

			btn = tTray.addChild(new SpriteButton({ x:tX-tButtonXInc*tButtonOnRight, y:tY, width:tButtonSize, height:tButtonSize, obj_scale:0.42, obj:new $Trash(), origin:0.5 }));
			btn.addEventListener(ButtonBase.CLICK, pData.onTrash);
			tButtonOnRight++;

			btn = tTray.addChild(new SpriteButton({ x:tX-tButtonXInc*tButtonOnRight, y:tY, width:tButtonSize, height:tButtonSize, obj_scale:0.5, obj:new $Refresh(), origin:0.5 }));
			btn.addEventListener(ButtonBase.CLICK, pData.onRandomize);
			tButtonOnRight++;
			
			animateButton = tTray.addChild(new SpriteButton({ x:tX-tButtonXInc*tButtonOnRight, y:tY, width:tButtonSize, height:tButtonSize, obj_scale:0.5, obj:new MovieClip(), origin:0.5 }));
			animateButton.addEventListener(ButtonBase.CLICK, pData.onAnimate);
			toggleAnimateButtonAsset(pData.character.animatePose);
			tButtonOnRight++;
			
			// if(ConstantsApp.ANIMATION_FRAME_BY_FRAME) {
			// 	curanimationFrameText = tTray.addChild(new TextBase({ text:"loading_progress", originX:1, x:_bg.Width/2-50, y:35 }));
			// 	curanimationFrameText.setValues( tCharacter.outfit.poseCurrentFrame + "/" + tCharacter.outfit.poseTotalFrames );
			// }
			
			/********************
			* Scale slider
			*********************/
			var tTotalButtons = tButtonsOnLeft+tButtonOnRight;
			var tSliderWidth = tTrayWidth - tButtonXInc*(tTotalButtons) - 20;
			scaleSlider = tTray.addChild(new FancySlider({
				x:-tSliderWidth*0.5+(tButtonXInc*((tButtonsOnLeft-tButtonOnRight)*0.5))-1, y:tY,
				value: pData.character.outfit.scaleX*10, min:10, max:80, width:tSliderWidth
			}));
			scaleSlider.addEventListener(FancySlider.CHANGE, pData.onScale);
			
			/****************************
			* Selectable text field
			*****************************/
			_createShareField(pData.onShareCodeEntered);
			
			/********************
			* Events
			*********************/
			// TODO
			// Fewf.dispatcher.addEventListener(ImgurApi.EVENT_DONE, _onImgurDone);
			
			pData = null;
		}
		
		public function toggleAnimateButtonAsset(pOn:Boolean) : void {
			animateButton.ChangeImage(pOn ? new $PauseButton() : new $PlayButton());
		}
		
		private function _onImgurDone(e:*) : void {
			imgurButton.enable();
		}
		
		/****************************
		* Share Code Paste Field Stuff
		*****************************/
		private var _textField			: TextField;
		private var _placeholderText	: TextBase;
		private var _placeholderState	: String;
		private var _placeholderTimeout	: Number;
		private var _shareFocusHandler	: fl.managers.FocusManager;
		
		private function _createShareField(pOnShareCodeEntered) {
			
			var tTFWidth:Number = 250, tTFHeight:Number = 18, tTFPaddingX:Number = 5, tTFPaddingY:Number = 5;
			// So much easier than doing it with those darn native text field options which have no padding.
			var tTextBackground:RoundedRectangle = addChild(new RoundedRectangle({ x:18, y:33, width:tTFWidth+tTFPaddingX*2, height:tTFHeight+tTFPaddingY*2, origin:0.5 })) as RoundedRectangle;
			tTextBackground.draw(0xdcdfea, 7, 0x444444, 0x444444, 0x444444);
			
			_textField = tTextBackground.addChild(new TextField()) as TextField;
			_textField.type = TextFieldType.INPUT;
			_textField.multiline = false;
			_textField.width = tTFWidth;
			_textField.height = tTFHeight;
			_textField.x = tTFPaddingX - tTextBackground.Width*0.5;
			_textField.y = tTFPaddingY - tTextBackground.Height*0.5;
			
			// Why TEXT_INPUT - https://stackoverflow.com/a/10049605/1411473
			_textField.addEventListener(TextEvent.TEXT_INPUT, function(e){
				var code = e.text;//_text.text;
				_textField.text = "";
				_forceShareFieldUnfocus();
				pOnShareCodeEntered(code, _setShareCodeProgress);
				e.preventDefault();
			});
			_placeholderText = tTextBackground.addChild(new TextBase({ text:"share_paste", originX:0, x:_textField.x+4 })) as TextBase;
			_placeholderText.mouseChildren = false;
			_placeholderText.mouseEnabled = false;
			_setShareCodeProgress("placeholder");
			
			_textField.addEventListener(FocusEvent.FOCUS_IN,  focusIn);
			_textField.addEventListener(FocusEvent.FOCUS_OUT, focusOut);
			// https://stackoverflow.com/a/3215687/1411473
			_textField.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, focusOut);
			_textField.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, focusOut);
		}
		
		private function focusIn(event:Event):void {
			if(_placeholderState != "focusIn") {
				_setShareCodeProgress("focusIn");
			}
		}
		
		private function focusOut(event:Event):void {
			if(_placeholderState == "focusIn") {
				_textField.text = "";
				_forceShareFieldUnfocus();
				_setShareCodeProgress("placeholder");
			}
		}
		
		private function _forceShareFieldUnfocus():void {
			_textField.stage.focus = null;
		}
		
		private function _setShareCodeProgress(state):void {
			_placeholderState = state;
			_placeholderText.alpha = 1;
			clearTimeout(_placeholderTimeout);
			switch(state) {
				case "focusIn": {
					_placeholderText.alpha = 0;
					break;
				}
				case "placeholder": {
					_placeholderText.setText("share_paste");
					_placeholderText.color = 0x666666;
					break;
				}
				case "success": {
					_placeholderText.setText("share_paste_success");
					_placeholderText.color = 0x01910d;
					_placeholderTimeout = setTimeout(function(){
						_setShareCodeProgress("placeholder");
					}, 1000);
					break;
				}
				case "invalid": {
					_placeholderText.setText("share_paste_invalid");
					_placeholderText.color = 0xc93302;
					_placeholderTimeout = setTimeout(function(){
						_setShareCodeProgress("placeholder");
					}, 1000);
					break;
				}
			}
		};
	}
}
