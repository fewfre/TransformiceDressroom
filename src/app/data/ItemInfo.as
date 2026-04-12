package app.data
{
	import com.fewfre.utils.Fewf;
	import flash.utils.Dictionary;
	import app.world.data.ItemData;

	public class ItemInfo
	{
		public static var _infoMap:Dictionary = new Dictionary(); // Dictionary<ItemID:string, ItemInfoProps>
		
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
			}
			if(jsonFile.head) {
				for(var headID in jsonFile.head) {
					_infoMap[_getKey(ItemType.HEAD, headID)] = new ItemInfoProps(jsonFile.head[headID]);
				}
			}
			if(jsonFile.ears) {
				for(var earsID in jsonFile.ears) {
					_infoMap[_getKey(ItemType.EARS, earsID)] = new ItemInfoProps(jsonFile.ears[earsID]);
				}
			}
		}
		
		private static function _getKey(pItemType:ItemType, pId:String) : String { return pItemType + "-" + pId; }
	}
}

class ItemInfoProps {
	private var _isCheeseOnly:Boolean;
	public function get isCheeseOnly():Boolean { return _isCheeseOnly; }
	
	private var _isEventReward:Boolean;
	public function get isEventReward():Boolean { return _isEventReward; }
	
	public function ItemInfoProps(data:*) {
		this._isCheeseOnly = !!data.isCheeseOnly;
		this._isEventReward = !!data.isEventReward;
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