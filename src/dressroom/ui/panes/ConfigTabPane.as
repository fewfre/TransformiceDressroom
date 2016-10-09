package dressroom.ui.panes
{
	import com.fewfre.display.*;
	import com.fewfre.events.FewfEvent;
	import dressroom.data.*;
	import dressroom.ui.*;
	import dressroom.ui.buttons.*;
	import dressroom.world.elements.*;
	import fl.containers.*;
	import flash.display.*;
	import flash.events.*;
	
	public class ConfigTabPane extends TabPane
	{
		// Storage
		public var character:Character;
		
		public var button_hand		: PushButton;
		public var button_back		: PushButton;
		public var button_backHand	: PushButton;
		
		public var shamanButtons	: Array;
		public var shamanColorPickerButton	: ScaleButton;
		
		// Constructor
		public function ConfigTabPane(pCharacter:Character) {
			super();
			character = pCharacter;
			
			var i:int = 0, xx:Number = 15, yy:Number = 15, tButton:GameButton, sizex:Number, sizey:Number, spacingx:Number;
			
			// Shaman options
			sizex = 65; sizey = 50; spacingx = sizex + 10; xx = 15 - spacingx;
			
			shamanButtons = [];
			var icon = addItem(new $ShamFeather()); icon.x = (xx += spacingx) + sizex*0.5; icon.y = yy + sizey*0.5; icon.scaleX = icon.scaleY = 2;
			icon.addEventListener(MouseEvent.CLICK, _onNoShamanButtonClicked);
			shamanButtons.push(tButton = addItem(new PushButton({ x:xx += spacingx, y:yy, width:sizex, height:sizey, obj:new TextBase({ text:"Normal" }), id:SHAMAN_MODE.NORMAL })));
			shamanButtons.push(tButton = addItem(new PushButton({ x:xx += spacingx, y:yy, width:sizex, height:sizey, obj:new TextBase({ text:"Hard" }), id:SHAMAN_MODE.HARD })));
			shamanButtons.push(tButton = addItem(new PushButton({ x:xx += spacingx, y:yy, width:sizex, height:sizey, obj:new TextBase({ text:"Divine" }), id:SHAMAN_MODE.DIVINE })));
			_registerClickHandler(shamanButtons, _onShamanButtonClicked);
			
			addItem( shamanColorPickerButton = new ScaleButton({ x:xx += spacingx + sizex*0.5, y:yy + sizey*0.5, obj:new $ColorWheel() }) );
			
			// Line
			yy += sizey + 10;
			_drawLine(this, 5, yy, ConstantsApp.PANE_WIDTH);
			
			// Grid
			yy += 15; xx = 15;
			var grid:Grid = this.addItem( new Grid({ x:xx, y:yy, width:385, columns:5, margin:5 }) );

			this.button_hand = new PushButton({ width:grid.radius, height:grid.radius, obj:new Main.costumes.hand.itemClass(), obj_scale:1.5, id:i++ });
			grid.add(this.button_hand);
			
			this.button_back = new PushButton({ width:grid.radius, height:grid.radius, obj:new Main.costumes.fromage.itemClass(), obj_scale:1.5, id:i++ });
			grid.add(this.button_back);
			
			this.button_backHand = new PushButton({ width:grid.radius, height:grid.radius, obj:new Main.costumes.backHand.itemClass(), obj_scale:1.5, id:i++ });
			grid.add(this.button_backHand);
			
			yy += grid.Height + 10;
			
			UpdatePane();
		}
		
		private function _drawLine(pParent:DisplayObject, pX:Number, pY:Number, pWidth:Number) : void {
			var tLine:Shape = new Shape();
			tLine.x = pX;
			tLine.y = pY;
			pParent.addChild(tLine);
			
			tLine.graphics.lineStyle(1, 0x11181c, 1, true);
			tLine.graphics.moveTo(0, 0);
			tLine.graphics.lineTo(pWidth - 10, 0);
			
			tLine.graphics.lineStyle(1, 0x608599, 1, true);
			tLine.graphics.moveTo(0, 1);
			tLine.graphics.lineTo(pWidth - 10, 1);
		}
		
		/****************************
		* Public
		*****************************/
		
		
		/****************************
		* Private
		*****************************/
		
		
		/****************************
		* Events
		*****************************/
		private function _registerClickHandler(pArray:Array, pCallback:Function) : void {
			for(var i:int = 0; i < pArray.length; i++) {
				pArray[i].addEventListener(PushButton.STATE_CHANGED_BEFORE, pCallback);
			}
		}
		
		private function _onShamanButtonClicked(pEvent:Event) {
			_untoggle(shamanButtons, pEvent.target);
			Main.costumes.shamanMode = pEvent.target.id;
			if(pEvent.target.pushed) {
				Main.costumes.shamanMode = SHAMAN_MODE.OFF;
			}
			character.updatePose();
		}
		
		private function _onNoShamanButtonClicked(pEvent:Event) {
			_untoggle(shamanButtons);
			Main.costumes.shamanMode = SHAMAN_MODE.OFF;
			character.updatePose();
		}

		private function _untoggle(pList:Array, pButton:PushButton=null) : void {
			/*if (pButton != null && pButton.pushed) { return; }*/

			for(var i:int = 0; i < pList.length; i++) {
				if (pList[i].pushed && pList[i] != pButton) {
					pList[i].toggleOff();
				}
			}
		}
	}
}
