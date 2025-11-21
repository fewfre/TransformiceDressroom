package app
{
	import app.world.World;
	import app.zFilterSelectionMode.FilterSelectionWorld;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;

	public class WorldManager
	{
		// Storage
		private var _root : Sprite;
		private var _stage : Stage;
		
		private var _currentWorldType     : WorldType;
		private var _currentWorld         : Sprite;
		
		private var _mainWorld            : World;
		private var _filterSelectionWorld : FilterSelectionWorld;
		
		// Properties
		public function get mainWorld() : World { return _mainWorld }
		
		// Constructor
		public function WorldManager(pParent:Sprite, pStage:Stage) {
			_root = pParent;
			_stage = pStage;
			_open(WorldType.MAIN);
		}
		
		//////////////////////////////////
		// World Creation / Changing
		//////////////////////////////////
		
		private function _open(pWorldType:WorldType) : void {
			if(_currentWorld) _root.removeChild(_currentWorld);
			_currentWorldType = pWorldType;
			switch(_currentWorldType) {
				case WorldType.MAIN: _currentWorld = _createMainWorld(); break;
				case WorldType.FILTER_SELECTION: _currentWorld = _createFilterSelectionWorld(); break;
			}
			_root.addChild(_currentWorld);
		}
		
		private function _createMainWorld() : World {
			if(_mainWorld) return _mainWorld;
			_mainWorld = new World(_stage);
			_mainWorld.addEventListener(World.SWITCH_TO_FILTER_SELECTION_MODE, function(e):void{ _open(WorldType.FILTER_SELECTION); _filterSelectionWorld.open(); });
			return _mainWorld;
		}
		
		private function _createFilterSelectionWorld() : FilterSelectionWorld {
			if(_filterSelectionWorld) return _filterSelectionWorld;
			_filterSelectionWorld = new FilterSelectionWorld();
			_filterSelectionWorld.addEventListener(FilterSelectionWorld.CLOSED, function(e):void{ _open(WorldType.MAIN); });
			_filterSelectionWorld.addEventListener(FilterSelectionWorld.PREVIEW_MODE_CLICKED, function(e):void{ _open(WorldType.MAIN); _mainWorld.filterSelectionMode_triggeredPreviewMode(); });
			return _filterSelectionWorld;
		}
	}
}

//////////////////////////////////
// WorldType Enum
//////////////////////////////////
final class WorldType
{
	public static const MAIN             : WorldType = new WorldType(1);
	public static const FILTER_SELECTION : WorldType = new WorldType(2);
	
	// Enum Storage + Constructor
	private var _value: int;
	function WorldType(pValue:int) { _value = pValue; }
	
	// This is required for proper auto string convertion on `trace`/`Dictionary` and such - enums should always have
	public function toString() : String { return _value.toString(); }
}