package app.zFilterSelectionMode.data
{
	public class SortType_FilterSelectionMode
	{
		public static const ID				: SortType_FilterSelectionMode = new SortType_FilterSelectionMode(1);
		public static const OWNED			: SortType_FilterSelectionMode = new SortType_FilterSelectionMode(2);
		public static const CUSTOMIZABLE	: SortType_FilterSelectionMode = new SortType_FilterSelectionMode(3);
		
		// Enum Storage + Constructor
		private var _value: int;
		function SortType_FilterSelectionMode(pValue:int) { _value = pValue; }
		
		public function toInt() : int { return _value; }
		
		// This is required for proper auto string conversion on `trace`/`Dictionary` and such - enums should always have
		public function toString() : String { return _value.toString(); }
	}
}