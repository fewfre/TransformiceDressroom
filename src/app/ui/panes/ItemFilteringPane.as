package app.ui.panes
{
	import app.data.ConstantsApp;
	import app.data.ShareCodeFilteringData;
	import app.ui.buttons.SpriteButton;
	import app.ui.common.FancyCopyField;
	import app.ui.panes.base.SidePane;
	import com.fewfre.display.TextTranslated;
	import com.fewfre.events.FewfEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class ItemFilteringPane extends SidePane
	{
		// Constants
		public static const EVENT_PREVIEW_ENABLED : String = "event_preview_enabled";
		public static const EVENT_STOP_FILTERING : String = "event_stop_filtering";
		public static const EVENT_RESET_FILTERING : String = "event_reset_filtering";
		
		// Storage
		private var _copyField : FancyCopyField;
		
		// Constructor
		public function ItemFilteringPane() {
			super();
			var i:int = 0, xx:Number = 0, yy:Number = 5, sizex:Number, sizey:Number, spacingx:Number;
			
			// Preview Button
			xx = 5+ConstantsApp.PANE_WIDTH/2; yy += 50; sizex = ConstantsApp.PANE_WIDTH * 0.9; sizey = 35;
			new SpriteButton({ width:sizex, height:sizey, origin:0.5, text:"filtermode_preview_btn" })
				.move(xx,yy).appendTo(this).onButtonClick(_onPreviewButtonClicked);
			
			// Description
			yy = 125; xx = 5+2 + 5;
			new TextTranslated("filtermode_description", { x:xx, y:yy, origin:0 }).appendToT(this).enableWordWrapUsingWidth(ConstantsApp.PANE_WIDTH - 5*2);
			
			// Share code textbox
			xx = 5+ConstantsApp.PANE_WIDTH/2; yy = ConstantsApp.SHOP_HEIGHT - 165
			_copyField = new FancyCopyField(ConstantsApp.PANE_WIDTH-20).appendTo(this).centerOrigin().move(xx, yy);
			
			// Stop Filtering Button
			sizex = ConstantsApp.PANE_WIDTH/2 - 10;
			sizey = 40;
			yy = ConstantsApp.SHOP_HEIGHT - sizey/2 - 15;
			xx = 10+sizex/2;
			new SpriteButton({ x:xx, y:yy, origin:0.5, width:sizex, height:sizey, obj:new $WhiteX() }).appendTo(this)
				.on(MouseEvent.CLICK, function(e):void{ dispatchEvent(new FewfEvent(EVENT_STOP_FILTERING)); });
			
			// Trash Changes Button
			yy = ConstantsApp.SHOP_HEIGHT - sizey/2 - 15;
			xx += sizex/2+10+sizex/2;
			new DeleteButton({ x:xx, y:yy, origin:0.5, width:sizex, height:sizey, obj:new $Trash(), obj_scale:0.6 }).appendTo(this)
				.on(MouseEvent.CLICK, function(e):void{ dispatchEvent(new FewfEvent(EVENT_RESET_FILTERING)); });
		}
		
		public override function open() : void {
			super.open();
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

import app.ui.buttons.SpriteButton;
class DeleteButton extends SpriteButton
{
		public function DeleteButton(pData) {
			super(pData);
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