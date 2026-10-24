package app.ui.common
{
	import com.fewfre.display.TextBase;
	import com.fewfre.display.Tooltip;

	import flash.display.Sprite;

	public class InfoTooltipIcon extends Sprite
	{
		// Storage
		private var _tooltip:Tooltip;
		private var _textBase:TextBase;
		private var _size:Number = 18;
		private var _color:uint = 0xC2C2DA;
		private var _backgroundColor:Number = NaN;
		private var _originX:Number = 0;
		private var _originY:Number = 0;

		// Constructor
		/**
		 * @param pTooltipText Translation key displayed by the tooltip.
		 * @param pOptions Optional settings:
		 *   tooltipOptions:Object (forwarded to Tooltip).
		 *   Set icon size, color, and origin with setSize(), setColor(), and setOrigin().
		 */
		public function InfoTooltipIcon(pTooltipText:String, pTooltipOptions:Object=null) {
			super();
			_textBase = new TextBase("?", { bold:true }).setOrigin(0.5).appendTo(this);
			_render();
			_tooltip = new Tooltip(this, pTooltipText, pTooltipOptions);
			
			buttonMode = true;
			mouseChildren = false;
		}
		public function move(pX:Number, pY:Number) : InfoTooltipIcon { x = pX; y = pY; return this; }
		public function appendTo(pParent:Sprite) : InfoTooltipIcon { pParent.addChild(this); return this; }
		public function setSize(pSize:Number) : InfoTooltipIcon { _size = pSize; _render(); return this; }
		public function setColor(pColor:uint) : InfoTooltipIcon { _color = pColor; _render(); return this; }
		public function setBackgroundColor(pColor:uint) : InfoTooltipIcon { _backgroundColor = pColor; _render(); return this; }
		public function setOrigin(pX:Number, pY:Object=null) : InfoTooltipIcon {
			_originX = pX; _originY = pY != null ? pY as Number : pX; // if no originY, then set both to originX value
			_render();
			return this;
		}

		/////////////////////////////
		// Public
		/////////////////////////////
		public function dispose() : void {
			if(_tooltip) {
				_tooltip.dispose();
				_tooltip = null;
			}
		}
		
		/////////////////////////////
		// Private
		/////////////////////////////
		private function _render() : void {
			var lineThickness:Number = _size / 18, radius:Number = _size * 0.5, centerX:Number = radius - _size * _originX, centerY:Number = radius - _size * _originY;
			graphics.clear();
			graphics.lineStyle(lineThickness, _color);
			graphics.beginFill(isNaN(_backgroundColor) ? 0 : uint(_backgroundColor), isNaN(_backgroundColor) ? 0 : 1);
			graphics.drawCircle(centerX, centerY, radius - lineThickness / 2);
			graphics.endFill();
			
			_textBase.move(centerX, centerY);
			_textBase.size = _size * 0.75;
			_textBase.color = _color;
		}
	}
}
