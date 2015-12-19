package 
{
	import com.piterwilson.utils.*;
	import flash.display.*;
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.events.*;
	import flash.geom.*;
	
	public class TheMouse extends flash.display.Sprite
	{
		// Storage
		public var mouse:Fur;
		
		internal var hat:MovieClip;
		internal var eye:MovieClip;
		internal var ear:MovieClip;
		internal var neck:MovieClip;
		internal var mouth:MovieClip;
		internal var hair:MovieClip;
		internal var tail:MovieClip;
		internal var paw:MovieClip;
		internal var back:MovieClip;
		internal var backPaw:MovieClip;
		
		internal var offset:int=0;

		public var isSetAsShaman:Boolean=false;
		
		// Constants
		/*public static var HAT_INDEX:int=0;
		public static var EYE_INDEX:int=1;
		public static var EAR_INDEX:int=2;
		public static var MOUTH_INDEX:int=3;
		public static var NECK_INDEX:int=4;
		public static var HAIR_INDEX:int=5;
		public static var TAIL_INDEX:int=6;*/
		
		// Constructor
		public function TheMouse(hat_item:MovieClip, eye_item:MovieClip, ear_item:MovieClip, mouth_item:MovieClip, neck_item:MovieClip, hair_item:MovieClip, tail_item:MovieClip, paw_item:MovieClip, back_item:MovieClip, backPaw_item:MovieClip, hide_hat:Boolean=true, hide_eye:Boolean=true, hide_ear:Boolean=true, hide_mouth:Boolean=true, hide_neck:Boolean=true)
		{
			super();
			
			this.hat = hat_item;
			this.hat.alpha = hide_hat ? 0 : 1;
			
			this.eye = eye_item;
			this.eye.alpha = hide_eye ? 0 : 1;
			
			this.neck = neck_item;
			this.neck.scaleX = 0.99;
			this.neck.scaleY = 0.99;
			this.neck.alpha = hide_neck ? 0 : 1;
				
			this.mouth = mouth_item;
			this.mouth.alpha = hide_mouth ? 0 : 1;
			
			this.ear = ear_item;
			this.ear.alpha = hide_ear ? 0 : 1;
			
			this.hair = hair_item;
			this.hair.alpha = 0;
			
			this.tail = tail_item;
			this.tail.alpha = 0;
			
			// Specials
			this.back = back_item;
			this.back.alpha = 0;
			
			this.paw = paw_item;
			this.paw.alpha = 0;
			
			this.backPaw = backPaw_item;
			this.backPaw.alpha = 0;
			
			// Add mouse and items to mouse.
			_addFur(ConstantsApp.DEFAULT_SKIN_INDEX, 6);
		}

		public function Update() : void {
			this.tail.x = this.mouse.tailOrnament.x + 4;//getChildAt(5).x + 4;
			this.tail.y = this.mouse.tailOrnament.y - 8;//getChildAt(5).y - 8;
			this.hair.x = this.mouse.face.x;//getChildAt(10).x;
			this.hair.y = this.mouse.face.y;//getChildAt(10).y;
			this.hat.x = this.mouse.face.x;//getChildAt(10).x;
			this.hat.y = this.mouse.face.y;//getChildAt(10).y;
			this.eye.x = this.mouse.eyes.x;//getChildAt(11).x;
			this.eye.y = this.mouse.eyes.y;//getChildAt(11).y;
			this.neck.x = this.mouse.face.x - 0.2;//getChildAt(10).x - 0.2;
			this.neck.y = this.mouse.face.y;//getChildAt(10).y;
			this.mouth.x = this.mouse.face.x;//getChildAt(10).x;
			this.mouth.y = this.mouse.face.y;//getChildAt(10).y;
			this.ear.x = this.mouse.earClose.x;//getChildAt(18).x;
			this.ear.y = this.mouse.earClose.y;//getChildAt(18).y;
			this.back.x = this.mouse.body.x - 21;
			this.back.y = this.mouse.body.y - 20.5;
			this.paw.x = this.mouse.armClose.x;
			this.paw.y = this.mouse.armClose.y + 3.3;
			this.paw.rotation = 18;
			this.backPaw.x = this.mouse.armFar.x + 3.5;
			this.backPaw.y = this.mouse.armFar.y + 1.3;
		}

		public function getItemFromIndex(pType:String):MovieClip
		{
			switch(pType) {
				case ItemType.HAT	: return this.hat; break;
				case ItemType.EYES	: return this.eye; break;
				case ItemType.EARS	: return this.ear; break;
				case ItemType.MOUTH	: return this.mouth; break;
				case ItemType.NECK	: return this.neck; break;
				case ItemType.HAIR	: return this.hair; break;
				case ItemType.TAIL	: return this.tail; break;
				case ItemType.FUR	: return this.mouse; break;
				default: trace("[TheMouse](getItemFromIndex) Unknown Type: "+pType); break;
			}
		}

		public function colorDefault(pType:String) : void {
			var tItem:MovieClip = this.getItemFromIndex(pType);
			if (tItem == null) { return; }
			
			var tChild:DisplayObject;
			var tHex:int=0;
			var tR:*=0;
			var tG:*=0;
			var tB:*=0;
			
			var i:int = 0;
			while (i < tItem.numChildren) {
				tChild = tItem.getChildAt(i)
				if (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7) 
				{
					tHex = int("0x" + tChild.name.substr(tChild.name.indexOf("_") + 1, 6));
					tR = tHex >> 16 & 255;
					tG = tHex >> 8 & 255;
					tB = tHex & 255;
					tChild.transform.colorTransform = new flash.geom.ColorTransform(tR / 128, tG / 128, tB / 128);
				}
				i++;
			}
			return;
		}

		public function getColors(pType:String) : Array {
			var tItem:MovieClip = this.getItemFromIndex(pType);
			if (tItem == null) { return new Array(); }
			
			var tChild:DisplayObject;
			var tTransform:*=null;
			var tArray:*=new Array();
			
			var i:int=0;
			while (i < tItem.numChildren) {
				tChild = tItem.getChildAt(i);
				if (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7) {
					tTransform = tChild.transform.colorTransform;
					tArray[tChild.name.charAt(7)] = com.piterwilson.utils.ColorMathUtil.RGBToHex(tTransform.redMultiplier * 128, tTransform.greenMultiplier * 128, tTransform.blueMultiplier * 128);
				}
				i++;
			}
			return tArray;
		}

		public function colorItem(pType:String, arg2:int, pColor:String) : void {
			var tItem:MovieClip = this.getItemFromIndex(pType);
			if (tItem == null) { return; }
			
			var tChild:DisplayObject;
			var tHex:int=0;
			var tR:*=0;
			var tG:*=0;
			var tB:*=0;
			
			var i:int=0;
			while (i < tItem.numChildren) {
				tChild = tItem.getChildAt(i);
				if (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7) {
					if (arg2 == tChild.name.charAt(7)) {
						tHex = int("0x" + pColor);
						tR = tHex >> 16 & 255;
						tG = tHex >> 8 & 255;
						tB = tHex & 255;
						tChild.transform.colorTransform = new flash.geom.ColorTransform(tR / 128, tG / 128, tB / 128);
					}
				}
				i++;
			}
		}

		public function setAnimStatique():void
		{
			return;
		}

		public function setHat(pMC:MovieClip, pRemove:Boolean=true) : void {
			if(pRemove) { this.mouse.removeChild(this.hat); }
			_insertAbove(this.hat = pMC, this.tail);
		}

		public function setEyes(pMC:MovieClip, pRemove:Boolean=true) : void {
			if(pRemove) { this.mouse.removeChild(this.eye); }
			_insertAbove(this.eye = pMC, this.hat);
		}

		public function setEar(pMC:MovieClip, pRemove:Boolean=true) : void {
			if(pRemove) { this.mouse.removeChild(this.ear); }
			_insertAbove(this.ear = pMC, this.mouse.earClose);
		}

		public function setMouth(pMC:MovieClip, pRemove:Boolean=true) : void {
			if(pRemove) { this.mouse.removeChild(this.mouth); }
			_insertAbove(this.mouth = pMC, this.hair);
		}

		public function setNeck(pMC:MovieClip, pRemove:Boolean=true) : void {
			if(pRemove) { this.mouse.removeChild(this.neck); }
			_insertAbove(this.neck = pMC, this.mouse.eyes);
		}

		public function setHair(pMC:MovieClip, pRemove:Boolean=true) : void {
			if(pRemove) { this.mouse.removeChild(this.hair); }
			_insertAbove(this.hair = pMC, this.neck);
		}

		public function setTailItem(pMC:MovieClip, pRemove:Boolean=true) : void {
			if(pRemove) { this.mouse.removeChild(this.tail); }
			_insertAbove(this.tail = pMC, this.mouth);
		}

		public function setBack(pMC:MovieClip, pRemove:Boolean=true) : void {
			if(pRemove) { this.mouse.removeChild(this.back); }
			_insertAbove(this.back = pMC, this.mouse.tailOrnament);
		}

		public function setPaw(pMC:MovieClip, pRemove:Boolean=true) : void {
			if(pRemove) { this.mouse.removeChild(this.paw); }
			_insertBehind(this.paw = pMC, this.mouse.armClose);
		}

		public function setBackPaw(pMC:MovieClip, pRemove:Boolean=true) : void {
			if(pRemove) { this.mouse.removeChild(this.backPaw); }
			_insertBehind(this.backPaw = pMC, this.mouse.armFar);
		}

		public function switchFurs(pFurIndex:int) : void {
			var oldScale:Number = this.mouse.scaleX;
			
			// Remove fur
			this.mouse.removeChild(this.eye);
			this.mouse.removeChild(this.neck);
			this.mouse.removeChild(this.mouth);
			this.mouse.removeChild(this.hat);
			this.mouse.removeChild(this.tail);
			this.mouse.removeChild(this.ear);
			
			this.mouse.removeChild(this.back);
			this.mouse.removeChild(this.paw);
			this.mouse.removeChild(this.backPaw);
			removeChild(this.mouse);
			this.mouse = null;
			
			// Add new fur
			_addFur(pFurIndex, oldScale);
		}
		
		private function _addFur(pNum:int, pScale:Number) : void {
			this.mouse = new Fur(Main.costumes.furs[pNum]);
			this.mouse.x = 180;
			this.mouse.y = 300;
			this.mouse.scaleX = pScale;
			this.mouse.scaleY = pScale;
			this.mouse.buttonMode = true;
			this.mouse.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, function ():*
			{
				mouse.startDrag();
				return;
			})
			this.mouse.addEventListener(flash.events.MouseEvent.MOUSE_UP, function ():*
			{
				mouse.stopDrag();
				return;
			})
			addChild(this.mouse);
			
			// Add items
			setNeck(this.neck, false);
			setHair(this.hair, false);
			setMouth(this.mouth, false);
			setTailItem(this.tail, false);
			setHat(this.hat, false);
			setEyes(this.eye, false);
			setEar(this.ear, false);
			
			setBack(this.back, false);
			setPaw(this.paw, false);
			setBackPaw(this.backPaw, false);
		}
		
		private function _insertBehind(pMC:MovieClip, pMC2:MovieClip) : void {
			this.mouse.addChildAt(pMC, this.mouse.getChildIndex(pMC2));
		}
		
		private function _insertAbove(pMC:MovieClip, pMC2:MovieClip) : void {
			this.mouse.addChildAt(pMC, this.mouse.getChildIndex(pMC2)+1);
		}
		
		public function addItem(pType:String, pItem:MovieClip) : void {
			switch(pType) {
				case ItemType.HAT	: setHat(pItem); break;
				case ItemType.EYES	: setEyes(pItem); break;
				case ItemType.EARS	: setEar(pItem); break;
				case ItemType.MOUTH	: setMouth(pItem); break;
				case ItemType.NECK	: setNeck(pItem); break;
				case ItemType.HAIR	: setHair(pItem); break;
				case ItemType.TAIL	: setTailItem(pItem); break;
				// case FUR	: 
				case ItemType.PAW	: setPaw(pItem); break;
				case ItemType.BACK	: setBack(pItem); break;
				case ItemType.PAW_BACK	: setBackPaw(pItem); break;
				default: trace("[TheMouse](addItem) Unknown Type: "+pType); break;
			}
		}
		
		public function removeItem(pType:String) : void {
			switch(pType) {
				case ItemType.HAT	: this.hat.alpha = 0; break;
				case ItemType.EYES	: this.eye.alpha = 0; break;
				case ItemType.EARS	: this.ear.alpha = 0; break;
				case ItemType.MOUTH	: this.mouth.alpha = 0; break;
				case ItemType.NECK	: this.neck.alpha = 0; break;
				case ItemType.HAIR	: this.hair.alpha = 0; break;
				case ItemType.TAIL	: this.tail.alpha = 0; break;
				// case FUR	: 
				case ItemType.PAW	: this.paw.alpha = 0; break;
				case ItemType.BACK	: this.back.alpha = 0; break;
				case ItemType.PAW_BACK	: this.backPaw.alpha = 0; break;
				default: trace("[TheMouse](removeItem) Unknown Type: "+pType); break;
			}
		}
	}
}
