package app.world
{
	import com.adobe.images.*;
	import com.piterwilson.utils.*;
	import com.fewfre.utils.AssetManager;
	import com.fewfre.display.*;
	import com.fewfre.events.*;
	import com.fewfre.utils.*;

	import app.ui.*;
	import app.ui.screens.*;
	import app.ui.buttons.*;
	import app.ui.common.*;
	import app.data.*;
	import app.world.data.*;
	import app.world.elements.*;

	import flash.display.*;
	import flash.text.*;
	import flash.events.*
	import flash.external.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.utils.*;
	import app.ui.panes.*;
	import app.ui.panes.colorpicker.ColorPickerTabPane;
	import flash.display.MovieClip;
	import flash.ui.Keyboard;
	
	public class World extends MovieClip
	{
		// Storage
		internal var character		: Character;
		internal var _paneManager	: PaneManager;

		internal var shopTabs		: ShopTabList;
		internal var _toolbox		: Toolbox;
		internal var linkTray		: LinkTray;
		internal var trashConfirmScreen	: TrashConfirmScreen;
		internal var _langScreen	: LangScreen;

		internal var button_hand	: PushButton;
		internal var button_back	: PushButton;
		internal var button_backHand: PushButton;

		internal var currentlyColoringType:ItemType=null;
		internal var configCurrentlyColoringType:String;
		
		// Constants
		public static const COLOR_PANE_ID:String = "colorPane";
		public static const TAB_OTHER:String = "other";
		public static const TAB_CONFIG:String = "config";
		public static const TAB_OUTFITS:String = "outfits";
		public static const CONFIG_COLOR_PANE_ID:String = "configColorPane";
		public static const COLOR_FINDER_PANE_ID:String = "colorFinderPane";
		
		// Constructor
		public function World(pStage:Stage) {
			super();
			ConstantsApp.CONFIG_TAB_ENABLED = !!Fewf.assets.getData("config").username_lookup_url;
			ConstantsApp.ANIMATION_DOWNLOAD_ENABLED = !!Fewf.assets.getData("config").spritesheet2gif_url && (Fewf.isExternallyLoaded || ExternalInterface.call("eval", "window.location.href") == null);
			_buildWorld(pStage);
			pStage.addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
			pStage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDownListener);
		}
		
		private function _buildWorld(pStage:Stage) {
			GameAssets.init();
			
			/****************************
			* Create Character
			*****************************/
			var parms:String = null;
			if(!Fewf.isExternallyLoaded) {
				try {
					var urlPath:String = ExternalInterface.call("eval", "window.location.href");
					if(urlPath && urlPath.indexOf("?") > 0) {
						urlPath = urlPath.substr(urlPath.indexOf("?") + 1, urlPath.length);
					}
					parms = urlPath;
				} catch (error:Error) { };
			}

			this.character = new Character(new <ItemData>[ GameAssets.defaultSkin, GameAssets.defaultPose ], parms)
				.setXY(180, 275).appendTo(this);

			/****************************
			* Setup UI
			*****************************/
			var tShop:RoundedRectangle = new RoundedRectangle({ x:450, y:10, width:ConstantsApp.SHOP_WIDTH, height:ConstantsApp.APP_HEIGHT })
				.appendTo(this).drawAsTray();
			_paneManager = tShop.addChild(new PaneManager()) as PaneManager;
			
			var tabs:Vector.<Object> = new <Object>[
				{ text:"tab_furs", event:ItemType.SKIN.toString() },
				{ text:"tab_head", event:ItemType.HEAD.toString() },
				{ text:"tab_ears", event:ItemType.EARS.toString() },
				{ text:"tab_eyes", event:ItemType.EYES.toString() },
				{ text:"tab_mouth", event:ItemType.MOUTH.toString() },
				{ text:"tab_neck", event:ItemType.NECK.toString() },
				{ text:"tab_tail", event:ItemType.TAIL.toString() },
				{ text:"tab_hair", event:ItemType.HAIR.toString() },
				{ text:"tab_contacts", event:ItemType.CONTACTS.toString() },
				{ text:"tab_tattoo", event:ItemType.TATTOO.toString() },
				{ text:"tab_hand", event:ItemType.HAND.toString() },
				{ text:"tab_poses", event:ItemType.POSE.toString() },
				{ text:"tab_other", event:TAB_OTHER }
			];
			if(ConstantsApp.CONFIG_TAB_ENABLED) {
				tabs.unshift({ text:"tab_config", event:TAB_CONFIG });
			}
			this.shopTabs = new ShopTabList(70, ConstantsApp.APP_HEIGHT, tabs).setXY(375, 10).appendTo(this);
			this.shopTabs.addEventListener(ShopTabList.TAB_CLICKED, _onTabClicked);

			// Toolbox
			_toolbox = new Toolbox({
				character:character,
				onSave:_onSaveClicked, onAnimate:_onPlayerAnimationToggle, onRandomize:_onRandomizeDesignClicked,
				onTrash:_onTrashButtonClicked, onShare:_onShareButtonClicked, onScale:_onScaleSliderChange,
				onShareCodeEntered:_onShareCodeEntered
			}).setXY(188, 28).appendTo(this);
			
			var tLangButton:LangButton = addChild(new LangButton({ x:22, y:pStage.stageHeight-17, width:30, height:25, origin:0.5 })) as LangButton;
			tLangButton.addEventListener(ButtonBase.CLICK, _onLangButtonClicked);
			
			new AppInfoBox().setXY(tLangButton.x+(tLangButton.Width*0.5)+(25*0.5)+2, pStage.stageHeight-17).appendTo(this);
			
			/****************************
			* Screens
			*****************************/
			linkTray = new LinkTray({ x:pStage.stageWidth * 0.5, y:pStage.stageHeight * 0.5 });
			linkTray.addEventListener(LinkTray.CLOSE, _onShareTrayClosed);
			
			trashConfirmScreen = new TrashConfirmScreen({ x:337, y:65 });
			trashConfirmScreen.addEventListener(TrashConfirmScreen.CONFIRM, _onTrashConfirmScreenConfirm);
			trashConfirmScreen.addEventListener(TrashConfirmScreen.CLOSE, _onTrashConfirmScreenClosed);
			
			_langScreen = new LangScreen({  });
			_langScreen.addEventListener(LangScreen.CLOSE, _onLangScreenClosed);

			/****************************
			* Create item panes
			*****************************/
			for each(var tType:ItemType in ItemType.TYPES_WITH_SHOP_PANES) {
				_paneManager.addPane(tType.toString(), _setupItemPane(tType));
				// Based on what the character is wearing at start, toggle on the appropriate buttons.
				getTabByType(tType).toggleGridButtonWithData( character.getItemData(tType) );
			}
			
			/****************************
			* Config Pane
			*****************************/
			if(ConstantsApp.CONFIG_TAB_ENABLED) {
				_paneManager.addPane(TAB_CONFIG, new ConfigTabPane({
					onShareCodeEntered:_onShareCodeEntered,
					onUserLookClicked:_useShareCode
				}));
			}
			
			/****************************
			* Other Pane
			*****************************/
			var tPaneOther:OtherTabPane = _paneManager.addPane(TAB_OTHER, new OtherTabPane(character)) as OtherTabPane;
			tPaneOther.button_hand.addEventListener(PushButton.STATE_CHANGED_AFTER, this.buttonHandClickAfter);
			tPaneOther.button_back.addEventListener(PushButton.STATE_CHANGED_AFTER, this.buttonBackClickAfter);
			tPaneOther.button_backHand.addEventListener(PushButton.STATE_CHANGED_AFTER, this.buttonBackHandClickAfter);
			tPaneOther.shamanColorPickerButton.addEventListener(ButtonBase.CLICK, function(pEvent:Event){ _shamanColorButtonClicked(); });
			tPaneOther.shamanColorBlueButton.addEventListener(ButtonBase.CLICK, function(pEvent:Event){ _setConfigShamanColor(0x95D9D6); });
			tPaneOther.shamanColorPinkButton.addEventListener(ButtonBase.CLICK, function(pEvent:Event){ _setConfigShamanColor(0xFCA6F1); });
			tPaneOther.outfitsButton.addEventListener(ButtonBase.CLICK, function(pEvent:Event){ _paneManager.openPane(TAB_OUTFITS); });
			tPaneOther = null;
			
			var tPane:TabPane = null;
			// Outfit Pane
			tPane = _paneManager.addPane(TAB_OUTFITS, new OutfitManagerTabPane(character, _useShareCode));
			tPane.infoBar.colorWheel.addEventListener(MouseEvent.MOUSE_UP, function(pEvent:Event){ _paneManager.openPane(TAB_OTHER); });
			// Grid Management Events
			tPane.infoBar.rightItemButton.addEventListener(ButtonBase.CLICK, function(){ _traversePaneButtonGrid(_paneManager.getPane(TAB_OUTFITS), true); });
			tPane.infoBar.leftItemButton.addEventListener(ButtonBase.CLICK, function(){ _traversePaneButtonGrid(_paneManager.getPane(TAB_OUTFITS), false); });
			
			// "Other" Tab Color Picker Pane
			tPane = _paneManager.addPane(CONFIG_COLOR_PANE_ID, new ColorPickerTabPane({ hide_default:true }));
			tPane.addEventListener(ColorPickerTabPane.EVENT_COLOR_PICKED, _onConfigColorPickChanged);
			tPane.addEventListener(ColorPickerTabPane.EVENT_EXIT, function(pEvent:Event){ _paneManager.openPane(TAB_OTHER); });
			tPane.infoBar.hideImageCont();
			
			// Color Picker Pane
			tPane = _paneManager.addPane(COLOR_PANE_ID, new ColorPickerTabPane({}));
			tPane.addEventListener(ColorPickerTabPane.EVENT_COLOR_PICKED, _onColorPickChanged);
			tPane.addEventListener(ColorPickerTabPane.EVENT_DEFAULT_CLICKED, _onDefaultsButtonClicked);
			tPane.addEventListener(ColorPickerTabPane.EVENT_PREVIEW_COLOR, _onColorPickHoverPreview);
			tPane.addEventListener(ColorPickerTabPane.EVENT_EXIT, _onColorPickerBackClicked);
			tPane.infoBar.removeItemOverlay.addEventListener(MouseEvent.CLICK, function(e){
				_onColorPickerBackClicked(e);
				_removeItem(_paneManager.getPane(COLOR_PANE_ID).infoBar.data.type);
			});
			
			// Color Finder Pane
			tPane = _paneManager.addPane(COLOR_FINDER_PANE_ID, new ColorFinderPane({ }));
			tPane.addEventListener(ColorFinderPane.EVENT_EXIT, _onColorFinderBackClicked);
			tPane.infoBar.removeItemOverlay.addEventListener(MouseEvent.CLICK, function(e){
				_onColorFinderBackClicked(e);
				_removeItem(_paneManager.getPane(COLOR_FINDER_PANE_ID).infoBar.data.type);
			});
			
			// Select First Pane
			shopTabs.tabs[0].toggleOn();
			
			tPane = null;
		}

		private function _setupItemPane(pType:ItemType) : ShopCategoryPane {
			var tPane:ShopCategoryPane = new ShopCategoryPane(pType);
			tPane.addEventListener(ShopCategoryPane.ITEM_TOGGLED, _onItemToggled);
			tPane.addEventListener(ShopCategoryPane.DEFAULT_SKIN_COLOR_BTN_CLICKED, function(){ _colorButtonClicked(pType); });
			
			tPane.infoBar.colorWheel.addEventListener(ButtonBase.CLICK, function(){ _colorButtonClicked(pType); });
			tPane.infoBar.removeItemOverlay.addEventListener(MouseEvent.CLICK, function(){ _removeItem(pType); });
			// Grid Management Events
			tPane.infoBar.randomizeButton.addEventListener(ButtonBase.CLICK, function(){ _randomItemOfType(pType); });
			tPane.infoBar.rightItemButton.addEventListener(ButtonBase.CLICK, function(){ _traversePaneButtonGrid(tPane, true); });
			tPane.infoBar.leftItemButton.addEventListener(ButtonBase.CLICK, function(){ _traversePaneButtonGrid(tPane, false); });
			// Misc
			if(tPane.infoBar.eyeDropButton) {
				tPane.infoBar.eyeDropButton.addEventListener(ButtonBase.CLICK, function(){ _eyeDropButtonClicked(pType); });
			}
			return tPane;
		}

		private function _onMouseWheel(pEvent:MouseEvent) : void {
			if(this.mouseX < this.shopTabs.x) {
				_toolbox.scaleSlider.updateViaMouseWheelDelta(pEvent.delta);
				character.scale = _toolbox.scaleSlider.value;
			}
		}

		private function _onKeyDownListener(e:KeyboardEvent) : void {
			if (e.keyCode == Keyboard.RIGHT){
				_traversePaneButtonGrid(_paneManager.getOpenPane(), true);
			}
			else if (e.keyCode == Keyboard.LEFT) {
				_traversePaneButtonGrid(_paneManager.getOpenPane(), false);
			}
			else if (e.keyCode == Keyboard.UP){
				_traversePaneButtonGridVertically(_paneManager.getOpenPane(), true);
			}
			else if (e.keyCode == Keyboard.DOWN) {
				_traversePaneButtonGridVertically(_paneManager.getOpenPane(), false);
			}
		}
		
		private function _traversePaneButtonGrid(pane:TabPane, pRight:Boolean):void {
			if(pane && pane.grid && pane.buttons && pane.buttons.length > 0 && pane.buttons[0] is PushButton) {
				var buttons:Array = pane.buttons;
				var activeButtonIndex:int = _findIndexActivePushButton(buttons);
				if(activeButtonIndex == -1) { activeButtonIndex = pane.grid.reversed ? buttons.length-1 : 0; }
				
				var dir:int = (pRight ? 1 : -1) * (pane.grid.reversed ? -1 : 1),
					length:uint = buttons.length;
					
				var newI:int = activeButtonIndex+dir;
				// mod it so it wraps - `length` added before mod to allow a `-1` dir to properly wrap
				newI = (length + newI) % length;
				
				var btn:PushButton = buttons[newI];
				btn.toggleOn();
				pane.scrollItemIntoView(btn);
			}
		}
		
		private function _traversePaneButtonGridVertically(pane:TabPane, pUp:Boolean):void {
			if(pane && pane.grid && pane.buttons && pane.buttons.length > 0 && pane.buttons[0] is PushButton) {
				var buttons:Array = pane.buttons, grid:Grid = pane.grid;
				
				var activeButtonIndex:int = _findIndexActivePushButton(buttons);
				if(activeButtonIndex == -1) { activeButtonIndex = grid.reversed ? buttons.length-1 : 0; }
				var dir:int = (pUp ? -1 : 1) * (grid.reversed ? -1 : 1),
					length:uint = buttons.length;
				
				var rowI:Number = Math.floor(activeButtonIndex / grid.columns);
				rowI = (rowI + dir); // increment row in direction
				rowI = (grid.rows + rowI) % grid.rows; // wrap it in both directions
				var colI = activeButtonIndex % grid.columns;
				
				// we want to stay in the same column, and just move up/down a row
				// var newRowI:Number = (grid.rows + rowI) % grid.rows;
				var newI:int = rowI*grid.columns + colI;
				
				// since row is modded, it can only ever be out of bounds at the end - this happens if the last
				// row doesn't have enough items to fill all columns, and active column is in one of them.
				if(newI >= length) {
					// we solve it by going an extra step in our current direction, mod it again so it can wrap if needed,
					// and then we recalculate the button i
					rowI += dir;
					rowI = (grid.rows + rowI) % grid.rows; // wrap it again
					newI = rowI*grid.columns + colI;
				}
				
				var btn:PushButton = buttons[newI];
				btn.toggleOn();
				pane.scrollItemIntoView(btn);
			}
		}
		
		// Find the pressed button
		private function _findIndexActivePushButton(pButtons:Array):int {
			for(var i:int = 0; i < pButtons.length; i++){
				if((pButtons[i] as PushButton).pushed){
					return i;
				}
			}
			return -1;
		}

		private function _onScaleSliderChange(pEvent:Event):void {
			character.scale = _toolbox.scaleSlider.value;
		}

		private function _onShareCodeEntered(pCode:String, pProgressCallback:Function):void {
			if(!pCode || pCode == "") { return; pProgressCallback("placeholder"); }
			
			try {
				_useShareCode(pCode);
				
				// Now tell code box that we are done
				pProgressCallback("success");
			}
			catch (error:Error) {
				pProgressCallback("invalid");
			};
		}
		
		private function _useShareCode(pCode:String):void {
			if(pCode.indexOf("?") > -1) {
				pCode = pCode.substr(pCode.indexOf("?") + 1, pCode.length);
			}
			
			// First remove old stuff to prevent conflicts
			character.shamanMode = ShamanMode.OFF;
			for each(var tType:ItemType in ItemType.LAYERING) { _removeItem(tType); }
			_removeItem(ItemType.POSE);
			
			// Now update pose
			character.parseParams(pCode);
			character.updatePose();
			
			for each(var tType:ItemType in ItemType.TYPES_WITH_SHOP_PANES) { _refreshButtonCustomizationForItemData(character.getItemData(tType)); }
			
			// now update the infobars
			_updateUIBasedOnCharacter();
			(_paneManager.getPane(TAB_OTHER) as OtherTabPane).updateButtonsBasedOnCurrentData();
		}

		private function _onPlayerAnimationToggle(pEvent:Event):void {
			character.animatePose = !character.animatePose;
			if(character.animatePose) {
				character.outfit.play();
			} else {
				character.outfit.stop();
			}
			_toolbox.toggleAnimateButtonAsset(character.animatePose);
		}

		private function _onSaveClicked(pEvent:Event) : void {
			if(ConstantsApp.ANIMATION_DOWNLOAD_ENABLED && character.animatePose) {
				// FewfDisplayUtils.saveAsSpriteSheet(this.character.copy().outfit.pose, "spritesheet", this.character.outfit.scaleX);
				_toolbox.downloadButton.disable();
				FewfDisplayUtils.saveAsAnimatedGif(this.character.copy().outfit.pose, "character", this.character.outfit.scaleX, null, function(){
					_toolbox.downloadButton.enable();
				});
			} else {
				FewfDisplayUtils.saveAsPNG(this.character, "character");
			}
		}

		// Note: does not automatically de-select previous buttons / infobars; do that before calling this
		// This function is required when setting data via parseParams
		private function _updateUIBasedOnCharacter() : void {
			var tPane:ShopCategoryPane;
			for each(var tType:ItemType in ItemType.TYPES_WITH_SHOP_PANES) {
				tPane = getTabByType(tType);
				// Based on what the character is wearing at start, toggle on the appropriate buttons.
				tPane.toggleGridButtonWithData( character.getItemData(tType) );
			}
		}

		private function _onItemToggled(pEvent:FewfEvent) : void {
			var tType:ItemType = pEvent.data.type;
			var tItemList:Vector.<ItemData> = GameAssets.getItemDataListByType(tType);
			var tInfoBar:ShopInfoBar = getInfoBarByType(tType);

			// De-select all buttons that aren't the clicked one.
			var tButtons:Array = getButtonArrayByType(tType);
			for(var i:int = 0; i < tButtons.length; i++) {
				if(tButtons[i].data.id != pEvent.data.id) {
					if (tButtons[i].pushed) { tButtons[i].toggleOff(); }
				}
			}

			var tButton:PushButton = tButtons[pEvent.data.id];
			var tData:ItemData;
			// If clicked button is toggled on, equip it. Otherwise remove it.
			if(tButton.pushed) {
				tData = tItemList[pEvent.data.id];
				setCurItemID(tType, tButton.id);
				this.character.setItemData(tData);

				tInfoBar.addInfo( tData, GameAssets.getColoredItemImage(tData) );
				tInfoBar.showColorWheel(GameAssets.getNumOfCustomColors(tButton.Image as MovieClip) > 0);
			} else {
				_removeItem(tType);
			}
		}

		public function buttonHandClickAfter(pEvent:Event):void {
			toggleItemSelectionOneOff(ItemType.OBJECT, pEvent.target as PushButton, GameAssets.extraObjectWand);
		}

		public function buttonBackClickAfter(pEvent:Event):void {
			toggleItemSelectionOneOff(ItemType.BACK, pEvent.target as PushButton, GameAssets.extraFromage);
		}

		public function buttonBackHandClickAfter(pEvent:Event):void {
			toggleItemSelectionOneOff(ItemType.PAW_BACK, pEvent.target as PushButton, GameAssets.extraBackHand);
		}

		private function toggleItemSelectionOneOff(pType:ItemType, pButton:PushButton, pItemData:ItemData) : void {
			if (pButton.pushed) {
				this.character.setItemData( pItemData );
			} else {
				this.character.removeItem(pType);
			}
		}

		private function _removeItem(pType:ItemType) : void {
			if(pType == ItemType.BACK || pType == ItemType.PAW_BACK || pType == ItemType.OBJECT) {
				this.character.removeItem(pType);
			}
			var tTabPane = getTabByType(pType);
			if(!tTabPane || tTabPane.infoBar.hasData == false) { return; }

			// If item has a default value, toggle it on. otherwise remove item.
			if(pType == ItemType.SKIN || pType == ItemType.POSE) {
				var tDefaultIndex = (pType == ItemType.POSE ? GameAssets.defaultPoseIndex : GameAssets.defaultSkinIndex);
				tTabPane.buttons[tDefaultIndex].toggleOn();
			} else {
				this.character.removeItem(pType);
				tTabPane.infoBar.removeInfo();
				tTabPane.buttons[ tTabPane.selectedButtonIndex ].toggleOff();
			}
		}
		
		private function _onTabClicked(pEvent:FewfEvent) : void {
			_paneManager.openPane(pEvent.data.toString());
		}

		private function _onRandomizeDesignClicked(pEvent:Event) : void {
			for each(var tType:ItemType in ItemType.TYPES_WITH_SHOP_PANES) {
				var odds:Number = tType == ItemType.POSE ? 0.5 : 0.65;
				_randomItemOfType(tType, Math.random() <= odds);
			}
			(_paneManager.getPane(TAB_OTHER) as OtherTabPane).updateButtonsBasedOnCurrentData();
		}

		private function _randomItemOfType(pType:ItemType, pSetToDefault:Boolean=false) : void {
			var pane:TabPane = getTabByType(pType);
			if(pane.infoBar.isRefreshLocked) { return; }
			
			if(!pSetToDefault) {
				var tLength = pane.buttons.length;
				var btn = pane.buttons[ Math.floor(Math.random() * tLength) ];
				btn.toggleOn();
				if(pane.flagOpen) pane.scrollItemIntoView(btn);
			} else {
				_removeItem(pType);
				// Set to default values for required types
				if(pType == ItemType.SKIN) {
					if(pane.flagOpen) pane.scrollItemIntoView(pane.buttons[GameAssets.defaultSkinIndex]);
				}
				else if(pType == ItemType.POSE) {
					if(pane.flagOpen) pane.scrollItemIntoView(pane.buttons[GameAssets.defaultPoseIndex]);
				}
			}
		}
		
		private function _onShareButtonClicked(pEvent:Event) : void {
			var tURL = "", tOfficialCode = "";
			try {
				if(Fewf.isExternallyLoaded) {
					tURL = this.character.getParams();
				} else {
					tURL = ExternalInterface.call("eval", "window.location.origin+window.location.pathname");
					tURL += "?"+this.character.getParams();
				}
			} catch (error:Error) {
				tURL = "<error creating link>";
			};
			
			try {
				tOfficialCode = this.character.getParamsTfmOfficialSyntax();
			} catch (error:Error) {
				tOfficialCode = "<error creating link>";
			};

			linkTray.open(tURL, tOfficialCode);
			addChild(linkTray);
		}

		private function _onShareTrayClosed(pEvent:Event) : void {
			removeChild(linkTray);
		}

		private function _onTrashButtonClicked(pEvent:Event) : void {
			addChild(trashConfirmScreen);
		}

		private function _onTrashConfirmScreenConfirm(pEvent:Event) : void {
			removeChild(trashConfirmScreen);
			character.shamanMode = ShamanMode.OFF;
			// Remove items
			for each(var tItem in ItemType.LAYERING) { _removeItem(tItem); }
			_removeItem(ItemType.POSE);
			
			// Refresh panes
			for each(var tItem in ItemType.TYPES_WITH_SHOP_PANES) {
				var pane:ShopCategoryPane = getTabByType(tItem);
				pane.infoBar.unlockRandomizeButton();
				
				// Reset customizations
				if(tItem != ItemType.POSE) {
					var buttons = pane.buttons;
					var dataList = GameAssets.getItemDataListByType(tItem);
					
					for(var i:int = 0; i < buttons.length; i++){
						if(dataList[i].hasModifiedColors()) {
							dataList[i].setColorsToDefault();
							_refreshButtonCustomizationForItemData(dataList[i]);
						}
					}
				}
				
			}
			(_paneManager.getPane(TAB_OTHER) as OtherTabPane).updateButtonsBasedOnCurrentData();
		}

		private function _onTrashConfirmScreenClosed(pEvent:Event) : void {
			removeChild(trashConfirmScreen);
		}

		private function _onLangButtonClicked(pEvent:Event) : void {
			_langScreen.open();
			addChild(_langScreen);
		}

		private function _onLangScreenClosed(pEvent:Event) : void {
			removeChild(_langScreen);
		}

		//{REGION Get TabPane data
			private function getTabByType(pType:ItemType) : ShopCategoryPane {
				return _paneManager.getPane(pType.toString()) as ShopCategoryPane;
			}

			private function getInfoBarByType(pType:ItemType) : ShopInfoBar {
				return getTabByType(pType).infoBar;
			}

			private function getButtonArrayByType(pType:ItemType) : Array {
				return getTabByType(pType).buttons;
			}

			private function getCurItemID(pType:ItemType) : int {
				return getTabByType(pType).selectedButtonIndex;
			}

			private function setCurItemID(pType:ItemType, pID:int) : void {
				getTabByType(pType).selectedButtonIndex = pID;
			}
		//}END Get TabPane data

		//{REGION Color Tab
			private function _onColorPickChanged(pEvent:FewfEvent):void {
				var color:uint = uint(pEvent.data.color);
				var pane = _paneManager.getPane(COLOR_PANE_ID) as ColorPickerTabPane;
				if(pEvent.data.randomizedAll) {
					this.character.getItemData(this.currentlyColoringType).colors = pane.getAllColors();
				} else {
					this.character.getItemData(this.currentlyColoringType).colors[pane.selectedSwatch] = color;
				}
				_refreshSelectedItemColor(this.currentlyColoringType);
			}

			private function _onDefaultsButtonClicked(pEvent:Event) : void {
				this.character.getItemData(this.currentlyColoringType).setColorsToDefault();
				_refreshSelectedItemColor(this.currentlyColoringType);
				var pane = _paneManager.getPane(COLOR_PANE_ID) as ColorPickerTabPane;
				pane.setupSwatches( this.character.getColors(this.currentlyColoringType) );
			}

			private function _onColorPickHoverPreview(pEvent:FewfEvent) : void {
				// Updated preview data
				GameAssets.swatchHoverPreviewData = pEvent.data;
				// refresh render for anything that uses it
				_refreshSelectedItemColor(this.currentlyColoringType);
			}
			
			private function _refreshSelectedItemColor(pType:ItemType) : void {
				character.updatePose();
				
				var tItemData = this.character.getItemData(pType);
				if(pType != ItemType.SKIN) {
					var tItem:MovieClip = GameAssets.getColoredItemImage(tItemData);
					GameAssets.copyColor(tItem, getButtonArrayByType(pType)[ getCurItemID(pType) ].Image );
					GameAssets.copyColor(tItem, getInfoBarByType( pType ).Image );
					GameAssets.copyColor(tItem, _paneManager.getPane(COLOR_PANE_ID).infoBar.Image);
				} else {
					_replaceImageWithNewImage(getButtonArrayByType(pType)[ getCurItemID(pType) ], GameAssets.getColoredItemImage(tItemData));
					_replaceImageWithNewImage(getInfoBarByType( pType ), GameAssets.getColoredItemImage(tItemData));
					_replaceImageWithNewImage(_paneManager.getPane(COLOR_PANE_ID).infoBar, GameAssets.getColoredItemImage(tItemData));
				}
				/*var tMC:MovieClip = this.character.getItemFromIndex(pType);
				if (tMC != null)
				{
					GameAssets.colorDefault(tMC);
					GameAssets.copyColor( tMC, getButtonArrayByType(pType)[ getCurItemID(pType) ].Image );
					GameAssets.copyColor(tMC, getInfoBarByType(pType).Image);
					GameAssets.copyColor(tMC, _paneManager.getPane(COLOR_PANE_ID).infoBar.Image);
					
				}*/
			}
			private function _replaceImageWithNewImage(pOldSource:Object, pNew:MovieClip) : void {
				pNew.x = pOldSource.Image.x;
				pNew.y = pOldSource.Image.y;
				pNew.scaleX = pOldSource.Image.scaleX;
				pNew.scaleY = pOldSource.Image.scaleY;
				pOldSource.Image.parent.addChild(pNew);
				pOldSource.Image.parent.removeChild(pOldSource.Image);
				pOldSource.Image = null;
				pOldSource.Image = pNew;
			}
			
			private function _refreshButtonCustomizationForItemData(data:ItemData) : void {
				if(!data || data.type == ItemType.POSE) { return; }
				
				var pane:ShopCategoryPane = getTabByType(data.type);
				var i:int = GameAssets.getItemIndexFromTypeID(data.type, data.id);
				if(data.type != ItemType.SKIN) {
					var tItem:MovieClip = GameAssets.getColoredItemImage(data);
					GameAssets.copyColor(tItem, pane.buttons[i].Image );
				} else {
					_replaceImageWithNewImage(pane.buttons[i], GameAssets.getColoredItemImage(data));
				}
			}

			private function _colorButtonClicked(pType:ItemType) : void {
				if(this.character.getItemData(pType) == null) { return; }

				var tData:ItemData = getInfoBarByType(pType).data;
				_paneManager.getPane(COLOR_PANE_ID).infoBar.addInfo( tData, GameAssets.getItemImage(tData) );
				this.currentlyColoringType = pType;
				(_paneManager.getPane(COLOR_PANE_ID) as ColorPickerTabPane).setupSwatches( this.character.getColors(pType) );
				_paneManager.openPane(COLOR_PANE_ID);
				_refreshSelectedItemColor(pType);
			}

			private function _onColorPickerBackClicked(pEvent:Event):void {
				_paneManager.openPane(_paneManager.getPane(COLOR_PANE_ID).infoBar.data.type.toString());
			}

			private function _eyeDropButtonClicked(pType:ItemType) : void {
				if(this.character.getItemData(pType) == null) { return; }

				var tData:ItemData = getInfoBarByType(pType).data;
				var tItem:MovieClip = GameAssets.getColoredItemImage(tData);
				var tItem2:MovieClip = GameAssets.getColoredItemImage(tData);
				_paneManager.getPane(COLOR_FINDER_PANE_ID).infoBar.addInfo( tData, tItem );
				this.currentlyColoringType = pType;
				(_paneManager.getPane(COLOR_FINDER_PANE_ID) as ColorFinderPane).setItem(tItem2);
				_paneManager.openPane(COLOR_FINDER_PANE_ID);
			}

			private function _onColorFinderBackClicked(pEvent:Event):void {
				_paneManager.openPane(_paneManager.getPane(COLOR_FINDER_PANE_ID).infoBar.data.type.toString());
			}

			private function _onConfigColorPickChanged(pEvent:FewfEvent):void {
				var tVal:uint = uint(pEvent.data.color);
				_setConfigShamanColor(tVal);
			}
			
			private function _setConfigShamanColor(val:uint) : void {
				/*_paneManager.getPane(TAB_OTHER).updateCustomColor(configCurrentlyColoringType, val);*/
				character.shamanColor = val;
				character.updatePose();
			}

			private function _shamanColorButtonClicked(/*pType:String, pColor:int*/) : void {
				/*this.configCurrentlyColoringType = pType;*/
				(_paneManager.getPane(CONFIG_COLOR_PANE_ID) as ColorPickerTabPane).setupSwatches( new <uint>[ character.shamanColor ] );
				_paneManager.openPane(CONFIG_COLOR_PANE_ID);
			}
		//}END Color Tab
	}
}
