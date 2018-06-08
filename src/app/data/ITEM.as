package app.data
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
		public static const CONTACTS			: String = "contacts";
		public static const HAND				: String = "hand";
		// Specials
		public static const OBJECT				: String = "object";
		public static const BACK				: String = "back";
		public static const PAW_BACK			: String = "back-paw";
		
		// Order of item layering when occupying the same spot.
		public static const LAYERING			: Array = [ SKIN, SKIN_COLOR, NECK, HAIR, HAT, EARS, MOUTH, CONTACTS, EYES, TAIL, HAND, OBJECT, BACK, PAW_BACK ];
	}
}
