package app.ui.buttons
{
	import com.fewfre.display.ButtonBase;
	import app.data.ConstantsApp;
	import app.ui.common.RoundedRectangle;
	
	public class GameButton extends ButtonBase
	{
		// Storage
		protected var _bg			: RoundedRectangle;
		
		// Properties
		public function get Width():Number { return _bg.Width; }
		public function get Height():Number { return _bg.Height; }
		
		// Constructor
		// pData = { x:Number, y:Number, (width:Number, height:Number OR size:Number), ?origin:Number, ?originX:Number, ?originY:Number }
		public function GameButton(pData:Object) {
			_bg = new RoundedRectangle(pData.size || pData.width, pData.size || pData.height, { origin:pData.origin, originX:pData.originX, originY:pData.originY }).appendTo(this);
			super(pData);
		}

		/****************************
		* Render
		*****************************/
		override protected function _renderUp() : void {
			_bg.draw(ConstantsApp.COLOR_BUTTON_BLUE, 7, ConstantsApp.COLOR_BUTTON_OUTSET_TOP, ConstantsApp.COLOR_BUTTON_OUTSET_BOTTOM, ConstantsApp.COLOR_BUTTON_BLUE);
		}
		
		override protected function _renderDown() : void
		{
			_bg.draw(ConstantsApp.COLOR_BUTTON_MOUSE_DOWN, 7, ConstantsApp.COLOR_BUTTON_OUTSET_BOTTOM, ConstantsApp.COLOR_BUTTON_BLUE, ConstantsApp.COLOR_BUTTON_MOUSE_DOWN);
		}
		
		override protected function _renderOver() : void {
			_bg.draw(ConstantsApp.COLOR_BUTTON_MOUSE_OVER, 7, ConstantsApp.COLOR_BUTTON_OUTSET_BOTTOM, ConstantsApp.COLOR_BUTTON_BLUE, ConstantsApp.COLOR_BUTTON_MOUSE_OVER);
		}
		
		override protected function _renderOut() : void {
			_renderUp();
		}
		
		override protected function _renderDisabled() : void {
			_bg.draw(0x555555, 7, ConstantsApp.COLOR_BUTTON_OUTSET_BOTTOM, ConstantsApp.COLOR_BUTTON_BLUE, 0x555555);
		}
	}
}
