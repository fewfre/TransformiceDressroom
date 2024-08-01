package app.ui.buttons
{
	import com.fewfre.display.ButtonBase;
	import app.data.ConstantsApp;
	import com.fewfre.display.RoundRectangle;
	
	public class GameButton extends ButtonBase
	{
		// Storage
		protected var _bg			: RoundRectangle;
		
		// Properties
		public function get Width():Number { return _bg.width; }
		public function get Height():Number { return _bg.height; }
		
		// Constructor
		// pData = { x:Number, y:Number, (width:Number, height:Number OR size:Number), ?origin:Number, ?originX:Number, ?originY:Number }
		public function GameButton(pData:Object) {
			_bg = new RoundRectangle(pData.size || pData.width, pData.size || pData.height, { origin:pData.origin, originX:pData.originX, originY:pData.originY })
				.toRadius(7).appendTo(this);
			super(pData);
		}

		/****************************
		* Render
		*****************************/
		override protected function _renderUp() : void {
			_bg.draw3d(ConstantsApp.COLOR_BUTTON_BLUE, ConstantsApp.COLOR_BUTTON_OUTSET_TOP, ConstantsApp.COLOR_BUTTON_OUTSET_BOTTOM, ConstantsApp.COLOR_BUTTON_BLUE);
		}
		
		override protected function _renderDown() : void {
			_bg.draw3d(ConstantsApp.COLOR_BUTTON_MOUSE_DOWN, ConstantsApp.COLOR_BUTTON_OUTSET_BOTTOM, ConstantsApp.COLOR_BUTTON_BLUE, ConstantsApp.COLOR_BUTTON_MOUSE_DOWN);
		}
		
		override protected function _renderOver() : void {
			_bg.draw3d(ConstantsApp.COLOR_BUTTON_MOUSE_OVER, ConstantsApp.COLOR_BUTTON_OUTSET_BOTTOM, ConstantsApp.COLOR_BUTTON_BLUE, ConstantsApp.COLOR_BUTTON_MOUSE_OVER);
		}
		
		override protected function _renderOut() : void {
			_renderUp();
		}
		
		override protected function _renderDisabled() : void {
			_bg.draw3d(0x555555, ConstantsApp.COLOR_BUTTON_OUTSET_BOTTOM, ConstantsApp.COLOR_BUTTON_BLUE, 0x555555);
		}
	}
}
