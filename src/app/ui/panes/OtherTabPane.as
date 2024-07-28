package app.ui.panes
{
	import com.fewfre.display.*;
	import com.fewfre.utils.FewfDisplayUtils;
	import com.fewfre.events.FewfEvent;
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import app.world.elements.*;
	import flash.display.*;
	import flash.events.*;
	import flash.display.MovieClip;
	import app.world.data.ItemData;
	import app.ui.panes.base.SidePane;
	
	public class OtherTabPane extends SidePane
	{
		// Storage
		public var character:Character;
		
		public var button_hand		: PushButton;
		public var button_backHand	: PushButton;
		public var buttons_back		: Vector.<PushButton>;
		
		public var shamanButtons	: Vector.<PushButton>;
		public var disableSkillsModeButton	: PushButton;
		public var shamanColorPickerButton	: ScaleButton;
		public var shamanColorBlueButton	: ColorButton;
		public var shamanColorPinkButton	: ColorButton;
		
		public var characterHead	: Character;
		public var webpButton		: GameButton;
		public var itemFilterButton	: SpriteButton;
		
		// Constructor
		public function OtherTabPane(pCharacter:Character) {
			super();
			character = pCharacter;
			
			var i:int = 0, xx:Number = 20, yy:Number = 20, tButton:GameButton, sizex:Number, sizey:Number, spacingx:Number;
			
			// Shaman options
			sizex = 80; sizey = 40; spacingx = sizex + 10; xx = 10 - spacingx;
			
			shamanButtons = new Vector.<PushButton>();
			DisplayWrapper.wrap(new $ShamFeather(), this).move((xx += spacingx) + sizex*0.5, yy + sizey*0.5).scale(2).on(MouseEvent.CLICK, _onNoShamanButtonClicked);
			xx -= 5;
			yy -= 10;
			shamanButtons.push(tButton = addChild(new PushButton({ x:xx += spacingx, y:yy, width:sizex, height:sizey, obj:new TextTranslated("btn_normal_mode"), id:ShamanMode.NORMAL.toInt() })) as PushButton);
			shamanButtons.push(tButton = addChild(new PushButton({ x:xx += spacingx, y:yy, width:sizex, height:sizey, obj:new TextTranslated("btn_hard_mode"), id:ShamanMode.HARD.toInt() })) as PushButton);
			shamanButtons.push(tButton = addChild(new PushButton({ x:xx += spacingx, y:yy, width:sizex, height:sizey, obj:new TextTranslated("btn_divine_mode"), id:ShamanMode.DIVINE.toInt() })) as PushButton);
			if(character.shamanMode != ShamanMode.OFF) {
				shamanButtons[character.shamanMode.toInt()-2].toggleOn();
			}
			_registerClickHandler(shamanButtons, _onShamanButtonClicked);
			
			disableSkillsModeButton = addChild(new PushButton({ x:10 + sizex*1.5 + spacingx - 180/2, y:yy + sizey + 5, width:180, height:20, obj:new TextTranslated("btn_no_skills_mode") })) as PushButton;
			if(character.disableSkillsMode) {
				disableSkillsModeButton.toggleOn();
			}
			disableSkillsModeButton.addEventListener(PushButton.STATE_CHANGED_AFTER, _onShamandisableSkillsModeButtonClicked);
			
			// Color buttons
			yy += 10;
			sizex = 80; sizey = 50;
			
			addChild( shamanColorPickerButton = new ScaleButton({ x:xx += spacingx + 30, y:yy + sizey*0.5 - 10, obj:new $ColorWheel() }) );
			
			sizex = 26; sizey = 18;
			
			addChild( shamanColorBlueButton = new ColorButton({ color:0x95D9D6, x:xx - (sizex*0.5+3), y:yy + sizey*0.5 + 35, width:sizex, height:sizey }) );
			addChild( shamanColorPinkButton = new ColorButton({ color:0xFCA6F1, x:xx + (sizex*0.5+3), y:yy + sizey*0.5 + 35, width:sizex, height:sizey }) );
			
			// Line
			yy += 50 + 10;
			addChild( GameAssets.createHorizontalRule(10, yy, ConstantsApp.PANE_WIDTH - 15) );
			
			// Grid
			yy += 15; xx = 20;
			var grid:Grid = new Grid(385, GameAssets.extraBack.length).setXY(xx,yy).appendTo(this);
			
			this.buttons_back = new Vector.<PushButton>();
			for each(var itemData:ItemData in GameAssets.extraBack) {
				var bttn:PushButton = new PushButton({ width:grid.cellSize, height:grid.cellSize, obj:new itemData.itemClass(), obj_scale:1.5, id:i++, data:{ id:itemData.id } });
				grid.add(bttn);
				this.buttons_back.push(bttn);
				if(character.getItemData(ItemType.BACK) && character.getItemData(ItemType.BACK).id == itemData.id) {
					bttn.toggleOn();
				}
			}

			yy = grid.y + grid.cellSize + 5;
			grid = new Grid(385, 5).setXY(xx,yy).appendTo(this);
			this.button_hand = new PushButton({ size:grid.cellSize, obj:new GameAssets.extraObjectWand.itemClass(), obj_scale:1.5, id:i++ });
			grid.add(this.button_hand);
			if(character.getItemData(ItemType.OBJECT)) { this.button_hand.toggleOn(); }
			
			this.button_backHand = new PushButton({ size:grid.cellSize, obj:new GameAssets.extraBackHand.itemClass(), obj_scale:1.5, id:i++ });
			grid.add(this.button_backHand);
			if(character.getItemData(ItemType.PAW_BACK)) { this.button_backHand.toggleOn(); }
			
			// Bottom buttons
			var saveHeadButton:GameButton = new GameButton({ x:353, y:315, width:70, height:70 }).appendTo(this) as GameButton;
			saveHeadButton.on(MouseEvent.CLICK, _onSaveMouseHeadClicked);
			characterHead = new Character(new <ItemData>[ GameAssets.defaultSkin, GameAssets.defaultPose ]);
			saveHeadButton.addChild(characterHead);
			
			if(ConstantsApp.ANIMATION_DOWNLOAD_ENABLED) {
				webpButton = new GameButton({ x:353-70-5, y:315, width:70, height:70 }).appendTo(this) as GameButton;
				webpButton.on(MouseEvent.CLICK, _onSaveAsWebpClicked);
				new TextBase('.webp', { x:35, y:35, origin:0.5, size:16 }).appendTo(webpButton);
			}
			
			itemFilterButton = SpriteButton.withObject(new $FilterIcon(), 0.85, { x:xx, y:315, width:70, height:70 }).appendTo(this) as SpriteButton;
		}
		
		/****************************
		* Public
		*****************************/
		
		public override function open() : void {
			super.open();
			
			_updateHead();
		}
		
		/****************************
		* Private
		*****************************/
		private function _updateHead() {
			// copy character data onto our copy
			for each(var tItemType in ItemType.LAYERING) {
				var data = character.getItemData(tItemType);
				if(data) characterHead.setItemData( data ); else characterHead.removeItem( tItemType );
			}
			characterHead.setItemData( character.getItemData(ItemType.POSE) );
			characterHead.scale = 1;
			
			// Cut the head off the poor mouse ;_;
			var pose = characterHead.outfit.pose;
			var partsToKeep:Array = ["Tete_", "Oeil_", "OeilVide_", "Oeil2_", "Oeil3_", "Oeil4_", "OreilleD_", "OreilleG_"];
			var tChild:DisplayObject = null;
			for(var i:int = pose.numChildren-1; i >= 0; i--) {
				tChild = pose.getChildAt(i);
				
				if(tChild.name && !partsToKeep.some(function(partName){ return tChild.name.indexOf(partName) == 0 })) {
					pose.removeChildAt(i);
				}
			}
			
			var btnSize = 70, size = 60;
			var tBounds = characterHead.getBounds(characterHead);
			var tOffset = tBounds.topLeft;
			FewfDisplayUtils.fitWithinBounds(characterHead, size, size, size, size);
			characterHead.x = btnSize / 2 - (tBounds.width / 2 + tOffset.x) * characterHead.scaleX;
			characterHead.y = btnSize / 2 - (tBounds.height / 2 + tOffset.y) * characterHead.scaleY;
		
		}
		
		/****************************
		* Events
		*****************************/
		private function _registerClickHandler(pList:Vector.<PushButton>, pCallback:Function) : void {
			for(var i:int = 0; i < pList.length; i++) {
				pList[i].addEventListener(PushButton.STATE_CHANGED_BEFORE, pCallback);
			}
		}
		
		private function _onShamanButtonClicked(pEvent:Event) {
			_untoggle(shamanButtons, pEvent.target as PushButton);
			character.shamanMode = ShamanMode.fromInt(pEvent.target.id);
			if(pEvent.target.pushed) {
				character.shamanMode = ShamanMode.OFF;
			}
			character.updatePose();
			_updateHead();
		}
		
		private function _onNoShamanButtonClicked(pEvent:Event) {
			_untoggle(shamanButtons);
			character.shamanMode = ShamanMode.OFF;
			character.updatePose();
			_updateHead();
		}
		
		private function _onShamandisableSkillsModeButtonClicked(pEvent:Event) {
			character.disableSkillsMode = (pEvent.target as PushButton).pushed;
			if(character.disableSkillsMode && character.shamanMode == ShamanMode.OFF) {
				character.shamanMode = ShamanMode.fromInt(shamanButtons[0].id);
				shamanButtons[0].toggleOn(false);
			}
			character.updatePose();
			_updateHead();
			
		}

		private function _untoggle(pList:Vector.<PushButton>, pButton:PushButton=null) : void {
			/*if (pButton != null && pButton.pushed) { return; }*/

			for(var i:int = 0; i < pList.length; i++) {
				if (pList[i].pushed && pList[i] != pButton) {
					pList[i].toggleOff();
				}
			}
			_updateHead();
		}
		
		public function updateButtonsBasedOnCurrentData() : void {
			for(var i:int = 0; i < shamanButtons.length; i++) {
				shamanButtons[i].toggleOff();
			}
			if(character.shamanMode != ShamanMode.OFF) {
				shamanButtons[character.shamanMode.toInt()-2].toggleOn(false);
			}
			disableSkillsModeButton.toggle(character.disableSkillsMode, false);
			
			button_hand.toggle(!!character.getItemData(ItemType.OBJECT), false);
			for each(var bttn:PushButton in buttons_back) {
				bttn.toggle(!!character.getItemData(ItemType.BACK) && character.getItemData(ItemType.BACK).id == bttn.data.id, false);
			}
			button_backHand.toggle(!!character.getItemData(ItemType.PAW_BACK), false);
			_updateHead();
		}
		
		private function _onSaveMouseHeadClicked(pEvent:Event) {
			FewfDisplayUtils.saveAsPNG(characterHead, 'mouse_head', character.outfit.scaleX);
		}
		
		private function _onSaveAsWebpClicked(e:Event) {
			webpButton.disable();
			FewfDisplayUtils.saveAsAnimatedGif(character.copy().outfit.pose, "character", this.character.outfit.scaleX, "webp", function(){
				webpButton.enable();
			});
		}
	}
}
