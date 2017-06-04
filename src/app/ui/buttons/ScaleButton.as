package app.ui.buttons
{
	import com.fewfre.display.ButtonBase;
	import app.ui.*;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class ScaleButton extends ButtonBase
	{
		// Storage
		public var Image:flash.display.MovieClip;
		
		// Constructor
		// pData = { x:Number, y:Number, obj:DisplayObject }
		public function ScaleButton(pData:Object)
		{
			super(pData);
			
			ChangeImage(pData.obj);
		}

		public function ChangeImage(pMC:MovieClip) : void
		{
			if(this.Image != null) { removeChild(this.Image); }
			this.Image = pMC;
			addChild(this.Image);
		}

		override protected function _renderDown() : void
		{
			this.scaleX = this.scaleY = 0.9;
		}

		override protected function _renderUp() : void
		{
			this.scaleX = this.scaleY = 1;
		}

		override protected function _renderOver() : void
		{
			this.scaleX = this.scaleY = 1.1;
		}

		override protected function _renderOut() : void
		{
			this.scaleX = this.scaleY = 1;
		}
	}
}
