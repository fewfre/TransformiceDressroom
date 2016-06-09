package 
{
	import flash.display.*;
	import flash.geom.*;
	
	public class FurData extends ShopItemData
	{
		// Storage
		public var color:String;
		
		public var earFar:Class; // _OreilleG_1_
		public var footFar:Class; // _PiedG_1_
		public var legFar:Class; // _CuisseG_1_
		public var armFar:Class; // _PatteG_1_
		public var footClose:Class; // _PiedD_1_
		public var tailOrnament:Class; // _Boule_1_
		public var wings:Class; // _Ailes_1_
		public var body:Class; // _Corps_1_
		public var tail:Class; // _Queue_1_
		public var legClose:Class; // _CuisseD_1_
		public var armClose:Class; // _PatteD_1_
		public var face:Class; // _Tete_1_
		public var eyes:Class; // _Oeil_1_
		public var earClose:Class; // _OreilleD_1_
		
		// Constants
		public static const DEFAULT_COLOR:String = "78583A";
		
		// Constructor
		public function FurData(pID:int, pType:String) {
			super(pID, pType, null);
			
			color = "";
		}
		
		public function initDefaultParts() : FurData {
			earFar = _OreilleG_1_1_1;
			footFar = _PiedG_1_1_1;
			legFar = _CuisseG_1_1_1;
			armFar = _PatteG_1_1_1;
			footClose = _PiedD_1_1_1;
			tailOrnament = _Boule_1_1_1;
			wings = null;
			body = _Corps_1_1_1;
			tail = _Queue_1_1_1;
			legClose = _CuisseD_1_1_1;
			armClose = _PatteD_1_1_1;
			face = _Tete_1_1_1;
			eyes = _Oeil_1_1_1;
			earClose = _OreilleD_1_1_1;
		}
		
		public function initFur() : FurData {
			var tNum:int = id;
			
			earFar		= Main.assets.getLoadedClass( "_OreilleG_1_"+tNum+"_1" );
			footFar		= Main.assets.getLoadedClass( "_PiedG_1_"+tNum+"_1" );
			legFar		= Main.assets.getLoadedClass( "_CuisseG_1_"+tNum+"_1" );
			armFar		= Main.assets.getLoadedClass( "_PatteG_1_"+tNum+"_1" );
			footClose	= Main.assets.getLoadedClass( "_PiedD_1_"+tNum+"_1" );
			tailOrnament= Main.assets.getLoadedClass( "_Boule_1_"+tNum+"_1" );
			wings		= Main.assets.getLoadedClass( "_Ailes_1_"+tNum+"_1" );
			body		= Main.assets.getLoadedClass( "_Corps_1_"+tNum+"_1" );
			tail		= Main.assets.getLoadedClass( "_Queue_1_"+tNum+"_1" );
			legClose	= Main.assets.getLoadedClass( "_CuisseD_1_"+tNum+"_1" );
			armClose	= Main.assets.getLoadedClass( "_PatteD_1_"+tNum+"_1" );
			face		= Main.assets.getLoadedClass( "_Tete_1_"+tNum+"_1" );
			eyes		= Main.assets.getLoadedClass( "_Oeil_1_"+tNum+"_1" );
			earClose	= Main.assets.getLoadedClass( "_OreilleD_1_"+tNum+"_1" );
			
			return this;
		}
		
		public function initColor(pColor:String=null) : FurData {
			if(pColor != null) {
				color = pColor;
			} else {
				switch (id) 
				{
					case 0: { color = "BD9067"; break; }
					case 1: { color = "593618"; break; }
					case 2: { color = "8C887F"; break; }
					case 3: { color = "DED7CE"; break; }
					case 4: { color = "4E443A"; break; }
					case 5: { color = "E3C07E"; break; }
					case 6: { color = "272220"; break; }
				}
			}
			
			initDefaultParts();
			
			return this;
		}
	}
}
