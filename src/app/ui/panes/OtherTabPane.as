package app.ui.panes
{
	import app.data.*;
	import app.ui.buttons.*;
	import app.ui.panes.base.SidePane;
	import app.world.data.ItemData;
	import app.world.elements.Character;
	import com.fewfre.display.*;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.utils.FewfDisplayUtils;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class OtherTabPane extends SidePane
	{
		// Constants
		public static const CUSTOM_SHAMAN_COLOR_CLICKED:String = "custom_shaman_color_clicked";
		public static const SHAMAN_COLOR_PICKED:String = "shaman_color_picked"; // FewfEvent<int>
		public static const ITEM_TOGGLED:String = "item_toggled"; // FewfEvent<{ type:ItemType, itemData:ItemData|null }>
		public static const FILTER_MODE_CLICKED:String = "filter_mode_clicked";
		public static const EMOJI_CLICKED:String = "emoji_clicked";
		public static const CHEESE_CLICKED:String = "cheese_clicked";
		public static const EYE_DROPPER_CLICKED:String = "eye_dropper_clicked"; // FewfEvent<{ itemData:ItemData }>
		
		// Storage
		private var _character       : Character;
		
		private var _frontHandButton  : PushButton;
		private var _backHandButton   : PushButton;
		private var _backItemButtons  : Vector.<PushButton>;
		private var _eyeDropperButton : SpriteButton;
		
		private var _shamanButtons   : Vector.<PushButton>;
		private var _disableSkillsModeButton : PushButton;
		
		private var _characterHead   : Character;
		
		// Constructor
		public function OtherTabPane(pCharacter:Character) {
			super();
			_character = pCharacter;
			
			var xx:Number = 20, yy:Number = 20, sizex:Number, sizey:Number, spacingx:Number;
			
			/////////////////////////////
			// Shaman Section
			/////////////////////////////
			var shamanAreaHeight:Number = 82
			// Shaman options
			sizex = 80; sizey = 40; spacingx = sizex + 10; xx = 10 - spacingx;
			
			DisplayWrapper.wrap(new $ShamFeather(), this).move((xx += spacingx) + sizex*0.5, shamanAreaHeight/2+3).toScale(2).on(MouseEvent.CLICK, _onNoShamanButtonClicked).asSprite.buttonMode = true;
			
			_shamanButtons = new Vector.<PushButton>();
			xx -= 5; yy -= 11;
			_shamanButtons.push(PushButton.rect(sizex, sizey).setText("btn_normal_mode").setData({ mode:ShamanMode.NORMAL }).appendTo(this) as PushButton);
			_shamanButtons.push(PushButton.rect(sizex, sizey).setText("btn_hard_mode").setData({ mode:ShamanMode.HARD }).appendTo(this) as PushButton);
			_shamanButtons.push(PushButton.rect(sizex, sizey).setText("btn_divine_mode").setData({ mode:ShamanMode.DIVINE }).appendTo(this) as PushButton);
			for each(var btn:PushButton in _shamanButtons) {
				btn.move(xx += spacingx, yy);
				btn.onToggle(_onShamanButtonClicked);
			}
			
			_disableSkillsModeButton = PushButton.rect(180, 20).setText("btn_no_skills_mode") as PushButton;
			_disableSkillsModeButton.move(10 + sizex*1.5 + spacingx - 180/2, yy + sizey + 7).appendTo(this);
			_disableSkillsModeButton.onToggle(_onShamanDisableSkillsModeButtonClicked);
			
			// Color buttons
			yy = shamanAreaHeight/2 - 24;
			sizex = 80; sizey = 50;
			ScaleButton.withObject(new $ColorWheel()).move(xx += spacingx + 30, yy + sizey*0.5 - 10).appendTo(this).onButtonClick(function(e):void{ dispatchEvent(new Event(CUSTOM_SHAMAN_COLOR_CLICKED)); });
			
			sizex = 26; sizey = 18;
			// Default Blue/Pink Shaman color buttons
			new ColorButton(0x95D9D6, sizex, sizey).move(xx - (sizex*0.5+3), yy + sizey*0.5 + 35).appendTo(this).onButtonClick(function(e:FewfEvent){ dispatchEvent(new FewfEvent(SHAMAN_COLOR_PICKED, e.data)); });
			new ColorButton(0xFCA6F1, sizex, sizey).move(xx + (sizex*0.5+3), yy + sizey*0.5 + 35).appendTo(this).onButtonClick(function(e:FewfEvent){ dispatchEvent(new FewfEvent(SHAMAN_COLOR_PICKED, e.data)); });
			
			// Line
			yy = shamanAreaHeight+2;
			GameAssets.createHorizontalRule(10, yy, ConstantsApp.PANE_WIDTH - 15).appendTo(this);
			
			/////////////////////////////
			// Item Section
			/////////////////////////////
			var itemsSectionFakeHalfWidth:Number = ConstantsApp.PANE_WIDTH/2 - 40;
			// Grid
			yy += 11; xx = 20;
			var grid:Grid = new Grid(itemsSectionFakeHalfWidth, 2).move(xx,yy).appendTo(this);
			
			grid.add(GameButton.square(grid.cellSize).setImage(GameAssets.getItemImage(GameAssets.extraBack[0])).appendTo(this)
				.onButtonClick(function(e:Event):void{ dispatchEvent(new Event(CHEESE_CLICKED)); }));
				
			grid.add(GameButton.square(grid.cellSize).setImage(GameAssets.getItemImage(GameAssets.emoji[0])).appendTo(this)
				.onButtonClick(function(e:Event):void{ dispatchEvent(new Event(EMOJI_CLICKED)); }));
			

			grid = new Grid(itemsSectionFakeHalfWidth, 2).move(ConstantsApp.PANE_WIDTH-14-itemsSectionFakeHalfWidth, yy).appendTo(this);
			
			_frontHandButton = new PushButton({ size:grid.cellSize, obj:new GameAssets.extraObjectWand.itemClass(), obj_scale:1.5, data:{ itemData:GameAssets.extraObjectWand } });
			_frontHandButton.onToggle(_onItemToggled)
				.on(MouseEvent.MOUSE_OVER, _onItemHoverInShowEyeDropper)
				.on(MouseEvent.MOUSE_OUT, _onItemHoverOutHideEyeDropper);
			grid.add(_frontHandButton);
			
			_backHandButton = new PushButton({ size:grid.cellSize, obj:new GameAssets.extraBackHand.itemClass(), obj_scale:1.5, data:{ itemData:GameAssets.extraBackHand } });
			_backHandButton.onToggle(_onItemToggled)
				.on(MouseEvent.MOUSE_OVER, _onItemHoverInShowEyeDropper)
				.on(MouseEvent.MOUSE_OUT, _onItemHoverOutHideEyeDropper);
			grid.add(_backHandButton);
			
			// Eye dropper button
			_eyeDropperButton = SpriteButton.withObject(new $EyeDropper(), 0.35, { size:16 }).appendTo(this) as SpriteButton;
			_eyeDropperButton.onButtonClick(function():void { dispatchEvent(new FewfEvent(EYE_DROPPER_CLICKED, { itemData:_eyeDropperButton.data.itemData })); })
				.on(MouseEvent.MOUSE_OVER, function(e:Event){ _eyeDropperButton.enable().alpha = 1; })
				.on(MouseEvent.MOUSE_OUT, function(e:Event){ _eyeDropperButton.disable().alpha = 0; })
			_eyeDropperButton.disable().alpha = 0;
			
			/////////////////////////////
			// Bottom Buttons
			/////////////////////////////
			// Left
			GameButton.square(70).setImage(new $FilterIcon(), 0.85).move(xx, 315).appendTo(this)
				.onButtonClick(function(e:Event):void{ dispatchEvent(new Event(FILTER_MODE_CLICKED)); });
			
			// Right
			// Save Head Image
			GameButton.square(70)
				.setImage(_characterHead = new Character(new <ItemData>[ GameAssets.defaultSkin, GameAssets.defaultPose ]))
				.move(353, 315).appendTo(this)
				.onButtonClick(_onSaveMouseHeadClicked);
			
			// Lastly, update state based on initial character state
			updateButtonsBasedOnCurrentData();
		}
		
		/****************************
		* Public
		*****************************/
		public override function open() : void {
			super.open();
			
			_updateHead();
		}
		
		public function updateButtonsBasedOnCurrentData() : void {
			for(var i:int = 0; i < _shamanButtons.length; i++) {
				_shamanButtons[i].toggleOff();
			}
			if(_character.shamanMode != ShamanMode.OFF) {
				_shamanButtons[_getIndexFromShamanMode(_character.shamanMode)].toggleOn(false);
			}
			_disableSkillsModeButton.toggle(_character.disableSkillsMode, false);
			
			for each(var bttn:PushButton in _backItemButtons) {
				bttn.toggle(!!_character.getItemData(ItemType.BACK) && _character.getItemData(ItemType.BACK).matches(bttn.data.itemData), false);
			}
			_frontHandButton.toggle(!!_character.getItemData(ItemType.OBJECT), false);
			_backHandButton.toggle(!!_character.getItemData(ItemType.PAW_BACK), false);
			_updateHead();
		}
		
		/****************************
		* Private
		*****************************/
		private function _getIndexFromShamanMode(pMode:ShamanMode) : int {
			return pMode.toInt()-2; // Modes in array goes from Normal (2) to Divine (4), so -1 will correctly 0 index it
		}
		
		private function _updateHead() {
			// copy character data onto our copy
			for each(var tItemType in ItemType.LAYERING) {
				var data:ItemData = _character.getItemData(tItemType);
				if(data) _characterHead.setItemData( data ); else _characterHead.removeItem( tItemType );
			}
			_characterHead.setItemData( _character.getItemData(ItemType.POSE) );
			_characterHead.scale = 1;
			
			// Cut the head off the poor mouse ;_;
			var pose = _characterHead.outfit.pose;
			var partsToKeep:Array = ["Tete_", "Oeil_", "OeilVide_", "Oeil2_", "Oeil3_", "Oeil4_", "OreilleD_", "OreilleG_"];
			var tChild:DisplayObject = null;
			for(var i:int = pose.numChildren-1; i >= 0; i--) {
				tChild = pose.getChildAt(i);
				
				if(tChild.name && !partsToKeep.some(function(partName){ return tChild.name.indexOf(partName) == 0 })) {
					pose.removeChildAt(i);
				}
			}
			
			// var bsize = 70, size = 60;
			// var tBounds = _characterHead.getBounds(_characterHead);
			// var tOffset = tBounds.topLeft;
			// FewfDisplayUtils.fitWithinBounds(_characterHead, size, size, size, size);
			// _characterHead.x = bsize / 2 - (tBounds.width / 2 + tOffset.x) * _characterHead.scaleX;
			// _characterHead.y = bsize / 2 - (tBounds.height / 2 + tOffset.y) * _characterHead.scaleY;
			
			var bsize = 70, size = 60;
			FewfDisplayUtils.fitWithinBounds(_characterHead, size, size, size, size);
			FewfDisplayUtils.alignChildrenAroundAnchor(_characterHead, 0.5);
			_characterHead.move(bsize/2, bsize/2);
		
		}
		
		/****************************
		* Events
		*****************************/
		private function _onShamanButtonClicked(e:FewfEvent) {
			var btn:PushButton = e.target as PushButton;
			_untoggle(_shamanButtons, btn);
			_character.shamanMode = !btn.pushed ? ShamanMode.OFF : e.data.mode as ShamanMode;
			_character.updatePose();
			_updateHead();
		}
		
		private function _onNoShamanButtonClicked(pEvent:Event) {
			_untoggle(_shamanButtons);
			_character.shamanMode = ShamanMode.OFF;
			_character.updatePose();
			_updateHead();
		}
		
		private function _onShamanDisableSkillsModeButtonClicked(e:Event) {
			_character.disableSkillsMode = (e.target as PushButton).pushed;
			if(_character.disableSkillsMode && _character.shamanMode == ShamanMode.OFF) {
				_character.shamanMode = _shamanButtons[0].data.mode as ShamanMode;
				_shamanButtons[0].toggleOn(false);
			}
			_character.updatePose();
			_updateHead();
			
		}
		
		private function _onItemHoverInShowEyeDropper(e:Event) : void {
			var tTargetButton:PushButton = e.target as PushButton;
			_eyeDropperButton.enable().alpha = 1;
			_eyeDropperButton.move(tTargetButton.parent.x + tTargetButton.x + tTargetButton.Width - _eyeDropperButton.Width, tTargetButton.parent.y + tTargetButton.y + 1);
			_eyeDropperButton.setData({ itemData: tTargetButton.data.itemData });
		}
		
		private function _onItemHoverOutHideEyeDropper(e:Event) : void {
			_eyeDropperButton.disable().alpha = 0;
		}
		
		private function _onItemToggled(e:FewfEvent) : void {
			var bttn:PushButton = e.target as PushButton, itemData:ItemData = e.data.itemData;
			dispatchEvent(new FewfEvent(ITEM_TOGGLED, { type:itemData.type, itemData:bttn.pushed ? itemData : null }));
		}

		private function _untoggle(pList:Vector.<PushButton>, pButton:PushButton=null) : void {
			PushButton.untoggleAll(pList, pButton);
			_updateHead();
		}
		
		private function _onSaveMouseHeadClicked(pEvent:Event) {
			FewfDisplayUtils.saveAsPNG(_characterHead, 'mouse_head', _character.outfit.scaleX);
		}
	}
}
