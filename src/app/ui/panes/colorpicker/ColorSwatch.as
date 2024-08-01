package app.ui.panes.colorpicker
{
	import app.ui.buttons.ScaleButton;
	import com.fewfre.events.FewfEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;

	public class ColorSwatch extends Sprite
	{
		// Constants
		// Main Events
		public static const BUTTON_CLICK:String = "button_click";
		public static const ENTER_PRESSED:String = "enter_pressed";
		public static const USER_MODIFIED_TEXT:String = "user_modified_text";
		// Side Events
		public static const LOCK_TOGGLED:String = "lock_toggled"; // FewfEvent<{ locked:bool }>
		public static const HISTORY_CLICKED:String = "history_clicked";
		public static const SHOW_PREVIEW:String = "show_preview";
		public static const HIDE_PREVIEW:String = "hide_preview";
		
		private static const SWATCH_SIZE:Number = 18;
		private static const TEXT_WIDTH:Number = 56;
		
		// Storage
		private var _swatch:Sprite;
		private var _swatchBorder:Sprite;
		private var _text:TextField;
		private var _textBorder:Sprite;
		private var _selected:Boolean=false;
		
		private var _historyBtn:ScaleButton;
		private var _lockIcon:ScaleButton;
		private var _locked:Boolean = false;
		
		// Properties
		public function get color():uint { return int("0x" + _text.text); }
		public function set color(pColor:uint) : void {
			_drawSwatch(pColor);
			_text.text = pColor.toString(16);
			padCodeIfNeeded();
		}
		public function get locked():Boolean { return _locked; }
		
		// Constructor
		public function ColorSwatch() {
			super();
			_swatch = addChild(new Sprite()) as Sprite;
			_swatch.x = 5;
			_swatch.buttonMode = true;
			_drawSwatch(0);
			_swatch.addEventListener(MouseEvent.CLICK, _onSwatchClicked);
			// Color preview signal (invert color) - desktop
			_swatch.addEventListener(MouseEvent.MOUSE_OVER, function(){ dispatchEvent(new Event(SHOW_PREVIEW)); });
			_swatch.addEventListener(MouseEvent.MOUSE_OUT, function(){ dispatchEvent(new Event(HIDE_PREVIEW)); });
			// Color preview signal (invert color) - mobile
			_swatch.addEventListener(MouseEvent.MOUSE_DOWN, function(){ dispatchEvent(new Event(SHOW_PREVIEW)); });
			_swatch.addEventListener(MouseEvent.MOUSE_UP, function(){ dispatchEvent(new Event(HIDE_PREVIEW)); });
			
			_swatchBorder = addChild(new Sprite()) as Sprite; _swatchBorder.x = 5;
			
			_text = addChild(new TextField()) as TextField;
			_text.defaultTextFormat = new TextFormat("Verdana", 11, 0xc2c2da);
			_text.x = _swatch.x + SWATCH_SIZE+2 + 6 + 3;
			_text.y = 1;
			_text.height = SWATCH_SIZE;
			_text.width = TEXT_WIDTH;
			_text.type = TextFieldType.INPUT;
			_text.text = "000000";
			_text.maxChars = 6;
			_text.restrict = "0-9a-f";
			_text.addEventListener(KeyboardEvent.KEY_UP, _onTextInputKeyUp);
			_text.addEventListener(KeyboardEvent.KEY_DOWN, _onPreventTextInputEatingArrowKeys);
			_text.addEventListener(MouseEvent.CLICK, _onSwatchClicked);
			
			_textBorder = addChild(new Sprite()) as Sprite; _textBorder.x = _swatchBorder.x + SWATCH_SIZE+2 + 6;
			
			var bttnIcon:Sprite = _createInvisibleHitboxWithIcon(SWATCH_SIZE*1.65, new $UndoArrow());
			_historyBtn = ScaleButton.withObject(bttnIcon, 0.5).move(100, SWATCH_SIZE*0.5+1.5).appendTo(this)
				.on(MouseEvent.CLICK, _onHistoryClicked) as ScaleButton
			_historyBtn.visible = false;
			
			bttnIcon = _createInvisibleHitboxWithIcon(SWATCH_SIZE*2, new $Lock());
			_lockIcon = ScaleButton.withObject(bttnIcon).appendTo(this).on(MouseEvent.CLICK, _onLockClicked) as ScaleButton
			unlock();
			
			_updateBorders();
		}
		public function move(pX:Number, pY:Number) : ColorSwatch { x = pX; y = pY; return this; }
		public function appendTo(pParent:Sprite): ColorSwatch { pParent.addChild(this); return this; }
		public function on(type:String, listener:Function): ColorSwatch { this.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): ColorSwatch { this.removeEventListener(type, listener); return this; }

		private function _onTextInputKeyUp(e:KeyboardEvent) : void {
			dispatchEvent(new Event(USER_MODIFIED_TEXT));
			_drawSwatch(color);
			
			if(e.charCode == 13) {
				dispatchEvent(new Event(ENTER_PRESSED));
			}
		}
		private function _onPreventTextInputEatingArrowKeys(e:KeyboardEvent) : void {
			// These key events are used to change between different swatches by parent
			if(e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN) {
				_text.stage.focus = null;
				e.stopImmediatePropagation();
				dispatchEvent(e.clone());
			}
		}
		private function _onSwatchClicked(pEvent:MouseEvent) : void {
			dispatchEvent(new Event(BUTTON_CLICK));
		}

		public function select() : void {
			if(_selected) { return; }
			_selected = true;
			_updateBorders();
		}

		public function unselect() : void {
			_selected = false;
			_updateBorders();
		}
		
		private function _drawSwatch(pColor:uint) : void {
			_swatch.graphics.clear();
			_swatch.graphics.beginFill(pColor);
			_swatch.graphics.drawRoundRect(1, 1, SWATCH_SIZE, SWATCH_SIZE, 5);
			_swatch.graphics.endFill();
		}
		
		private function _updateBorders() : void {
			// Draw border around swatch
			_swatchBorder.graphics.clear();
			if(_selected) {
				_swatchBorder.graphics.lineStyle(0.5, 0x888888);
				_swatchBorder.graphics.drawRoundRect(-1.5, -1.5, SWATCH_SIZE+2+3, SWATCH_SIZE+2+3, 5);
			}
			_swatchBorder.graphics.lineStyle(1.5, 0);
			_swatchBorder.graphics.drawRoundRect(0, 0, SWATCH_SIZE+2, SWATCH_SIZE+2, 5);
			
			// Draw border around input
			_textBorder.graphics.clear();
			if(_selected) {
				_textBorder.graphics.lineStyle(0.5, 0x888888);
				_textBorder.graphics.drawRoundRect(-1.5, -1.5, TEXT_WIDTH+2+3, SWATCH_SIZE+2+3, 5);
			}
			_textBorder.graphics.lineStyle(1.5, 0);
			_textBorder.graphics.drawRoundRect(0, 0, TEXT_WIDTH+2, SWATCH_SIZE+2, 5);
		}
		
		public function showHistoryButton() : void { _historyBtn.visible = true; }
		public function hideHistoryButton() : void { _historyBtn.visible = false; }
		
		public function lock() : void {
			_lockIcon.alpha = 0.7;
			_lockIcon.setScale(0.65);
			_lockIcon.x = _swatch.x + SWATCH_SIZE*0.5 + 0.5 + 1;
			_lockIcon.y = _swatch.y + SWATCH_SIZE*0.5 + 0.5;
			_locked = true;
		}
		
		public function unlock() : void {
			_lockIcon.alpha = 0.5;
			_lockIcon.setScale(0.5);
			_lockIcon.x = -1;
			_lockIcon.y = SWATCH_SIZE*0.5;
			_locked = false;
		}
		
		public function padCodeIfNeeded() : void {
			var s:String = _text.text, pad:int = 6;
			for(;s.length<pad;s='0'+s);
			_text.text = s;
		}
		
		private function _createInvisibleHitboxWithIcon(pSize:Number, pIcon:Sprite) : Sprite {
			var tHitbox:Sprite = new Sprite();
			tHitbox.graphics.beginFill(0, 0);
			tHitbox.graphics.drawRect(-pSize*0.5, -pSize*0.5, pSize, pSize);
			tHitbox.graphics.endFill();
			tHitbox.addChild(pIcon);
			return tHitbox;
		}
		
		///////////////////////
		// Private
		///////////////////////
		private function _onHistoryClicked(e:Event) : void { dispatchEvent(new Event(HISTORY_CLICKED)); }
		private function _onLockClicked(e:Event) : void {
			_locked ? unlock() : lock(); // Update state
			dispatchEvent(new FewfEvent(LOCK_TOGGLED, { locked:_locked })); // Send event with new state
		}
	}
}
