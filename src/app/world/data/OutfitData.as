package app.world.data
{
	import app.data.GameAssets;
	import app.data.ItemType;
	import app.data.ShamanMode;
	import app.world.data.ItemData;
	import app.world.data.SkinData;
	import com.fewfre.utils.FewfUtils;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLVariables;
	import flash.utils.Dictionary;

	public class OutfitData extends EventDispatcher
	{
		// Constants
		public static const UPDATED : String = "updated";
		
		// Storage
		private var _shamanMode:ShamanMode = ShamanMode.OFF;
		public function get shamanMode():ShamanMode { return _shamanMode; }
		public function set shamanMode(val:ShamanMode) { _shamanMode = val; _dispatchUpdate(); }
		
		private var _shamanColor:int = 0x95D9D6;
		public function get shamanColor():int { return _shamanColor; }
		public function set shamanColor(val:int) { _shamanColor = val; _dispatchUpdate(); }
		
		private var _disableSkillsMode:Boolean = false;
		public function get disableSkillsMode():Boolean { return _disableSkillsMode; }
		public function set disableSkillsMode(val:Boolean) { _disableSkillsMode = val; _dispatchUpdate(); }
		
		private var _flagWavingCode:String = "";
		public function get flagWavingCode():String { return _flagWavingCode; }
		public function set flagWavingCode(val:String) { _flagWavingCode = val; _dispatchUpdate(); }

		private var _itemDataMap:Dictionary; // Record<ItemType, ItemData>
		private var _itemLockMap:Dictionary; // Record<ItemType, Boolean>
		
		public var _flagMakeItemDataCopiesFromShareCodes:Boolean;

		// Constructor
		public function OutfitData(pMakeCopies:Boolean=false) {
			super();
			_flagMakeItemDataCopiesFromShareCodes = pMakeCopies;
			_itemDataMap = new Dictionary();
			_itemLockMap = new Dictionary();
		}
		public function copy() : OutfitData { var od:OutfitData; (od=new OutfitData(_flagMakeItemDataCopiesFromShareCodes)).parseShareCode(this.stringify_fewfreSyntax()); return od; }
		public function on(type:String, listener:Function): OutfitData { this.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): OutfitData { this.removeEventListener(type, listener); return this; }

		private function _dispatchUpdate() : void { dispatchEvent(new Event(UPDATED)); }

		/////////////////////////////
		//#region Item Data
		/////////////////////////////
		public function getItemData(pType:ItemType) : ItemData {
			return _itemDataMap[pType];
		}

		public function getItemDataVector() : Vector.<ItemData> {
			var list:Vector.<ItemData> = new Vector.<ItemData>();
			for each(var itemData:ItemData in _itemDataMap) {
				list.push(itemData);
			}
			return list;
		}

		public function setItemData(pItemData:ItemData) : OutfitData {
			_itemDataMap[pItemData.type] = pItemData;
			_dispatchUpdate();
			return this;
		}

		public function setItemDataVector(pItemDatas:Vector.<ItemData>) : OutfitData {
			for each(var itemData:ItemData in pItemDatas) {
				_itemDataMap[itemData.type] = itemData;
			}
			_dispatchUpdate();
			return this;
		}

		public function removeItem(pType:ItemType) : void {
			_itemDataMap[pType] = null;
			_dispatchUpdate();
		}

		/////////////////////////////
		//#region ItemType Locked
		/////////////////////////////
		public function isItemTypeLocked(pType:ItemType) : Boolean {
			return !!_itemLockMap[pType];
		}
		
		public function setItemTypeLock(pType:ItemType, pLocked:Boolean) : void {
			_itemLockMap[pType] = pLocked;
			// no need to update pose as this has no direct effect on character, only controlling what changes can be made to it
		}

		/////////////////////////////
		//#region Share Code - Constants
		/////////////////////////////
		public static const ITEM_TYPE_TO_FEWFRE_PARAM_NAME : Dictionary = new Dictionary();
		ITEM_TYPE_TO_FEWFRE_PARAM_NAME[ItemType.SKIN] = "s";
		ITEM_TYPE_TO_FEWFRE_PARAM_NAME[ItemType.HAIR] = "d";
		ITEM_TYPE_TO_FEWFRE_PARAM_NAME[ItemType.HEAD] = "h";
		ITEM_TYPE_TO_FEWFRE_PARAM_NAME[ItemType.EARS] = "e";
		ITEM_TYPE_TO_FEWFRE_PARAM_NAME[ItemType.EYES] = "y";
		ITEM_TYPE_TO_FEWFRE_PARAM_NAME[ItemType.MOUTH] = "m";
		ITEM_TYPE_TO_FEWFRE_PARAM_NAME[ItemType.NECK] = "n";
		ITEM_TYPE_TO_FEWFRE_PARAM_NAME[ItemType.TAIL] = "t";
		ITEM_TYPE_TO_FEWFRE_PARAM_NAME[ItemType.CONTACTS] = "c";
		ITEM_TYPE_TO_FEWFRE_PARAM_NAME[ItemType.HAND] = "hd";
		ITEM_TYPE_TO_FEWFRE_PARAM_NAME[ItemType.TATTOO] = "tt";
		ITEM_TYPE_TO_FEWFRE_PARAM_NAME[ItemType.EMOJI] = "em";
		ITEM_TYPE_TO_FEWFRE_PARAM_NAME[ItemType.POSE] = "p";
		
		public static const FEWFRE_SYNTAX_LOOPING_ITEM_TYPES : Vector.<ItemType> = new <ItemType>[
			ItemType.SKIN, ItemType.HAIR, ItemType.HEAD, ItemType.EARS, ItemType.EYES, ItemType.MOUTH, ItemType.NECK, ItemType.TAIL, ItemType.CONTACTS, ItemType.HAND, ItemType.TATTOO, ItemType.EMOJI, ItemType.POSE
		];

		/////////////////////////////
		//#region Share Code - Parse
		/////////////////////////////
		public function parseShareCode(pCode:String, pSkipTrace:Boolean=false) : Boolean {
			if(!pCode) return true; // true since technically no errors, just an empty share code?
			if(!pSkipTrace) trace("(parseParams) ", pCode);
			
			// Url param code
			if(pCode.indexOf("=") > -1) {
				return _parseParamsFewfreSyntax(pCode);
			}
			else { // Official TFM /dressing params
				return _parseParamsTfmOfficialSyntax(pCode);
			}
			return true;
		}
		public function parseShareCodeSelf(pCode:String, pSkipTrace:Boolean=false) : OutfitData {
			parseShareCode(pCode, pSkipTrace);
			return this;
		}
		
		private function _parseParamsFewfreSyntax(pCode:String) : Boolean {
			try {
				var pParams = new URLVariables();
				pParams.decode(pCode);
				
				for each(var itemType:ItemType in FEWFRE_SYNTAX_LOOPING_ITEM_TYPES) {
					if(isItemTypeLocked(itemType)) continue;
					var tParam:String = ITEM_TYPE_TO_FEWFRE_PARAM_NAME[itemType];
					// try {
						var tData:ItemData = null, tID = pParams[tParam], tColors;
						if(tID != null && tID != "") {
							tColors = _splitOnUrlColorSeperator(tID); // Get a list of all the colors (ID is first); ex: 5;ffffff;abcdef;169742
							tID = tColors.splice(0, 1)[0]; // Remove first item and store it as the ID.
							tData = GameAssets.getItemFromTypeID(itemType, tID); if(_flagMakeItemDataCopiesFromShareCodes) tData = tData.copy();
							if(tColors.length > 0) { tData.colors = _hexArrayToIntList(tColors, tData.defaultColors); }
							else if(tData.isCustomizable) { tData.setColorsToDefault(); }
						}
						var tAllowNull:Boolean = itemType == ItemType.SKIN || itemType == ItemType.POSE;
						_itemDataMap[itemType] = tAllowNull ? tData : ( tData == null ? _itemDataMap[itemType] : tData );
					// } catch (error:Error) { };
				}
				
				if(pParams.paw == "y") { _itemDataMap[ItemType.OBJECT] = GameAssets.extraObjectWand; }
				if(pParams.back != null && pParams.back != "") {
					if(pParams.back == "y") pParams.back = GameAssets.extraBack[0].id;
					for each(var itemData:ItemData in GameAssets.extraBack) {
						if(pParams.back == itemData.id) _itemDataMap[ItemType.BACK] = itemData;
					}
				}
				if(pParams.pawb == "y") { _itemDataMap[ItemType.PAW_BACK] = GameAssets.extraBackHand; }
				
				if(pParams["sh"] && pParams["sh"] != "") {
					var tColor = _splitOnUrlColorSeperator(pParams["sh"]);
					_shamanMode = ShamanMode.fromInt( parseInt(tColor.splice(0, 1)[0]) );
					if(tColor.length > 0) {
						_shamanColor = FewfUtils.colorHexStringToInt(tColor[0]);
					}
				}
				_disableSkillsMode = pParams.ds == 'y';
				_flagWavingCode = pParams.fw;
				_dispatchUpdate();
			}
			catch (error:Error) { return false; };
			return true;
		}
		
		private function _parseParamsTfmOfficialSyntax(pCode:String) : Boolean {
			try {
				var arr:Array = pCode.split(";");
				// Check for wierd syntax where fur id isn't included (old account, or maybe haven't bought one yet?)
				if(arr[0].indexOf(",") >= 0) {
					arr = [ "1", arr[0] ];
				}
				_setParamToTypeTfmOfficialSyntax(ItemType.SKIN, arr[2] && arr[0]==1 ? arr[0]+"_"+arr[2] : arr[0], false);
				
				arr = arr[1].split(",");
				// Add the `0` categories if an older shorter code
				if(arr.length <= 10) { arr.splice(9, 0, "0"); arr.splice(10, 0, "0"); }
				var tTypes:Vector.<ItemType> = ItemType.LOOK_CODE_ITEM_ORDER;
				for(var i:int = 0; i < tTypes.length; i++) {
					if(tTypes[i] === null) { continue; }
					_setParamToTypeTfmOfficialSyntax(tTypes[i], arr[i]);
				}
				_dispatchUpdate();
			} catch(error:Error) { return false; };
			return true;
		}
		private function _setParamToTypeTfmOfficialSyntax(pType:ItemType, pParamVal:String, pAllowNull:Boolean=true) {
			if(isItemTypeLocked(pType)) return;
			try {
				var tData:ItemData = null, tID:String = pParamVal, tColors;
				if(tID != null && tID != "") {
					tColors = tID.split(/\_|\+/); // Get a list of all the colors (ID is first); ex: 5_ffffff+abcdef+169742
					tID = tColors.splice(0, 1)[0]; // Remove first item and store it as the ID.
					// Color skins in game syntax are stored differently than dressroom
					if(pType == ItemType.SKIN && tID == "1" && tColors[0] && GameAssets.FUR_COLORS.indexOf(FewfUtils.colorHexStringToInt(tColors[0])) >= 0) {
						tID = "color"+GameAssets.FUR_COLORS.indexOf(FewfUtils.colorHexStringToInt(tColors[0]));
						tColors = [];
					}
					tData = GameAssets.getItemFromTypeID(pType, tID); if(_flagMakeItemDataCopiesFromShareCodes) tData = tData.copy();
					if(tColors.length > 0) { tData.colors = _hexArrayToIntList(tColors, tData.defaultColors); }
					else if(pType != ItemType.SKIN || (tID == 1 || tID == "1")) { tData.setColorsToDefault(); }
				}
				_itemDataMap[pType] = pAllowNull ? tData : ( tData == null ? _itemDataMap[pType] : tData );
			} catch (error:Error) { };
		}
		private function _hexArrayToIntList(pColors:Array, pDefaults:Vector.<uint>) : Vector.<uint> {
			var ints = new Vector.<uint>();
			for(var i = 0; i < pDefaults.length; i++) {
				ints.push( pColors[i] ? FewfUtils.colorHexStringToInt(pColors[i]) : pDefaults[i] );
			}
			return ints;
		}
		private function _splitOnUrlColorSeperator(pVal:String) : Array {
			// Used to be , but changed to ; (for atelier801 forum support)
			return pVal.indexOf(";") > -1 ? pVal.split(";") : pVal.split(",");
		}

		/////////////////////////////
		//#region Share Code - Stringify
		/////////////////////////////
		public function stringify_fewfreSyntax() : String {
			var tParms = new URLVariables();
			
			for each(var itemType:ItemType in FEWFRE_SYNTAX_LOOPING_ITEM_TYPES) {
				var tParam:String = ITEM_TYPE_TO_FEWFRE_PARAM_NAME[itemType];
				var tData:ItemData = getItemData(itemType);
				if(tData) {
					tParms[tParam] = tData.id;
					var tColors:Vector.<uint> = tData.colors;
					if(String(tColors) != String(tData.defaultColors)) { // Quick way to compare two arrays with primitive types
						tParms[tParam] += ";"+_intListToHexList(tColors).join(";");
					}
				}
				/*else { tParms[tParam] = ''; }*/
			}
			
			if(getItemData(ItemType.OBJECT)) { tParms.paw = "y"; }
			if(getItemData(ItemType.BACK)) {
				tParms.back = getItemData(ItemType.BACK).id == GameAssets.extraBack[0].id ? "y" : getItemData(ItemType.BACK).id;
			}
			if(getItemData(ItemType.PAW_BACK)) { tParms.pawb = "y"; }
			
			if(_shamanMode != ShamanMode.OFF) {
				tParms["sh"] = _shamanMode.toInt()+";"+FewfUtils.colorIntToHexString(_shamanColor);
			}
			if(_disableSkillsMode) {
				tParms.ds = 'y';
			}
			if(_flagWavingCode && getItemData(ItemType.POSE).id == "Drapeau") {
				tParms.fw = _flagWavingCode;
			}

			return tParms.toString().replace(/%3B/g, ";");
		}
		public function stringify_tfmOfficialSyntax() : String {
			var tSkinData:SkinData = getItemData(ItemType.SKIN) as SkinData;
			if(tSkinData.id == "hide") tSkinData = GameAssets.defaultSkin as SkinData; // Official syntax can't support hidden skin, so fallback to default skin
			var skinId = tSkinData.isSkinColor ? 1 : tSkinData.id;
			var code:String = skinId+";";
			
			// Apply various parts
			var tTypes = ItemType.LOOK_CODE_ITEM_ORDER;
			var tIds = [];
			for(var i:int = 0; i < tTypes.length; i++) {
				if(tTypes[i] === null) { tIds.push(0); continue; }
				
				var tData:ItemData = getItemData(tTypes[i]);
				if(tData) {
					var tColors:Vector.<uint> = tData.colors;
					if(String(tColors) != String(tData.defaultColors)) { // Quick way to compare two arrays with primitive types
						tIds.push(tData.id+"_"+_intListToHexList(tColors).join("+") );
					} else {
						tIds.push(tData.id);
					}
				} else {
					tIds.push(0);
				}
			}
			code += tIds.join(",");
			
			// Add fur color to end, if there is one
			if(tSkinData.defaultColors && skinId == 1 && tSkinData.colors[0] != GameAssets.DEFAULT_FUR_COLOR) {
				code += ";"+_intListToHexList(tSkinData.colors)[0];
			}
			return code;
		}
		private function _intListToHexList(pColors:Vector.<uint>) : Vector.<String> {
			var hexList = new Vector.<String>();
			for(var i = 0; i < pColors.length; i++) {
				hexList.push( FewfUtils.colorIntToHexString(pColors[i]) );
			}
			return hexList;
		}
	}
}
