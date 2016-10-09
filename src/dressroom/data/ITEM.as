package dressroom.data
{
	public class ITEM
	{
		public static const POSE				: String = "pose";
		public static const SKIN				: String = "fur";
		public static const SKIN_COLOR			: String = "fur-color";
		public static const HAT					: String = "head";
		public static const HAIR				: String = "hair";
		public static const EYES				: String = "eyes";
		public static const EARS				: String = "ears";
		public static const MOUTH				: String = "mouth";
		public static const NECK				: String = "neck";
		public static const TAIL				: String = "tail";
		// Specials
		public static const PAW					: String = "paw";
		public static const BACK				: String = "back";
		public static const PAW_BACK			: String = "back-paw";
		
		// Order of item layering when occupying the same spot.
		public static const LAYERING			: Array = [ SKIN, SKIN_COLOR, HAIR, HAT, EYES, EARS, MOUTH, NECK, TAIL, PAW, BACK, PAW_BACK ];
	}
}