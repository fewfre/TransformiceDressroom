package app.ui
{
	import com.fewfre.display.*;
	import com.fewfre.events.*;
	import com.fewfre.utils.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import flash.display.*;
	import flash.text.TextTranslated;
	import flash.events.MouseEvent;
	import app.ui.common.RoundedRectangle;
	import flash.events.Event;
	import app.ui.common.FancySlider;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import fl.controls.Button;
	
	public class AnimationControls extends Sprite
	{
		// Storage
		private var _bg : RoundedRectangle;
		private var _dragHandle : Sprite;
		
		public var _animateButton : SpriteButton;
		public var _loopButton : SpriteButton;
		public var _speedButtons : Vector.<PushButton>;
		public var _nextFrameButton : SpriteButton;
		public var _framesText : TextBase;
		
		public var _timelineSlider : FancySlider;
		
		private var _animationTarget : MovieClip;
		
		private var _animating : Boolean;
		private var _looping : Boolean;
		private var _speedMulti : Number;
		
		private static var ORIGINAL_FRAMERATE : Number = -1;
		
		// Constructor
		public function AnimationControls() {
			super();
			if(ORIGINAL_FRAMERATE == -1) ORIGINAL_FRAMERATE = Fewf.stage.frameRate;
			_bg = new RoundedRectangle(220, 35, { originY:0.5 }).draw(0x444444, 3, 0x222222).appendTo(this);
			
			_animating = false;
			_looping = true;
			_speedMulti = 1;
			
			visible = false;
			
			/////////////////////
			// Drag Handle
			/////////////////////
			_dragHandle = new Sprite();
			_dragHandle.graphics.beginFill(0, 0.35);
			_dragHandle.graphics.drawRect(-7, -_bg.Height/2, 14, _bg.Height-2);
			_dragHandle.graphics.endFill();
			_dragHandle.graphics.beginFill(0xFFFFFF);
			_dragHandle.graphics.drawCircle(0, 0, 2);
			_dragHandle.graphics.drawCircle(0, -10, 2);
			_dragHandle.graphics.drawCircle(0, 10, 2);
			_dragHandle.graphics.endFill();
			addChild(_dragHandle);
			_dragHandle.x = 7 + 1.5;
			_dragHandle.y = -0.5;
			_dragHandle.buttonMode = true;
			_dragHandle.useHandCursor = true;
			_dragHandle.addEventListener(MouseEvent.MOUSE_DOWN, _onDragStart);
			_dragHandle.addEventListener(MouseEvent.MOUSE_OVER, function(e):void{ Mouse.cursor = MouseCursor.HAND; });
			_dragHandle.addEventListener(MouseEvent.MOUSE_OUT, function(e):void{ Mouse.cursor = MouseCursor.AUTO; });
			
			/////////////////////
			// Buttons - Left
			/////////////////////
			var bsize = 28, bspace=5, tButtonXInc=bsize+bspace;
			var xx = _dragHandle.width + bsize/2 + 3, yy = 0, tButtonsOnLeft = 0, tButtonOnRight = 0;
			
			_animateButton = new SpriteButton({ x:xx, y:yy, width:bsize, height:bsize, obj_scale:0.5, obj:new Sprite(), origin:0.5 }).appendTo(this) as SpriteButton;
			_animateButton.addEventListener(ButtonBase.CLICK, _onAnimationButtonToggled);
			tButtonsOnLeft++;
			
			xx += tButtonXInc;
			_loopButton = new SpriteButton({ x:xx, y:yy, width:bsize, height:bsize, obj_scale:0.5, obj:new Sprite(), origin:0.5 }).appendTo(this) as SpriteButton;
			_loopButton.addEventListener(ButtonBase.CLICK, _onLoopButtonToggled);
			tButtonsOnLeft++;
			
			xx += tButtonXInc;
			var msize = bsize/2-1;
			_speedButtons = new <PushButton>[
				new PushButton({ text:'loading_progress', width:msize, height:msize, origin:0.5, data:{ speed:0.25 }, allowToggleOff:false }).setXY(xx - msize/2-1, yy - msize/2-1).on(PushButton.STATE_CHANGED_AFTER, _onSpeedButtonClicked).appendTo(this) as PushButton,
				new PushButton({ text:'loading_progress', width:msize, height:msize, origin:0.5, data:{ speed:0.50 }, allowToggleOff:false }).setXY(xx + msize/2+1, yy - msize/2-1).on(PushButton.STATE_CHANGED_AFTER, _onSpeedButtonClicked).appendTo(this) as PushButton,
				new PushButton({ text:'loading_progress', width:msize, height:msize, origin:0.5, data:{ speed:1.00 }, allowToggleOff:false }).setXY(xx - msize/2-1, yy + msize/2+1).on(PushButton.STATE_CHANGED_AFTER, _onSpeedButtonClicked).appendTo(this) as PushButton,
				new PushButton({ text:'loading_progress', width:msize, height:msize, origin:0.5, data:{ speed:2.00 }, allowToggleOff:false }).setXY(xx + msize/2+1, yy + msize/2+1).on(PushButton.STATE_CHANGED_AFTER, _onSpeedButtonClicked).appendTo(this) as PushButton,
			];
			_speedButtons[0].Text.setUntranslatedText('¼');
			_speedButtons[1].Text.setUntranslatedText('½');
			_speedButtons[2].Text.setUntranslatedText('1'); _speedButtons[2].toggleOn(false);
			_speedButtons[3].Text.setUntranslatedText('2');
			for each(var sb:PushButton in _speedButtons) { sb.Text.size = 10; sb.Text.x -= sb.data.speed < 1 ? -0.5 : 0; sb.Text.y -= 0.5; }
			tButtonsOnLeft++;
			
			xx += tButtonXInc;
			var sliderLeft:Number = xx - bsize / 2;
			
			/////////////////////
			// Buttons - Right
			/////////////////////
			xx = _bg.Width - bsize/2 - 4, yy = 0, tButtonsOnLeft = 0, tButtonOnRight = 0;
			
			_nextFrameButton = new SpriteButton({ x:xx-tButtonXInc*tButtonsOnLeft, y:yy, width:bsize, height:bsize, obj_scale:0.5, obj:new Sprite(), origin:0.5 }).appendTo(this) as SpriteButton;
			_nextFrameButton.addEventListener(ButtonBase.CLICK, _onNextFrameClicked);
			tButtonOnRight++;
			_framesText = new TextBase('', { size:8 }).setXY(_nextFrameButton.x, _nextFrameButton.y).appendTo(this);
			_framesText.mouseEnabled = false;
			_framesText.mouseChildren = false;
			
			var sliderRight:Number = _nextFrameButton.x - bsize / 2 - bspace;
			
			/////////////////////
			// Timeline
			/////////////////////
			var tTotalButtons:Number = tButtonsOnLeft+tButtonOnRight;
			var tSliderWidth:Number = sliderRight - sliderLeft;
			_timelineSlider = new FancySlider(tSliderWidth).setXY(sliderLeft, 0)
				.setSliderParams(1, 1, 1)
				.appendTo(this);
			_timelineSlider.addEventListener(FancySlider.CHANGE, _onTimelineSliderChanged);
			
			/////////////////////
			// Misc
			/////////////////////
			new ScaleButton({ obj:new $WhiteX(), obj_scale:0.25 }).setXY(_bg.Width, -_bg.Height/2).appendTo(this)
				.on(MouseEvent.CLICK, function(e){ dispatchEvent(new Event(Event.CLOSE)); });
			
			_updateUIBasedOnState();
		}
		public function setXY(pX:Number, pY:Number) : AnimationControls { x = pX; y = pY; return this; }
		public function appendTo(target:Sprite): AnimationControls { target.addChild(this); return this; }

		/****************************
		* Public
		*****************************/
		public function show() : void {
			visible = true;
			_animating = true;
		}
		public function hide() : void {
			visible = false;
			_animating = false;
			Fewf.stage.frameRate = ORIGINAL_FRAMERATE;
			
			_applyStateToAnimationTarget();
			_removeTargetEventListeners(_animationTarget);
			_animationTarget = null;
		}
		// Ignores target based in if controls are not visible
		public function setTargetMovieClip(pTarget:MovieClip) : void {
			if(!visible) return;
			if(_animationTarget) {
				_removeTargetEventListeners(_animationTarget);
			}
			_animationTarget = pTarget;
			_addTargetEventListeners(_animationTarget);
			_timelineSlider.setSliderParams(1, _animationTarget.totalFrames, 1, 1);
			_applyStateToAnimationTarget();
			_updateUIBasedOnState();
		}

		/****************************
		* Private
		*****************************/
		private function _addTargetEventListeners(pTarget:MovieClip) : void {
			_animationTarget.addEventListener(Event.ENTER_FRAME, _onFrameChanged);
		}
		private function _removeTargetEventListeners(pTarget:MovieClip) : void {
			_animationTarget.removeEventListener(Event.ENTER_FRAME, _onFrameChanged);
		}
		
		private function _updateUIBasedOnState() : void {
			_animateButton.ChangeImage(!_animating ? new $PlayButton() : new $PauseButton());
			_loopButton.ChangeImage(_looping ? new $Refresh() : newNoLoopIcon());
			
			_nextFrameButton.visible = !_animating;
			if(_animationTarget) {
				_timelineSlider.value = _animationTarget.currentFrame;
				_framesText.text = _animationTarget.currentFrame+"/"+_animationTarget.totalFrames;
			}
		}
		private function newNoLoopIcon() : Sprite {
			var icon:Sprite = new Sprite();
			var wallWidth:Number = 6, spacing:Number = 2;
			var offsetX:Number = -(spacing + wallWidth) / 2; // make it centered around origin
			
			var arrow:MovieClip = new $BackArrow();
			arrow.scaleX = -1;
			arrow.x = offsetX;
			
			icon.addChild(arrow);
			icon.graphics.beginFill(0xFFFFFF);
			icon.graphics.lineStyle(2, 0);
			icon.graphics.drawRect(offsetX + arrow.width/2 + 2, -arrow.height/2, wallWidth, arrow.height);
			icon.graphics.endFill();
			return icon;
		}
		
		private function _applyStateToAnimationTarget() : void {
			if(_animating) {
				_playAnimationTarget();
			} else {
				_stopAnimationTarget();
			}
			Fewf.stage.frameRate = !_animating ? ORIGINAL_FRAMERATE : ORIGINAL_FRAMERATE * _speedMulti;
		}
		
		private function _playAnimationTarget() : void {
			_animationTarget.play();
			_playAnimationTargetChildren();
		}
		private function _playAnimationTargetChildren() : void {
			// This is needed to re-start children after animation unpaused
			for(var i:int = 0; i < _animationTarget.numChildren; i++){
				if(_animationTarget.getChildAt(i) is MovieClip) {
					(_animationTarget.getChildAt(i) as MovieClip).play();
				}
			}
		}
		
		private function _stopAnimationTarget() : void {
			_animationTarget.stop();
			_stopAnimationTargetChildren();
		}
		private function _stopAnimationTargetChildren() : void {
			// This is needed to avoid the heart icon from flashing while an animation is paused
			// Also stop stuff like tears from animating while stopped (which is good)
			for(var i:int = 0; i < _animationTarget.numChildren; i++){
				if(_animationTarget.getChildAt(i) is MovieClip) {
					(_animationTarget.getChildAt(i) as MovieClip).stop();
				}
			}
		}

		/****************************
		* Events
		*****************************/
		private function _onDragStart(e:MouseEvent) : void {
			this.startDrag();
			Mouse.cursor = MouseCursor.HAND;

			// Handle drop cases.
			stage.addEventListener(Event.MOUSE_LEAVE, _onDragDropped);
			_dragHandle.addEventListener(MouseEvent.MOUSE_UP, _onDragDropped);
		}
		private function _onDragDropped(e:Event) : void {
			stage.removeEventListener(Event.MOUSE_LEAVE, _onDragDropped);
			_dragHandle.removeEventListener(MouseEvent.MOUSE_UP, _onDragDropped);
			
			Mouse.cursor = MouseCursor.AUTO;
			this.stopDrag();
		}
		
		private function _onFrameChanged(e:Event) : void {
			if(!_looping && _animationTarget.currentFrame == _animationTarget.totalFrames) {
				_stopAnimationTarget();
				_animating = false;
			}
			_updateUIBasedOnState();
		}
		
		private function _onAnimationButtonToggled(e:Event) : void {
			_animating = !_animating;
			_updateUIBasedOnState();
			if(_animating) {
				_playAnimationTarget();
			} else {
				_stopAnimationTarget();
			}
		}
		
		private function _onLoopButtonToggled(e:Event) : void {
			_looping = !_looping;
			_updateUIBasedOnState();
			_animating = true;
			_animationTarget.gotoAndPlay(0);
			_playAnimationTargetChildren();
		}
		
		private function _onSpeedButtonClicked(e:FewfEvent) : void {
			_speedMulti = e.data.speed;
			_untoggle(_speedButtons, e.target as PushButton);
			_applyStateToAnimationTarget();
		}
		private function _untoggle(pList:Vector.<PushButton>, pButton:PushButton=null) : void {
			for(var i:int = 0; i < pList.length; i++) {
				if (pList[i].pushed && pList[i] != pButton) {
					pList[i].toggleOff();
				}
			}
		}
		
		private function _onNextFrameClicked(e:Event) : void {
			if(_animationTarget.currentFrame == _animationTarget.totalFrames) {
				_animationTarget.gotoAndStop(1);
			} else {
				_animationTarget.nextFrame();
			}
			_stopAnimationTargetChildren();
			_updateUIBasedOnState();
		}
		
		private function _onTimelineSliderChanged(e:Event) : void {
			_animationTarget.gotoAndStop(_timelineSlider.value);
			_stopAnimationTargetChildren();
			_applyStateToAnimationTarget();
			_updateUIBasedOnState();
		}
	}
}
