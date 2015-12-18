package
{
	import flash.display.*;
	import flash.display.MovieClip;
    import flash.geom.*;
	
	public class Costumes
	{
		private const _MAX_COSTUMES_TO_CHECK_TO:Number = 250;
		
		public var loadedData:Array;
		
		public var head:Array;
		public var eyes:Array;
		public var ears:Array;
		public var mouth:Array;
		public var neck:Array;
		public var hair:Array;
		public var tail:Array;

		public var hand:Class;
		public var fromage:Class;
		public var backHand:Class;
		
		// public var colors:Array;
		public var furs:Array;
		
		public function Costumes(pMCs:Array) {
			super();
			loadedData = pMCs;
		}
		
		public function init() : Costumes {
			this.head = _setupCostumeArray("$Costume_0_", ItemType.HAT);
			this.eyes = _setupCostumeArray("$Costume_1_", ItemType.EYES);
			this.ears = _setupCostumeArray("$Costume_2_", ItemType.EARS);
			this.mouth = _setupCostumeArray("$Costume_3_", ItemType.MOUTH);
			this.neck = _setupCostumeArray("$Costume_4_", ItemType.NECK);
			this.hair = _setupCostumeArray("$Costume_5_", ItemType.HAIR);
			this.tail = _setupCostumeArray("$Costume_6_", ItemType.TAIL);
			
			this.hand = getLoadedClass("$Costume_7_1");
			this.backHand = getLoadedClass("$Costume_8_1");
			this.fromage = getLoadedClass("FromageSouris");
			
			// this.colors = new Array();
			this.furs = new Array();
			
			for(var i = 0; i < 7; i++) {
				this.furs.push( new FurData( i, ItemType.COLOR ).initColor() );
			}
			
			this.furs.push( new FurData( 1, ItemType.FUR ).initColor(FurData.DEFAULT_COLOR) );
			for(var i = 2; i < _MAX_COSTUMES_TO_CHECK_TO; i++) {
				if(getLoadedClass( "_Corps_2_"+i+"_1" ) != null) {
					//this.furs.push( new Fur().initFur( i, _setupFur(i) ) );
					this.furs.push( new FurData( i, ItemType.FUR ).initFur() );
				}
			}
			
			return this;
		}
		
		public function getLoadedClass(pName:String, pTrace:Boolean=false) : Class {
			for(var i = 0; i < loadedData.length; i++) {
				if(loadedData[i].loaderInfo.applicationDomain.hasDefinition(pName)) {
					return loadedData[i].loaderInfo.applicationDomain.getDefinition( pName ) as Class;
				}
			}
			if(pTrace) { trace("ERROR: No Linkage by name: "+pName); }
			return null;
		}
		
		private function _setupCostumeArray(pBase:String, pType:String) : Array {
			var tArray:Array = new Array();
			var tClass:Class;
			for(var i = 1; i <= _MAX_COSTUMES_TO_CHECK_TO; i++) {
				tClass = getLoadedClass( pBase+i );
				if(tClass != null) {
					tArray.push( new ShopItemData(i, pType, tClass) );
				}
			}
			return tArray;
		}

		public function copyColor(arg1:MovieClip, arg2:MovieClip) : MovieClip {
			var loc2:*=undefined;
			var loc3:*=undefined;
			if (arg1 == null || arg2 == null) 
			{
				return;
			}
			var loc1:*=0;
			while (loc1 < arg1.numChildren) 
			{
				loc2 = arg1.getChildAt(loc1);
				loc3 = arg2.getChildAt(loc1);
				if (loc2.name.indexOf("Couleur") == 0 && loc2.name.length > 7) 
				{
					loc3.transform.colorTransform = loc2.transform.colorTransform;
				}
				++loc1;
			}
			return arg2;
		}

		public function colorDefault(arg1:MovieClip) : MovieClip {
			var loc2:*=undefined;
			var loc3:*=null;
			var loc4:*=0;
			var loc5:*=0;
			var loc6:*=0;
			var loc7:*=0;
			var loc8:*=null;
			if (arg1 == null) 
			{
				return;
			}
			var loc1:*=0;
			while (loc1 < arg1.numChildren) 
			{
				loc2 = arg1.getChildAt(loc1);
				if (loc2.name.indexOf("Couleur") == 0 && loc2.name.length > 7) 
				{
					loc3 = loc2.name;
					loc5 = (loc4 = int("0x" + loc3.substr(loc3.indexOf("_") + 1, 6))) >> 16 & 255;
					loc6 = loc4 >> 8 & 255;
					loc7 = loc4 & 255;
					loc8 = new flash.geom.ColorTransform(loc5 / 128, loc6 / 128, loc7 / 128);
					loc2.transform.colorTransform = loc8;
				}
				++loc1;
			}
			return arg1;
		}
	}
}