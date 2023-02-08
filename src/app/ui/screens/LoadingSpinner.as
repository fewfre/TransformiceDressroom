package app.ui.screens
{
	import com.fewfre.display.*;
	import com.fewfre.utils.*;
	import com.fewfre.events.FewfEvent;
	import app.data.*;
	import app.ui.*;
	import flash.display.*;
	import flash.events.*
	import flash.text.*;
	import flash.display.MovieClip;
	
	public class LoadingSpinner extends MovieClip
	{
		private var _loadingSpinner	: MovieClip;
		
		// pData = { x, y, scale }
		public function LoadingSpinner(pData:Object) {
			if(pData.x) { this.x = pData.x; }
			if(pData.y) { this.y = pData.y; }
			var scale:Number = pData.scale ? pData.scale : 2;
			
			_loadingSpinner = addChild( new $Loader() ) as MovieClip;
			_loadingSpinner.scaleX = scale;
			_loadingSpinner.scaleY = scale;
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		public function destroy():void {
			removeEventListener(Event.ENTER_FRAME, update);
			_loadingSpinner = null;
		}
		
		public function update(pEvent:Event):void {
			var dt:Number = 0.1;
			if(_loadingSpinner != null) {
				_loadingSpinner.rotation += 360 * dt;
			}
		}
	}
}
