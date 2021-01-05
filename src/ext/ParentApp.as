package ext
{
	import flash.display.MovieClip;

	// Anything here is overwritten by parent swf when externally loaded
	public class ParentApp
	{
		public static function newFancySlider(props:Object) {
			return new MovieClip();
		}
	}
}
