package GUI 
{
	import flash.display.*;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.text.*;
	
	public class ColorSwatch extends Sprite
	{
		// Storage
		var _swatch:Sprite;
		var _border:Sprite;
		
		var Text:flash.text.TextField;
		
		public var selected:Boolean=false;
		
		// Constants
		public static const BUTTON_CLICK:String="button_click";
		public static const ENTER_PRESSED:String="enter_pressed";
		
		// Constructor
		public function ColorSwatch()
		{
			var format:flash.text.TextFormat;

			var loc1:*;
			format = null;
			super();
			this.Text = new TextField();
			format = new TextFormat("Verdana", 11, 12763866);
			this.Text.x = 30;
			this.Text.y = 0;
			this.Text.border = true;
			this.Text.defaultTextFormat = format;
			this.Text.height = 18;
			this.Text.width = 60;
			this.Text.type = "input";
			this.Text.text = "000000";
			this.Text.maxChars = 6;
			this.Text.restrict = "0-9a-f";
			addChild(this.Text);
			this.Text.addEventListener(flash.events.KeyboardEvent.KEY_UP, this.textInputOnKeyUp);
			this._swatch = new Sprite();
			this._swatch.graphics.beginFill(0);
			this._swatch.graphics.drawRoundRect(1, 1, 18, 18, 5);
			this._swatch.graphics.endFill();
			addChild(this._swatch);
			this._swatch.buttonMode = true;
			this._swatch.addEventListener(flash.events.MouseEvent.CLICK, function ():*
			{
				dispatchEvent(new flash.events.Event(BUTTON_CLICK));
				return;
			})
			this._border = new Sprite();
			this._border.graphics.lineStyle(1.5, 0);
			this._border.graphics.drawRoundRect(0, 0, 20, 20, 5);
			addChild(this._border);
			return;
		}

		public function get TextValue():String
		{
			return this.Text.text;
		}

		public function set Value(arg1:uint):*
		{
			this._swatch.graphics.clear();
			this._swatch.graphics.beginFill(arg1);
			this._swatch.graphics.drawRoundRect(1, 1, 18, 18, 5);
			this._swatch.graphics.endFill();
			this.Text.text = arg1.toString(16);
			return;
		}

		function textInputOnKeyUp(arg1:flash.events.KeyboardEvent):*
		{
			if (arg1.charCode == 13) 
			{
				dispatchEvent(new flash.events.Event(ENTER_PRESSED));
			}
			return;
		}

		public function select():*
		{
			if(this.selected) { return; }
			
			this.selected = true;
			this._border.graphics.clear();
			this._border.graphics.lineStyle(0.5, 8947848);
			this._border.graphics.drawRoundRect(-1.5, -1.5, 23, 23, 5);
			this._border.graphics.lineStyle(1.5, 0);
			this._border.graphics.drawRoundRect(0, 0, 20, 20, 5);
			return;
		}

		public function unselect():*
		{
			this.selected = false;
			this._border.graphics.clear();
			this._border.graphics.lineStyle(1.5, 0);
			this._border.graphics.drawRoundRect(0, 0, 20, 20, 5);
			return;
		}
	}
}
