package app.ui.panes.filteringmode
{
	import app.data.ConstantsApp;
	import app.data.ShareCodeFilteringData;
	import app.ui.buttons.GameButton;
	import app.ui.common.FancyCopyField;
	import app.ui.panes.base.SidePane;
	import com.fewfre.display.TextTranslated;
	import com.fewfre.events.FewfEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.fewfre.display.RoundRectangle;
	import com.fewfre.display.DisplayWrapper;
	import app.ui.screens.TrashConfirmScreen;

	public class FilterSelectionModeInfoAside extends Sprite
	{
		// Constants
		public static const EVENT_PREVIEW_ENABLED : String = "event_preview_enabled";
		public static const EVENT_STOP_FILTERING : String = "event_stop_filtering";
		public static const EVENT_RESET_FILTERING : String = "event_reset_filtering";
		
		// Storage
		private var _copyField : FancyCopyField;
		private var _trashConfirmScreen : TrashConfirmScreen;
		
		// Constructor
		public function FilterSelectionModeInfoAside() {
			super();
			// Background
			var trayMargin:Number=10, trayWidth:Number = 375-(trayMargin*2), trayHeight:Number=ConstantsApp.APP_HEIGHT-(trayMargin*2);
			this.x = trayMargin+(trayWidth/2); this.y = trayMargin;
			new RoundRectangle(trayWidth, trayHeight).drawSolid(ConstantsApp.COLOR_TRAY_GRADIENT[0], ConstantsApp.COLOR_TRAY_B_1).toOrigin(0.5, 0).appendTo(this);
			
			var i:int = 0, xx:Number = 0, yy:Number = 5, sizex:Number, sizey:Number, spacingx:Number;
			
			// Preview Button
			yy += 30; sizex = trayWidth * 0.9; sizey = 35;
			new GameButton(sizex, sizey).setText("filtermode_preview_btn").setOrigin(0.5).move(xx,yy).appendTo(this)
				.onButtonClick(_onPreviewButtonClicked);
			
			// Icon
			yy = 105;
			DisplayWrapper.wrap(new $FilterIcon(), this).toScale(1.2).move(xx, yy).appendTo(this);
			
			// Description
			yy = 155;
			new TextTranslated("filtermode_description").setOrigin(0.5, 0).move(xx, yy).appendTo(this).enableWordWrapUsingWidth(trayWidth - 5*2);
			
			// Share code textbox
			yy = trayHeight - 120
			_copyField = new FancyCopyField(trayWidth-20).appendTo(this).centerOrigin().move(xx, yy);
			
			// Trash Changes Button
			spacingx = 10;
			sizex = trayWidth/2 - (spacingx*3/2);
			sizey = 40;
			yy = trayHeight - sizey/2 - 12;
			xx = -trayWidth/2 + (spacingx+sizex/2);
			new DeleteButton(sizex, sizey).setImage(new $Trash(), 0.6).setOrigin(0.5).move(xx, yy).appendTo(this)
				.on(MouseEvent.CLICK, function(e):void{ addChild(_trashConfirmScreen) });
				
			_trashConfirmScreen = new TrashConfirmScreen().move(xx, yy)
				.on(TrashConfirmScreen.CONFIRM, function(e):void{ dispatchEvent(new FewfEvent(EVENT_RESET_FILTERING)); })
				.on(Event.CLOSE, function(e):void{ _trashConfirmScreen.removeSelf(); });
			
			// Stop Filtering Button
			yy = trayHeight - sizey/2 - 12;
			xx = trayWidth/2 - (sizex/2+spacingx);
			new GameButton(sizex, sizey).setImage(new $WhiteX()).setOrigin(0.5).move(xx, yy).appendTo(this)
				.on(MouseEvent.CLICK, function(e):void{ dispatchEvent(new FewfEvent(EVENT_STOP_FILTERING)); });
		}
		public function move(pX:Number, pY:Number) : FilterSelectionModeInfoAside { x = pX; y = pY; return this; }
		public function appendTo(pParent:Sprite): FilterSelectionModeInfoAside { pParent.addChild(this); return this; }
		public function on(type:String, listener:Function): FilterSelectionModeInfoAside { this.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): FilterSelectionModeInfoAside { this.removeEventListener(type, listener); return this; }
		
		public function update() : void {
			var code:String = ShareCodeFilteringData.generateShareCode();
			if(!code) {
				code = ShareCodeFilteringData.getShareCodeCache();
				ShareCodeFilteringData.parseShareCode(code);
			}
			_copyField.text = code || '...';
		}
		
		/****************************
		* Private
		*****************************/
		private function _onPreviewButtonClicked(e:Event) : void {
			dispatchEvent(new FewfEvent(EVENT_PREVIEW_ENABLED));
		}
	}
}

import app.ui.buttons.GameButton;
class DeleteButton extends GameButton
{
		public function DeleteButton(pWidth:Number, pHeight:Number) {
			super(pWidth, pHeight);
			_bg.radius = 5;
		}
		/****************************
		* Render
		*****************************/
		override protected function _renderUp() : void {
			_bg.draw3d(0xDD0000, 0x780f11);
		}
		
		override protected function _renderDown() : void {
			_renderOver();
		}
		
		override protected function _renderOver() : void {
			_bg.draw3d(0xFF0000, 0x780f11);
		}
		
		override protected function _renderOut() : void {
			_renderUp();
		}
}