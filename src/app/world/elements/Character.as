package app.world.elements
{
	import com.piterwilson.utils.*;
	import app.data.*;
	import app.world.data.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;

	public class Character extends Sprite
	{
		// Storage
		public var outfit:MovieClip;
		public var animatePose:Boolean;
		public var isOutfit:Boolean;

		private var _itemDataMap:Object;

		// Properties
		public function set scale(pVal:Number) : void { outfit.scaleX = outfit.scaleY = pVal; }

		// Constructor
		// pData = { x:Number, y:Number, [various "__Data"s], ?params:String }
		public function Character(pData:Object) {
			super();
			animatePose = false;
			isOutfit = !!pData.isOutfit;

			this.x = pData.x;
			this.y = pData.y;

			this.buttonMode = true;
			this.addEventListener(MouseEvent.MOUSE_DOWN, function () { startDrag(); });
			this.addEventListener(MouseEvent.MOUSE_UP, function () { stopDrag(); });

			/****************************
			* Store Data
			*****************************/
			_itemDataMap = {};
			_itemDataMap[ITEM.SKIN] = pData.skin;
			_itemDataMap[ITEM.HAT] = pData.hat;
			_itemDataMap[ITEM.HAIR] = pData.hair;
			_itemDataMap[ITEM.EARS] = pData.ears;
			_itemDataMap[ITEM.EYES] = pData.eyes;
			_itemDataMap[ITEM.MOUTH] = pData.mouth;
			_itemDataMap[ITEM.NECK] = pData.neck;
			_itemDataMap[ITEM.TAIL] = pData.tail;
			_itemDataMap[ITEM.CONTACTS] = pData.contacts;
			_itemDataMap[ITEM.HAND] = pData.hand;
			_itemDataMap[ITEM.POSE] = pData.pose;

			_itemDataMap[ITEM.OBJECT] = pData.object;
			_itemDataMap[ITEM.BACK] = pData.back;
			_itemDataMap[ITEM.PAW_BACK] = pData.pawback;
			
			if(pData.params) parseParams(pData.params);

			updatePose();
		}

		public function updatePose() {
			var tScale = 3;
			if(outfit != null) { tScale = outfit.scaleX; removeChild(outfit); }
			outfit = addChild(new Pose(getItemData(ITEM.POSE))) as Pose;
			outfit.scaleX = outfit.scaleY = tScale;
			// Don't let the pose eat mouse input
			outfit.mouseChildren = false;
			outfit.mouseEnabled = false;

			outfit.apply({
				items:[
					getItemData(ITEM.SKIN),
					getItemData(ITEM.HAT),
					getItemData(ITEM.HAIR),
					getItemData(ITEM.EARS),
					getItemData(ITEM.EYES),
					getItemData(ITEM.MOUTH),
					getItemData(ITEM.NECK),
					getItemData(ITEM.TAIL),
					getItemData(ITEM.CONTACTS),
					getItemData(ITEM.HAND),

					getItemData(ITEM.OBJECT),
					getItemData(ITEM.BACK),
					getItemData(ITEM.PAW_BACK)
				],
				shamanMode: isOutfit ? SHAMAN_MODE.OFF : null // null sets it to use global value
			});
			if(animatePose) outfit.play(); else outfit.stopAtLastFrame();
		}

		public function parseParams(pCode:String) : Boolean {
			trace("(parseParams) ", pCode);
			
			// Url param code
			if(pCode.indexOf("=") > -1) {
				try {
					var pParams = new flash.net.URLVariables();
					pParams.decode(pCode);
					
					_setParamToType(pParams, ITEM.SKIN, "s", false);
					_setParamToType(pParams, ITEM.HAIR, "d");
					_setParamToType(pParams, ITEM.HAT, "h");
					_setParamToType(pParams, ITEM.EARS, "e");
					_setParamToType(pParams, ITEM.EYES, "y");
					_setParamToType(pParams, ITEM.MOUTH, "m");
					_setParamToType(pParams, ITEM.NECK, "n");
					_setParamToType(pParams, ITEM.TAIL, "t");
					_setParamToType(pParams, ITEM.CONTACTS, "c");
					_setParamToType(pParams, ITEM.HAND, "hd");
					_setParamToType(pParams, ITEM.POSE, "p", false);
					
					if(pParams.paw == "y") { _itemDataMap[ITEM.OBJECT] = GameAssets.extraObjectWand; }
					if(pParams.back == "y") { _itemDataMap[ITEM.BACK] = GameAssets.extraFromage; }
					if(pParams.pawb == "y") { _itemDataMap[ITEM.PAW_BACK] = GameAssets.extraBackHand; }
					
					if(pParams["sh"] && pParams["sh"] != "") {
						var tColor = _splitOnUrlColorSeperator(pParams["sh"]);
						GameAssets.shamanMode = parseInt(tColor.splice(0, 1)[0]);
						if(tColor.length > 0) {
							GameAssets.shamanColor = _hexToInt(tColor[0]);
						}
					}
					
				} catch (error:Error) { return false; };
			} else {
				// Official TFM /dressing params
				try {
					var arr = pCode.split(";");
					// Check for wierd syntax where fur id isn't included (old account, or maybe haven't bought one yet?)
					if(arr[0].indexOf(",") >= 0) {
						arr = [ "1", arr[0] ];
					}
					_setParamToTypeTfmOfficialSyntax(ITEM.SKIN, arr[2] && arr[0]==1 ? arr[0]+"_"+arr[2] : arr[0], false);
					
					arr = arr[1].split(",");
					var tTypes = [ITEM.HAT, ITEM.EYES, ITEM.EARS, ITEM.MOUTH, ITEM.NECK, ITEM.HAIR, ITEM.TAIL, ITEM.CONTACTS, ITEM.HAND];
					for(var i:int = 0; i < tTypes.length; i++) {
						_setParamToTypeTfmOfficialSyntax(tTypes[i], arr[i]);
					}
				} catch(error:Error) { return false; };
			}
			return true;
		}
		private function _setParamToTypeTfmOfficialSyntax(pType:String, pParamVal:String, pAllowNull:Boolean=true) {
			try {
				var tData:ItemData = null, tID = pParamVal, tColors;
				if(tID != null && tID != "") {
					tColors = tID.split(/\_|\+/); // Get a list of all the colors (ID is first); ex: 5_ffffff+abcdef+169742
					tID = tColors.splice(0, 1)[0]; // Remove first item and store it as the ID.
					// Color skins in game syntax are stored differently than dressroom
					if(pType == ITEM.SKIN && tID == "1" && tColors[0] && GameAssets.FUR_COLORS.indexOf(_hexToInt(tColors[0])) >= 0) {
						tID = "color"+GameAssets.FUR_COLORS.indexOf(_hexToInt(tColors[0]));
						tColors = [];
					}
					tData = GameAssets.getItemFromTypeID(pType, tID);
					if(isOutfit) tData = tData.copy();
					if(tColors.length > 0) { tData.colors = _hexArrayToIntArray(tColors, tData.defaultColors); }
					else if(tID == 1 || tID == "1") { tData.setColorsToDefault(); }
				}
				_itemDataMap[pType] = pAllowNull ? tData : ( tData == null ? _itemDataMap[pType] : tData );
			} catch (error:Error) { };
		}
		private function _setParamToType(pParams:URLVariables, pType:String, pParam:String, pAllowNull:Boolean=true) {
			try {
				var tData:ItemData = null, tID = pParams[pParam], tColors;
				if(tID != null && tID != "") {
					tColors = _splitOnUrlColorSeperator(tID); // Get a list of all the colors (ID is first); ex: 5;ffffff;abcdef;169742
					tID = tColors.splice(0, 1)[0]; // Remove first item and store it as the ID.
					tData = GameAssets.getItemFromTypeID(pType, tID);
					if(isOutfit) tData = tData.copy();
					if(tColors.length > 0) { tData.colors = _hexArrayToIntArray(tColors, tData.defaultColors); }
					else if(tID == 1 || tID == "1") { tData.setColorsToDefault(); }
				}
				_itemDataMap[pType] = pAllowNull ? tData : ( tData == null ? _itemDataMap[pType] : tData );
			} catch (error:Error) { };
		}
		private function _hexArrayToIntArray(pColors:Array, pDefaults:Array) : Array {
			pColors = pColors.concat(); // Shallow Copy
			for(var i = 0; i < pDefaults.length; i++) {
				pColors[i] = pColors[i] ? _hexToInt(pColors[i]) : pDefaults[i];
			}
			return pColors;
		}
		private function _hexToInt(pVal:String) : int {
			return parseInt(pVal, 16);
		}
		private function _splitOnUrlColorSeperator(pVal:String) : Array {
			// Used to be , but changed to ; (for atelier801 forum support)
			return pVal.indexOf(";") > -1 ? pVal.split(";") : pVal.split(",");
		}

		public function getParams() : String {
			var tParms = new URLVariables();

			_addParamToVariables(tParms, "s", ITEM.SKIN);
			_addParamToVariables(tParms, "d", ITEM.HAIR);
			_addParamToVariables(tParms, "h", ITEM.HAT);
			_addParamToVariables(tParms, "e", ITEM.EARS);
			_addParamToVariables(tParms, "y", ITEM.EYES);
			_addParamToVariables(tParms, "m", ITEM.MOUTH);
			_addParamToVariables(tParms, "n", ITEM.NECK);
			_addParamToVariables(tParms, "t", ITEM.TAIL);
			_addParamToVariables(tParms, "c", ITEM.CONTACTS);
			_addParamToVariables(tParms, "hd", ITEM.HAND);
			_addParamToVariables(tParms, "p", ITEM.POSE);
			
			if(getItemData(ITEM.OBJECT)) { tParms.paw = "y"; }
			if(getItemData(ITEM.BACK)) { tParms.back = "y"; }
			if(getItemData(ITEM.PAW_BACK)) { tParms.pawb = "y"; }
			
			if(GameAssets.shamanMode != SHAMAN_MODE.OFF) {
				tParms["sh"] = GameAssets.shamanMode+";"+_intToHex(GameAssets.shamanColor);
			}

			return tParms.toString().replace(/%3B/g, ";");
		}
		public function getParamsTfmOfficialSyntax() : String {
			var tSkinData = getItemData(ITEM.SKIN);
			var skinId = tSkinData.id;
			if(tSkinData.type == ITEM.SKIN_COLOR) {
				skinId = 1;
			}
			var code:String = skinId+";";
			
			// Apply various parts
			var tTypes = [ITEM.HAT, ITEM.EYES, ITEM.EARS, ITEM.MOUTH, ITEM.NECK, ITEM.HAIR, ITEM.TAIL, ITEM.CONTACTS, ITEM.HAND];
			var tIds = [];
			for(var i:int = 0; i < tTypes.length; i++) {
				var tData:ItemData = getItemData(tTypes[i]);
				if(tData) {
					var tColors = getColors(tTypes[i]);
					if(String(tColors) != String(tData.defaultColors)) { // Quick way to compare two arrays with primitive types
						tIds.push(tData.id+"_"+_intArrayToHexArray(tColors).join("+") );
					} else {
						tIds.push(tData.id);
					}
				} else {
					tIds.push(0);
				}
			}
			code += tIds.join(",");
			
			// Add fur color to end, if there is one
			if(tSkinData.defaultColors && skinId == 1 && tSkinData.colors[0] != 0x78583A) {
				code += ";"+_intArrayToHexArray(tSkinData.colors)[0];
			}
			return code;
		}
		private function _addParamToVariables(pParams:URLVariables, pParam:String, pType:String) {
			var tData:ItemData = getItemData(pType);
			if(tData) {
				pParams[pParam] = tData.id;
				var tColors = getColors(pType);
				if(String(tColors) != String(tData.defaultColors)) { // Quick way to compare two arrays with primitive types
					pParams[pParam] += ";"+_intArrayToHexArray(tColors).join(";");
				}
			}
			/*else { pParams[pParam] = ''; }*/
		}
		private function _intArrayToHexArray(pColors:Array) : Array {
			pColors = pColors.concat(); // Shallow Copy
			for(var i = 0; i < pColors.length; i++) {
				pColors[i] = _intToHex(pColors[i]);
			}
			return pColors;
		}
		private function _intToHex(pVal:int) : String {
			return pVal.toString(16).toUpperCase();
		}

		/****************************
		* Color
		*****************************/
		public function getColors(pType:String) : Array {
			return _itemDataMap[pType].colors;
		}

		public function colorItem(pType:String, arg2:int, pColor:String) : void {
			_itemDataMap[pType].colors[arg2] = GameAssets.convertColorToNumber(pColor);
			updatePose();
		}

		/****************************
		* Update Data
		*****************************/
		public function getItemData(pType:String) : ItemData {
			return _itemDataMap[pType];
		}

		public function setItemData(pItem:ItemData) : void {
			var tType = pItem.type == ITEM.SKIN_COLOR ? ITEM.SKIN : pItem.type;
			_itemDataMap[tType] = pItem;
			updatePose();
		}

		public function removeItem(pType:String) : void {
			_itemDataMap[pType] = null;
			updatePose();
		}
	}
}
