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
		
		// private static const boneSpecificItemTypeOrdering:Dictionary = new Dictionary();
		// boneSpecificItemTypeOrdering["Tete_1"] = new <ItemType>[ ItemType.HEAD, ItemType.MOUTH, ItemType.HAIR, ItemType.NECK ];
		// boneSpecificItemTypeOrdering["OreilleD_1"] = new <ItemType>[ ItemType.EARS ];
		// boneSpecificItemTypeOrdering["Oeil_1"] = new <ItemType>[ ItemType.CONTACTS, ItemType.EYES ];
		// boneSpecificItemTypeOrdering["OeilVide_1"] = new <ItemType>[ ItemType.EYES ];
		// boneSpecificItemTypeOrdering["Oeil2_1"] = new <ItemType>[ ItemType.EYES ];
		// boneSpecificItemTypeOrdering["Oeil3_1"] = new <ItemType>[ ItemType.EYES ];
		// boneSpecificItemTypeOrdering["Oeil4_1"] = new <ItemType>[ ItemType.EYES ];
		// boneSpecificItemTypeOrdering["Boule_1"] = new <ItemType>[ ItemType.TAIL ];
		// boneSpecificItemTypeOrdering["Arme_1"] = new <ItemType>[ ItemType.OBJECT ];//ItemType.WEAPON ];
		// boneSpecificItemTypeOrdering["Bouclier_1"] = new <ItemType>[ ItemType.PAW_BACK ];//ItemType.SHIELD ];
		// boneSpecificItemTypeOrdering["Gant_1"] = new <ItemType>[ ItemType.HAND ];
		
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
		public function apply(items:Vector.<ItemData>, shamanMode:ShamanMode, shamanColor:uint=0x95D9D6, disableSkillsMode:Boolean=false, removeBlanks:Boolean=false) : MovieClip {
			if(!items) items = new Vector.<ItemData>();
			
			var tSkinDataIndex = FewfUtils.getIndexFromVectorWithKeyVal(items, "type", ItemType.SKIN);
			var tSkinData:SkinData = tSkinDataIndex == -1 ? null : items.splice(tSkinDataIndex, 1)[0] as SkinData;//FewfUtils.getFromVectorWithKeyVal(items, "type", ItemType.SKIN);
			
			var tShopData:Vector.<ItemData> = _orderType(items);
			var part:MovieClip = null;
			var tPoseBone:MovieClip = null;
			var tBoneName:String;
			
			var tAccessories:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			
			var addToPoseData = { shamanMode:shamanMode };
			
			// This works because poses, skins, and items have a group of letters/numbers that let each other know they should be grouped together.
			// For example; the "head" of a pose is T, as is the skin's head, hats, and hair. Thus they all go onto same area of the skin.
			// Loop in reverse so unused parts can be removed if required
			for(var i:int = 0; i < _pose.numChildren; i++) {
				tPoseBone = _pose.getChildAt(i) as MovieClip;
				if(!tPoseBone) continue;
				tBoneName = tPoseBone.name;
				_pose[tBoneName] = tPoseBone; // Needed for inline scripts (ex: Tail 69)
				
				// First add skin to bone
				if(tSkinData) {
					part = _addToPoseIfCan(tPoseBone, tSkinData, tBoneName, addToPoseData) as MovieClip;
					if(part) {
						_colorSkinPart(part, tSkinData.colors ? tSkinData.colors[0] : -1, shamanColor);
						tAccessories = tAccessories.concat(getMcItemSubAccessories(part));
					}
					
					// Add divine mode wings (if divine mode)
					if(tBoneName == "CuisseD_1" && shamanMode == ShamanMode.DIVINE && isPoseWingsAddable(_poseData.id)) {
						tPoseBone.addChild( _getWingsMC(shamanColor) );
					}
					// Add mask face tattoo (if noskills mode)
					if(tBoneName == 'Tete_1' && shamanMode != ShamanMode.OFF && disableSkillsMode) {
						// remove all other face tattoos first
						var oldTattoo:DisplayObject = null;
						for(var tatI:int = 0; tatI < part.numChildren; tatI++) {
							var tChild:DisplayObject = part.getChildAt(tatI);
							if(tChild.name == "c1") {
								oldTattoo = tChild;
							}
						}
						if(oldTattoo) {
							oldTattoo.parent.removeChild(oldTattoo);
						}
						// Add noskills face tattoo
						var noSkillsTattoo = new $TatouageSansComp();
						noSkillsTattoo.name = "c1";
						part.addChild(noSkillsTattoo);
						_colorSkinPart(part, -1, shamanColor);
						
					}
				}
				
				// Next add equipped items to current bone if they need to be
				for(var j:int = 0; j < tShopData.length; j++) {
					part = _addToPoseIfCan(tPoseBone, tShopData[j], tBoneName, addToPoseData) as MovieClip;
					if(part) {
						_colorItemPart(part, tShopData[j], tBoneName, shamanColor);
						tAccessories = tAccessories.concat(getMcItemSubAccessories(part));
					}
				}
				part = null;
			}
			
			_handleAccessories(tAccessories);
				
			if(removeBlanks) {
				// If removing blanks, then loop through the bones again in reverse order (to prevent index errors)
				for(var i:int = _pose.numChildren-1; i >= 0; i--) {
					if(!!_pose.getChildAt(i) && (_pose.getChildAt(i) as MovieClip).numChildren == 0) {
						_pose.removeChildAt(i);
					}
				}
			}
			
			return this;
		}
		
		private function _addToPoseIfCan(pBone:MovieClip, pData:ItemData, pID:String, pOptions:Object=null) : DisplayObject {
			if(pData) {
				var tClass = pData.getPart(pID, pOptions);
				if(tClass) {
					var tMC = new tClass();
					// This code seems to be related to `first` / `behind` working properly in `_handleAccessories`
					if(pData.type == ItemType.HAIR || pData.type == ItemType.NECK) {
						return pBone.addChildAt(tMC, pBone.numChildren > 0 ? 1 : 0);
					}
					else if(pData.type == ItemType.TAIL) {
						// Removes shaman tail item, if it exists?
						if(pBone.numChildren) {
							pBone.removeChildAt(0);
						}
						return pBone.addChild(tMC);
					}
					return pBone.addChild(tMC);
				}
			}
			return null;
		}
		
		private function _handleAccessories(pAccessoires:Vector.<DisplayObject>) : void {
			var accMC:DisplayObject;
			for(var aI:int = 0; aI < pAccessoires.length; aI++) {
				accMC = pAccessoires[aI];
				var nameParts:Array = accMC.name.split("_"); // [0] is always just 'slot' so we don't care about it
				var accItemCat:int = 0;
				var layer:String = null;
				
				if(nameParts.length == 3) {
					accItemCat = int(nameParts[2]);
					layer = String(nameParts[1]);
				} else {
					accItemCat = int(nameParts[1]);
				}
				
				var validBoneNamesForItemCat:Vector.<String> = GameAssets.accessorySlotBones[accItemCat];
				if(validBoneNamesForItemCat) {
					for(var bnaI:int = 0; bnaI < validBoneNamesForItemCat.length; bnaI++) {
						var tBoneMC:MovieClip = _pose.getChildByName(validBoneNamesForItemCat[bnaI]) as MovieClip;

						if(tBoneMC) {
							var tNewAccPos:Point = tBoneMC.globalToLocal(accMC.parent.localToGlobal(new Point(accMC.x,accMC.y)));
							accMC.x = tNewAccPos.x;
							accMC.y = tNewAccPos.y;
							if(layer == "behind") {
								tBoneMC.addChildAt(accMC,0);
							}
							else if(layer == "first") {
								tBoneMC.addChildAt(accMC,1);
							}
							else if(layer == "behindzero") {
								accMC.x = 0;
								accMC.y = 0;
								tBoneMC.addChildAt(accMC,0);
							}
							else if(layer == "firstzero") {
								accMC.x = 0;
								accMC.y = 0;
								tBoneMC.addChildAt(accMC,1);
							}
							else {
								tBoneMC.addChild(accMC);
							}
						}
					}
				}
			}
		}
		
		private function _colorItemPart(part:MovieClip, pData:ItemData, pSlotName:String, pShamanColor:uint) : void {
			if(!part) { return; }
			if(part is MovieClip) {
				if(pData.colors != null) {
					GameAssets.colorItemUsingColorList(part, GameAssets.getColorsWithPossibleHoverEffect(pData));
				}
				else { GameAssets.colorDefault(part); }
			}
		}
		private function _colorSkinPart(part:MovieClip, pColor:int, pShamanColor:uint):MovieClip {
			const colors:Vector.<int> = new <int>[ pColor, pShamanColor ];
			for(var i:int = 0; i < part.numChildren; i++) {
				var child:MovieClip = part.getChildAt(i) as MovieClip;
				if(!child) continue;
				if(child.name.charAt(0) == "c"){
					var colorIndex:int = int(child.name.charAt(1));
					if(colorIndex < colors.length) {
						GameAssets.applyColorToObject(child, colors[colorIndex]);
					}
				}
			}
			return part;
		}
		
		private function getMcItemSubAccessories(part:MovieClip):Vector.<DisplayObject> {
			var tAccessoires:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			var tChild:DisplayObject;
			for(var i:int = 0; i < part.numChildren; i++) {
				tChild = part.getChildAt(i);
				if(tChild.name.indexOf("slot_") == 0) {
					tAccessoires.push(tChild);
				}
				if(tChild is MovieClip) {
					tAccessoires = tAccessoires.concat(getMcItemSubAccessories(tChild as MovieClip))
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
		private function isPoseWingsAddable(poseID:String) : Boolean {
			// All emotes remove wings - so wings only show for these animations in-game
			return poseID == "Statique" || poseID == "Course" || poseID == "Duck";
		}
		private function _getWingsMC(pShamanColor:uint) : MovieClip {
			var part = new $AileChamane();
			// Official hardcoded stats - found in decompiled game code
			part.x = 10;
			part.y = -8;
			part.scaleX = 0.9;
			part.scaleY = 0.9;
			part.rotation = -10;
			_colorSkinPart(part, -1, pShamanColor);
			return part;
		}
	}
}
