package ext
{
	import flash.display.MovieClip;

	// Anything here is overwritten by parent swf when externally loaded
	public class ParentApp
	{
		public static var sharedData : Object = {};
		
		public static function reopenSelectionLauncher() : Function {
			return null;
		}
	}
}
