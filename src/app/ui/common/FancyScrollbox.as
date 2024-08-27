
package app.ui.common
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import fl.containers.ScrollPane;
	import flash.geom.Rectangle;

	public class FancyScrollbox extends Sprite
	{
		// Storage
		private var _scrollPane : ScrollPane;
		private var _content:Sprite;
		// For scrollwheel to work, the cursor has to intersect a child element of the ScrollPane source - as such we add a backing behind the content that's the same size as it's parent.
		private var _contentHitbox:Sprite;
		
		// Properties
		public function get scrollPane() : ScrollPane { return _scrollPane; }
		public function get contentHitbox() : Sprite { return _contentHitbox; }
		
		// Constructor
		public function FancyScrollbox(pWidth:Number, pHeight:Number) {
			super();
			_scrollPane = _newScrollPane(pWidth, pHeight);
			_content = new Sprite();
			_contentHitbox = new Sprite();
			
			_content.addChild(_contentHitbox);
			_scrollPane.source = _content;
			super.addChild(_scrollPane);
		}
		public function move(pX:Number, pY:Number) : FancyScrollbox { x = pX; y = pY; return this; }
		public function resize(pWidth:Number, pHeight:Number) : FancyScrollbox { _scrollPane.setSize(pWidth, pHeight); return this; }
		
		private function _newScrollPane(pWidth:Number, pHeight:Number) : ScrollPane {
			var pane:ScrollPaneWithDragFix = new ScrollPaneWithDragFix();
			pane.setSize(pWidth, pHeight);
			pane.verticalLineScrollSize = 25;
			pane.verticalPageScrollSize = 25;
			pane.scrollDrag = true;
			pane.focusEnabled = false; // disables arrow keys moving scrollbars (we use arrows for grid traversal)
			
			var tStyle:MovieClip=new MovieClip();
			tStyle.graphics.clear();
			pane.setStyle("upSkin", tStyle);
			return pane;
		}
		
		///////////////////////
		// Public
		///////////////////////
		public function add(pItem:DisplayObject):DisplayObject {
			_content.addChild(pItem);
			refresh();
			return pItem;
		}
		// Just convience functions so expected type is returned
		public function addSprite(pItem:Sprite) : Sprite { return add(pItem) as Sprite; }
		public function addMovieClip(pItem:MovieClip) : MovieClip { return add(pItem) as MovieClip; }

		public function remove(pItem:DisplayObject) : DisplayObject {
			_content.removeChild(pItem);
			refresh();
			return pItem;
		}

		public override function contains(pItem:DisplayObject) : Boolean {
			return _content.contains(pItem);
		}

		public function scrollItemIntoView(pItem:DisplayObject) : void {
			var rect:Rectangle = pItem.getRect(_content);
			// If item is above the viewport, scroll so until the top of the item appears along the top
			if(rect.top+0.4 < _scrollPane.verticalScrollPosition) {
				_scrollPane.verticalScrollPosition = rect.top+0.4;
			}
			// If item is below the viewport, scroll so until the bottom of the item appears along the bottom
			else if(rect.bottom+1.1 - _scrollPane.height > _scrollPane.verticalScrollPosition) {
				_scrollPane.verticalScrollPosition = rect.bottom+1.1 - _scrollPane.height;
			}
		}
		
		public function refresh() : void {
			_updateHitbox();
			_scrollPane.source = _content;
			super.addChild(_scrollPane);
		}
		
		///////////////////////
		// Private
		///////////////////////
		public function _updateHitbox() : void {
			_contentHitbox.graphics.clear();
			_contentHitbox.graphics.beginFill(0, 0);
			_contentHitbox.graphics.drawRect(0, 0, _content.width, _content.height);
			_contentHitbox.graphics.endFill();
		}
		
		public override function addChild(pItem:DisplayObject):DisplayObject {
			throw "Don't use `addChild` on Scrollbox, use `add` instead!";
			return pItem;
		}
	}
}

import fl.containers.ScrollPane;
import flash.events.MouseEvent;
// https://stackoverflow.com/a/14332350/1411473
class ScrollPaneWithDragFix extends ScrollPane
{
    protected override function endDrag(event:MouseEvent):void {
        if (stage) {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, doDrag);
        }
    }
}