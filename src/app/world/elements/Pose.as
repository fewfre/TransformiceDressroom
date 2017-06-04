package app.world.elements
{
	import com.fewfre.utils.*;
	import app.data.*;
	import app.world.data.*;
	import flash.display.*;
	import flash.geom.*;
	
	public class Pose extends MovieClip
	{
		// Storage
		private var _poseData : ItemData;
		private var _pose : MovieClip;
		
		public function get pose():MovieClip { return _pose; }
		
		// Constructor
		public function Pose(pPoseData:ItemData) {
			super();
			_poseData = pPoseData;
			
			_pose = addChild( new pPoseData.itemClass() );
			stop();
		}
		
		override public function play() : void {
			super.play();
			_pose.play();
		}
		
		override public function stop() : void {
			super.stop();
			_pose.stop();
		}
		
		public function stopAtLastFrame() : void {
			_pose.gotoAndPlay(10000);
			stop();
		}
		
		// pData = { ?items:Array, ?removeBlanks:Boolean=false, ?shamanMode:int(SHAMAN_MODE) }
		public function apply(pData:Object) : MovieClip {
			if(!pData.items) pData.items = [];
			
			var tSkinData = FewfUtils.getFromArrayWithKeyVal(pData.items, "type", ITEM.SKIN);
			if(tSkinData == null) { tSkinData = FewfUtils.getFromArrayWithKeyVal(pData.items, "type", ITEM.SKIN_COLOR); }
			var tTailData = FewfUtils.getFromArrayWithKeyVal(pData.items, "type", ITEM.TAIL);
			
			var tShopData:Array = _orderType(pData.items);
			var part:DisplayObject = null;
			var tChild:DisplayObject = null;
			var tSlotName:String;
			
			pData.shamanMode = pData.shamanMode != null ? pData.shamanMode : Costumes.instance.shamanMode;
			
			// This works because poses, skins, and items have a group of letters/numbers that let each other know they should be grouped together.
			// For example; the "head" of a pose is T, as is the skin's head, hats, and hair. Thus they all go onto same area of the skin.
			for(var i:int = 0; i < _pose.numChildren; i++) {
				tChild = _pose.getChildAt(i);
				tSlotName = tChild.name;
				for(var j:int = 0; j < tShopData.length; j++) {
					if(tTailData != null && tShopData[j].isSkin() && tSlotName.indexOf("Boule_") > -1) { continue; }
					part = _addToPoseIfCan(tChild, tShopData[j], tSlotName, pData);
					_colorPart(part, tShopData[j], tSlotName);
				}
				// A complete hack to get shaman wings. Can't figure out the "proper" way to do it.
				if(tSlotName.indexOf("CuisseD_") > -1 && tSkinData != null && pData.shamanMode == SHAMAN_MODE.DIVINE
					&& (_poseData.id == "Statique" || _poseData.id == "Course" || _poseData.id == "Duck") // Wings only show for these animations in-game
				) {
					part = tChild.addChild(new (Fewf.assets.getLoadedClass("$AileChamane"))());
					_colorPart(part, tSkinData, "shamanwings");
					part.x += 15; part.y -= 10; part.rotation-=9;
				}
				part = null;
			}
			if(pData.removeBlanks) {
				_removeUnusedParts();
			}
			
			return this;
		}
		
		private function _removeUnusedParts() {
			i = _pose.numChildren;
			while(i > 0) { i--;
				tChild = _pose.getChildAt(i);
				if(!tChild.enabled) { _pose.removeChildAt(i); }// else { var ttt = new $ColorWheel(); ttt.scaleX = ttt.scaleY = 0.1; tChild.addChild(ttt); }
			}
		}
		
		private function _addToPoseIfCan(pSkinPart:DisplayObject, pData:ItemData, pID:String, pOptions:Object=null) : DisplayObject {
			if(pData) {
				var tClass = pData.getPart(pID, pOptions);
				if(tClass) {
					return pSkinPart.addChild( new tClass() );
				}
			}
			return null;
		}
		
		private function _colorPart(part:DisplayObject, pData:ItemData, pSlotName:String) : void {
			if(!part) { return; }
			if(part is MovieClip) {
				if(pData.colors != null && !pData.isSkin()) {
					Costumes.instance.colorItem({ obj:part, colors:pData.colors });
				}
				else { Costumes.instance.colorDefault(part); }
				
				if(pData.isSkin() && isFurPartColorable(pSlotName)) {
					colorFur(part, pData.colors ? pData.colors[0] : -1);
				}
				//Costumes.instance.colorItem({ obj:part, color: tSkinColor, name:"$0" });
				//Costumes.instance.colorItem({ obj:part, color: tSecondaryColor, name:"$2" });
			}
		}
		
		private function _orderType(pItems:Array) : Array {
			var i = pItems.length;
			while(i > 0) { i--;
				if(pItems[i] == null) {
					pItems.splice(i, 1);
				}
			}
			
			pItems.sort(function(a, b){
				return ITEM.LAYERING.indexOf(a.type) > ITEM.LAYERING.indexOf(b.type) ? 1 : -1;
			});
			
			return pItems;
		}
		
		public function colorFur(pSkinPart:DisplayObject, pColor:int):DisplayObject {
			var i:int=0;
			var tChild:DisplayObject;
			if (pSkinPart.numChildren > 1) {
				while (i < pSkinPart.numChildren) {
					tChild = pSkinPart.getChildAt(i);
					if (tChild.name == "c0") {
						Costumes.instance.applyColorToObject(tChild, pColor);
					}
					else if (tChild.name == "c1") {
						Costumes.instance.applyColorToObject(tChild, Costumes.instance.shamanColor);
					}
					i++;
				}
			} else {
				Costumes.instance.applyColorToObject(pSkinPart, pColor);
			}
			return pSkinPart;
		}
		public function isFurPartColorable(pSkinPart:String) : Boolean {
			// Back Feet, tail, eyes.
			return !(false
				|| pSkinPart.indexOf("Oeil_") > -1
				|| pSkinPart.indexOf("Queue_") > -1
				|| pSkinPart.indexOf("PiedG_") > -1
				|| pSkinPart.indexOf("PiedD_") > -1
			);
		}
	}
}
