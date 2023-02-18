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
		
		// pData = { ?removeBlanks:Boolean=false }
		public function apply(items:Vector.<ItemData>, shamanMode:ShamanMode, shamanColor:uint=0x95D9D6, removeBlanks:Boolean=false) : MovieClip {
			if(!items) items = new Vector.<ItemData>();
			
			var tSkinData = FewfUtils.getFromVectorWithKeyVal(items, "type", ItemType.SKIN);
			var tTailData = FewfUtils.getFromVectorWithKeyVal(items, "type", ItemType.TAIL);
			
			var tShopData:Vector.<ItemData> = _orderType(items);
			var part:MovieClip = null;
			var tChild:DisplayObject = null;
			var tItemsOnChild:int = 0;
			var tSlotName:String;
			var tHandItemAdded:Boolean = false;
			
			var tAccessoires:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			
			var addToPoseData = { shamanMode:shamanMode };
			
			// This works because poses, skins, and items have a group of letters/numbers that let each other know they should be grouped together.
			// For example; the "head" of a pose is T, as is the skin's head, hats, and hair. Thus they all go onto same area of the skin.
			// Loop in reverse so unused parts can be removed if required
			for(var i:int = _pose.numChildren-1; i >= 0; i--) {
				tChild = _pose.getChildAt(i);
				tItemsOnChild = 0;
				tSlotName = tChild.name;
				for(var j:int = 0; j < tShopData.length; j++) {
					if(tTailData != null && tShopData[j].isSkin() && tSlotName.indexOf("Boule_") > -1) { continue; }
					part = _addToPoseIfCan(tChild as MovieClip, tShopData[j], tSlotName, addToPoseData) as MovieClip;
					if(part) {
						_colorPart(part, tShopData[j], tSlotName, shamanColor);
						tAccessoires = tAccessoires.concat(getMcItemSubAccessories(part));
						tItemsOnChild++;
					}
				}
				// A complete hack to get shaman wings. Can't figure out the "proper" way to do it.
				if(tSlotName.indexOf("CuisseD_") > -1 && tSkinData != null && shamanMode == ShamanMode.DIVINE
					&& (_poseData.id == "Statique" || _poseData.id == "Course" || _poseData.id == "Duck") // Wings only show for these animations in-game
				) {
					part = _getWingsMC(tSkinData, shamanColor);
					(tChild as MovieClip).addChild(part);
				}
				if(removeBlanks && tItemsOnChild == 0) {
					_pose.removeChildAt(i);
				}
				part = null;
			}
			
			_handleAccessories(tAccessoires);
			
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
		
		private function _handleAccessories(pAccessoires:Vector.<DisplayObject>) : void {
			var tAccMC:DisplayObject;
			for(var aI:int = 0; aI < pAccessoires.length; aI++) {
				tAccMC = pAccessoires[aI];
				var tName:String = tAccMC.name;
				var tNameMinusSlotPrefix:String = tName.substr(5); // removes `slot_`
				var tSlotIsBehind = tNameMinusSlotPrefix.substr(0,6) == "behind";
				if(tSlotIsBehind) {
					tNameMinusSlotPrefix = tNameMinusSlotPrefix.substr(7); // removed "behind_"
				}
				var tAccItemCat:int = int(tNameMinusSlotPrefix);
				var validBoneNamesForItemCat:Vector.<String> = GameAssets.accessorySlotBones[tAccItemCat];
				if(validBoneNamesForItemCat) {
					for(var bnaI:int = 0; bnaI < validBoneNamesForItemCat.length; bnaI++) {
						var tBoneMC:MovieClip = _pose.getChildByName(validBoneNamesForItemCat[bnaI]) as MovieClip;

						if(tBoneMC) {
							var tNewAccPos:Point = tBoneMC.globalToLocal(tAccMC.parent.localToGlobal(new Point(tAccMC.x,tAccMC.y)));
							tAccMC.x = tNewAccPos.x;
							tAccMC.y = tNewAccPos.y;
							if(tSlotIsBehind) {
							tBoneMC.addChildAt(tAccMC, 0);
							} else {
								
							tBoneMC.addChild(tAccMC);
							}
						}
					}
				}
			}
		}
		
		private function _colorPart(part:MovieClip, pData:ItemData, pSlotName:String, pShamanColor:uint) : void {
			if(!part) { return; }
			if(part is MovieClip) {
				if(pData.colors != null && !pData.isSkin()) {
					GameAssets.colorItemUsingColorList(part, GameAssets.getColorsWithPossibleHoverEffect(pData));
				}
				else { GameAssets.colorDefault(part); }
				
				if(pData.isSkin() && isFurPartColorable(pSlotName)) {
					colorFur(part, pData.colors ? pData.colors[0] : -1, pShamanColor);
				}
			}
		}
		
		private function getMcItemSubAccessories(part:MovieClip):Vector.<DisplayObject> {
			var tAccessoires:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			var tChild:DisplayObject;
			for(var i:int = 0; i < part.numChildren; i++) {
				tChild = part.getChildAt(i);
				if(tChild.name.indexOf("slot_") == 0) {
					tAccessoires.push(tChild);
				}
			}
			return tAccessoires;
		}
		
		private function _orderType(pItems:Vector.<ItemData>) : Vector.<ItemData> {
			return pItems
			.filter(function(a){ return a != null })
			.sort(function(a, b){
				return ItemType.LAYERING.indexOf(a.type) > ItemType.LAYERING.indexOf(b.type) ? 1 : -1;
			});
		}
		
		public function colorFur(pSkinPart:MovieClip, pColor:int, pShamanColor:uint):DisplayObject {
			var i:int=0;
			var tChild:DisplayObject;
			if (pSkinPart.numChildren > 1) {
				while (i < pSkinPart.numChildren) {
					tChild = pSkinPart.getChildAt(i);
					if (tChild.name == "c0") {
						GameAssets.applyColorToObject(tChild, pColor);
					}
					else if (tChild.name == "c1") {
						GameAssets.applyColorToObject(tChild, pShamanColor);
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
		private function _getWingsMC(pSkinData:SkinData, pShamanColor:uint) : MovieClip {
			var part = new $AileChamane();
			// Official hardcoded stats - found in decompiled game code
			part.x = 10;
			part.y = -8;
			part.scaleX = 0.9;
			part.scaleY = 0.9;
			part.rotation = -10;
			_colorPart(part, pSkinData, "shamanwings", pShamanColor);
			return part;
		}
	}
}
