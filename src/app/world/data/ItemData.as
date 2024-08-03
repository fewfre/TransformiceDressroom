package app.world.data
{
	import app.data.*;
	import flash.display.*;
	import flash.geom.*;

	public class ItemData
	{
		public var type			: ItemType;
		public var id			: String;
		public var itemClass	: Class;
		public var classMap		: Object;

		public var defaultColors: Vector.<uint>;
		public var colors		: Vector.<uint>;

		// pData = { itemClass:Class, ?classMap:Object<Class> }
		public function ItemData(pType:ItemType, pId:String, pData:Object) {
			super();
			type = pType;
			id = pId;
			itemClass = pData.itemClass;
			classMap = pData.classMap;
			_initDefaultColors();
		}
		public function copy() : ItemData { return new ItemData(type, id, { itemClass:itemClass, classMap:classMap }); }
		
		protected function _initDefaultColors() : void {
			defaultColors = GameAssets.findDefaultColors(new itemClass());
			setColorsToDefault();
		}
		public function setColorsToDefault() : void {
			colors = defaultColors.concat();
		}
		public function hasModifiedColors() : Boolean {
			return (colors ? colors.join() : "") != (defaultColors ? defaultColors.join() : "");
		}
		
		public function matches(compare:ItemData) : Boolean {
			return !!compare && type == compare.type && id == compare.id;
		}
		
		public function uniqId() : String {
			return this.type + '--' + this.id;
		}
		
		public function isSkin() : Boolean { return type == ItemType.SKIN; }
		public function isBitmap() : Boolean { return false; }

		public function getPart(pID:String, pOptions:Object=null) : Class {
			return !classMap ? null : (classMap[pID] ? classMap[pID] : null);
		}
	}
}
