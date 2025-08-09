package app.ui.panes
{
	import app.data.*;
	import app.ui.buttons.*;
	import app.ui.panes.base.SidePane;
	import app.world.data.ItemData;
	import app.world.data.OutfitData;
	import app.world.elements.Character;
	import app.world.elements.Pose;
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
		public static const SHAMAN_MODE_CHANGED:String = "shaman_mode_changed"; // FewfEvent<{ shamanMode:ShamanMode }>
		public static const DISABLE_SKILLS_MODE_CHANGED:String = "disable_skills_mode_changed"; // FewfEvent<{ disableSkillsMode:Boolean }>
		public static const ITEM_TOGGLED:String = "item_toggled"; // FewfEvent<{ type:ItemType, itemData:ItemData|null }>
		public static const EYE_DROPPER_CLICKED:String = "eye_dropper_clicked"; // FewfEvent<{ itemData:ItemData }>
		public static const EMOJI_CLICKED:String = "emoji_clicked";
		public static const CHEESE_CLICKED:String = "cheese_clicked";
		public static const FILTER_MODE_CLICKED:String = "filter_mode_clicked";
		public static const SAVE_MOUSE_HEAD_CLICKED:String = "save_mouse_head_clicked";
		
		// Storage
		private var _character       : Character;
		
		private var _shamanButtons    : Vector.<PushButton>;
		private var _disableSkillsModeButton : PushButton;
		
		private var _frontHandButton  : PushButton;
		private var _backHandButton   : PushButton;
		private var _eyeDropperButton : SpriteButton;
		
		private var _mouseHeadButton  : GameButton;
		private var _mouseHead        : Pose;
		
		private var _tipsText         : TextTranslated;
		private static const TIPS     : Vector.<String> = new <String>["tip_worn_items", "tip_save_scale", "tip_arrow_keys"];
		private var _tipsIndex        : int = Math.floor(Math.random() * TIPS.length);
		
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
			_shamanButtons.push(PushButton.rect(sizex, sizey).setText("btn_normal_mode").setData({ shamanMode:ShamanMode.NORMAL }).appendTo(this) as PushButton);
			_shamanButtons.push(PushButton.rect(sizex, sizey).setText("btn_hard_mode").setData({ shamanMode:ShamanMode.HARD }).appendTo(this) as PushButton);
			_shamanButtons.push(PushButton.rect(sizex, sizey).setText("btn_divine_mode").setData({ shamanMode:ShamanMode.DIVINE }).appendTo(this) as PushButton);
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
			
			(_frontHandButton = PushButton.square(grid.cellSize)).setImage(new GameAssets.extraObjectWand.itemClass(), 1.5).setData({ itemData:GameAssets.extraObjectWand });
			_frontHandButton.onToggle(_onItemToggled)
				.on(MouseEvent.MOUSE_OVER, _onItemHoverInShowEyeDropper)
				.on(MouseEvent.MOUSE_OUT, _onItemHoverOutHideEyeDropper);
			grid.add(_frontHandButton);
			
			(_backHandButton = PushButton.square(grid.cellSize)).setImage(new GameAssets.extraBackHand.itemClass(), 1.5).setData({ itemData:GameAssets.extraBackHand });
			_backHandButton.onToggle(_onItemToggled)
				.on(MouseEvent.MOUSE_OVER, _onItemHoverInShowEyeDropper)
				.on(MouseEvent.MOUSE_OUT, _onItemHoverOutHideEyeDropper);
			grid.add(_backHandButton);
			
			// Eye dropper button
			(_eyeDropperButton = SpriteButton.square(16)).setImage(new $EyeDropper(), 0.35).appendTo(this);
			_eyeDropperButton.onButtonClick(function():void { dispatchEvent(new FewfEvent(EYE_DROPPER_CLICKED, { itemData:_eyeDropperButton.data.itemData })); })
				.on(MouseEvent.MOUSE_OVER, function(e:Event){ _eyeDropperButton.enable().alpha = 1; })
				.on(MouseEvent.MOUSE_OUT, function(e:Event){ _eyeDropperButton.disable().alpha = 0; })
			_eyeDropperButton.disable().alpha = 0;
			
			/////////////////////////////
			// Tips
			/////////////////////////////
			yy += grid.cellSize + 70; sizex = ConstantsApp.PANE_WIDTH - 5*2;
			_tipsText = new TextTranslated("").moveT(ConstantsApp.PANE_WIDTH / 2+5, yy).appendToT(this);
			_tipsText.enableWordWrapUsingWidth(sizex);
			
			/////////////////////////////
			// Bottom Buttons
			/////////////////////////////
			// Left
			GameButton.square(70).setImage(new $FilterIcon(), 0.85).move(xx, 315).appendTo(this)
				.onButtonClick(function(e:Event):void{ dispatchEvent(new Event(FILTER_MODE_CLICKED)); });
			
			// Right
			// Save Head Image
			(_mouseHeadButton = GameButton.square(70))
				.setImage(_mouseHead = new Pose().applyOutfitData(new OutfitData().setItemDataVector(new <ItemData>[ GameAssets.defaultSkin, GameAssets.defaultPose ])), 3)
				.move(353, 315).appendTo(this)
				.onButtonClick(function():void{ dispatchEvent(new FewfEvent(SAVE_MOUSE_HEAD_CLICKED, _mouseHead)); });
			
			// Lastly, update state based on initial character state
			updateButtonsBasedOnCurrentData();
		}
		
		/****************************
		* Public
		*****************************/
		public override function open() : void {
			super.open();
			
			_updateHead(_character.outfitData);
			_tipsText.setText(TIPS[_tipsIndex = (_tipsIndex+1) % TIPS.length]);
		}
		
		public function updateButtonsBasedOnCurrentData() : void {
			var pOutfitData:OutfitData = _character.outfitData;
			
			// Update shaman area
			PushButton.untoggleAll(_shamanButtons);
			if(pOutfitData.shamanMode != ShamanMode.OFF) {
				_shamanButtons[_getIndexFromShamanMode(pOutfitData.shamanMode)].toggleOn(false);
			}
			_disableSkillsModeButton.toggle(pOutfitData.disableSkillsMode, false);
			
			// Update grids
			_frontHandButton.toggle(!!pOutfitData.getItemData(ItemType.OBJECT), false);
			_backHandButton.toggle(!!pOutfitData.getItemData(ItemType.PAW_BACK), false);
			
			// Update bottom area
			_updateHead(pOutfitData);
		}
		
		/****************************
		* Private
		*****************************/
		private function _getIndexFromShamanMode(pMode:ShamanMode) : int {
			return pMode.toInt()-2; // Modes in array goes from Normal (2) to Divine (4), so -1 will correctly 0 index it
		}
		
		private function _updateHead(pOutfitData:OutfitData) {
			_mouseHead = new Pose().applyOutfitData(pOutfitData);
			
			// Cut the head off the poor mouse ;_;
			var pose = _mouseHead.pose;
			var partsToKeep:Array = ["Tete_", "Oeil_", "OeilVide_", "Oeil2_", "Oeil3_", "Oeil4_", "OreilleD_", "OreilleG_"];
			var tChild:DisplayObject = null;
			for(var i:int = pose.numChildren-1; i >= 0; i--) {
				tChild = pose.getChildAt(i);
				
				if(tChild.name && !partsToKeep.some(function(partName){ return tChild.name.indexOf(partName) == 0 })) {
					pose.removeChildAt(i);
				}
			}
			
			_mouseHeadButton.setImage(_mouseHead, 3);
		}
		
		/****************************
		* Events
		*****************************/
		private function _onShamanButtonClicked(e:FewfEvent) {
			dispatchEvent(new FewfEvent(SHAMAN_MODE_CHANGED, { shamanMode: (e.target as PushButton).pushed ? e.data.shamanMode : ShamanMode.OFF }));
			// This event should trigger `updateButtonsBasedOnCurrentData` which will properly update the UI
		}
		
		private function _onNoShamanButtonClicked(pEvent:Event) {
			dispatchEvent(new FewfEvent(SHAMAN_MODE_CHANGED, { shamanMode: ShamanMode.OFF }));
			dispatchEvent(new FewfEvent(DISABLE_SKILLS_MODE_CHANGED, { disableSkillsMode: false }));
			// This event should trigger `updateButtonsBasedOnCurrentData` which will properly update the UI
		}
		
		private function _onShamanDisableSkillsModeButtonClicked(e:Event) {
			dispatchEvent(new FewfEvent(DISABLE_SKILLS_MODE_CHANGED, { disableSkillsMode: (e.target as PushButton).pushed }));
			// This event should trigger `updateButtonsBasedOnCurrentData` which will properly update the UI
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
	}
}
