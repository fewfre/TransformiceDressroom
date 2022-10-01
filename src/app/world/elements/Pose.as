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
		public function get poseCurrentFrame():Number { return _pose.currentFrame; }
		public function get poseTotalFrames():Number { return _pose.totalFrames; }
		
		// Constructor
		public function Pose(pPoseData:ItemData) {
			super();
			_poseData = pPoseData;
			
			_pose = addChild( new pPoseData.itemClass() ) as MovieClip;
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
		
		public function poseNextFrame() : void {
			if(poseCurrentFrame == poseTotalFrames) {
				_pose.gotoAndPlay(0);
			} else {
				_pose.nextFrame();
			}
			stop();
		}
		
		// pData = { ?items:Array, ?removeBlanks:Boolean=false, ?shamanMode:int(SHAMAN_MODE) }
		public function apply(pData:Object) : MovieClip {
			if(!pData.items) pData.items = [];
			
			var tSkinData = FewfUtils.getFromArrayWithKeyVal(pData.items, "type", ITEM.SKIN);
			if(tSkinData == null) { tSkinData = FewfUtils.getFromArrayWithKeyVal(pData.items, "type", ITEM.SKIN_COLOR); }
			var tTailData = FewfUtils.getFromArrayWithKeyVal(pData.items, "type", ITEM.TAIL);
			
			var tShopData:Array = _orderType(pData.items);
			var part:MovieClip = null;
			var tChild:DisplayObject = null;
			var tItemsOnChild:int = 0;
			var tSlotName:String;
			var tHandItemAdded:Boolean = false;
			
			pData.shamanMode = pData.shamanMode != null ? pData.shamanMode : GameAssets.shamanMode;
			
			var tAccessoires = [];
			
			// This works because poses, skins, and items have a group of letters/numbers that let each other know they should be grouped together.
			// For example; the "head" of a pose is T, as is the skin's head, hats, and hair. Thus they all go onto same area of the skin.
			// Loop in reverse so unused parts can be removed if required
			for(var i:int = _pose.numChildren-1; i >= 0; i--) {
				tChild = _pose.getChildAt(i);
				tItemsOnChild = 0;
				tSlotName = tChild.name;
				for(var j:int = 0; j < tShopData.length; j++) {
					if(tTailData != null && tShopData[j].isSkin() && tSlotName.indexOf("Boule_") > -1) { continue; }
					part = _addToPoseIfCan(tChild as MovieClip, tShopData[j], tSlotName, pData) as MovieClip;
					if(part) {
						_colorPart(part, tShopData[j], tSlotName);
						tAccessoires = tAccessoires.concat(getMcItemSubAccessories(part));
						tItemsOnChild++;
					}
				}
				// A complete hack to get shaman wings. Can't figure out the "proper" way to do it.
				if(tSlotName.indexOf("CuisseD_") > -1 && tSkinData != null && pData.shamanMode == SHAMAN_MODE.DIVINE
					&& (_poseData.id == "Statique" || _poseData.id == "Course" || _poseData.id == "Duck") // Wings only show for these animations in-game
				) {
					part = _getWingsMC(tSkinData);
					(tChild as MovieClip).addChild(part);
				}
				if(pData.removeBlanks && tItemsOnChild == 0) {
					_pose.removeChildAt(i);
				}
				part = null;
			}
			
			var tAccMC:MovieClip;
			for(var aI:int = 0; aI < tAccessoires.length; aI++) {
				tAccMC = tAccessoires[aI];
				var tAccItemCat = int(tAccMC.name.substr(5)); // removes `slot_`
				var validBoneNamesForItemCat:Array = GameAssets.accessorySlotBones[tAccItemCat];
				if(validBoneNamesForItemCat) {
					for(var bnaI:int = 0; bnaI < validBoneNamesForItemCat.length; bnaI++) {
						var tBoneMC:MovieClip = _pose.getChildByName(validBoneNamesForItemCat[bnaI]);

						if(tBoneMC) {
							var tNewAccPos:Point = tBoneMC.globalToLocal(tAccMC.parent.localToGlobal(new Point(tAccMC.x,tAccMC.y)));
							tAccMC.x = tNewAccPos.x;
							tAccMC.y = tNewAccPos.y;
							tBoneMC.addChild(tAccMC);
						}
					}
				}
			}
			
			return this;
		}
		
		private function _addToPoseIfCan(pSkinPart:MovieClip, pData:ItemData, pID:String, pOptions:Object=null) : DisplayObject {
			if(pData) {
				var tClass = pData.getPart(pID, pOptions);
				if(tClass) {
					return pSkinPart.addChild( new tClass() );
				}
			}
			return null;
		}
		
		private function _colorPart(part:MovieClip, pData:ItemData, pSlotName:String) : void {
			if(!part) { return; }
			if(part is MovieClip) {
				if(pData.colors != null && !pData.isSkin()) {
					GameAssets.colorItem({ obj:part, colors:pData.colors });
				}
				else { GameAssets.colorDefault(part); }
				
				if(pData.isSkin() && isFurPartColorable(pSlotName)) {
					colorFur(part, pData.colors ? pData.colors[0] : -1);
				}
				//GameAssets.colorItem({ obj:part, color: tSkinColor, name:"$0" });
				//GameAssets.colorItem({ obj:part, color: tSecondaryColor, name:"$2" });
			}
		}
		
		private function getMcItemSubAccessories(part:MovieClip) {
			var tAccessoires = [];
			var tChild:DisplayObject;
			for(var i:int = 0; i < part.numChildren; i++) {
				tChild = part.getChildAt(i);
				if(tChild.name.indexOf("slot_") == 0) {
					tAccessoires.push(tChild);
				}
			}
			return tAccessoires;
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
		
		public function colorFur(pSkinPart:MovieClip, pColor:int):DisplayObject {
			var i:int=0;
			var tChild:DisplayObject;
			if (pSkinPart.numChildren > 1) {
				while (i < pSkinPart.numChildren) {
					tChild = pSkinPart.getChildAt(i);
					if (tChild.name == "c0") {
						GameAssets.applyColorToObject(tChild, pColor);
					}
					else if (tChild.name == "c1") {
						GameAssets.applyColorToObject(tChild, GameAssets.shamanColor);
					}
					i++;
				}
			} else {
				GameAssets.applyColorToObject(pSkinPart, pColor);
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
				|| pSkinPart.indexOf("PiedD2_") > -1
			);
		}
		private function _getWingsMC(pSkinData:SkinData) : MovieClip {
			var part = new $AileChamane();
			// Official hardcoded stats - found in decompiled game code
			part.x = 10;
			part.y = -8;
			part.scaleX = 0.9;
			part.scaleY = 0.9;
			part.rotation = -10;
			_colorPart(part, pSkinData, "shamanwings");
			return part;
		}
	}
}
