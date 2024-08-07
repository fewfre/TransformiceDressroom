package app.data
{
	import flash.utils.Dictionary;
	import flash.net.URLVariables;
	import com.fewfre.utils.Fewf;
	import app.world.data.ItemData;
	import flash.events.Event;
	import com.fewfre.events.FewfEvent;

	public final class FavoriteItemsLocalStorageManager
	{
		////////////////////////////
		// Public
		////////////////////////////
		public static function getFavoritesIdList(pType:ItemType) : Array {
			return Fewf.sharedObject.getData(_getKey(pType)) || [];
		}
		public static function saveFavoritesIdList(pType:ItemType, list:Array) : void {
			Fewf.sharedObject.setData(_getKey(pType), list);
		}
		
		public static function has(pItemData:ItemData) : Boolean { return !!pItemData && hasId(pItemData.type, pItemData.id); }
		public static function hasId(pType:ItemType, pId:String) : Boolean {
			return getFavoritesIdList(pType).some(function(id:String,i,a){ return id == pId; })
		}
		
		public static function addFavorite(pItemData:ItemData) : void { addFavoriteId(pItemData.type, pItemData.id); }
		public static function addFavoriteId(pType:ItemType, pId:String) : void {
			// Remove id if it already exists so we can re-add it (now to end of the list), to avoid duplicates
			var list:Array = getFavoritesIdList(pType).filter(function(id:String,i,a){ return id != pId; });
			list.push(pId);
			saveFavoritesIdList(pType, list);
			Fewf.dispatcher.dispatchEvent(new FewfEvent(ConstantsApp.FAVORITE_ADDED_OR_REMOVED, { itemType:pType }));
		}
		
		public static function removeFavorite(pItemData:ItemData) : void { removeFavoriteId(pItemData.type, pItemData.id); }
		public static function removeFavoriteId(pType:ItemType, pId:String) : void {
			saveFavoritesIdList(pType, getFavoritesIdList(pType).filter(function(id:String,i,a){ return id != pId; }));
			Fewf.dispatcher.dispatchEvent(new FewfEvent(ConstantsApp.FAVORITE_ADDED_OR_REMOVED, { itemType:pType }));
		}
		
		public static function getAllFavorites() : Vector.<ItemData> {
			var list:Vector.<ItemData> = new Vector.<ItemData>();
			for each(var itemType:ItemType in ItemType.TYPES_WITH_SHOP_PANES) {
				var ids:Array = getFavoritesIdList(itemType);
				for each(var id:String in ids) {
					list.push(GameAssets.getItemFromTypeID(itemType, id));
				}
			}
			return list;
		}
		
		public static function deleteAll() : void {
			for each(var itemType:ItemType in ItemType.TYPES_WITH_SHOP_PANES) {
				saveFavoritesIdList(itemType, []);
				Fewf.dispatcher.dispatchEvent(new FewfEvent(ConstantsApp.FAVORITE_ADDED_OR_REMOVED, { itemType:itemType }));
			}
		}
		
		////////////////////////////
		// Private
		////////////////////////////
		private static function _getKey(pType:ItemType) : String {
			return ConstantsApp.SHARED_OBJECT_KEY_TYPE_FAVORITES_PREFIX+pType.toString();
		}
	}
}
