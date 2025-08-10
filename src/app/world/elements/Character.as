package app.world.elements
{
	import app.data.ConstantsApp;
	import app.data.ItemType;
	import app.world.data.*;
	import com.fewfre.utils.Fewf;
	import com.fewfre.utils.FewfUtils;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	public class Character
	{
		// Constants
		public static const POSE_UPDATED : String = "pose_updated";
		
		// Storage
		private var _root       : Sprite;
		private var _outfitData : OutfitData;
		private var _pose       : Pose;
		
		private var _dragging   : Boolean = false;
		private var _dragBounds : Rectangle;

		// Properties
		public function get outfitData() : OutfitData { return _outfitData; }
		public function get pose() : Pose { return _pose; }
		
		public function get scale() : Number { return _pose.scaleX; }
		public function set scale(pVal:Number) : void { _pose.scaleX = _pose.scaleY = pVal; }

		// Constructor
		public function Character(pOutfitData:OutfitData=null) {
			_root = new Sprite();
			_outfitData = (pOutfitData || new OutfitData())
				.on(OutfitData.UPDATED, function(e:Event):void{ updatePose(); });
			updatePose();
			
			// Make interactable
			_initDragging();
		}
		public function move(pX:Number, pY:Number) : Character { _root.x = pX; _root.y = pY; return this; }
		public function appendTo(pParent:Sprite): Character { pParent.addChild(_root); return this; }
		public function on(type:String, listener:Function, useCapture:Boolean = false): Character { _root.addEventListener(type, listener, useCapture); return this; }
		public function off(type:String, listener:Function, useCapture:Boolean = false): Character { _root.removeEventListener(type, listener, useCapture); return this; }

		public function updatePose() {
			var tScale = ConstantsApp.DEFAULT_CHARACTER_SCALE, tOldPose:Pose = _pose;
			if(_pose != null) { tScale = _pose.scaleX; _root.removeChild(_pose); }
			_pose = new Pose().appendTo(_root);
			_pose.scaleX = _pose.scaleY = tScale;
			// Don't let the pose eat mouse input
			_pose.mouseChildren = false;
			_pose.mouseEnabled = false;

			_pose.applyOutfitData(_outfitData);
			// if(animatePose) outfit.play(); else outfit.stopAtLastFrame();
			_pose.stopAtLastFrame();
			_pose.goToPreviousFrameIfPoseHasntChanged(tOldPose);
			_root.dispatchEvent(new Event(POSE_UPDATED));
		}
		
		public function enableDoubleClick() : Character {
			_root.doubleClickEnabled = true;
			return this;
		}

		/////////////////////////////
		// Dragging
		/////////////////////////////
		private function _initDragging() : void {
			_root.buttonMode = true;
			_root.addEventListener(MouseEvent.MOUSE_DOWN, function (e:MouseEvent) {
				_dragging = true;
				var bounds:Rectangle = _dragBounds.clone();
				bounds.x -= e.localX * _root.scaleX;
				bounds.y -= e.localY * _root.scaleY;
				_root.startDrag(false, bounds);
			});
			Fewf.stage.addEventListener(MouseEvent.MOUSE_UP, function () { if(_dragging) { _dragging = false; _root.stopDrag(); } });
		}
		public function setDragBounds(pX:Number, pY:Number, pWidth:Number, pHeight:Number): Character {
			_dragBounds = new Rectangle(pX, pY, pWidth, pHeight); return this;
		}
		public function clampCoordsToDragBounds() : void {
			_root.x = Math.max(_dragBounds.x, Math.min(_dragBounds.right, _root.x));
			_root.y = Math.max(_dragBounds.y, Math.min(_dragBounds.bottom, _root.y));
		}
		
		/////////////////////////////
		// Shortcuts
		/////////////////////////////
		public function getItemData(pType:ItemType) : ItemData { return _outfitData.getItemData(pType); }
		public function setItemData(pItemData:ItemData) : void { _outfitData.setItemData(pItemData); }
		public function removeItem(pType:ItemType) : void { _outfitData.removeItem(pType); }

		public function isItemTypeLocked(pType:ItemType) : Boolean { return _outfitData.isItemTypeLocked(pType); }
		public function setItemTypeLock(pType:ItemType, pLocked:Boolean) : void { _outfitData.setItemTypeLock(pType, pLocked); }
	}
}
