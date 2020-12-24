package app.ui.screens
{
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import app.world.data.*;
	import com.adobe.images.*;
	import com.fewfre.display.*;
	import com.fewfre.events.*;
	import com.fewfre.utils.*;
	import flash.display.*;
	import flash.events.*;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	public class UpdateAppScreen extends MovieClip
	{
		// Constants
		public static const CLOSE : String= "close_update_app_screen";
		
		// Storage
		private var _tray			: RoundedRectangle;
		
		// Constructor
		// pData = {  }
		public function UpdateAppScreen(pData:Object) {
			this.x = Fewf.stage.stageWidth * 0.5;
			this.y = Fewf.stage.stageHeight * 0.5;
			
			/****************************
			* Click Tray
			*****************************/
			var tClickTray = addChild(new Sprite());
			tClickTray.x = -5000;
			tClickTray.y = -5000;
			tClickTray.graphics.beginFill(0x000000, 0.2);
			tClickTray.graphics.drawRect(0, 0, -tClickTray.x*2, -tClickTray.y*2);
			tClickTray.graphics.endFill();
			tClickTray.addEventListener(MouseEvent.CLICK, _onCloseClicked);
			
			/****************************
			* Background
			*****************************/
			var tWidth:Number = 500, tHeight:Number = 200;
			_tray = addChild(new RoundedRectangle({ x:0, y:0, width:tWidth, height:tHeight, origin:0.5 })) as RoundedRectangle;
			_tray.drawSimpleGradient(ConstantsApp.COLOR_TRAY_GRADIENT, 15, ConstantsApp.COLOR_TRAY_B_1, ConstantsApp.COLOR_TRAY_B_2, ConstantsApp.COLOR_TRAY_B_3);
			
			/****************************
			* Header
			*****************************/
			_tray.addChild(new TextBase({ text:"update_header", size:25, y:-68 }));
			
			/****************************
			* Stuff
			*****************************/
			var tData = Fewf.assets.getData("update");
			
			_tray.addChild(new TextBase({ text:"version", values:[tData.version+" ["+tData.date+"]"], size:14, y:-40 }));
			_tray.addChild(new TextBase({ text:"update_summary", values:[tData.message], y:4 }));
			
			var tCopyButton:SpriteButton = addChild(new SpriteButton({ x:0, y:63, text:"update_btn", width:250, height:35, origin:0.5 })) as SpriteButton;
			tCopyButton.addEventListener(ButtonBase.CLICK, _onUpdateClicked);
			
			/****************************
			* Close Button
			*****************************/
			var tCloseButton:ScaleButton = addChild(new ScaleButton({ x:tWidth*0.5 - 5, y:-tHeight*0.5 + 5, obj:new MovieClip() })) as ScaleButton;
			tCloseButton.addEventListener(ButtonBase.CLICK, _onCloseClicked);
			
			var tSize:Number = 10;
			tCloseButton.Image.graphics.beginFill(0x000000, 0);
			tCloseButton.Image.graphics.drawRect(-tSize*2, -tSize*2, tSize*4, tSize*4);
			tCloseButton.Image.graphics.endFill();
			tCloseButton.Image.graphics.lineStyle(8, 0xFFFFFF, 1, true);
			tCloseButton.Image.graphics.moveTo(-tSize, -tSize);
			tCloseButton.Image.graphics.lineTo(tSize, tSize);
			tCloseButton.Image.graphics.moveTo(tSize, -tSize);
			tCloseButton.Image.graphics.lineTo(-tSize, tSize);
		}
		
		public function open() : void {
			
		}
		
		private function _onCloseClicked(pEvent:Event) : void {
			_close();
		}
		
		private function _close() : void {
			dispatchEvent(new Event(CLOSE));
		}
		
		private function _onUpdateClicked(e:Event) : void {
			_close();
			var tData = Fewf.assets.getData("update");
			navigateToURL(new URLRequest(tData.url), "_blank");
		}
	}
}
