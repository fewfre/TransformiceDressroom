package app.ui
{
	import flash.display.*;

	// Display items in a grid format.
	public class Grid extends MovieClip
	{
		// Storage
		private var _width : Number;
		private var _columns : int;
		private var _margin : Number;
		private var _radius : Number; // The max size an item that's added can be before it won't fit.
		private var _spacing : Number; // Simply the radius+margin for easily spacing items added to grid.

		private var _array : Array;

		// Temp for add
		private var _w : int; // column of item
		private var _h : int; // row of item

		// Properties
		public function get radius():Number { return _radius; }
		public function get array():Array { return _array; }
		public function get Height():Number { return _radius + (_h * _spacing); }

		// pData = { width:Number, columns:int, margin:Number, ?x:Number=0, ?y:Number=0 }
		public function Grid(pData:Object) {
			_width = pData.width;
			_columns = pData.columns;
			_margin = pData.margin;
			x = pData.x != null ? pData.x : 0;
			y = pData.y != null ? pData.y : 0;

			_array = [];
			_w = 0;
			_h = 0;

			_radius = Math.floor((_width - (_margin * (_columns-1))) / _columns);
			_spacing = radius + _margin;
		}

		public function reset() : void {
			var i = _array.length;
			while(i > 0) { i--;
				removeChild(_array[i]);
			}
			_array = [];
			_w = 0;
			_h = 0;
			this.graphics.clear();
		}

		// pArray:Array<MovieClip>
		public function addList(pArray:Array) : void {
			reset();
			for (var i in pArray) {
				add(pArray[i]);
			}
		}

		public function add(pItem:Sprite) : Sprite {
			pItem.x = _spacing * _w;
			pItem.y = _spacing * _h;

			addChild(pItem);
			_array.push(pItem);

			_w++;
			if (_w >= _columns) {
				_w = 0;
				_h++;
			}
			return pItem;
		}
		
		public function reverse() : void {
			var list = _array;
			reset();
			addList(list.reverse());
		}
	}
}
