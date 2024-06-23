package app.ui.screens
{
	import app.data.*;
	import app.ui.buttons.*;
	import app.ui.common.*;
	import app.world.data.*;
	import com.adobe.images.*;
	import com.fewfre.display.*;
	import com.fewfre.events.*;
	import com.fewfre.utils.*;
	import flash.display.*;
	import flash.events.*;
	
	public class LangScreen extends MovieClip
	{
		// Storage
		private var _tray			: RoundedRectangle;
		
		// Constructor
		// pData = {  }
		public function LangScreen(pData:Object) {
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
			_tray = new RoundedRectangle(tWidth, tHeight, { origin:0.5 }).appendTo(this).drawAsTray();

			/****************************
			* Languages
			*****************************/
			var tLanguages = Fewf.assets.getData("config").languages.list;
			
			var tFlagTray = _tray.addChild(new MovieClip()), tFlagRowTray, tX;
			var tBtn:SpriteButton, tLangData:Object, tColumns = 8, tRows = 1+Math.floor((tLanguages.length-1) / tColumns), tColumnsInRow = tColumns;
			for(var i = 0; i < tLanguages.length; i++) { tLangData = tLanguages[i];
				if(i%tColumns == 0) {
					tColumnsInRow = i+tColumns > tLanguages.length ? tLanguages.length - i : tColumns;
					tFlagRowTray = tFlagTray.addChild(new MovieClip());
					tFlagRowTray.x += -(tColumnsInRow*55*0.5)+(55*0.5)+1;
					tFlagRowTray.y += Math.floor(i/tColumns)*55;
					tX = -55;
				}
				tFlagRowTray.addChild(new SpriteButton({ x:tX+=55, width:50, height:50, obj_scale:0.3, obj:_getFlagImage(tLangData), data:tLangData, origin:0.5 }))
				.addEventListener(ButtonBase.CLICK, _onLanguageClicked);
			}
			tFlagTray.y -= 55*(tRows-1)*0.5;
			
			/****************************
			* Close Button
			*****************************/
			var tCloseButton:ScaleButton = addChild(new ScaleButton({ x:tWidth*0.5 - 5, y:-tHeight*0.5 + 5, obj:new $WhiteX() })) as ScaleButton;
			tCloseButton.addEventListener(ButtonBase.CLICK, _onCloseClicked);
		}
		
		private function _newScreenBacking() : Sprite {
			var backing:Sprite = new Sprite(), size:Number = 10000;
			backing.x = -size/2;
			backing.y = -size/2;
			backing.graphics.beginFill(0x000000, 0.2);
			backing.graphics.drawRect(0, 0, size, size);
			backing.graphics.endFill();
			return backing;
		}
		
		///////////////////////
		// Public
		///////////////////////
		public function open() : void {
			
		}
		
		///////////////////////
		// Private
		///////////////////////
		private function _close() : void {
			dispatchEvent(new Event(Event.CLOSE));
		}
		private function _onCloseClicked(pEvent:Event) : void { _close(); }
		
		private function _getFlagImage(pLangData:Object) : MovieClip {
			var tImage = new MovieClip();
			var tFlag = tImage.addChild(Fewf.assets.getLoadedMovieClip(pLangData.flags_swf_linkage));
			tFlag.x -= tFlag.width*0.5;
			tFlag.y -= tFlag.height*0.5;
			return tImage;
		}
		
		private function _onLanguageClicked(pEvent:FewfEvent) : void {
			var tLangData = pEvent.data;
			Fewf.sharedObjectGlobal.setData(ConstantsApp.SHARED_OBJECT_KEY_GLOBAL_LANG, tLangData.code);
			_close();
			if(Fewf.assets.getData(tLangData.code)) {
				Fewf.i18n.parseFile(tLangData.code, Fewf.assets.getData(tLangData.code));
				return;
			}
			var tLoaderDisplay = addChild( new LoaderDisplay({  }) );
			
			Fewf.assets.load([
				Fewf.swfUrlBase+"resources/i18n/"+tLangData.code+".json",
			]);
			Fewf.assets.addEventListener(AssetManager.LOADING_FINISHED, function(e:Event){
				Fewf.assets.removeEventListener(AssetManager.LOADING_FINISHED, arguments.callee);
				tLoaderDisplay.destroy();
				removeChild( tLoaderDisplay );
				tLoaderDisplay = null;
				
				Fewf.i18n.parseFile(tLangData.code, Fewf.assets.getData(tLangData.code));
			});
		}
	}
}
