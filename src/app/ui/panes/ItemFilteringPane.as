package app.ui.panes
{
	import com.fewfre.display.*;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.utils.Fewf;
	import com.fewfre.utils.AssetManager;
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import app.ui.common.*;
	import app.ui.screens.LoaderDisplay;
	import app.ui.screens.LoadingSpinner;
	import app.world.elements.*;
	import flash.display.*;
	import flash.events.*;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormatAlign;
	import flash.display.MovieClip;
	import app.world.data.ItemData;
	import fl.transitions.Tween;
	import fl.transitions.easing.Elastic;
	import flash.system.System;
	import app.ui.panes.base.SidePane;
	
	public class ItemFilteringPane extends SidePane
	{
		// Constants
		public static const EVENT_PREVIEW_ENABLED : String = "event_preview_enabled";
		public static const EVENT_STOP_FILTERING : String = "event_stop_filtering";
		public static const EVENT_RESET_FILTERING : String = "event_reset_filtering";
		
		// Storage
		private var _textCopyField		: TextField;
		private var _textCopiedMessage	: TextBase;
		private var _textCopyTween		: Tween;
		
		// Constructor
		public function ItemFilteringPane() {
			super();
			var i:int = 0, xx:Number = 0, yy:Number = 5, tButton:GameButton, sizex:Number, sizey:Number, spacingx:Number;
			
			// Preview Button
			xx = ConstantsApp.PANE_WIDTH/2; yy += 50; sizex = ConstantsApp.PANE_WIDTH * 0.9; sizey = 35;
			new SpriteButton({ width:sizex, height:sizey, origin:0.5, text:"filtermode_preview_btn" })
				.setXY(xx,yy).appendTo(this).on(ButtonBase.CLICK, _onPreviewButtonClicked);
			
			// Description
			yy = 125; xx = 2 + 5;
			var desc:TextBase = new TextBase({ text:"filtermode_description", x:xx, y:yy, origin:0 });
			desc.field.width = ConstantsApp.PANE_WIDTH - 5*2;
			desc.field.wordWrap = true;
			addChild(desc);
			
			// Share code textbox
			_addNewCopySection(ConstantsApp.APP_HEIGHT - 165);
			
			// Stop Filtering Button
			sizex = ConstantsApp.PANE_WIDTH/2 - 10;
			sizey = 40;
			yy = ConstantsApp.APP_HEIGHT - sizey/2 - 15;
			xx = 10+sizex/2;
			var stopBtn = new SpriteButton({ x:xx, y:yy, origin:0.5, width:sizex, height:sizey, obj:new $WhiteX() });
			stopBtn.addEventListener(MouseEvent.CLICK, function(e):void{ dispatchEvent(new FewfEvent(EVENT_STOP_FILTERING)); });
			addChild(stopBtn);
			
			// Trash Changes Button
			yy = ConstantsApp.APP_HEIGHT - sizey/2 - 15;
			xx += sizex/2+10+sizex/2;
			var stopBtn = new DeleteButton({ x:xx, y:yy, origin:0.5, width:sizex, height:sizey, obj:new $Trash(), obj_scale:0.6 });
			stopBtn.addEventListener(MouseEvent.CLICK, function(e):void{ dispatchEvent(new FewfEvent(EVENT_RESET_FILTERING)); });
			addChild(stopBtn);
		}
		
		public override function open() : void {
			super.open();	
			_textCopyField.text = ShareCodeFilteringData.generateShareCode();
		}
		
		/****************************
		* Copy Section
		*****************************/
		private function _addNewCopySection(pY:Number) : void {
			var tWidth:Number = ConstantsApp.PANE_WIDTH-20;
			_textCopyField = _newCopyInput({ x:ConstantsApp.PANE_WIDTH/2, y:pY, width:tWidth }, this);
			
			var tCopyButton:SpriteButton = addChild(new SpriteButton({ x:-_textCopyField.x+tWidth*0.5-(80/2)+13, y:pY+39, text:"share_copy", width:80, height:25, origin:0.5 })) as SpriteButton;
			tCopyButton.addEventListener(ButtonBase.CLICK, function():void{ _copyToClipboard(); });
			
			_textCopiedMessage = addChild(new TextBase({ text:"share_link_copied", size:15, originX:1, x:tCopyButton.x - tCopyButton.Width/2 - 10, y:tCopyButton.y-2, alpha:0 })) as TextBase;
			
		}
		
		private function _clearCopiedMessages() : void {
			if(_textCopyTween) _textCopyTween.stop();
			_textCopiedMessage.alpha = 0;
		}
		
		private function _copyToClipboard() : void {
			_clearCopiedMessages();
			_textCopyField.setSelection(0, _textCopyField.text.length)
			System.setClipboard(_textCopyField.text);
			_textCopiedMessage.alpha = 0;
			if(_textCopyTween) _textCopyTween.start(); else _textCopyTween = new Tween(_textCopiedMessage, "alpha", Elastic.easeOut, 0, 1, 1, true);
		}
		
		
		private function _newCopyInput(pData:Object, pParent:Sprite) : TextField {
			var tTFWidth:Number = pData.width, tTFHeight:Number = 18, tTFPaddingX:Number = 5, tTFPaddingY:Number = 5;
			var tTextBackground:RoundedRectangle = new RoundedRectangle({ x:pData.x, y:pData.y, width:tTFWidth+tTFPaddingX*2, height:tTFHeight+tTFPaddingY*2, origin:0.5 })
				.appendTo(pParent).draw(0xFFFFFF, 7, 0x444444);
			
			var tTextField:TextField = tTextBackground.addChild(new TextField()) as TextField;
			tTextField.type = TextFieldType.DYNAMIC;
			tTextField.multiline = false;
			tTextField.width = tTFWidth;
			tTextField.height = tTFHeight;
			tTextField.x = tTFPaddingX - tTextBackground.Width*0.5;
			tTextField.y = tTFPaddingY - tTextBackground.Height*0.5;
			tTextField.addEventListener(MouseEvent.CLICK, function(pEvent:Event):void{
				_clearCopiedMessages();
				tTextField.setSelection(0, tTextField.text.length);
			});
			return tTextField;
		}
		
		/****************************
		* Private
		*****************************/
		private function _onPreviewButtonClicked(e:Event) : void {
			dispatchEvent(new FewfEvent(EVENT_PREVIEW_ENABLED));
		}

		private function _untoggle(pList:Vector.<PushButton>, pButton:PushButton=null) : void {
			// if (pButton != null && pButton.pushed) { return; }

			for(var i:int = 0; i < pList.length; i++) {
				if (pList[i].pushed && pList[i] != pButton) {
					pList[i].toggleOff();
				}
			}
		}
	}
}

import app.ui.buttons.SpriteButton;
class DeleteButton extends SpriteButton
{
		public function DeleteButton(pData) {
			super(pData);
		}
		/****************************
		* Render
		*****************************/
		override protected function _renderUp() : void {
			_bg.draw(0xDD0000, 5, 0x780f11);
		}
		
		override protected function _renderDown() : void {
			_renderOver();
		}
		
		override protected function _renderOver() : void {
			_bg.draw(0xFF0000, 5, 0x780f11);
		}
		
		override protected function _renderOut() : void {
			_renderUp();
		}
}