package com.piterwilson.utils 
{
	import com.paulcoyle.utils.colour.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	public class ColorPicker extends flash.display.MovieClip
	{
		public static const COLOR_PICKED:String="colorpicker_pick";
		
		internal var _newColorSprite:Sprite;
		internal var _oldColorSprite:Sprite;
		internal var _colorGradSprite:Sprite;
		internal var _colorCursor:Sprite;
		internal var _matr:flash.geom.Matrix;
		internal var _swatchWidth:Number=25;
		internal var mouseDownInsideColorGrad:Boolean=false;
		internal var _fType:String="linear";
		internal var _sprMethod:String="pad";
		internal var _handle:Sprite;
		internal var _ratios:*;
		internal var _alphas:*;
		internal var _colors:Array;
		internal var _height:Number;
		internal var _width:Number;
		internal var _colorHueTarget:Number;
		internal var _hueBitmapData:flash.display.BitmapData;
		internal var _colorHueControlBar:Sprite;
		internal var _blackWhiteSprite:Sprite;
		internal var _colorSprite:Sprite;
		internal var _rads:Number;
		
		public function ColorPicker() {
			super();
			this._width = 270;
			this._height = 270;
			this.setupColorHueControlBar();
			this._colorCursor = new Sprite();
			this._colorGradSprite = new Sprite();
			this._colorSprite = new Sprite();
			this._blackWhiteSprite = new Sprite();
			this._newColorSprite = new Sprite();
			this._oldColorSprite = new Sprite();
			this._newColorSprite.x = 290;
			this._newColorSprite.y = 40;
			this._newColorSprite.graphics.beginFill(0, 1);
			this._newColorSprite.graphics.drawRect(0, 0, this._swatchWidth, 135);
			this._newColorSprite.graphics.endFill();
			addChild(this._newColorSprite);
			this._oldColorSprite.x = 290;
			this._oldColorSprite.y = 175;
			this._oldColorSprite.graphics.beginFill(0, 1);
			this._oldColorSprite.graphics.drawRect(0, 0, this._swatchWidth, 135);
			this._oldColorSprite.graphics.endFill();
			addChild(this._oldColorSprite);
			addChild(this._colorGradSprite);
			this._colorGradSprite.y = 40;
			this._colorGradSprite.x = 10;
			this._colorGradSprite.graphics.beginFill(268435455, 1);
			this._colorGradSprite.graphics.drawRect(0, 0, this._width, this._height);
			this._colorGradSprite.graphics.endFill();
			this._colorGradSprite.addEventListener(MouseEvent.MOUSE_DOWN, this.colorGradSpriteMouseDown);
			if (stage) {
				this.onAddedToStage(null);
			} else {
				addEventListener(flash.events.Event.ADDED_TO_STAGE, this.onAddedToStage);
			}
			this._colorGradSprite.addChild(this._colorSprite);
			this._colorSprite.y = 0;
			this._colorSprite.x = 0;
			this._colorGradSprite.addChild(this._blackWhiteSprite);
			this._blackWhiteSprite.y = 0;
			this._blackWhiteSprite.x = 0;
			this._colors = [0, 0];
			this._alphas = [0, 1];
			this._ratios = [0, 255];
			this._colorCursor.graphics.lineStyle(2, 0, 1);
			this._colorCursor.graphics.drawCircle(0, 0, 6);
			this._colorCursor.graphics.lineStyle(2, 16777215, 1);
			this._colorCursor.graphics.drawCircle(0, 0, 5);
			this._colorGradSprite.addChild(this._colorCursor);
			var loc1:*=this._blackWhiteSprite.graphics;
			this._matr = new flash.geom.Matrix();
			this._matr.createGradientBox(this._width, this._height, Math.PI / 2, 0, 0);
			loc1.beginGradientFill(this._fType, this._colors, this._alphas, this._ratios, this._matr, this._sprMethod);
			loc1.drawRect(0, 0, this._width, this._height);
			this.redrawBigGradient();
		}

		internal function colorGradSpriteMouseDown(arg1:MouseEvent):void {
			this.mouseDownInsideColorGrad = true;
			this.setCursorXY(this._colorGradSprite.mouseX, this._colorGradSprite.mouseY);
			this.setNewColor(this.getColor());
		}

		internal function setCursorXY(pX:Number, pY:Number):void {
			var tX:Number=pX, tY:Number = pY;
			if (tX < 0) { tX = 0; }
			if (tY < 0) { tY = 0; }
			if (tX > this._width) { tX = this._width; }
			if (tY > this._height) { tY = this._height; }
			this._colorCursor.x = tX;
			this._colorCursor.y = tY;
		}

		public function setCursor(color:uint):void {
			var loc2:*=com.piterwilson.utils.ColorMathUtil.hexToHsv(color);
			var loc3:*=360 * 0.75;
			if (loc2[0] > 0) 
			{
				loc3 = Math.ceil(loc2[0] * 0.75);
			}
			if (loc3 >= this._width) 
			{
				loc3 = (this._width - 1);
			}
			this._handle.x = loc3 + 10;
			this._colorHueTarget = this._hueBitmapData.getPixel(loc3, 0);
			this.redrawBigGradient();
			var loc4:*=this._width * loc2[1] * 0.01;
			var loc5:*=this._height - this._height * loc2[2] * 0.01;
			this.setCursorXY(loc4, loc5);
			this._newColorSprite.graphics.beginFill(color, 1);
			this._newColorSprite.graphics.drawRect(0, 0, this._swatchWidth, 135);
			this._newColorSprite.graphics.endFill();
			this._oldColorSprite.graphics.beginFill(color, 1);
			this._oldColorSprite.graphics.drawRect(0, 0, this._swatchWidth, 135);
			this._oldColorSprite.graphics.endFill();
			this.setNewColor(color, false);
		}

		internal function onAddedToStage(e:Event):void {
			if (hasEventListener(Event.ADDED_TO_STAGE)) {
				removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
			}
			stage.addEventListener(MouseEvent.MOUSE_MOVE, this.colorGradSpriteMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, this.colorGradSpriteMouseUp);
		}

		internal function redrawBigGradient(arg1:Boolean=false):void {
			this._ratios = [0, 255];
			this._matr = new flash.geom.Matrix();
			this._matr.createGradientBox(this._width, this._height, 0, 0, 0);
			this._colorSprite.graphics.clear();
			this._colors = [this._colorHueTarget, this._colorHueTarget];
			this._colorSprite.graphics.beginGradientFill(this._fType, this._colors, this._alphas, this._ratios, this._matr, this._sprMethod);
			this._colorSprite.graphics.drawRect(0, 0, this._width, this._height);
			if (arg1) {
				this.setNewColor(this.getColor());
			}
		}

		internal function getColor():uint {
			var loc1:*=com.piterwilson.utils.ColorMathUtil.hexToHsv(this._colorHueTarget);
			var tMouseX:Number=this._colorCursor.x;
			var tMouseY:Number=this._colorCursor.y;
			if (tMouseX < 0) { tMouseX = 0; }
			if (tMouseY < 0) { tMouseY = 0; }
			if (tMouseX > this._width) { tMouseX = this._width; }
			if (tMouseY > this._height) { tMouseY = this._height; }
			var loc4:*=loc1[0];
			var loc5:*=tMouseX / this._width * 100;
			var loc6:*=(this._height - tMouseY) / this._height * 100;
			return com.piterwilson.utils.ColorMathUtil.hsvToHex(loc4, loc5, loc6);
		}

		internal function setNewColor(pColor:uint, pTriggerEvent:Boolean=true):void {
			this._newColorSprite.graphics.clear();
			this._newColorSprite.graphics.beginFill(pColor, 1);
			this._newColorSprite.graphics.drawRect(0, 0, this._swatchWidth, 135);
			this._newColorSprite.graphics.endFill();
			if(pTriggerEvent) dispatchEvent(new flash.events.DataEvent(COLOR_PICKED, false, false, pColor.toString()));
		}

		internal function colorPickerHandleMotion(arg1:MouseEvent):void {
			if (this._colorHueControlBar.mouseX >= 0 && this._colorHueControlBar.mouseX <= this._width) {
				this._handle.x = mouseX;
				this._colorHueTarget = this._hueBitmapData.getPixel(this._colorHueControlBar.mouseX, 0);
				this.redrawBigGradient(true);
				this._oldColorSprite.graphics.beginFill(this.getColor(), 1);
				this._oldColorSprite.graphics.drawRect(0, 0, this._swatchWidth, 135);
				this._oldColorSprite.graphics.endFill();
			}
		}

		internal function stopColorPickerHandleMotion(arg1:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.colorPickerHandleMotion);
			stage.removeEventListener(MouseEvent.MOUSE_UP, this.stopColorPickerHandleMotion);
			this._colorGradSprite.addEventListener(MouseEvent.MOUSE_MOVE, this.colorGradSpriteMouseMove);
		}

		internal function startColorPickerHandleMotionHue(arg1:MouseEvent):void {
			startColorPickerHandleMotion(null);
			colorPickerHandleMotion(null);
		}
		
		internal function startColorPickerHandleMotionHandle(arg1:MouseEvent):void {
			startColorPickerHandleMotion(null);
		}
		
		internal function startColorPickerHandleMotion(arg1:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_MOVE, this.colorPickerHandleMotion);
			stage.addEventListener(MouseEvent.MOUSE_UP, this.stopColorPickerHandleMotion);
			this._colorGradSprite.removeEventListener(MouseEvent.MOUSE_MOVE, this.colorGradSpriteMouseMove);
		}

		internal function setupColorHueControlBar():void {
			this._handle = new ColorPickerHandle();
			this._colorHueControlBar = new Sprite();
			this._hueBitmapData = new flash.display.BitmapData(this._width, 1);
			var loc1:*=20;
			this._rads = 2 * Math.PI / this._width;
			var loc2:*=0;
			while (loc2 < this._width) {
				this._colorHueControlBar.graphics.beginFill(com.paulcoyle.utils.colour.AngularColour.angle_to_colour(this._rads * loc2), 1);
				this._colorHueControlBar.graphics.drawRect(loc2, 0, 1, loc1);
				++loc2;
			}
			this._hueBitmapData.draw(this._colorHueControlBar);
			this._colorHueTarget = this._hueBitmapData.getPixel(0, 0);
			addChild(this._colorHueControlBar);
			addChild(this._handle);
			this._colorHueControlBar.x = 10;
			this._colorHueControlBar.y = 10;
			this._colorHueControlBar.addEventListener(MouseEvent.MOUSE_DOWN, this.startColorPickerHandleMotionHue);
			this._handle.x = 10;
			this._handle.y = 10;
			this._handle.buttonMode = true;
			this._handle.useHandCursor = true;
			this._handle.addEventListener(MouseEvent.MOUSE_DOWN, this.startColorPickerHandleMotionHandle);
		}

		internal function colorGradSpriteMouseMove(e:MouseEvent):void {
			if (e.buttonDown && this.mouseDownInsideColorGrad) {
				this.setCursorXY(this._colorGradSprite.mouseX, this._colorGradSprite.mouseY);
				this.setNewColor(this.getColor());
			}
		}

		internal function colorGradSpriteMouseUp(e:MouseEvent):void {
			this._oldColorSprite.graphics.beginFill(this.getColor(), 1);
			this._oldColorSprite.graphics.drawRect(0, 0, this._swatchWidth, 135);
			this._oldColorSprite.graphics.endFill();
			this.mouseDownInsideColorGrad = false;
		}
	}
}
