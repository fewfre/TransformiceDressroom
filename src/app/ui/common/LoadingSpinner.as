package app.ui.common
{
	import com.fewfre.display.DisplayWrapper;
	import flash.display.Sprite;
	import flash.events.Event;

	public class LoadingSpinner extends Sprite
	{
		// Storage
		private var _loadingSpinner	: Sprite;
		private var _speedScale	: Number = 1;
		
		// Constructor
		public function LoadingSpinner(pScale:Number=2) {
			_loadingSpinner = DisplayWrapper.wrap(new $Loader(), this).toScale(pScale).asSprite;
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		public function move(pX:Number, pY:Number) : LoadingSpinner { x = pX; y = pY; return this; }
		public function appendTo(pParent:Sprite): LoadingSpinner { pParent.addChild(this); return this; }
		public function removeSelf(): LoadingSpinner { if(this.parent){ this.parent.removeChild(this); } return this; }
		public function setSpeedScale(pSpeedScale:Number): LoadingSpinner { _speedScale = pSpeedScale; return this; }
		
		public function destroy():void {
			removeEventListener(Event.ENTER_FRAME, update);
			_loadingSpinner = null;
		}
		
		public function update(pEvent:Event):void {
			var dt:Number = 0.1;
			if(_loadingSpinner != null) {
				_loadingSpinner.rotation += 360 * _speedScale * dt;
			}
		}
	}
}
