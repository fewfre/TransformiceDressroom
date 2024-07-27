package com.fewfre.display
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import com.fewfre.utils.FewfDisplayUtils;
	import flash.display.MovieClip;

	public class DisplayWrapper
	{
		// Storage
		protected var _target : DisplayObject;
		
		// Properties
		public function get asDisplayObject() : DisplayObject { return _target; }
		public function get asSprite() : Sprite { return _target as Sprite; }
		public function get asMovieClip() : MovieClip { return _target as MovieClip; }
		
		// Constructor
		// pProps = { x?:Number, y?:Number, (scale?:Number OR scaleX?:Number, scaleY:Number) }
		public function DisplayWrapper(pTarget:DisplayObject, pProps:Object=null) {
			_target = pTarget;
			
			pProps = pProps || {};
			_target.x = pProps.x != null ? pProps.x : 0;
			_target.y = pProps.y != null ? pProps.y : 0;
			
			if(pProps.scale) _target.scaleX = _target.scaleY = pProps.scale;
			if(pProps.scaleX) _target.scaleX = pProps.scaleX;
			if(pProps.scaleY) _target.scaleY = pProps.scaleY;
		}
		public function move(pX:Number, pY:Number) : DisplayWrapper { _target.x = pX; _target.y = pY; return this; }
		public function scale(pX:Number, pY:Object=null) : DisplayWrapper { _target.scaleX = pX; _target.scaleY = pY != null ? pY as Number : pX; return this; }
		public function alpha(pAlpha:Number) : DisplayWrapper { _target.alpha = pAlpha; return this; }
		public function appendTo(pParent:Sprite): DisplayWrapper { pParent.addChild(_target); return this; }
		public function on(type:String, listener:Function, useCapture:Boolean = false): DisplayWrapper { _target.addEventListener(type, listener, useCapture); return this; }
		public function off(type:String, listener:Function, useCapture:Boolean = false): DisplayWrapper { _target.removeEventListener(type, listener, useCapture); return this; }
		
		/////////////////////////////
		// Public
		/////////////////////////////
		/**
		 * function passed in is immediately called with the target's graphics object passed in as the only parameter
		 */
		public function draw(pFunc:Function) : DisplayWrapper {
			if(_target is Sprite) {
				pFunc(asSprite.graphics);
			} else {
				trace("[ERROR] DisplayWrapper.draw() requires a Sprite");
			}
			return this;
		}
		
		public function fitWithinBounds(pMaxWidth:Number, pMaxHeight:Number, pMinWidth:Number = 0, pMinHeight:Number = 0) : DisplayWrapper {
			FewfDisplayUtils.fitWithinBounds(_target, pMaxWidth, pMaxHeight, pMinWidth, pMinHeight);
			return this;
		}
		
		public function alignChildrenAroundAnchor(originX:Object=0.5, originY:Object=0.5, pDrawScaffolding:Boolean=false) : DisplayWrapper {
			if(_target is Sprite) {
				FewfDisplayUtils.alignChildrenAroundAnchor(_target as Sprite, originX, originY, pDrawScaffolding);
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
