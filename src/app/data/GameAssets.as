package app.data
{
	import com.adobe.images.*;
	import com.fewfre.utils.*;
	import com.piterwilson.utils.ColorMathUtil;
	import app.data.*;
	import app.world.data.*;
	import app.world.elements.*;
	import flash.display.*;
	import flash.geom.*;
	import flash.net.*;

	public class GameAssets
	{
		private static const _MAX_COSTUMES_TO_CHECK_TO:Number = 999;
		public static const FUR_COLORS:Vector.<uint> = new <uint>[ 0xBD9067, 0x593618, 0x8C887F, 0xDED7CE, 0x4E443A, 0xE3C07E, 0x272220 ];
		public static const DEFAULT_FUR_COLOR:uint = 0x78583A;

		public static var hair: Vector.<ItemData>;
		public static var head: Vector.<ItemData>;
		public static var eyes: Vector.<ItemData>;
		public static var ears: Vector.<ItemData>;
		public static var mouth: Vector.<ItemData>;
		public static var neck: Vector.<ItemData>;
		public static var tail: Vector.<ItemData>;
		public static var contacts: Vector.<ItemData>;
		public static var hands: Vector.<ItemData>;

		public static var skins: Vector.<ItemData>;
		public static var poses: Vector.<ItemData>;
		
		public static var accessorySlotBones:Vector.< Vector.<String> >;

		public static var defaultSkinIndex:int;
		public static var defaultPoseIndex:int;

		public static var extraObjectWand:ItemData;
		public static var extraBackHand:ItemData;
		public static var extraFromage:ItemData;
		
		public static var shamanMode:ShamanMode = ShamanMode.OFF;
		public static var shamanColor:int = 0x95D9D6;
		
		// { type:ItemType, id:String, colorI:int }
		public static var swatchHoverPreviewData:Object = null;

		public static function get defaultSkin() : ItemData { return skins[defaultSkinIndex]; }
		public static function get defaultPose() : ItemData { return poses[defaultPoseIndex]; }

		public static function init() : void {
			var i:int;

			head = _setupCostumeList(ItemType.HEAD, "$Costume_0_", { itemClassToClassMap:"Tete_1" });
			eyes = _setupCostumeList(ItemType.EYES, "$Costume_1_", { itemClassToClassMap:["Oeil_1", "OeilVide_1", "Oeil2_1", "Oeil3_1", "Oeil4_1"] });
			ears = _setupCostumeList(ItemType.EARS, "$Costume_2_", { itemClassToClassMap:"OreilleD_1" });
			mouth = _setupCostumeList(ItemType.MOUTH, "$Costume_3_", { itemClassToClassMap:"Tete_1" });
			neck = _setupCostumeList(ItemType.NECK, "$Costume_4_", { itemClassToClassMap:"Tete_1" });
			hair = _setupCostumeList(ItemType.HAIR, "$Costume_5_", { itemClassToClassMap:"Tete_1" });
			tail = _setupCostumeList(ItemType.TAIL, "$Costume_6_", { itemClassToClassMap:"Boule_1" });
			contacts = _setupCostumeList(ItemType.CONTACTS, "$Costume_7_", { itemClassToClassMap:["Oeil_1", "OeilVide_1"] });
			hands = _setupCostumeList(ItemType.HAND, "$Costume_8_", { itemClassToClassMap:"Gant_1" });

			extraObjectWand = new ItemData(ItemType.OBJECT, null, { itemClass:Fewf.assets.getLoadedClass("$Costume_9_1") });
			extraObjectWand.classMap = { Arme_1:extraObjectWand.itemClass };
			extraBackHand = new ItemData(ItemType.PAW_BACK, null, { itemClass:$HandButtonShield });
			extraBackHand.classMap = { PatteG_1:extraBackHand.itemClass };
			extraFromage = new ItemData(ItemType.BACK, null, { itemClass:Fewf.assets.getLoadedClass("FromageSouris") });
			extraFromage.classMap = { ClipGrosse:extraFromage.itemClass };
			
			accessorySlotBones = new Vector.< Vector.<String> >();
			accessorySlotBones[0] = new <String>["Tete_1"];
			accessorySlotBones[1] = new <String>["OeilVide_1","Oeil2_1","Oeil3_1","Oeil4_1"];
			accessorySlotBones[2] = new <String>["OreilleD_1"];
			accessorySlotBones[3] = new <String>["Tete_1"];
			accessorySlotBones[4] = new <String>["Tete_1"];
			accessorySlotBones[5] = new <String>["Tete_1"];
			accessorySlotBones[6] = new <String>["Boule_1"];
			accessorySlotBones[7] = new <String>["Oeil_1"];
			accessorySlotBones[8] = new <String>["Gant_1"];
			accessorySlotBones[9] = new <String>["Arme_1"];
			accessorySlotBones[10]= new <String>["Bouclier_1"];

			skins = new Vector.<ItemData>();
			
			for(i = 0; i < FUR_COLORS.length; i++) {
				skins.push( new SkinData({ id:"color"+i, assetID:1, color:FUR_COLORS[i], isSkinColor:true }) );
			}
			
			skins.push( new SkinData({ id:1, assetID:1, color:DEFAULT_FUR_COLOR, type:ItemType.SKIN }) );
			for(i = 2; i < _MAX_COSTUMES_TO_CHECK_TO; i++) {
				if(Fewf.assets.getLoadedClass( "_Corps_2_"+i+"_1" ) != null) {
					skins.push( new SkinData({ id:i }) );
				}
			}
			defaultSkinIndex = 7;//FewfUtils.getIndexFromVectorWithKeyVal(skins, "id", ConstantsApp.DEFAULT_SKIN_ID);

			/*for(var i = 0; i < 7; i++) {
				furs.push( new FurData( i, ItemType.COLOR ).initColor() );
			}

			furs.push( new FurData( 1, ItemType.FUR ).initColor(FurData.DEFAULT_COLOR) );
			for(var i = 2; i < _MAX_COSTUMES_TO_CHECK_TO; i++) {
				if(Fewf.assets.getLoadedClass( "_Corps_2_"+i+"_1" ) != null) {
					//furs.push( new Fur().initFur( i, _setupFur(i) ) );
					furs.push( new FurData( i, ItemType.FUR ).initFur() );
				}
			}*/

			poses = new Vector.<ItemData>();
			var tPoseClasses = [
				"Statique", "Course", "Duck", "Sleep", "Sit", "Mad", "Laugh", "Kiss", "Facepalm", "Danse", "Cry", "Confetti", "Clap",
				"Rondoudou", "Selfie", "Zelda", "Plumes", "Langue", "Drapeau",
				"StatiqueBalai", "CourseBalai", "Peche", "Neige", "Marshmallow", "PreInvoc", "Invoc", "Cadeau", "Attaque",
				"Hi5_1", "Hi5_2", "Calin_1", "Calin_2", "Bisou_1", "Bisou_2",
			];
			// Unused: Calin,
			for(i = 0; i < tPoseClasses.length; i++) {
				poses.push(new ItemData(ItemType.POSE, tPoseClasses[i], { itemClass:Fewf.assets.getLoadedClass( "Anim"+tPoseClasses[i] ) }));
			}
			defaultPoseIndex = 0;//FewfUtils.getIndexFromVectorWithKeyVal(poses, "id", ConstantsApp.DEFAULT_POSE_ID);
		}

		// pData = { after:String, pad:int, itemClassToClassMap:String OR Array }
		private static function _setupCostumeList(type:ItemType, base:String, pData:Object) : Vector.<ItemData> {
			var list:Vector.<ItemData> = new Vector.<ItemData>(), tClassName:String, tClass:Class;
			var breakCount = 0; // quit early if enough nulls in a row
			
			for(var i = 0; i <= _MAX_COSTUMES_TO_CHECK_TO; i++) {
				// hardcoded skip for duplicate items in game files - TODO: add values to config maybe?
				if(i == 85 && type == ItemType.MOUTH) {
					continue;
				}
				
				tClass = Fewf.assets.getLoadedClass( base+(pData.pad ? zeroPad(i, pData.pad) : i)+(pData.after ? pData.after : "") );
				if(tClass != null) {
					breakCount = 0;
					list.push( new ItemData(type, i, { itemClass:tClass }) );
					if(pData.itemClassToClassMap) {
						list[list.length-1].classMap = {};
						if(pData.itemClassToClassMap is Array) {
							for(var c:int = 0; c < pData.itemClassToClassMap.length; c++) {
								list[list.length-1].classMap[pData.itemClassToClassMap[c]] = tClass;
							}
						} else {
							list[list.length-1].classMap[pData.itemClassToClassMap] = tClass;
						}
					}
				} else {
					breakCount++;
					if(breakCount > 5) {
						break;
					}
				}
			}
			return list;
		}

		public static function zeroPad(number:int, width:int):String {
			var ret:String = ""+number;
			while( ret.length < width )
				ret="0" + ret;
			return ret;
		}

		public static function getItemDataListByType(pType:ItemType) :  Vector.<ItemData> {
			switch(pType) {
				case ItemType.HAIR:		return hair;
				case ItemType.HEAD:		return head;
				case ItemType.EARS:		return ears;
				case ItemType.EYES:		return eyes;
				case ItemType.MOUTH:	return mouth;
				case ItemType.NECK:		return neck;
				case ItemType.TAIL:		return tail;
				case ItemType.CONTACTS:	return contacts;
				case ItemType.HAND:		return hands;
				case ItemType.SKIN:		return skins;
				case ItemType.POSE:		return poses;
				default: trace("[GameAssets](getItemDataListByType) Unknown type: "+pType);
			}
			return null;
		}

		public static function getItemFromTypeID(pType:ItemType, pID:String) : ItemData {
			return FewfUtils.getFromVectorWithKeyVal(getItemDataListByType(pType), "id", pID);
		}

		public static function getItemIndexFromTypeID(pType:ItemType, pID:String) : int {
			return FewfUtils.getIndexFromVectorWithKeyVal(getItemDataListByType(pType), "id", pID);
		}

		/****************************
		* Color
		*****************************/
		public static function copyColor(copyFromMC:MovieClip, copyToMC:MovieClip) : MovieClip {
			if (copyFromMC == null || copyToMC == null) { return null; }
			var tChild1:*=null;
			var tChild2:*=null;
			var i:int = 0;
			while (i < copyFromMC.numChildren) {
				tChild1 = copyFromMC.getChildAt(i);
				tChild2 = copyToMC.getChildAt(i);
				if (tChild1.name.indexOf("Couleur") == 0 && tChild1.name.length > 7) {
					tChild2.transform.colorTransform = tChild1.transform.colorTransform;
				}
				i++;
			}
			return copyToMC;
		}

		public static function colorDefault(pMC:MovieClip) : MovieClip {
			if (pMC == null) { return null; }

			var tChild:*=null;
			var tHex:int=0;
			var loc1:*=0;
			while (loc1 < pMC.numChildren)
			{
				tChild = pMC.getChildAt(loc1);
				if (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7)
				{
					tHex = int("0x" + tChild.name.substr(tChild.name.indexOf("_") + 1, 6));
					applyColorToObject(tChild, tHex);
				}
				else if(tChild.name.indexOf("slot_") == 0) {
					colorDefault(tChild)
				}
				++loc1;
			}
			return pMC;
		}

		public static function colorItemUsingColorList(pSprite:Sprite, pColors:Vector.<uint>) : DisplayObject {
			if (pSprite == null) { return null; }

			var tChild: DisplayObject, name:String;
			var i:int=0;
			while (i < pSprite.numChildren) {
				tChild = pSprite.getChildAt(i); name = tChild.name;
				if (tChild.name.indexOf("Couleur") == 0 && name.length > 7 && pColors[name.charAt(7)] != null) {
					applyColorToObject(tChild, pColors[name.charAt(7)]);
				}
				else if(tChild.name.indexOf("slot_") == 0) {
					colorItemUsingColorList(tChild as Sprite, pColors);
				}
				i++;
			}
			return pSprite;
		}
		
		// pColor is an int hex value. ex: 0x000000
		public static function applyColorToObject(pItem:DisplayObject, pColor:int) : void {
			if(pColor < 0) { return; }
			var tR:*=pColor >> 16 & 255;
			var tG:*=pColor >> 8 & 255;
			var tB:*=pColor & 255;
			pItem.transform.colorTransform = new flash.geom.ColorTransform(tR / 128, tG / 128, tB / 128);
		}

		public static function getColors(pMC:MovieClip) : Vector.<uint> {
			return Vector.<uint>( _getColorsRecursive(pMC, []) );
		}
		// Has to be an array since numbers aren't always added in order, which messes up Vectors
		private static function _getColorsRecursive(pMC:MovieClip, tArray:Array) : Array {
			var tChild:*=null, tTransform:ColorTransform=null, color:uint;
			var i:int=0;
			while (i < pMC.numChildren) {
				tChild = pMC.getChildAt(i);
				if (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7) {
					tTransform = tChild.transform.colorTransform;
					color = ColorMathUtil.RGBToHex(tTransform.redMultiplier * 128, tTransform.greenMultiplier * 128, tTransform.blueMultiplier * 128);
					tArray[tChild.name.charAt(7)] = color;
				}
				else if(tChild.name.indexOf("slot_") == 0) {
					_getColorsRecursive(tChild, tArray);
				}
				i++;
			}
			return tArray;
		}

		public static function getNumOfCustomColors(pMC:MovieClip) : int {
			var count:int = 0, tChild:*=null;
			var i:int = 0;
			while (i < pMC.numChildren) {
				tChild = pMC.getChildAt(i);
				if (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7) {
					count++;
				}
				else if(tChild.name.indexOf("slot_") == 0) {
					count += getNumOfCustomColors(tChild);
				}
				i++;
			}
			return count;
		}
		
		public static function getColoredItemImage(pData:ItemData) : MovieClip {
			return colorItemUsingColorList(getItemImage(pData), getColorsWithPossibleHoverEffect(pData)) as MovieClip;
		}
		
		public static function getColorsWithPossibleHoverEffect(pData:ItemData) : Vector.<uint> {
			if(!pData.colors || !swatchHoverPreviewData) { return pData.colors; }
			var colors = pData.colors.concat(); // shallow copy
			if(pData.type == swatchHoverPreviewData.type && pData.id == swatchHoverPreviewData.id) {
				var i = swatchHoverPreviewData.colorI;
				colors[i] = GameAssets.invertColor(colors[i]);
			}
			return colors;
		}
		
		public static function invertColor(pColor:uint) : uint {
			var tR:*=pColor >> 16 & 255;
			var tG:*=pColor >> 8 & 255;
			var tB:*=pColor & 255;
			
			return (255-tR)<<16 | (255-tG)<<8 | (255-tB);
		}

		/****************************
		* Asset Creation
		*****************************/
		public static function getItemImage(pData:ItemData) : MovieClip {
			var tItem:MovieClip;
			switch(pData.type) {
				case ItemType.SKIN:
					tItem = getDefaultPoseSetup({ skin:pData });
					break;
				case ItemType.POSE:
					tItem = getDefaultPoseSetup({ pose:pData });
					break;
				/*case ItemType.SHIRT:
				case ItemType.PANTS:
				case ItemType.SHOES:
					tItem = new Pose(poses[defaultPoseIndex]).apply(new <ItemData>[ pData ], ShamanMode.OFF, true);
					break;*/
				default:
					tItem = new pData.itemClass();
					colorDefault(tItem);
					break;
			}
			return tItem;
		}

		// pData = { ?pose:ItemData, ?skin:SkinData }
		public static function getDefaultPoseSetup(pData:Object) : Pose {
			var tPoseData = pData.pose ? pData.pose : poses[defaultPoseIndex];
			var tSkinData = pData.skin ? pData.skin : skins[defaultSkinIndex];

			var tPose:Pose = new Pose(tPoseData);
			tPose.apply(new <ItemData>[ tSkinData ], ShamanMode.OFF);
			tPose.stopAtLastFrame();

			return tPose;
		}
		
		/****************************
		* Misc
		*****************************/
		public static function createHorizontalRule(pX:Number, pY:Number, pWidth:Number) : Sprite {
			var tLine:Sprite = new Sprite(); tLine.x = pX; tLine.y = pY;
			
			tLine.graphics.lineStyle(1, 0x11181c, 1, true);
			tLine.graphics.moveTo(0, 0);
			tLine.graphics.lineTo(pWidth, 0);
			
			tLine.graphics.lineStyle(1, 0x608599, 1, true);
			tLine.graphics.moveTo(0, 1);
			tLine.graphics.lineTo(pWidth, 1);
			
			return tLine;
		}
		
		// Converts the image to a PNG bitmap and prompts the user to save.
		public static function saveAsPNGFrameByFrameVersion(pObj:app.world.elements.Character, pName:String) {
			if(!pObj){ return; }

			var tOrigScale = pObj.outfit.scaleX;
			pObj.scale = 1;
			var tWidth = 80, tHeight = 65;
			var tRect:flash.geom.Rectangle = pObj.getBounds(pObj);
			var tBitmap:flash.display.BitmapData = new flash.display.BitmapData(tWidth, tHeight, true, 0xFFFFFF);

			var tMatrix:flash.geom.Matrix = new flash.geom.Matrix(1, 0, 0, 1, -tRect.left + (tWidth-tRect.width)/2, -tRect.top + (tHeight-tRect.height)/2);
			tMatrix.scale(1, 1);

			tBitmap.draw(pObj, tMatrix);
			var fileRef = new flash.net.FileReference();
			fileRef.save( com.adobe.images.PNGEncoder.encode(tBitmap), pName+".png" );
			
			pObj.scale = tOrigScale;
			return fileRef;
		}
	}
}
