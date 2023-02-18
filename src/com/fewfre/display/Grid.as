package com.fewfre.display
{
	import flash.display.*;

	// Display items in a grid format.
	public class Grid extends Sprite
	{
		// Storage
		private var _width : Number;
		private var _columns : uint;
		private var _margin : Number;
		private var _cellSize : Number; // The max size an item that's added can be before it won't fit.
		private var _spacing : Number; // Simply the radius+margin for easily spacing items added to grid.

		private var _list : Vector.<DisplayObject>;
		private var _reversed : Boolean;

		// Properties
		public function get cells():Vector.<DisplayObject> { return _list; }
		public function get reversed():Boolean { return _reversed; }
		
		public function get cellSize():Number { return _cellSize; }
		public function get rows():Number { return Math.ceil(_list.length / _columns); }
		public function get columns():uint { return _columns; }

		// Constructor
		public function Grid(pWidth:Number, pColumns:uint, pMargin:Number=5) {
			_width = pWidth;
			_columns = pColumns;
			_margin = pMargin;

			_list = new Vector.<DisplayObject>();
			_reversed = false;

			_cellSize = Math.floor((_width - (_margin * (_columns-1))) / _columns);
			_spacing = _cellSize + _margin;
		}
		public function setXY(pX:Number, pY:Number) : Grid { x = pX; y = pY; return this; }
		
		/****************************
		* Public
		*****************************/
		public function reset(pResetReversal:Boolean=false) : Grid {
			_list.forEach(function(o:*,i:int,a:*):void{ removeChild(a[i]); });
			_list = new Vector.<DisplayObject>();
			if(pResetReversal) _reversed = false;
			this.graphics.clear();
			return this;
		}

		// pArray:Array<DisplayObject>
		public function addList(pArray:Array) : void {
			for each(var item:DisplayObject in pArray) {
				_list.push( addChild(item) );
			}
			_repositionCells();
		}
		
		public function add(pItem:DisplayObject) : DisplayObject {
			_list.push( addChild(pItem) );
			
			_repositionCells();
			return pItem;
		}
		
		public function reverse() : void {
			_reversed = !_reversed;
			_repositionCells();
		}
		
		/****************************
		* Public
		*****************************/
		private function _repositionCells() : void {
			var tList:Vector.<DisplayObject> = reversed ? _list.concat().reverse() : _list;
			var len:int = tList.length;
			for (var i:uint in tList) {
				tList[i].x = i % _columns * _spacing;
				tList[i].y = Math.floor(i / columns) * _spacing;
			}
		}
	}
}
