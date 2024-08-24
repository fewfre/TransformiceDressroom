package app.world.data
{
	import com.fewfre.utils.Fewf;
	import app.data.*;
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.getDefinitionByName;

	public class SkinData extends ItemData
	{
		// Storage
		private var _assetID : String;
		public var isSkinColor : Boolean;
		
		// Properties
		// Only the default fur can be customized (but not the colored variations, as they're hardcoded customizations)
		public override function get isCustomizable() : Boolean { return id == 1 || id == "1"; }
		
		// Constructor
		// pData = { id:String, ?isSkinColor:Boolean, ?color:int, ?assetID:String }
		public function SkinData(pId:String, pData:Object=null) {
			super(ItemType.SKIN, pId, {});
			pData = pData || {};
			_assetID = pData.assetID != null ? pData.assetID : id;
			isSkinColor = !!pData.isSkinColor;
			if(pData.color) {
				defaultColors = new <uint>[ pData.color ];
				setColorsToDefault();
			}
			classMap = {};
		}
		public override function copy() : ItemData {
			return new SkinData(id, { assetID:_assetID, isSkinColor:isSkinColor, color:defaultColors ? defaultColors[0] : null, itemClass:itemClass, classMap:classMap });
		}

		// Only fur 1 has default colors, and it's manually passed in, not found in the asset
		protected override function _initDefaultColors() : void {}
		
		// pOptions = { shamanMode:ShamanMode }
		public override function getPart(pID:String, pOptions:Object=null) : Class {
			var shamanMode:ShamanMode = ShamanMode.OFF;
			if(pOptions != null) {
				if(pOptions.shamanMode) { shamanMode = pOptions.shamanMode; }
			}
			if(shamanMode == ShamanMode.DIVINE) {
				shamanMode = ShamanMode.HARD; // Divine uses the same setup as hard, so just switch to hard
			}
			var mcName = "_"+pID+"_"+_assetID+"_"+shamanMode.toInt();
			var tClass = _assetID == 1 ? getDefaultSkinPart(mcName) : Fewf.assets.getLoadedClass(mcName);
			// trace("_"+pID+"_"+_assetID+"_"+shamanMode+" - "+tClass);
			// recursively decrease shaman mode until valid part is found
			return tClass == null && shamanMode.toInt() > ShamanMode.NORMAL.toInt() ? getPart(pID, { shamanMode:ShamanMode.fromInt(shamanMode.toInt()-1) }) : tClass;
		}
		
		private function getDefaultSkinPart(pName:String) : Class {
			try {
				return getDefinitionByName(pName) as Class;
			}
			catch(err:Error) {
				return null;
			}
		}
		
		// Needed for default skin to be included into code by compiler from swc, since it's never accessed directly
		private static var DEFAULT_SKIN_CLASS_TO_FIX_BUG:Array = [
			_Boule_1_1_1, _Boule_1_1_2, _Boule_1_1_3,
			_Corps_1_1_1, _Corps_1_1_2, _Corps_2_1_1, _Corps_2_1_2,
			_CuisseD_1_1_1, _CuisseD_1_1_2, _CuisseD_2_1_1, _CuisseD_2_1_2,
			_CuisseG_1_1_1, _CuisseG_1_1_2,
			_Oeil_1_1_1, _Oeil_1_1_2, _Oeil2_1_1_1, _Oeil2_1_1_2, _Oeil3_1_1_1, _Oeil3_1_1_2,
			_OreilleD_1_1_1, _OreilleD_1_1_2, _OreilleG_1_1_1, _OreilleG_1_1_2,
			_PatteD_1_1_1, _PatteD_1_1_2, _PatteD2_1_1_1, _PatteD2_1_1_2,
			_PatteG_1_1_1, _PatteG_1_1_2, _PatteG2_1_1_1, _PatteG2_1_1_2,
			_PiedD_1_1_1, _PiedD_1_1_2, _PiedD2_1_1_1, _PiedD2_1_1_2,
			_PiedG_1_1_1, _PiedG_1_1_2,
			_Queue_1_1_1, _Queue_1_1_2,
			_Tete_1_1_1, _Tete_1_1_2, _Tete_1_1_3
		];
	}

	// // Face
	// classMap.Tete_1			= Fewf.assets.getLoadedClass( "_Tete_1_"+_assetID+"_1" );
	// // Eyes
	// classMap.Oeil_1			= Fewf.assets.getLoadedClass( "_Oeil_1_"+_assetID+"_1" );
	// // Body
	// classMap.Corps_1		= Fewf.assets.getLoadedClass( "_Corps_1_"+_assetID+"_1" );
	// // Wings
	// classMap.Ailes_1		= Fewf.assets.getLoadedClass( "_Ailes_1_"+_assetID+"_1" );
	// // Tail
	// classMap.Queue_1		= Fewf.assets.getLoadedClass( "_Queue_1_"+_assetID+"_1" );
	// // Tail Ornament
	// classMap.Boule_1		= Fewf.assets.getLoadedClass( "_Boule_1_"+_assetID+"_1" );

	// // Back Paws
	// classMap.PiedG_1		= Fewf.assets.getLoadedClass( "_PiedG_1_"+_assetID+"_1" );
	// classMap.PiedD_1		= Fewf.assets.getLoadedClass( "_PiedD_1_"+_assetID+"_1" );
	// classMap.PiedD2_1		= Fewf.assets.getLoadedClass( "_PiedD2_1_"+_assetID+"_1" );
	// // Front Paws
	// classMap.PatteG_1		= Fewf.assets.getLoadedClass( "_PatteG_1_"+_assetID+"_1" );
	// classMap.PatteD_1		= Fewf.assets.getLoadedClass( "_PatteD_1_"+_assetID+"_1" );
	// // Ears
	// classMap.OreilleG_1		= Fewf.assets.getLoadedClass( "_OreilleG_1_"+_assetID+"_1" );
	// classMap.OreilleD_1		= Fewf.assets.getLoadedClass( "_OreilleD_1_"+_assetID+"_1" );
	// // Legs
	// classMap.CuisseG_1		= Fewf.assets.getLoadedClass( "_CuisseG_1_"+_assetID+"_1" );
	// classMap.CuisseD_1		= Fewf.assets.getLoadedClass( "_CuisseD_1_"+_assetID+"_1" );
}
