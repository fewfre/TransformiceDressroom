package com.fewfre.data
{
	import flash.net.SharedObject;

	public class SharedObjectManager {
		public var sharedObject:SharedObject;
		
		public function SharedObjectManager(storageID:String):void {
			sharedObject = SharedObject.getLocal(storageID);
		}
		public function getData(_key:String):* {
			return sharedObject.data[_key];
		}
		public function setData(_key:String,_val:*):void {
			sharedObject.data[_key] = _val;
			save();
		}
		public function save():void {
			// save the shared object
			sharedObject.flush();
		}
	}
}