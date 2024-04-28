package app.data
{
	import flash.utils.Dictionary;
	import flash.net.URLVariables;

	public final class ShareCodeFilteringData
	{
		public static const PREFIX:String = "ITEMFILTER?";
		public static const CUSTOMIZE_SYMBOL:String = "¤";
		
		private static var _itemFilterMap:Dictionary;
		private static var _itemCustomizableMap:Dictionary;
		
		public static function init() : void {
			reset();
		}
		
		public static function reset() : void {
			_itemFilterMap = new Dictionary();
			_itemCustomizableMap = new Dictionary();
			for each(var itemType:ItemType in ItemType.TYPES_WITH_SHARE_FILTER_PANES) {
				if(itemType == ItemType.POSE) continue;
				_itemFilterMap[itemType] = new Vector.<String>();
				_itemCustomizableMap[itemType] = new Dictionary();
			}
		}
		
		////////////////////////////
		// ID Methods
		////////////////////////////
		public static function getSelectedIds(itemType:ItemType) : Vector.<String> {
			return _itemFilterMap[itemType];
		}
		
		public static function hasId(itemType:ItemType, id:String) : Boolean {
			return getSelectedIds(itemType).indexOf(id) > -1;
		}
		
		public static function addId(itemType:ItemType, id:String) : void {
			getSelectedIds(itemType).push(id);
		}
		
		public static function removeId(itemType:ItemType, id:String) : void {
			var vector : Vector.<String> = getSelectedIds(itemType);
			var i:Number = vector.indexOf(id);
			if(i > -1) {
				vector.splice(i, 1);
			}
		}
		
		////////////////////////////
		// Customizable Methods
		////////////////////////////
		public static function getCustomizableIdMap(itemType:ItemType) : Dictionary {
			return _itemCustomizableMap[itemType];
		}
		
		public static function isCustomizable(itemType:ItemType, id:String) : Boolean {
			return !!_itemCustomizableMap[itemType][id];
		}
		
		public static function setCustomizable(itemType:ItemType, id:String, flag:Boolean) : void {
			_itemCustomizableMap[itemType][id] = flag;
		}
		
		////////////////////////////
		// Share Code Methods
		////////////////////////////
		public static function parseShareCode(code:String) : void {
			reset();
			code = code.replace(PREFIX, "");
			
			var pParams : URLVariables = new URLVariables();
			pParams.decode(code);
			for each(var type:ItemType in ItemType.TYPES_WITH_SHARE_FILTER_PANES) {
				var paramVal:String = pParams[ type.toString() ];
				if(paramVal != null) {
					var paramIds : Array = paramVal == '' ? [] : paramVal.split(',');
					for each(var val:String in paramIds) {
						var id : String = val, customizable:Boolean = false;
						if(id.indexOf(CUSTOMIZE_SYMBOL) > -1) {
							id = id.replace(CUSTOMIZE_SYMBOL, '');
							customizable = true;
						}
						addId(type, id);
						setCustomizable(type, id, customizable);
					}
				}
			}
		}
		
		private static function _sortIds(a:String, b:String) : Number {
			return !isNaN(Number(a)) && !isNaN(Number(b))
				? parseInt(a) < parseInt(b) ? -1 : 1
				: a < b ? -1 : 1;
		}
		public static function generateShareCode() : String {
			var pParams : Array = new Array();
			for each(var tType:ItemType in ItemType.TYPES_WITH_SHARE_FILTER_PANES) {
				var ids : Vector.<String> = getSelectedIds(tType).sort(_sortIds);
				if(!!ids && ids.length > 0) {
					pParams.push(tType.toString()+"="+ids.map(function(id){ return id+(isCustomizable(tType, id) ? CUSTOMIZE_SYMBOL : '') }).join(','));
				}
			}
			return pParams.length > 0 ? PREFIX + pParams.join('&') : '';
		}
	}
}
