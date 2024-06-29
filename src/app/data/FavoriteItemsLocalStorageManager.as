package app.data
{
	import flash.utils.Dictionary;
	import flash.net.URLVariables;
	import com.fewfre.utils.Fewf;

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
		
		public static function hasId(pType:ItemType, pId:String) : Boolean {
			return getFavoritesIdList(pType).some(function(id:String,i,a){ return id == pId; })
		}
		
		public static function addFavoriteId(pType:ItemType, pId:String) : void {
			// Remove id if it already exists so we can re-add it (now to end of the list), to avoid duplicates
			var list:Array = getFavoritesIdList(pType).filter(function(id:String,i,a){ return id != pId; });
			list.push(pId);
			saveFavoritesIdList(pType, list);
		}
		
		public static function removeFavoriteId(pType:ItemType, pId:String) : void {
			saveFavoritesIdList(pType, getFavoritesIdList(pType).filter(function(id:String,i,a){ return id != pId; }));
		}
		
		////////////////////////////
		// Private
		////////////////////////////
		private static function _getKey(pType:ItemType) : String {
			return ConstantsApp.SHARED_OBJECT_KEY_TYPE_FAVORITES_PREFIX+pType.toString();
		}
	}
}
