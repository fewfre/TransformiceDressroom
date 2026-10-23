package app.world.elements
{
	import app.world.data.ItemData;
	import app.world.data.OutfitData;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;

	public class CharacterPartner extends Sprite
	{
		private var _pose:Pose;
		private var _mainPose:Pose;
		private var _offsetX:Number;
		private var _lastMainFrame:int = -1;
		private var _lastMainPlaying:Boolean;

		public function get pose() : Pose { return _pose; }

		public function CharacterPartner(pOutfitData:OutfitData, pPartnerPoseData:ItemData, pOffsetX:Number, pMainPose:Pose) {
			_mainPose = pMainPose;
			_offsetX = pOffsetX;

			var partnerOutfit:OutfitData = pOutfitData.copy();
			partnerOutfit.setItemData(pPartnerPoseData);
			_pose = new Pose().applyOutfitData(partnerOutfit);
			_pose.mouseChildren = false;
			_pose.mouseEnabled = false;
			_pose.stopAtLastFrame();
			addChild(_pose);

			_pose.scaleX = -1;
			_pose.scaleY = 1;
			_pose.x = _offsetX;
			addEventListener(Event.ENTER_FRAME, _syncAnimation);
			_syncAnimation(null);
		}
		public function appendToAt(pParent:Sprite, pIndex:int): CharacterPartner { pParent.addChildAt(this, pIndex); return this; }
		public function removeSelf(): CharacterPartner { if(this.parent){ this.parent.removeChild(this); } return this; }

		public function destroy() : void {
			removeEventListener(Event.ENTER_FRAME, _syncAnimation);
			_mainPose = null;
		}

		public function syncToMainFrame() : void {
			var partnerClip:MovieClip = _pose.poseMC;
			partnerClip.gotoAndStop(Math.min(_mainPose.poseMC.currentFrame, partnerClip.totalFrames));
			_setPartnerPoseChildrenPlaying(false);
		}

		private function _syncAnimation(e:Event) : void {
			if(!_mainPose || !_pose) return;

			var mainClip:MovieClip = _mainPose.poseMC;
			var partnerClip:MovieClip = _pose.poseMC;
			var mainFrame:int = mainClip.currentFrame;
			var partnerFrame:int = Math.min(mainFrame, partnerClip.totalFrames);
			var mainPlaying:Boolean = mainClip.isPlaying;
			var expectedNextFrame:int = _lastMainFrame == mainClip.totalFrames ? 1 : _lastMainFrame + 1;
			var mainFrameJumped:Boolean = _lastMainFrame >= 0 && mainFrame != _lastMainFrame && mainFrame != expectedNextFrame;

			if(mainPlaying) {
				if(!partnerClip.isPlaying || !_lastMainPlaying || mainFrameJumped) {
					partnerClip.gotoAndPlay(partnerFrame);
					_setPartnerPoseChildrenPlaying(true);
				}
			} else if(partnerClip.isPlaying || _lastMainPlaying || _lastMainFrame != mainFrame) {
				partnerClip.gotoAndStop(partnerFrame);
				_setPartnerPoseChildrenPlaying(false);
			}

			_lastMainFrame = mainFrame;
			_lastMainPlaying = mainPlaying;
		}

		private function _setPartnerPoseChildrenPlaying(pPlaying:Boolean) : void {
			var partnerClip:MovieClip = _pose.poseMC;
			for(var i:int = 0; i < partnerClip.numChildren; i++) {
				if(partnerClip.getChildAt(i) is MovieClip) {
					if(pPlaying) (partnerClip.getChildAt(i) as MovieClip).play();
					else (partnerClip.getChildAt(i) as MovieClip).stop();
				}
			}
		}
	}
}
