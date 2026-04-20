package app.data
{
	import com.fewfre.utils.Fewf;
	import flash.utils.Dictionary;
	import app.world.data.ItemData;

	public class ItemInfo
	{
		// Storage
		private static var _infoMap:Dictionary = new Dictionary(); // Dictionary<ItemID:string, ItemInfoProps>
		private static var _supportedItemTypes:Vector.<ItemType> = new Vector.<ItemType>();
		
		public static var showPurchaseTypeInUi:Boolean = false;
		
		// Properties
		public static function get supportedItemTypes() : Vector.<ItemType> { return _supportedItemTypes; }
		
		// Public
		public static function getById(pItemType:ItemType, pId:String) : ItemInfoProps { return _infoMap[_getKey(pItemType, pId)]; }
		public static function get(pData:ItemData) : ItemInfoProps { return getById(pData.type, pData.id); }
		// Same as get() but casts the type to SkinInfoProps for convenience (since currently skins have some custom info)
		public static function getSkin(pSkinID:String) : SkinInfoProps { return getById(ItemType.SKIN, pSkinID) as SkinInfoProps; }

		public static function init() : void {
			var jsonFile = Fewf.assets.getData("item-info");
			if(!jsonFile) { return; }
			
			if(jsonFile.skin) {
				for(var skinID in jsonFile.skin) {
					_infoMap[_getKey(ItemType.SKIN, skinID)] = new SkinInfoProps(jsonFile.skin[skinID]);
				}
				_supportedItemTypes.push(ItemType.SKIN);
			}
			for each(var itemType:ItemType in ItemType.ALL) {
				var infoMapForType = jsonFile[itemType.toString()], typeSupported:Boolean = false;
				if(itemType == ItemType.SKIN || !infoMapForType) { continue; } // skin already handled above since skins have extra info
				for(var itemID in infoMapForType) {
					_infoMap[_getKey(itemType, itemID)] = new ItemInfoProps(infoMapForType[itemID]);
					typeSupported = true;
				}
				if(typeSupported) _supportedItemTypes.push(itemType);
			}
		}
		
		private static function _getKey(pItemType:ItemType, pId:String) : String { return pItemType + "-" + pId; }
	}
}

class ItemInfoProps {
	// Purchase related flags
	private var _isAlwaysInShop:Boolean;
	public function get isAlwaysInShop():Boolean { return _isAlwaysInShop; }
	private var _isCheeseOnly:Boolean;
	public function get isCheeseOnly():Boolean { return _isCheeseOnly; }
	private var _isCollector:Boolean;
	public function get isCollector():Boolean { return _isCollector; }
	private var _isEventReward:Boolean;
	public function get isEventReward():Boolean { return _isEventReward; }
	private var _isStarCoin:Boolean;
	public function get isStarCoin():Boolean { return _isStarCoin; }
	private var _isFreeish:Boolean;
	public function get isFreeish():Boolean { return _isFreeish; }

	public function ItemInfoProps(data:*) {
		const ptype:String = data.ptype;
		this._isAlwaysInShop = ptype === "alwaysInShop";
		this._isCheeseOnly = ptype === "cheeseOnly";
		this._isCollector = ptype === "collector";
		this._isEventReward = ptype === "eventReward";
		this._isStarCoin = ptype && ptype.indexOf("starcoin") > -1;
		this._isFreeish = ptype === "freeish";
	}
}
class SkinInfoProps extends ItemInfoProps {
	private var _isCostume:*; // can be bool or "both" (for items that are costumes but also have a non-costume version, like skin 7)
	public function get isCostumeOnly():Boolean { return _isCostume === true; }
	public function get isCostumeAndPurchasable():Boolean { return _isCostume === "both"; }
	
	public function SkinInfoProps(data:*) {
		super(data);
		this._isCostume = data.isCostume;
	}
}