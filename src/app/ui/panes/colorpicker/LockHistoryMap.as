package app.ui.panes.colorpicker
{
	import flash.utils.Dictionary;
	import app.ui.buttons.ColorButton;
	import com.fewfre.display.ButtonBase;
	import com.fewfre.events.FewfEvent;
	
	public class LockHistoryMap
	{
		// Constants
		private static var LOCKS_MAP : Dictionary = new Dictionary();
		
		/****************************
		* Instance
		*****************************/
		// Storage
		private var _currentLockListId : String;
		
		// Constructor
		public function LockHistoryMap() {}
		
		public function init(pLockId:String, pSize:uint) {
			_currentLockListId = pLockId;
			
			if(!LOCKS_MAP[_currentLockListId]) {
				LOCKS_MAP[_currentLockListId] = new Vector.<Boolean>(pSize);
			}
		}
		
		public function getLockHistoryMap() : Vector.<Boolean> {
			return LOCKS_MAP[_currentLockListId];
		}
		public function getLockHistory(index:uint) : Boolean {
			var history:Vector.<Boolean> = getLockHistoryMap();
			return index < history.length ? history[index] : false;
		}
		public function setLockHistory(index:uint, val:Boolean) : void {
			var history:Vector.<Boolean> = getLockHistoryMap();
			history[index] = val;
		}
		public function clearLockHistory() : void{
			if(LOCKS_MAP[_currentLockListId])
				LOCKS_MAP[_currentLockListId] = new Vector.<Boolean>(LOCKS_MAP[_currentLockListId].length);
		}
		
		/****************************
		* Static
		*****************************/
		public static function deleteLockHistoryAtId(pLockId:String) {
			delete LOCKS_MAP[pLockId];
		}
		public static function deleteAllLockHistory() {
			LOCKS_MAP = new Dictionary();
		}
	}
}
