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

	public class Costumes
	{
		private static var _instance:Costumes;
		public static function get instance() : Costumes {
			if(!_instance) { _instance = new Costumes(); _instance.init(); }
			return _instance;
		}
		
		private const _MAX_COSTUMES_TO_CHECK_TO:Number = 250;//999;

		public var hair:Array;
		public var head:Array;
		public var eyes:Array;
		public var ears:Array;
		public var mouth:Array;
		public var neck:Array;
		public var tail:Array;
		public var contacts:Array;

		public var skins:Array;
		public var poses:Array;

		public var defaultSkinIndex:int;
		public var defaultPoseIndex:int;

		public var hand:ItemData;
		public var backHand:ItemData;
		public var fromage:ItemData;
		
		public var shamanMode:int = SHAMAN_MODE.OFF;
		public var shamanColor:int = 0x95D9D6;

		public function Costumes() {
			if(_instance){ throw new Error("Singleton class; Call using Costumes.instance"); }
		}

		public function init() : Costumes {
			var i:int;

			this.head = _setupCostumeArray({ base:"$Costume_0_", type:ITEM.HAT, itemClassToClassMap:"Tete_1" });
			this.eyes = _setupCostumeArray({ base:"$Costume_1_", type:ITEM.EYES, itemClassToClassMap:["Oeil_1", "OeilVide_1"] });
			this.ears = _setupCostumeArray({ base:"$Costume_2_", type:ITEM.EARS, itemClassToClassMap:"OreilleD_1" });
			this.mouth = _setupCostumeArray({ base:"$Costume_3_", type:ITEM.MOUTH, itemClassToClassMap:"Tete_1" });
			this.neck = _setupCostumeArray({ base:"$Costume_4_", type:ITEM.NECK, itemClassToClassMap:"Tete_1" });
			this.hair = _setupCostumeArray({ base:"$Costume_5_", type:ITEM.HAIR, itemClassToClassMap:"Tete_1" });
			this.tail = _setupCostumeArray({ base:"$Costume_6_", type:ITEM.TAIL, itemClassToClassMap:"Boule_1" });
			this.contacts = _setupCostumeArray({ base:"$Costume_7_", type:ITEM.CONTACTS, itemClassToClassMap:["Oeil_1", "OeilVide_1"] });

			this.hand = new ItemData({ type:ITEM.PAW, itemClass:Fewf.assets.getLoadedClass("$Costume_8_1") });
			this.hand.classMap = { Arme_1:this.hand.itemClass };
			this.backHand = new ItemData({ type:ITEM.PAW_BACK, itemClass:Fewf.assets.getLoadedClass("$Costume_9_1") });
			this.backHand.classMap = { PatteG_1:this.backHand.itemClass };
			this.fromage = new ItemData({ type:ITEM.BACK, itemClass:Fewf.assets.getLoadedClass("FromageSouris") });
			this.fromage.classMap = { ClipGrosse:this.fromage.itemClass };

			this.skins = new Array();
			
			var tFurColors = [ 0xBD9067, 0x593618, 0x8C887F, 0xDED7CE, 0x4E443A, 0xE3C07E, 0x272220 ];
			for(i = 0; i < tFurColors.length; i++) {
				this.skins.push( new SkinData({ id:"color"+i, assetID:1, color:tFurColors[i], type:ITEM.SKIN_COLOR }) );
			}
			
			this.skins.push( new SkinData({ id:1, assetID:1, color:0x78583A, type:ITEM.SKIN }) );
			for(i = 2; i < _MAX_COSTUMES_TO_CHECK_TO; i++) {
				if(Fewf.assets.getLoadedClass( "_Corps_2_"+i+"_1" ) != null) {
					this.skins.push( new SkinData({ id:i }) );
				}
			}
			this.defaultSkinIndex = 7;//FewfUtils.getIndexFromArrayWithKeyVal(this.skins, "id", ConstantsApp.DEFAULT_SKIN_ID);

			/*for(var i = 0; i < 7; i++) {
				this.furs.push( new FurData( i, ItemType.COLOR ).initColor() );
			}

			this.furs.push( new FurData( 1, ItemType.FUR ).initColor(FurData.DEFAULT_COLOR) );
			for(var i = 2; i < _MAX_COSTUMES_TO_CHECK_TO; i++) {
				if(Fewf.assets.getLoadedClass( "_Corps_2_"+i+"_1" ) != null) {
					//this.furs.push( new Fur().initFur( i, _setupFur(i) ) );
					this.furs.push( new FurData( i, ItemType.FUR ).initFur() );
				}
			}*/

			this.poses = [];
			var tPoseClasses = [
				"Statique", "Course", "Duck", "Sleep", "Sit", "Mad", "Laugh", "Kiss", "Facepalm", "Danse", "Cry", "Confetti", "Clap",
				"Rondoudou", "Selfie", "Zelda", "Plumes", "Langue", "Drapeau",
				"StatiqueBalai", "CourseBalai", "Peche", "Neige", "Marshmallow", "PreInvoc", "Invoc", "Cadeau", "Attaque",
				"Hi5_1", "Hi5_2", "Calin_1", "Calin_2", "Bisou_1", "Bisou_2",
			];
			// Unused: Calin,
			for(i = 0; i < tPoseClasses.length; i++) {
				this.poses.push(new ItemData({ id:tPoseClasses[i], type:ITEM.POSE, itemClass:Fewf.assets.getLoadedClass( "Anim"+tPoseClasses[i] ) }));
			}
			this.defaultPoseIndex = 0;//FewfUtils.getIndexFromArrayWithKeyVal(this.poses, "id", ConstantsApp.DEFAULT_POSE_ID);

			return this;
		}

		// pData = { base:String, type:String, after:String, pad:int, map:Array, sex:Boolean, itemClassToClassMap:String OR Array }
		private function _setupCostumeArray(pData:Object) : Array {
			var tArray:Array = new Array();
			var tClassName:String;
			var tClass:Class;
			var tSexSpecificParts:int;
			for(var i = 0; i <= _MAX_COSTUMES_TO_CHECK_TO; i++) {
				if(pData.map) {
					for(var g:int = 0; g < (pData.sex ? 2 : 1); g++) {
						var tClassMap = {  }, tClassSuccess = null;
						tSexSpecificParts = 0;
						for(var j = 0; j <= pData.map.length; j++) {
							tClass = Fewf.assets.getLoadedClass( tClassName = pData.base+(pData.pad ? zeroPad(i, pData.pad) : i)+(pData.after ? pData.after : "")+pData.map[j] );
							if(tClass) { tClassMap[pData.map[j]] = tClass; tClassSuccess = tClass; }
							else if(pData.sex){
								tClass = Fewf.assets.getLoadedClass( tClassName+"_"+(g==0?1:2) );
								if(tClass) { tClassMap[pData.map[j]] = tClass; tClassSuccess = tClass; tSexSpecificParts++ }
							}
						}
						if(tClassSuccess) {
							var tIsSexSpecific = pData.sex && tSexSpecificParts > 0;
							tArray.push( new ItemData({ id:i+(tIsSexSpecific ? (g==1 ? "M" : "F") : ""), type:pData.type, classMap:tClassMap, itemClass:tClassSuccess, gender:(tIsSexSpecific ? (g==1?GENDER.MALE:GENDER.FEMALE) : null) }) );
						}
						if(tSexSpecificParts == 0) {
							break;
						}
					}
				} else {
					tClass = Fewf.assets.getLoadedClass( pData.base+(pData.pad ? zeroPad(i, pData.pad) : i)+(pData.after ? pData.after : "") );
					if(tClass != null) {
						tArray.push( new ItemData({ id:i, type:pData.type, itemClass:tClass}) );
						if(pData.itemClassToClassMap) {
							tArray[tArray.length-1].classMap = {};
							if(pData.itemClassToClassMap is Array) {
								for(var c:int = 0; c < pData.itemClassToClassMap.length; c++) {
									tArray[tArray.length-1].classMap[pData.itemClassToClassMap[c]] = tClass;
								}
							} else {
								tArray[tArray.length-1].classMap[pData.itemClassToClassMap] = tClass;
							}
						}
					}
				}
			}
			return tArray;
		}

		public function zeroPad(number:int, width:int):String {
			var ret:String = ""+number;
			while( ret.length < width )
				ret="0" + ret;
			return ret;
		}

		public function getArrayByType(pType:String) : Array {
			switch(pType) {
				case ITEM.HAIR:		return hair;
				case ITEM.HAT:		return head;
				case ITEM.EARS:		return ears;
				case ITEM.EYES:		return eyes;
				case ITEM.MOUTH:	return mouth;
				case ITEM.NECK:		return neck;
				case ITEM.TAIL:		return tail;
				case ITEM.CONTACTS:	return contacts;
				case ITEM.SKIN_COLOR:
				case ITEM.SKIN:		return skins;
				case ITEM.POSE:		return poses;
				default: trace("[Costumes](getArrayByType) Unknown type: "+pType);
			}
			return null;
		}

		public function getItemFromTypeID(pType:String, pID:String) : ItemData {
			return FewfUtils.getFromArrayWithKeyVal(getArrayByType(pType), "id", pID);
		}

		/****************************
		* Color
		*****************************/
			public function copyColor(copyFromMC:MovieClip, copyToMC:MovieClip) : MovieClip {
				if (copyFromMC == null || copyToMC == null) { return; }
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

			public function colorDefault(pMC:MovieClip) : MovieClip {
				if (pMC == null) { return; }

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
					++loc1;
				}
				return pMC;
			}

			// pData = { obj:DisplayObject, color:String OR int, ?swatch:int, ?name:String, ?colors:Array<int> }
			public function colorItem(pData:Object) : DisplayObject {
				if (pData.obj == null) { return; }

				var tHex:int = convertColorToNumber(pData.color);

				var tChild:DisplayObject;
				var i:int=0;
				while (i < pData.obj.numChildren) {
					tChild = pData.obj.getChildAt(i);
					if (tChild.name == pData.name || (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7)) {
						if(pData.colors != null && pData.colors[tChild.name.charAt(7)] != null) {
							applyColorToObject(tChild, convertColorToNumber(pData.colors[tChild.name.charAt(7)]));
						}
						else if (!pData.swatch || pData.swatch == tChild.name.charAt(7)) {
							applyColorToObject(tChild, tHex);
						}
					}
					i++;
				}
				return pData.obj;
			}
			public function convertColorToNumber(pColor) : int {
				return pColor is Number || pColor == null ? pColor : int("0x" + pColor);
			}
			
			// pColor is an int hex value. ex: 0x000000
			public function applyColorToObject(pItem:DisplayObject, pColor:int) : void {
				if(pColor < 0) { return; }
				var tR:*=pColor >> 16 & 255;
				var tG:*=pColor >> 8 & 255;
				var tB:*=pColor & 255;
				pItem.transform.colorTransform = new flash.geom.ColorTransform(tR / 128, tG / 128, tB / 128);
			}

			public function getColors(pMC:MovieClip) : Array {
				var tChild:*=null;
				var tTransform:*=null;
				var tArray:Array=new Array();

				var i:int=0;
				while (i < pMC.numChildren) {
					tChild = pMC.getChildAt(i);
					if (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7) {
						tTransform = tChild.transform.colorTransform;
						tArray[tChild.name.charAt(7)] = ColorMathUtil.RGBToHex(tTransform.redMultiplier * 128, tTransform.greenMultiplier * 128, tTransform.blueMultiplier * 128);
					}
					i++;
				}
				return tArray;
			}

			public function getNumOfCustomColors(pMC:MovieClip) : int {
				var tChild:*=null;
				var num:int = 0;
				var i:int = 0;
				while (i < pMC.numChildren) {
					tChild = pMC.getChildAt(i);
					if (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7) {
						num++;
					}
					i++;
				}
				return num;
			}

		/****************************
		* Asset Creation
		*****************************/
			public function getItemImage(pData:ItemData) : MovieClip {
				var tItem:MovieClip;
				switch(pData.type) {
					case ITEM.SKIN:
					case ITEM.SKIN_COLOR:
						tItem = getDefaultPoseSetup({ skin:pData });
						break;
					case ITEM.POSE:
						tItem = getDefaultPoseSetup({ pose:pData });
						break;
					/*case ITEM.SHIRT:
					case ITEM.PANTS:
					case ITEM.SHOES:
						tItem = new Pose(poses[defaultPoseIndex]).apply({ items:[ pData ], removeBlanks:true });
						break;*/
					default:
						tItem = new pData.itemClass();
						colorDefault(tItem);
						break;
				}
				return tItem;
			}

			// pData = { ?pose:ItemData, ?skin:SkinData }
			public function getDefaultPoseSetup(pData:Object) : Pose {
				var tPoseData = pData.pose ? pData.pose : poses[defaultPoseIndex];
				var tSkinData = pData.skin ? pData.skin : skins[defaultSkinIndex];

				tPose = new Pose(tPoseData);
				if(tSkinData.gender == GENDER.MALE) {
					tPose.apply({ items:[
						tSkinData
					], shamanMode:SHAMAN_MODE.OFF });
				} else {
					tPose.apply({ items:[
						tSkinData
					], shamanMode:SHAMAN_MODE.OFF });
				}
				tPose.stopAtLastFrame();

				return tPose;
			}

		// Converts the image to a PNG bitmap and prompts the user to save.
		public function saveMovieClipAsBitmap(pObj:DisplayObject, pName:String="character", pScale:Number=1) : void
		{
			if(!pObj){ return; }

			var tRect:flash.geom.Rectangle = pObj.getBounds(pObj);
			var tBitmap:flash.display.BitmapData = new flash.display.BitmapData(tRect.width*pScale, tRect.height*pScale, true, 0xFFFFFF);

			var tMatrix:flash.geom.Matrix = new flash.geom.Matrix(1, 0, 0, 1, -tRect.left, -tRect.top);
			tMatrix.scale(pScale, pScale);

			tBitmap.draw(pObj, tMatrix);
			( new flash.net.FileReference() ).save( com.adobe.images.PNGEncoder.encode(tBitmap), pName+".png" );
		}
	}
}
