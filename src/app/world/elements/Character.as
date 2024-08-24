package app.world.elements
{
	import com.piterwilson.utils.*;
	import app.data.*;
	import app.world.data.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.utils.Dictionary;
	import com.fewfre.utils.Fewf;
	import com.fewfre.utils.FewfUtils;

	public class Character extends Sprite
	{
		// Constants
		public static const POSE_UPDATED : String = "pose_updated";
		
		// Storage
		public var outfit:Pose;
		// public var animatePose:Boolean;
		public var isOutfit:Boolean;
		
		public var _shamanMode:ShamanMode = ShamanMode.OFF;
		public var _shamanColor:int = 0x95D9D6;
		public var _disableSkillsMode:Boolean = false;
		public function get shamanMode():ShamanMode { return _shamanMode; }
		public function set shamanMode(val:ShamanMode) { _shamanMode = val; updatePose(); }
		public function get shamanColor():int { return _shamanColor; }
		public function set shamanColor(val:int) { _shamanColor = val; updatePose(); }
		public function get disableSkillsMode():Boolean { return _disableSkillsMode; }
		public function set disableSkillsMode(val:Boolean) { _disableSkillsMode = val; updatePose(); }
		
		public var _flagWavingCode:String = "";
		public function get flagWavingCode():String { return _flagWavingCode; }
		public function set flagWavingCode(val:String) { _flagWavingCode = val; updatePose(); }
		
		private var _dragging:Boolean = false;
		private var _dragBounds:Rectangle;

		private var _itemDataMap:Dictionary;

		// Properties
		public function set scale(pVal:Number) : void { outfit.scaleX = outfit.scaleY = pVal; }

		// Constructor
		public function Character(pWornItems:Vector.<ItemData>=null, pParams:String=null, pIsOutfit:Boolean=false) {
			super();
			// animatePose = false;
			isOutfit = pIsOutfit;

			this.buttonMode = true;
			this.addEventListener(MouseEvent.MOUSE_DOWN, function (e:MouseEvent) {
				_dragging = true;
				var bounds:Rectangle = _dragBounds.clone();
				bounds.x -= e.localX * scaleX;
				bounds.y -= e.localY * scaleY;
				startDrag(false, bounds);
			});
			Fewf.stage.addEventListener(MouseEvent.MOUSE_UP, function () { if(_dragging) { _dragging = false; stopDrag(); } });

			// Store Data
			_itemDataMap = new Dictionary();
			for each(var item:ItemData in pWornItems) {
				_itemDataMap[item.type] = item;
			}
			
			if(pParams) parseParams(pParams);

			updatePose();
		}
		public function move(pX:Number, pY:Number) : Character { x = pX; y = pY; return this; }
		public function appendTo(pParent:Sprite): Character { pParent.addChild(this); return this; }
		
		public function copy() : Character { return new Character(null, getParams(), true); }

		public function updatePose() {
			var tScale = 3, tOldPose:Pose = outfit;
			if(outfit != null) { tScale = outfit.scaleX; removeChild(outfit); }
			outfit = new Pose(getItemData(ItemType.POSE)).appendTo(this);
			outfit.scaleX = outfit.scaleY = tScale;
			// Don't let the pose eat mouse input
			outfit.mouseChildren = false;
			outfit.mouseEnabled = false;

			outfit.apply(new <ItemData>[
					getItemData(ItemType.SKIN),
					getItemData(ItemType.HEAD),
					getItemData(ItemType.HAIR),
					getItemData(ItemType.EARS),
					getItemData(ItemType.EYES),
					getItemData(ItemType.MOUTH),
					getItemData(ItemType.NECK),
					getItemData(ItemType.TAIL),
					getItemData(ItemType.CONTACTS),
					getItemData(ItemType.HAND),
					getItemData(ItemType.TATTOO),

					getItemData(ItemType.OBJECT),
					getItemData(ItemType.BACK),
					getItemData(ItemType.PAW_BACK)
				],
				_shamanMode,
				_shamanColor,
				_disableSkillsMode,
				_flagWavingCode
			);
			// if(animatePose) outfit.play(); else outfit.stopAtLastFrame();
			outfit.stopAtLastFrame();
			outfit.goToPreviousFrameIfPoseHasntChanged(tOldPose);
			dispatchEvent(new Event(POSE_UPDATED));
			
			var emojiData:ItemData = getItemData(ItemType.EMOJI);
			if(emojiData) {
				var emoji = outfit.addChild((emojiData as BitmapItemData).getBitmap());
				emoji.x = -35/2;
				emoji.y = -45 - 35/2;
			}
		}
		
		public function setDragBounds(pX:Number, pY:Number, pWidth:Number, pHeight:Number): Character {
			_dragBounds = new Rectangle(pX, pY, pWidth, pHeight); return this;
		}
		public function clampCoordsToDragBounds() : void {
			this.x = Math.max(_dragBounds.x, Math.min(_dragBounds.right, this.x));
			this.y = Math.max(_dragBounds.y, Math.min(_dragBounds.bottom, this.y));
		}

		/////////////////////////////
		// Item Data
		/////////////////////////////
		public function getItemData(pType:ItemType) : ItemData {
			return _itemDataMap[pType];
		}

		public function setItemData(pItem:ItemData) : void {
			_itemDataMap[pItem.type] = pItem;
			updatePose();
		}

		public function removeItem(pType:ItemType) : void {
			_itemDataMap[pType] = null;
			updatePose();
		}

		/////////////////////////////
		// Share Code
		/////////////////////////////
		public function parseParams(pCode:String) : Boolean {
			if(!isOutfit) trace("(parseParams) ", pCode);
			
			// Url param code
			if(pCode.indexOf("=") > -1) {
				return _parseParamsFewfreSyntax(pCode);
			}
			else { // Official TFM /dressing params
				return _parseParamsTfmOfficialSyntax(pCode);
			}
			return true;
		}
		
		private function _parseParamsFewfreSyntax(pCode:String) : Boolean {
			try {
				var pParams = new flash.net.URLVariables();
				pParams.decode(pCode);
				
				_setParamToType(pParams, ItemType.SKIN, "s", false);
				_setParamToType(pParams, ItemType.HAIR, "d");
				_setParamToType(pParams, ItemType.HEAD, "h");
				_setParamToType(pParams, ItemType.EARS, "e");
				_setParamToType(pParams, ItemType.EYES, "y");
				_setParamToType(pParams, ItemType.MOUTH, "m");
				_setParamToType(pParams, ItemType.NECK, "n");
				_setParamToType(pParams, ItemType.TAIL, "t");
				_setParamToType(pParams, ItemType.CONTACTS, "c");
				_setParamToType(pParams, ItemType.HAND, "hd");
				_setParamToType(pParams, ItemType.TATTOO, "tt");
				_setParamToType(pParams, ItemType.EMOJI, "em");
				_setParamToType(pParams, ItemType.POSE, "p", false);
				
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
			}
			catch (error:Error) { return false; };
			return true;
		}
		private function _setParamToType(pParams:URLVariables, pType:ItemType, pParam:String, pAllowNull:Boolean=true) {
			// try {
				var tData:ItemData = null, tID = pParams[pParam], tColors;
				if(tID != null && tID != "") {
					tColors = _splitOnUrlColorSeperator(tID); // Get a list of all the colors (ID is first); ex: 5;ffffff;abcdef;169742
					tID = tColors.splice(0, 1)[0]; // Remove first item and store it as the ID.
					tData = GameAssets.getItemFromTypeID(pType, tID); if(isOutfit) tData = tData.copy();
					if(tColors.length > 0) { tData.colors = _hexArrayToIntList(tColors, tData.defaultColors); }
					else if(tData.isCustomizable) { tData.setColorsToDefault(); }
				}
				_itemDataMap[pType] = pAllowNull ? tData : ( tData == null ? _itemDataMap[pType] : tData );
			// } catch (error:Error) { };
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
			} catch(error:Error) { return false; };
			return true;
		}
		private function _setParamToTypeTfmOfficialSyntax(pType:ItemType, pParamVal:String, pAllowNull:Boolean=true) {
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
					tData = GameAssets.getItemFromTypeID(pType, tID); if(isOutfit) tData = tData.copy();
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

		public function getParams() : String {
			var tParms = new URLVariables();

			_addParamToVariables(tParms, "s", ItemType.SKIN);
			_addParamToVariables(tParms, "d", ItemType.HAIR);
			_addParamToVariables(tParms, "h", ItemType.HEAD);
			_addParamToVariables(tParms, "e", ItemType.EARS);
			_addParamToVariables(tParms, "y", ItemType.EYES);
			_addParamToVariables(tParms, "m", ItemType.MOUTH);
			_addParamToVariables(tParms, "n", ItemType.NECK);
			_addParamToVariables(tParms, "t", ItemType.TAIL);
			_addParamToVariables(tParms, "c", ItemType.CONTACTS);
			_addParamToVariables(tParms, "hd", ItemType.HAND);
			_addParamToVariables(tParms, "tt", ItemType.TATTOO);
			_addParamToVariables(tParms, "em", ItemType.EMOJI);
			_addParamToVariables(tParms, "p", ItemType.POSE);
			
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
		public function getParamsTfmOfficialSyntax() : String {
			var tSkinData:SkinData = getItemData(ItemType.SKIN) as SkinData;
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
		private function _addParamToVariables(pParams:URLVariables, pParam:String, pType:ItemType) {
			var tData:ItemData = getItemData(pType);
			if(tData) {
				pParams[pParam] = tData.id;
				var tColors:Vector.<uint> = tData.colors;
				if(String(tColors) != String(tData.defaultColors)) { // Quick way to compare two arrays with primitive types
					pParams[pParam] += ";"+_intListToHexList(tColors).join(";");
				}
			}
			/*else { pParams[pParam] = ''; }*/
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
