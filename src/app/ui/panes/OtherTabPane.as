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
		
		// Storage
		private var _character       : Character;
		
		private var _frontHandButton : PushButton;
		private var _backHandButton  : PushButton;
		private var _backItemButtons : Vector.<PushButton>;
		
		private var _shamanButtons   : Vector.<PushButton>;
		private var _disableSkillsModeButton : PushButton;
		
		private var _characterHead   : Character;
		private var _webpButton      : GameButton;
		
		// Constructor
		public function OtherTabPane(pCharacter:Character) {
			super();
			_character = pCharacter;
			
			var i:int = 0, xx:Number = 20, yy:Number = 20, sizex:Number, sizey:Number, spacingx:Number;
			
			/////////////////////////////
			// Shaman Section
			/////////////////////////////
			// Shaman options
			sizex = 80; sizey = 40; spacingx = sizex + 10; xx = 10 - spacingx;
			
			_shamanButtons = new Vector.<PushButton>();
			DisplayWrapper.wrap(new $ShamFeather(), this).move((xx += spacingx) + sizex*0.5, yy + sizey*0.5).scale(2).on(MouseEvent.CLICK, _onNoShamanButtonClicked).asSprite.buttonMode = true;
			xx -= 5; yy -= 10;
			_shamanButtons.push(new PushButton({ x:xx += spacingx, y:yy, width:sizex, height:sizey, obj:new TextTranslated("btn_normal_mode"), id:ShamanMode.NORMAL.toInt() }).appendTo(this) as PushButton);
			_shamanButtons.push(new PushButton({ x:xx += spacingx, y:yy, width:sizex, height:sizey, obj:new TextTranslated("btn_hard_mode"), id:ShamanMode.HARD.toInt() }).appendTo(this) as PushButton);
			_shamanButtons.push(new PushButton({ x:xx += spacingx, y:yy, width:sizex, height:sizey, obj:new TextTranslated("btn_divine_mode"), id:ShamanMode.DIVINE.toInt() }).appendTo(this) as PushButton);
			if(_character.shamanMode != ShamanMode.OFF) {
				_shamanButtons[_character.shamanMode.toInt()-2].toggleOn();
			}
			_registerClickHandler(_shamanButtons, _onShamanButtonClicked);
			
			_disableSkillsModeButton = new PushButton({ x:10 + sizex*1.5 + spacingx - 180/2, y:yy + sizey + 5, width:180, height:20, obj:new TextTranslated("btn_no_skills_mode") }).appendTo(this) as PushButton;
			if(_character.disableSkillsMode) {
				_disableSkillsModeButton.toggleOn();
			}
			_disableSkillsModeButton.addEventListener(PushButton.TOGGLE, _onShamanDisableSkillsModeButtonClicked);
			
			// Color buttons
			yy += 10;
			sizex = 80; sizey = 50;
			ScaleButton.withObject(new $ColorWheel()).setXY(xx += spacingx + 30, yy + sizey*0.5 - 10).appendTo(this).on(ButtonBase.CLICK, function(e):void{ dispatchEvent(new Event(CUSTOM_SHAMAN_COLOR_CLICKED)); });
			
			sizex = 26; sizey = 18;
			// Default Blue/Pink Shaman color buttons
			new ColorButton({ color:0x95D9D6, x:xx - (sizex*0.5+3), y:yy + sizey*0.5 + 35, width:sizex, height:sizey }).appendTo(this).on(ButtonBase.CLICK, function(e:FewfEvent){ dispatchEvent(new FewfEvent(SHAMAN_COLOR_PICKED, e.data)); });
			new ColorButton({ color:0xFCA6F1, x:xx + (sizex*0.5+3), y:yy + sizey*0.5 + 35, width:sizex, height:sizey }).appendTo(this).on(ButtonBase.CLICK, function(e:FewfEvent){ dispatchEvent(new FewfEvent(SHAMAN_COLOR_PICKED, e.data)); });
			
			// Line
			yy += 50 + 10;
			GameAssets.createHorizontalRule(10, yy, ConstantsApp.PANE_WIDTH - 15).appendTo(this);
			
			/////////////////////////////
			// Item Section
			/////////////////////////////
			// Grid
			yy += 15; xx = 20;
			var grid:Grid = new Grid(385, GameAssets.extraBack.length).setXY(xx,yy).appendTo(this);
			
			_backItemButtons = new Vector.<PushButton>();
			for each(var itemData:ItemData in GameAssets.extraBack) {
				var bttn:PushButton = new PushButton({ size:grid.cellSize, obj:new itemData.itemClass(), obj_scale:1.5, id:i++, data:{ id:itemData.id, itemData:itemData } });
				bttn.on(PushButton.TOGGLE, function(e:FewfEvent):void{
					// Deselect other toggled back items
					for each(var bttn:PushButton in _backItemButtons) {
						if(bttn.data.id != e.data.id) bttn.toggleOff(false);
					}
				});
				bttn.on(PushButton.TOGGLE, _onItemToggled);
				grid.add(bttn);
				_backItemButtons.push(bttn);
				if(_character.getItemData(ItemType.BACK) && _character.getItemData(ItemType.BACK).id == itemData.id) {
					bttn.toggleOn();
				}
			}

			yy = grid.y + grid.cellSize + 5;
			grid = new Grid(385, 5).setXY(xx,yy).appendTo(this);
			
			_frontHandButton = new PushButton({ size:grid.cellSize, obj:new GameAssets.extraObjectWand.itemClass(), obj_scale:1.5, id:i++, data:{ itemData:GameAssets.extraObjectWand } });
			_frontHandButton.on(PushButton.TOGGLE, _onItemToggled);
			grid.add(_frontHandButton);
			if(_character.getItemData(ItemType.OBJECT)) { _frontHandButton.toggleOn(); }
			
			_backHandButton = new PushButton({ size:grid.cellSize, obj:new GameAssets.extraBackHand.itemClass(), obj_scale:1.5, id:i++, data:{ itemData:GameAssets.extraBackHand } });
			_backHandButton.on(PushButton.TOGGLE, _onItemToggled);
			grid.add(_backHandButton);
			if(_character.getItemData(ItemType.PAW_BACK)) { _backHandButton.toggleOn(); }
			
			/////////////////////////////
			// Bottom Buttons
			/////////////////////////////
			var saveHeadButton:GameButton = new GameButton({ x:353, y:315, width:70, height:70 }).appendTo(this) as GameButton;
			saveHeadButton.on(MouseEvent.CLICK, _onSaveMouseHeadClicked);
			_characterHead = new Character(new <ItemData>[ GameAssets.defaultSkin, GameAssets.defaultPose ]).appendTo(saveHeadButton);
			
			if(ConstantsApp.ANIMATION_DOWNLOAD_ENABLED) {
				_webpButton = new GameButton({ x:353-70-5, y:315, width:70, height:70 }).appendTo(this) as GameButton;
				_webpButton.on(MouseEvent.CLICK, _onSaveAsWebpClicked);
				new TextBase('.webp', { x:35, y:35, origin:0.5, size:16 }).appendTo(_webpButton);
			}
			
			SpriteButton.withObject(new $FilterIcon(), 0.85, { x:xx, y:315, width:70, height:70 }).appendTo(this)
				.on(ButtonBase.CLICK, function(e:Event):void{ dispatchEvent(new Event(FILTER_MODE_CLICKED)); });
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
				_shamanButtons[_character.shamanMode.toInt()-2].toggleOn(false);
			}
			_disableSkillsModeButton.toggle(_character.disableSkillsMode, false);
			
			_frontHandButton.toggle(!!_character.getItemData(ItemType.OBJECT), false);
			for each(var bttn:PushButton in _backItemButtons) {
				bttn.toggle(!!_character.getItemData(ItemType.BACK) && _character.getItemData(ItemType.BACK).id == bttn.data.id, false);
			}
			_backHandButton.toggle(!!_character.getItemData(ItemType.PAW_BACK), false);
			_updateHead();
		}
		
		/****************************
		* Private
		*****************************/
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
			
			var btnSize = 70, size = 60;
			var tBounds = _characterHead.getBounds(_characterHead);
			var tOffset = tBounds.topLeft;
			FewfDisplayUtils.fitWithinBounds(_characterHead, size, size, size, size);
			_characterHead.x = btnSize / 2 - (tBounds.width / 2 + tOffset.x) * _characterHead.scaleX;
			_characterHead.y = btnSize / 2 - (tBounds.height / 2 + tOffset.y) * _characterHead.scaleY;
		
		}
		
		/****************************
		* Events
		*****************************/
		private function _registerClickHandler(pList:Vector.<PushButton>, pCallback:Function) : void {
			for(var i:int = 0; i < pList.length; i++) {
				pList[i].addEventListener(PushButton.BEFORE_TOGGLE, pCallback);
			}
		}
		
		private function _onShamanButtonClicked(pEvent:Event) {
			_untoggle(_shamanButtons, pEvent.target as PushButton);
			_character.shamanMode = ShamanMode.fromInt(pEvent.target.id);
			if(pEvent.target.pushed) {
				_character.shamanMode = ShamanMode.OFF;
			}
			_character.updatePose();
			_updateHead();
		}
		
		private function _onNoShamanButtonClicked(pEvent:Event) {
			_untoggle(_shamanButtons);
			_character.shamanMode = ShamanMode.OFF;
			_character.updatePose();
			_updateHead();
		}
		
		private function _onShamanDisableSkillsModeButtonClicked(pEvent:Event) {
			_character.disableSkillsMode = (pEvent.target as PushButton).pushed;
			if(_character.disableSkillsMode && _character.shamanMode == ShamanMode.OFF) {
				_character.shamanMode = ShamanMode.fromInt(_shamanButtons[0].id);
				_shamanButtons[0].toggleOn(false);
			}
			_character.updatePose();
			_updateHead();
			
		}
		
		private function _onItemToggled(e:FewfEvent) : void {
			var bttn:PushButton = e.target as PushButton, itemData:ItemData = e.data.itemData;
			dispatchEvent(new FewfEvent(ITEM_TOGGLED, { type:itemData.type, itemData:bttn.pushed ? itemData : null }));
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
		
		private function _onSaveMouseHeadClicked(pEvent:Event) {
			FewfDisplayUtils.saveAsPNG(_characterHead, 'mouse_head', _character.outfit.scaleX);
		}
		
		private function _onSaveAsWebpClicked(e:Event) {
			_webpButton.disable();
			FewfDisplayUtils.saveAsAnimatedGif(_character.copy().outfit.pose, "character", _character.outfit.scaleX, "webp", function(){
				_webpButton.enable();
			});
		}
	}
}
