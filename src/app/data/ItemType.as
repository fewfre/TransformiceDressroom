package app.data
{
	public final class ItemType
	{
		public static const POSE				: ItemType = new ItemType("pose");
		public static const SKIN				: ItemType = new ItemType("fur");
		public static const SKIN_COLOR			: ItemType = new ItemType("fur-color");
		public static const HEAD				: ItemType = new ItemType("head");
		public static const HAIR				: ItemType = new ItemType("hair");
		public static const EYES				: ItemType = new ItemType("eyes");
		public static const EARS				: ItemType = new ItemType("ears");
		public static const MOUTH				: ItemType = new ItemType("mouth");
		public static const NECK				: ItemType = new ItemType("neck");
		public static const TAIL				: ItemType = new ItemType("tail");
		public static const CONTACTS			: ItemType = new ItemType("contacts");
		public static const HAND				: ItemType = new ItemType("hands");
		// Specials
		public static const OBJECT				: ItemType = new ItemType("object");
		public static const BACK				: ItemType = new ItemType("back");
		public static const PAW_BACK			: ItemType = new ItemType("back-paw");
		
		// Order of item layering when occupying the same spot.
		public static const LAYERING : Vector.<ItemType> = new <ItemType>[
			SKIN, SKIN_COLOR, NECK, HAIR, HEAD, EARS, MOUTH, CONTACTS, EYES, TAIL, HAND, OBJECT, BACK, PAW_BACK
		];
		
		// Enum Storage + Constructor
		private var _value: String;
		function ItemType(pValue:String) { _value = pValue; }
		
		// This is required for proper auto string convertion on `trace`/`Dictionary` and such - enums should always have
		public function toString() : String { return _value.toString(); }
	}
}
