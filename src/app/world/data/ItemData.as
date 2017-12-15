package app.world.data
{
	import app.data.*;
	import flash.display.*;
	import flash.geom.*;

	public class ItemData
	{
		public var id			: String;
		public var type			: String;
		public var gender		: String;
		public var itemClass	: Class;
		public var classMap		: Object;

		public var defaultColors: Array;
		public var colors		: Array;

		// pData = { id:String, type:String, itemClass:Class, ?gender:String, ?classMap:Object<Class> }
		public function ItemData(pData:Object) {
			super();
			id = pData.id;
			type = pData.type;
			gender = pData.gender;
			itemClass = pData.itemClass;
			classMap = pData.classMap;
			_initDefaultColors();
		}
		protected function _initDefaultColors() : void {
			defaultColors = GameAssets.getColors(GameAssets.colorDefault(new itemClass()));
			setColorsToDefault();
		}
		public function setColorsToDefault() : void {
			colors = defaultColors.concat();
		}
		
		public function isSkin() : Boolean { return type == ITEM.SKIN || type == ITEM.SKIN_COLOR; }

		public function getPart(pID:String, pOptions:Object=null) : Class {
			return !classMap ? null : (classMap[pID] ? classMap[pID] : null);
		}
	}
}
