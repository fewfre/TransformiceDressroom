package app.world.data
{
	import app.data.*;
	import flash.display.*;
	import flash.geom.*;
	import com.fewfre.utils.Fewf;
	import flash.events.Event;
	import com.fewfre.utils.FewfDisplayUtils;
	import app.ui.screens.LoadingSpinner;

	public class BitmapItemData extends ItemData
	{
		// Storage
		public var url : String;
		
		// Properties
		public override function get isCustomizable() : Boolean { return false; }
		
		// Constructor
		public function BitmapItemData(pType:ItemType, pUrl:String) {
			var id:String = pUrl.split('/').pop();
			id = id.replace('x_', '').replace('L', '').replace('.png', '');
			super(pType, id, {});
			this.url = pUrl;
		}
		public override function copy() : ItemData { return new BitmapItemData(type, url); }
		
		protected override function _initDefaultColors() : void {} // Bitmaps don't use customizable colors

		public override function getPart(pID:String, pOptions:Object=null) : Class {
			return null;
		}
		
		public function getBitmap() : Bitmap {
			return Fewf.assets.lazyLoadImageUrlAsBitmap(this.url);
		}
	}
}
