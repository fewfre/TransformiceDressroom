package ext
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	// Anything here is overwritten by parent AIR swf when externally loaded
	public class ParentAppSystem
	{
		public static function getCameraRollClass() : Class {
			return null;
		}
		
		public static function getFileClass() : Class {
			return null;
		}
		
		public static function getFileStreamClass() : Class {
			return null;
		}
		
		public static function getPermissionStatusClass() : Class {
			return null;
		}
	}
}