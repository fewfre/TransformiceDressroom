package com.fewfre.display
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import com.fewfre.utils.FewfDisplayUtils;
	import flash.display.MovieClip;
	import flash.display.Shape;

	public class DisplayWrapper
	{
		// Storage
		protected var _root : DisplayObject;
		
		// Properties
		public function get root() : DisplayObject { return _root; }
		public function get asSprite() : Sprite { return _root as Sprite; }
		public function get asMovieClip() : MovieClip { return _root as MovieClip; }
		public function get asShape() : Shape { return _root as Shape; }
		
		// Constructor
		// pProps = { x?:Number, y?:Number, (scale?:Number OR scaleX?:Number, scaleY:Number) }
		public function DisplayWrapper(pTarget:DisplayObject, pProps:Object=null) {
			_root = pTarget;
			
			pProps = pProps || {};
			_root.x = pProps.x != null ? pProps.x : 0;
			_root.y = pProps.y != null ? pProps.y : 0;
			
			if(pProps.scale) _root.scaleX = _root.scaleY = pProps.scale;
			if(pProps.scaleX) _root.scaleX = pProps.scaleX;
			if(pProps.scaleY) _root.scaleY = pProps.scaleY;
		}
		public function move(pX:Number, pY:Number) : DisplayWrapper { _root.x = pX; _root.y = pY; return this; }
		public function toScale(pX:Number, pY:Object=null) : DisplayWrapper { _root.scaleX = pX; _root.scaleY = pY != null ? pY as Number : pX; return this; }
		public function toAlpha(pAlpha:Number) : DisplayWrapper { _root.alpha = pAlpha; return this; }
		public function appendTo(pParent:Sprite): DisplayWrapper { pParent.addChild(_root); return this; }
		public function on(type:String, listener:Function, useCapture:Boolean = false): DisplayWrapper { _root.addEventListener(type, listener, useCapture); return this; }
		public function off(type:String, listener:Function, useCapture:Boolean = false): DisplayWrapper { _root.removeEventListener(type, listener, useCapture); return this; }
		
		/////////////////////////////
		// Public
		/////////////////////////////
		/**
		 * function passed in is immediately called with the target's graphics object passed in as the only parameter
		 */
		public function draw(pFunc:Function) : DisplayWrapper {
			if(_root is Sprite)     { pFunc(asSprite.graphics); }
			else if(_root is Shape) { pFunc(asShape.graphics); }
			else { trace("[ERROR] DisplayWrapper.draw() requires a Sprite or Shape"); }
			return this;
		}
		
		public function fitWithinBounds(pMaxWidth:Number, pMaxHeight:Number, pMinWidth:Number = 0, pMinHeight:Number = 0) : DisplayWrapper {
			FewfDisplayUtils.fitWithinBounds(_root, pMaxWidth, pMaxHeight, pMinWidth, pMinHeight);
			return this;
		}
		
		public function alignChildrenAroundAnchor(originX:Object=0.5, originY:Object=0.5, pDrawScaffolding:Boolean=false) : DisplayWrapper {
			if(_root is Sprite) {
				FewfDisplayUtils.alignChildrenAroundAnchor(_root as Sprite, originX, originY, pDrawScaffolding);
			} else {
				trace("[ERROR] DisplayWrapper.alignChildrenAroundAnchor() requires a Sprite");
			}
			return this;
		}
		
		/////////////////////////////
		// Static
		/////////////////////////////
		public static function wrap(pTarget:DisplayObject, pParent:Sprite) : DisplayWrapper {
			return new DisplayWrapper(pTarget).appendTo(pParent);
		}
	}
}
