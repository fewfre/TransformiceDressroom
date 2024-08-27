package app.ui.buttons
{
	import app.ui.*;
	import com.fewfre.display.ButtonBase;
	import com.fewfre.display.TextTranslated;
	import com.fewfre.utils.FewfDisplayUtils;
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.*;
	import com.fewfre.display.TextBase;
	
	public class SpriteButton extends GameButton
	{
		// Storage
		public var id:int;
		
		// Constructor
		// pData = { x:Number, y:Number, (width:Number, height:Number OR size:Number), ?obj:DisplayObject, ?obj_scale:Number, ?id:int, ?text:String, ?origin:Number, ?originX:Number, ?originY:Number }
		public function SpriteButton(pData:Object)
		{
			super(pData);
			if(pData.id) { id = pData.id; }
			
			if(pData.text) { setText(pData.text); }
			if(pData.obj) {
				if(pData.obj_scale == "auto") {
					setImage(pData.obj);
				} else {
					ChangeImage(pData.obj);
					if(pData.obj_scale) {
						_image.scaleX = pData.obj_scale ? pData.obj_scale : 0.75;
						_image.scaleY = pData.obj_scale ? pData.obj_scale : 0.75;
					}
				}
			}
		}

		public function ChangeImage(pMC:DisplayObject) : GameButton {
			var tScale:Number = 1;
			if(_image != null) { tScale = _image.scaleX; removeChild(_image); }
			_image = addChild( pMC );
			_image.x = this.Width * (0.5 - _bg.originX);
			_image.y = this.Height * (0.5 - _bg.originY);
			_image.scaleX = _image.scaleY = tScale;
			return this;
		}
		
		public override function setText(pKey:String, params:Object = null) : GameButton {
			params = params || {};
			params.size = params.size || 11;
			return super.setText(pKey, params);
		}
		public override function setTextUntranslated(pText:String, params:Object = null) : GameButton {
			params = params || {};
			params.size = params.size || 11;
			return super.setTextUntranslated(pText, params);
		}

		
		/////////////////////////////
		// Static
		/////////////////////////////
		public static function withObject(pObj:DisplayObject, pScale:Object=null, pData:Object=null) : SpriteButton {
			pData = pData || {};
			pData.obj = pObj;
			pData.obj_scale = pScale;
			return new SpriteButton(pData);
		}
		
		public static function square(pSize:Number) : SpriteButton {
			return new SpriteButton({ size:pSize });
		}
		public static function rect(pWidth:Number, pHeight:Number) : SpriteButton {
			return new SpriteButton({ width:pWidth, height:pHeight });
		}
	}
}
