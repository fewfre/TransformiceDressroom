package com.fewfre.utils
{
	public class FewfUtils
	{
		public static function getFromArrayWithKeyVal(pArray:Array, pKey:String, pVal:*) : * {
			return pArray[getIndexFromArrayWithKeyVal(pArray, pKey, pVal)];
		}
		
		// Checks each item in array to see if it's pKey variable is equal to pVal.
		public static function getIndexFromArrayWithKeyVal(pArray:Array, pKey:String, pVal:*) : int {
			for(var i = 0; i < pArray.length; i++) {
				if(pArray[i] && pArray[i][pKey] == pVal) {
					return i;
				}
			}
			return -1;
		}
		
		public static function stringSubstitute(pVal:String, ...pValues) : String {
			if(pValues[0] is Array) { pValues = pValues[0]; }
			// pVal.replace(/{(.*?)}/gi, "a");
			for(var i:int in pValues) {
				pVal = pVal.replace("{"+i+"}", pValues[i]);
			}
			return pVal;
		}
	}
}
