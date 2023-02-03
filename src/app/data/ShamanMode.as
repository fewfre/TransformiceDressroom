package app.data
{
	public final class ShamanMode
	{
		public static const OFF				: ShamanMode = new ShamanMode(1);
		public static const NORMAL			: ShamanMode = new ShamanMode(2);
		public static const HARD			: ShamanMode = new ShamanMode(3);
		public static const DIVINE			: ShamanMode = new ShamanMode(4);
		
		// Enum Storage + Constructor
		private var _value: int;
		function ShamanMode(pValue:int) { _value = pValue; }
		
		public function toInt() : int { return _value; }
		public static function fromInt(pValue:int) : ShamanMode {
			switch(pValue) {
				case OFF.toInt(): return OFF;
				case NORMAL.toInt(): return NORMAL;
				case HARD.toInt(): return HARD;
				case DIVINE.toInt(): return DIVINE;
			}
			return OFF;
		}
		
		// This is required for proper auto string convertion on `trace`/`Dictionary` and such - enums should always have
		public function toString() : String { return _value.toString(); }
	}
}
