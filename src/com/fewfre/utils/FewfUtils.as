package com.fewfre.utils
{
	public class FewfUtils
	{
		////////////////////////////////
		// Get From Array
		////////////////////////////////
		public static function getFromArrayWithKeyVal(pArray:Array, pKey:String, pVal:*) : * {
			return pArray[getIndexFromArrayWithKeyVal(pArray, pKey, pVal)];
		}
		
		// Checks each item in array to see if it's pKey variable is equal to pVal.
		public static function getIndexFromArrayWithKeyVal(pArray:Array, pKey:String, pVal:*) : int {
			for(var i:int = 0; i < pArray.length; i++) {
				if(pArray[i] && pArray[i][pKey] == pVal) {
					return i;
				}
			}
			return -1;
		}
		
		////////////////////////////////
		// Get From Vector
		////////////////////////////////
		public static function getFromVectorWithKeyVal(pVector:Object, pKey:String, pVal:*) : * {
			var i:int = getIndexFromVectorWithKeyVal(pVector, pKey, pVal);
			return i > -1 ? pVector[i] : null;
		}
		
		// Sadly can't checky for generic vector, so just accept Object
		public static function getIndexFromVectorWithKeyVal(pVector:Object, pKey:String, pVal:*) : int {
			for(var i:int = 0; i < pVector.length; i++) {
				if(pVector[i] && pVector[i][pKey] == pVal) { return i; }
			}
			return -1;
		}
		
		////////////////////////////////
		// Find From Array (callback)
		////////////////////////////////
		public static function arrayFindIndex(pArray:Array, pCallback:Function) : int {
			for(var i:int = 0; i < pArray.length; i++) {
				if(pCallback(pArray[i])) { return i; }
			}
			return -1;
		}
		public static function arrayFind(pArray:Array, pCallback:Function) : * {
			var i:int = arrayFindIndex(pArray, pCallback);
			return i > -1 ? pArray[i] : null;
		}
		
		////////////////////////////////
		// Find From Vector (callback)
		////////////////////////////////
		public static function vectorFindIndex(pVector:Object, pCallback:Function) : int {
			for(var i:int = 0; i < pVector.length; i++) {
				if(pCallback(pVector[i])) { return i; }
			}
			return -1;
		}
		public static function vectorFind(pVector:Object, pCallback:Function) : * {
			var i:int = vectorFindIndex(pVector, pCallback);
			return i > -1 ? pVector[i] : null;
		}
		
		////////////////////////////////
		// Stable Sort (vector)
		////////////////////////////////
		/**
		 * Sorts the given vector in-place using the provided compare function, which should return a negative number if a < b, positive if a > b, and 0 if they are equal.
		 * This is a stable sort, meaning that if compare(a, b) == 0, the original order of a and b will be preserved.
		 */
		public static function vectorStableMergeSort(arr:Object, compare:Function):Object {
				for (var i:int = 1; i < arr.length; i++) {
				var cur:* = arr[i];
				var j:int = i - 1;
				// shift elements greater than cur to the right
				while (j >= 0 && compare(arr[j], cur) > 0) {
					arr[j + 1] = arr[j];
					j--;
				}
				// placing cur at j+1 preserves order when compare(...) == 0
				arr[j + 1] = cur;
			}
			return arr;
		}
		
		////////////////////////////////
		// String Helpers
		////////////////////////////////
		public static function stringSubstitute(pVal:String, ...pValues) : String {
			if(pValues[0] is Array) { pValues = pValues[0]; }
			// pVal.replace(/{(.*?)}/gi, "a");
			for(var i:* in pValues) {
				pVal = pVal.replace("{"+i+"}", pValues[i]);
			}
			return pVal;
		}
		
		public static function lpad(str:String, width:int, pad:String="0") : String {
			var ret:String = ""+str;
			while( ret.length < width )
				ret = pad + ret;
			return ret;
		}
		
		public static function trim(str:String) : String {
			return !str ? str : str.replace(/^\s+|\s+$/g, ''); // trim whitespace
		}
		
		////////////////////////////////
		// Color Helpers
		////////////////////////////////
		public static function colorIntToHexString(pVal:uint) : String {
			return pVal.toString(16).toUpperCase();
		}
		public static function colorHexStringToInt(pVal:String) : uint {
			return parseInt(pVal.replace("#", ""), 16);
		}
	}
}
