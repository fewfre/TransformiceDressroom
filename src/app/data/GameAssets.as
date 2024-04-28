package app.data
{
	import com.fewfre.utils.*;
	import com.piterwilson.utils.ColorMathUtil;
	import app.data.*;
	import app.world.data.*;
	import app.world.elements.*;
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;

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
		public static var tattoo: Vector.<ItemData>;

		public static var skins: Vector.<ItemData>;
		public static var poses: Vector.<ItemData>;
		
		public static var accessorySlotBones:Dictionary;

		private static var _defaultSkinIndex:int;
		private static var _defaultPoseIndex:int;

		public static var extraObjectWand:ItemData;
		public static var extraBackHand:ItemData;
		public static var extraBack:Vector.<ItemData>;
		
		// { type:ItemType, id:String, colorI:int }
		public static var swatchHoverPreviewData:Object = null;

		public static function get defaultSkin() : ItemData { return skins[_defaultSkinIndex]; }
		public static function get defaultPose() : ItemData { return poses[_defaultPoseIndex]; }

		public static function init(pOnInitComplete:Function) : void {
			_doInitSteps(new <Function>[
function(){ head = _setupCostumeList(ItemType.HEAD, "$Costume_0_", { itemClassToClassMap:"Tete_1" }); },
function(){ eyes = _setupCostumeList(ItemType.EYES, "$Costume_1_", { itemClassToClassMap:["Oeil_1", "OeilVide_1", "Oeil2_1", "Oeil3_1", "Oeil4_1"] }); },
function(){ ears = _setupCostumeList(ItemType.EARS, "$Costume_2_", { itemClassToClassMap:"OreilleD_1" }); },
function(){ mouth = _setupCostumeList(ItemType.MOUTH, "$Costume_3_", { itemClassToClassMap:"Tete_1" }); },
function(){ neck = _setupCostumeList(ItemType.NECK, "$Costume_4_", { itemClassToClassMap:"Tete_1" }); },
function(){ hair = _setupCostumeList(ItemType.HAIR, "$Costume_5_", { itemClassToClassMap:"Tete_1" }); },
function(){ tail = _setupCostumeList(ItemType.TAIL, "$Costume_6_", { itemClassToClassMap:"Boule_1" }); },
function(){ contacts = _setupCostumeList(ItemType.CONTACTS, "$Costume_7_", { itemClassToClassMap:["Oeil_1"] }); },
function(){ hands = _setupCostumeList(ItemType.HAND, "$Costume_8_", { itemClassToClassMap:"Gant_1" }); },
function(){ tattoo = _setupCostumeList(ItemType.TATTOO, "$Costume_11_", { itemClassToClassMap:"CuisseD_1" }); },
function(){
	extraObjectWand = new ItemData(ItemType.OBJECT, null, { itemClass:Fewf.assets.getLoadedClass("$Costume_9_1"), classMap:{ Arme_1:Fewf.assets.getLoadedClass("$Costume_9_1") } });
	extraBackHand = new ItemData(ItemType.PAW_BACK, null, { itemClass:$HandButtonShield, classMap:{ PatteG_1:$HandButtonShield } });
	extraBack = new <ItemData>[
		new ItemData(ItemType.BACK, 'frm', { itemClass:FromageSouris, classMap:{ ClipGrosse:FromageSouris } }),
		new ItemData(ItemType.BACK, 'stnk', { itemClass:FromageSourisPasFrais, classMap:{ ClipGrosse:FromageSourisPasFrais } }),
		new ItemData(ItemType.BACK, 'cit', { itemClass:FromageSourisCitrouille, classMap:{ ClipGrosse:FromageSourisCitrouille } }),
		new ItemData(ItemType.BACK, 'glace', { itemClass:FromageSourisGlace, classMap:{ ClipGrosse:FromageSourisGlace } }),
		new ItemData(ItemType.BACK, 'nounours', { itemClass:FromageSourisNounours, classMap:{ ClipGrosse:FromageSourisNounours } }),
	];
},
function(){
	skins = new Vector.<ItemData>();
	
	var i:int;
	for(i = 0; i < FUR_COLORS.length; i++) {
		skins.push( new SkinData({ id:"color"+i, assetID:1, color:FUR_COLORS[i], isSkinColor:true }) );
	}
	
	skins.push( new SkinData({ id:1, assetID:1, color:DEFAULT_FUR_COLOR, type:ItemType.SKIN }) );
	for(i = 2; i < _MAX_COSTUMES_TO_CHECK_TO; i++) {
		if(Fewf.assets.getLoadedClass( "_Corps_2_"+i+"_1" ) != null) {
			skins.push( new SkinData({ id:i }) );
		}
	}
	_defaultSkinIndex = 7;//FewfUtils.getIndexFromVectorWithKeyVal(skins, "id", ConstantsApp.DEFAULT_SKIN_ID);

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
},
function(){
	poses = new Vector.<ItemData>();
	var tPoseClasses = [
		"Statique", "Course", "Duck", "Sleep", "Sit", "Mad", "Laugh", "Kiss", "Facepalm", "Danse", "Cry", "Confetti", "Clap",
		"Rondoudou", "Selfie", "Zelda", "Plumes", "Langue", "Drapeau",
		"StatiqueBalai", "CourseBalai", "Peche", "Neige", "Marshmallow", "PreInvoc", "Invoc", "Cadeau", "Attaque",
		"Hi5_1", "Hi5_2", "Calin_1", "Calin_2", "Bisou_1", "Bisou_2",
	];
	// Unused: Calin,
	for(var i:int = 0; i < tPoseClasses.length; i++) {
		poses.push(new ItemData(ItemType.POSE, tPoseClasses[i], { itemClass:Fewf.assets.getLoadedClass( "Anim"+tPoseClasses[i] ) }));
	}
	_defaultPoseIndex = 0;//FewfUtils.getIndexFromVectorWithKeyVal(poses, "id", ConstantsApp.DEFAULT_POSE_ID);
},
pOnInitComplete
			]);

			accessorySlotBones = new Dictionary();
			accessorySlotBones[0]   = new <String>["Tete_1"];
			accessorySlotBones[1]   = new <String>["OeilVide_1","Oeil2_1","Oeil3_1","Oeil4_1"];
			accessorySlotBones[2]   = new <String>["OreilleD_1"];
			accessorySlotBones[3]   = new <String>["Tete_1"];
			accessorySlotBones[4]   = new <String>["Tete_1"];
			accessorySlotBones[5]   = new <String>["Tete_1"];
			accessorySlotBones[6]   = new <String>["Boule_1"];
			accessorySlotBones[7]   = new <String>["Oeil_1"];
			accessorySlotBones[8]   = new <String>["Gant_1"];
			accessorySlotBones[9]   = new <String>["Arme_1"];
			accessorySlotBones[10]  = new <String>["Bouclier_1"];
			accessorySlotBones[11]  = new <String>["CuisseD_1","CuisseG_1"];
			accessorySlotBones[12]  = new <String>["Queue_1"];
			accessorySlotBones[101] = new <String>["OreilleG_1"];
		}
		
		private static function _doInitSteps(steps:Vector.<Function>) : void {
			setTimeout(function(){
				steps.shift()();
				if(steps.length > 0) _doInitSteps(steps);
			}, 0);
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

		/****************************
		* Access Data
		*****************************/
		public static function getItemDataListByType(pType:ItemType) : Vector.<ItemData> {
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
				case ItemType.TATTOO:	return tattoo;
				case ItemType.SKIN:		return skins;
				case ItemType.POSE:		return poses;
				case ItemType.BACK:		return extraBack;
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
		* Color - GET
		*****************************/
		public static function findDefaultColors(pMC:MovieClip) : Vector.<uint> {
			return Vector.<uint>( _findDefaultColorsRecursive(pMC, []) );
		}
		private static function _findDefaultColorsRecursive(pMC:MovieClip, pList:Array) : Array {
			if (!pMC) { return pList; }

			var child:DisplayObject=null, name:String=null, colorI:int = 0;
			var i:*=0;
			while (i < pMC.numChildren)
			{
				child = pMC.getChildAt(i);
				name = child.name;
				
				if(name) {
					if (name.indexOf("Couleur") == 0 && name.length > 7) {
						// hardcoded fix for tfm eye:31, which has a color of: Couleur_08C7474 (0 and _ are swapped)
						if(name.charAt(7) == '_') {
							colorI = int(name.charAt(8));
							pList[colorI] = int("0x" + name.substr(name.indexOf("_") + 2, 6));
						} else {
							colorI = int(name.charAt(7));
							pList[colorI] = int("0x" + name.substr(name.indexOf("_") + 1, 6));
						}
					}
					else if(name.indexOf("slot_") == 0) {
						_findDefaultColorsRecursive(child as MovieClip, pList);
					}
					i++;
				}
			}
			return pList;
		}

		public static function getNumOfCustomColors(pMC:MovieClip) : int {
			// Use recursive one since the array it returns is a bit more safe for this than the vector
			return _findDefaultColorsRecursive(pMC, []).length;
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
		* Color - APPLY
		*****************************/
		public static function copyColor(copyFromMC:MovieClip, copyToMC:MovieClip) : MovieClip {
			if (copyFromMC == null || copyToMC == null) { return null; }
			var tChildSource:DisplayObject=null, tChildTarget:DisplayObject=null;
			
			for(var i:int = 0; i < copyFromMC.numChildren; i++){
				tChildSource = copyFromMC.getChildAt(i);
				tChildTarget = copyToMC.getChildAt(i);
				if (tChildSource.name.indexOf("Couleur") == 0 && tChildSource.name.length > 7) {
					tChildTarget.transform.colorTransform = tChildSource.transform.colorTransform;
				}
				if(tChildSource is MovieClip && (tChildSource as MovieClip).numChildren > 0) {
					copyColor(tChildSource as MovieClip, tChildTarget as MovieClip);
				}
			}
			return copyToMC;
		}
		
		// pColor is an int hex value. ex: 0x000000
		public static function applyColorToObject(pItem:DisplayObject, pColor:int) : void {
			if(pColor < 0) { return; }
			var tR:*=pColor >> 16 & 255;
			var tG:*=pColor >> 8 & 255;
			var tB:*=pColor & 255;
			pItem.transform.colorTransform = new flash.geom.ColorTransform(tR / 128, tG / 128, tB / 128);
		}

		public static function colorItemUsingColorList(pSprite:Sprite, pColors:Vector.<uint>) : DisplayObject {
			if (pSprite == null) { return null; }

			var tChild: DisplayObject, name:String;
			var i:int=0;
			while (i < pSprite.numChildren) {
				tChild = pSprite.getChildAt(i); name = tChild.name;
				
				if (name.indexOf("Couleur") == 0 && name.length > 7) {
					// hardcoded fix for tfm eye:31, which has a color of: Couleur_08C7474 (0 and _ are swapped)
					var colorI:int = int(name.charAt(7) == '_' ? name.charAt(8) : name.charAt(7));
					// fallback encase colorI is outside of the list
					var color:uint = colorI < pColors.length ? pColors[colorI] : int("0x" + name.split("_")[1]);
					applyColorToObject(tChild, color);
				}
				else if(tChild.name.indexOf("slot_") == 0) {
					colorItemUsingColorList(tChild as Sprite, pColors);
				}
				i++;
			}
			return pSprite;
		}

		public static function colorDefault(pMC:MovieClip) : MovieClip {
			var colors:Vector.<uint> = findDefaultColors(pMC);
			colorItemUsingColorList(pMC, colors);
			return pMC;
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
		
		public static function getColoredItemImage(pData:ItemData) : MovieClip {
			return colorItemUsingColorList(getItemImage(pData), getColorsWithPossibleHoverEffect(pData)) as MovieClip;
		}

		// pData = { ?pose:ItemData, ?skin:SkinData }
		public static function getDefaultPoseSetup(pData:Object) : Pose {
			var tPoseData = pData.pose ? pData.pose : defaultPose;
			var tSkinData = pData.skin ? pData.skin : defaultSkin;

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
	}
}
