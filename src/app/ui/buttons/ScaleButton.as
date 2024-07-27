package app.ui.buttons
{
	import com.fewfre.display.ButtonBase;
	import app.ui.*;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	public class ScaleButton extends ButtonBase
	{
		// Storage
		public var Image:DisplayObject;
		protected var _buttonScale:Number = 1;
		
		// Constructor
		// pData = { x:Number, y:Number, obj:DisplayObject, ?obj_scale:Number }
		public function ScaleButton(pData:Object)
		{
			super(pData);
			if(pData.obj_scale) { setScale(pData.obj_scale); }
			
			ChangeImage(pData.obj);
		}

		public function ChangeImage(pMC:DisplayObject) : void
		{
			if(this.Image != null) { removeChild(this.Image); }
			this.Image = pMC;
			addChild(this.Image);
		}
		
		public function setScale(pScale:Number) : void {
			_buttonScale = pScale;
			_renderUp();
		}

		override protected function _renderDown() : void
		{
			this.scaleX = this.scaleY = _buttonScale*0.9;
		}

		override protected function _renderUp() : void
		{
			this.scaleX = this.scaleY = _buttonScale;
		}

		override protected function _renderOver() : void
		{
			this.scaleX = this.scaleY = _buttonScale*1.1;
		}

		override protected function _renderOut() : void
		{
			this.scaleX = this.scaleY = _buttonScale;
		}
		
		/////////////////////////////
		// Static
		/////////////////////////////
		public static function withObject(pObj:DisplayObject, pScale:Object=null) : ScaleButton {
			return new ScaleButton({ obj:pObj, obj_scale:pScale });
		}
	}
}
