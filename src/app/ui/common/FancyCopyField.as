package app.ui.common
{
	import com.fewfre.utils.FewfDisplayUtils;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	import app.data.ConstantsApp;
	import com.fewfre.display.TextBase;
	import com.fewfre.display.RoundRectangle;

	public class FancyCopyField
	{
		// Constants
		private static const BG_COLOR : uint = ConstantsApp.COLOR_BUTTON_BLUE;//0x374151;//0xFFFFFF;
		private static const BORDER_COLOR : uint = 0x4b5563;//0x444444;
		private static const TEXT_COLOR : uint = TextBase.DEFAULT_COLOR;//0x9ca3af;//0x000000;
		
		// Storage
		private var _root			: Sprite;
		private var _tray			: RoundRectangle;
		private var _field			: TextField;
		private var _button			: CopyButton;
		
		// Properties
		public function get root() : Sprite { return _root; }
		public function set text(str:String) : void { _field.text = str; }
		
		// Constructor
		public function FancyCopyField(pWidth:Number) {
			_root = new Sprite();
			
			var padX:int = 10, padY:int = 8;
			var width:Number = pWidth, wInner:Number = width-padX*2;
			var height:Number = 38, hInner:Number = height-padY*2;
			_tray = new RoundRectangle(width, height).toRadius(8).drawSolid(BG_COLOR, BORDER_COLOR).appendTo(_root);
			var bsize:Number = 30, btnFieldGap:Number = 10;
			
			// Text field
			_field = _tray.addChild(new TextField()) as TextField;
			_field.type = TextFieldType.DYNAMIC;
			_field.multiline = false;
			_field.defaultTextFormat = new TextFormat(null, 16, TEXT_COLOR);
			_field.width = wInner - btnFieldGap - bsize;
			_field.height = hInner;
			_field.x = padX;
			_field.y = padY;
			
			// _field.addEventListener(MouseEvent.CLICK, function(pEvent:Event):void{
			// 	_field.setSelection(0, _field.text.length);
			// });
			
			// _tray.addEventListener(MouseEvent.ROLL_OUT, function(pEvent:Event):void{
			// 	_field.stage.focus = null; // Forces text field to unfocus
			// });
			
			// Copy button
			_button = new CopyButton({ size:bsize, origin:0.5 }).appendTo(_tray.root)
				.move(width - padX - bsize/2 + 2, height/2)
				.onButtonClick(_onCopyButtonClicked) as CopyButton;
			_button.changeIcon(true);
		}
		public function move(pX:Number, pY:Number) : FancyCopyField { _root.x = pX; _root.y = pY; return this; }
		public function appendTo(pParent:Sprite): FancyCopyField { pParent.addChild(_root); return this; }
		
		/////////////////////////////
		// Public
		/////////////////////////////
		public function centerOrigin() : FancyCopyField {
			FewfDisplayUtils.alignChildrenAroundAnchor(_root);
			return this;
		}
		
		/////////////////////////////
		// Events
		/////////////////////////////
		private function _onCopyButtonClicked(e:Event) : void {
			System.setClipboard(_field.text);
			_button.changeIcon(false).disable();
			setTimeout(function():void{ _button.changeIcon(true).enable(); }, 2000);
		}
	}
}

import app.ui.buttons.GameButton;
import flash.display.Sprite;
class CopyButton extends GameButton
{
	private var _icon:Sprite;
	private var _iconDefaultAlpha:Number = 1;
	
	public function CopyButton(pData) {
		super(pData);
		_bg.toRadius(8).drawSolid(0x1f2937, 0x1f2937);
		addChild(_icon = new Sprite());
	}
	
	/////////////////////////////
	// Render
	/////////////////////////////
	override protected function _renderOut() : void { _renderUp(); }
	override protected function _renderUp() : void {
		_bg.alpha = 0;
		if(_icon) _icon.alpha = _iconDefaultAlpha;
	}
	
	override protected function _renderDown() : void { _renderOver(); }
	override protected function _renderOver() : void {
		_bg.alpha = 1;
		if(_icon) _icon.alpha = 1;
	}
	
	override protected function _renderDisabled() : void {} // Don't have any visual change
	
	/////////////////////////////
	// Icon
	/////////////////////////////
	private function _newCopyIcon() : Sprite {
		var tIcon:Sprite = new $CopyIcon();
		tIcon.scaleX = tIcon.scaleY = 0.35;
		_iconDefaultAlpha = tIcon.alpha = 0.5;
		return tIcon;
	}
	
	private function _newCheckmarkIcon() : Sprite {
		var tIcon:Sprite = new $Yes();
		tIcon.scaleX = tIcon.scaleY = 0.5;
		_iconDefaultAlpha = tIcon.alpha = 0.8;
		return tIcon;
	}
	
	public function changeIcon(pCopyIcon:Boolean) : CopyButton {
		removeChild(_icon);
		addChild(_icon = pCopyIcon ? _newCopyIcon() : _newCheckmarkIcon());
		return this;
	}
}
