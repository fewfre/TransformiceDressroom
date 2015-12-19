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
			
			// Multi-color fur
			//this.furs.push( new FurData( -1, ItemType.COLOR ).initColor(0xFF0000) );
			
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

		public function copyColor(copyFromMC:MovieClip, copyToMC:MovieClip) : MovieClip {
			if (copyFromMC == null || copyToMC == null) { return; }
			var tChild1:*=null;
			var tChild2:*=null;
			var i:int = 0;
			while (i < copyFromMC.numChildren) 
			{
				tChild1 = copyFromMC.getChildAt(i);
				tChild2 = copyToMC.getChildAt(i);
				if (tChild1.name.indexOf("Couleur") == 0 && tChild1.name.length > 7) 
				{
					tChild2.transform.colorTransform = tChild1.transform.colorTransform;
				}
				++i;
			}
			return copyToMC;
		}

		public function colorDefault(pMC:MovieClip) : MovieClip {
			var tChild:*=null;
			var tChildName:*=null;
			var tHex:int=0;
			var tR:*=0;
			var tG:*=0;
			var tB:*=0;
			if (pMC == null) 
			{
				return;
			}
			var loc1:*=0;
			while (loc1 < pMC.numChildren) 
			{
				tChild = pMC.getChildAt(loc1);
				if (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7) 
				{
					tChildName = tChild.name;
					tHex = int("0x" + tChildName.substr(tChildName.indexOf("_") + 1, 6));
					tR = tHex >> 16 & 255;
					tG = tHex >> 8 & 255;
					tB = tHex & 255;
					tChild.transform.colorTransform = new flash.geom.ColorTransform(tR / 128, tG / 128, tB / 128);;
				}
				++loc1;
			}
			return pMC;
		}
		
		public function getNumOfCustomColors(pMC:MovieClip) : int {
			var tChild:*=null;
			var num:int = 0;
			var i:int = 0;
			while (i < pMC.numChildren) 
			{
				tChild = pMC.getChildAt(i);
				if (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7) 
				{
					num++;
				}
				++i;
			}
			return num;
		}
	}
}