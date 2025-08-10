package app.world
{
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import app.ui.panes.*;
	import app.ui.panes.base.ButtonGridSidePane;
	import app.ui.panes.base.SidePane;
	import app.ui.panes.colorpicker.ColorPickerTabPane;
	import app.ui.panes.colorpicker.LockHistoryMap;
	import app.ui.panes.filteringmode.*;
	import app.ui.panes.infobar.GridManagementWidget;
	import app.ui.panes.infobar.Infobar;
	import app.ui.screens.*;
	import app.world.data.*;
	import app.world.elements.*;
	import app.world.events.ItemDataEvent;
	
	import com.fewfre.display.*;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.utils.*;
	import ext.ParentApp;
	
	import flash.display.*;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	public class World extends Sprite
	{
		// Storage
		private var _panes             : WorldPaneManager;
		private var _leftSideTray      : Sprite;
		private var _filterModeTray    : Sprite;

		private var _character         : Character;
		private var _shopTabs          : ShopTabList;
		private var _toolbox           : Toolbox;
		private var _itemFilterBanner  : ItemFilterBanner;
		private var _animationControls : AnimationControls;
		private var _restoreAutoSaveBtn: GameButton;
		
		private var _shareScreen       : ShareScreen;
		private var trashConfirmScreen : TrashConfirmScreen;
		private var _langScreen        : LangScreen;
		private var _aboutScreen       : AboutScreen;

		private var currentlyColoringType:ItemType=null;
		
		private var _itemFiltering_filterEnabled : Boolean = false;
		private var _itemFiltering_selectionModeOn : Boolean = false;
		private var _filterSelectionModeInfoAside : FilterSelectionModeInfoAside;
		
		// Constructor
		public function World(pStage:Stage) {
			super();
			ConstantsApp.CONFIG_TAB_ENABLED = !!Fewf.assets.getData("config").username_lookup_url;
			ConstantsApp.ANIMATION_DOWNLOAD_ENABLED = !!Fewf.assets.getData("config").spritesheet2gif_url && (Fewf.isExternallyLoaded || (ExternalInterface.available && ExternalInterface.call("eval", "window.location.href") == null));
			_buildWorld(pStage);
			pStage.addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
			pStage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDownListener);
		}
		
		private function _buildWorld(pStage:Stage) {
			ShareCodeFilteringData.init();
			
			_initFilterSelectionModeTray();
			_leftSideTray = new Sprite(); addChild(_leftSideTray);
			
			/////////////////////////////
			// Create Character
			/////////////////////////////
			var paramsString:String = null;
			if(!Fewf.isExternallyLoaded) {
				try {
					var urlPath:String = ExternalInterface.call("eval", "window.location.href");
					if(urlPath && urlPath.indexOf("?") > 0) {
						urlPath = urlPath.substr(urlPath.indexOf("?") + 1, urlPath.length);
					}
					paramsString = urlPath;
				} catch (error:Error) { };
			}
			
			_character = new Character(new OutfitData().setItemDataVector(new <ItemData>[ GameAssets.defaultSkin, GameAssets.defaultPose ]).parseShareCodeSelf(paramsString))
				.move(180, 275).setDragBounds(0+4, 73+4, 375-4-4, ConstantsApp.APP_HEIGHT-(73+4)-4).appendTo(_leftSideTray)
				.on(Character.POSE_UPDATED, _onCharacterPoseUpdated)
				.enableDoubleClick().on(MouseEvent.DOUBLE_CLICK, function(e:MouseEvent){ _panes.openPane(WorldPaneManager.WORN_ITEMS_PANE); _panes.wornItemsPane.init(_character.outfitData); });
			
			/////////////////////////////
			// Setup UI
			/////////////////////////////
			_shopTabs = new ShopTabList(70, ConstantsApp.SHOP_HEIGHT).move(375, 10).appendTo(this).on(ShopTabList.TAB_CLICKED, _onTabClicked);
			_populateShopTabs();
			
			var tShop:RoundRectangle = new RoundRectangle(ConstantsApp.SHOP_WIDTH, ConstantsApp.SHOP_HEIGHT).move(450, 10)
				.appendTo(this).drawAsTray();
			_panes = new WorldPaneManager().appendTo(tShop.root) as WorldPaneManager;

			/////////////////////////////
			// Top Area
			/////////////////////////////
			_toolbox = new Toolbox().move(188, 28).appendTo(_leftSideTray)
				.on(Toolbox.SAVE_CLICKED, _onSaveClicked)
				.on(Toolbox.GIF_CLICKED, function(e:Event):void{ _saveAsAnimation(); })
				.on(Toolbox.WEBP_CLICKED, function(e:Event):void{ _saveAsAnimation('webp'); })
				.on(Toolbox.SHARE_CLICKED, _onShareButtonClicked)
				.on(Toolbox.CLIPBOARD_CLICKED, _onClipboardButtonClicked)
				
				.on(Toolbox.SCALE_SLIDER_CHANGE, _onScaleSliderChange)
				.on(Toolbox.DEFAULT_SCALE_CLICKED, _onScaleSliderDefaultClicked)
				
				.on(Toolbox.ANIMATION_TOGGLED, _onPlayerAnimationToggle)
				.on(Toolbox.RANDOM_CLICKED, _onRandomizeDesignClicked)
				.on(Toolbox.TRASH_CLICKED, _onTrashButtonClicked);
				
			if(!ConstantsApp.CONFIG_TAB_ENABLED) {
				new PasteShareCodeInput().appendTo(_leftSideTray).move(206, 62)
					.on(PasteShareCodeInput.CHANGE, function(e:FewfEvent):void{ _onShareCodeEntered(e.data.code, e.data.update); });
			}
				
			_itemFilterBanner = new ItemFilterBanner().move(76, 63).appendTo(_leftSideTray)
				.on(ItemFilterBanner.ONLY_INCLUDE_CUSTOMIZATIONS_TOGGLED, _toggleItemFilterModeToOnlyShowCustomizableItems)
				.on(ItemFilterBanner.FILTER_BANNER_CLOSED, _onExitItemFilteringMode);
			
			// Outfit Button
			new ScaleButton(new $Outfit(), 0.4).move(_toolbox.x+167, _toolbox.y+12.5+21).appendTo(_leftSideTray)
				.onButtonClick(function(e:Event){ _panes.openPane(WorldPaneManager.OUTFITS_PANE); });
			
			// Favorite Button
			var favButton:ScaleButton = new ScaleButton(new $HeartFull()).appendTo(_leftSideTray).move(_toolbox.x+167 + 1, _toolbox.y+12.5+21 + 23)
				.onButtonClick(function(e:Event){ _panes.openPane(WorldPaneManager.FAVORITES_PANE); }) as ScaleButton;
			favButton.visible = FavoriteItemsLocalStorageManager.getAllFavorites().length > 0;
			Fewf.dispatcher.addEventListener(ConstantsApp.FAVORITE_ADDED_OR_REMOVED, function(e:FewfEvent):void{
				favButton.visible = FavoriteItemsLocalStorageManager.getAllFavorites().length > 0;
			});
			
			_animationControls = new AnimationControls().move(78, ConstantsApp.APP_HEIGHT - 35/2 - 5).appendTo(_leftSideTray)
				.on(Event.CLOSE, function(e):void{ _toolbox.toggleAnimationButtonOffWithEvent(); });
			
			_addRestoreAutoSaveButtonIfNeeded(Fewf.sharedObject.getData(ConstantsApp.SHARED_OBJECT_KEY_AUTO_SAVE_LOOK));
			
			/////////////////////////////
			// Bottom Left Area
			/////////////////////////////
			var tLangButton:GameButton = LangScreen.createLangButton(30, 25).move(22, ConstantsApp.APP_HEIGHT-17).appendTo(_leftSideTray)
				.onButtonClick(_onLangButtonClicked) as GameButton;
			
			// About Screen Button
			var aboutButton:GameButton = new GameButton(25).setOrigin(0.5).move(tLangButton.x+(tLangButton.Width/2)+2+(25/2), ConstantsApp.APP_HEIGHT - 17).appendTo(_leftSideTray)
				.onButtonClick(_onAboutButtonClicked) as GameButton;
			new TextBase("?", { size:22, color:0xFFFFFF, bold:true, origin:0.5 }).move(0, -1).appendTo(aboutButton);
			
			if(!!(ParentApp.reopenSelectionLauncher())) {
				new ScaleButton(new $BackArrow(), 0.5).appendTo(_leftSideTray)
					.move(22, ConstantsApp.APP_HEIGHT-17-28)
					.onButtonClick(function():void{ ParentApp.reopenSelectionLauncher()(); });
			}
			
			/////////////////////////////
			// Screens
			/////////////////////////////
			_shareScreen = new ShareScreen().on(Event.CLOSE, _onShareScreenClosed);
			_langScreen = new LangScreen().on(Event.CLOSE, _onLangScreenClosed);
			_aboutScreen = new AboutScreen().on(Event.CLOSE, _onAboutScreenClosed);
			
			trashConfirmScreen = new TrashConfirmScreen().move(337, 65)
				.on(TrashConfirmScreen.CONFIRM, _onTrashConfirmScreenConfirm)
				.on(Event.CLOSE, _onTrashConfirmScreenClosed);

			/////////////////////////////
			// Create item panes
			/////////////////////////////
			for each(var tType:ItemType in ItemType.TYPES_WITH_SHOP_PANES) {
				_panes.addPane(WorldPaneManager.itemTypeToId(tType), _setupItemPane(tType));
				if(tType != ItemType.POSE && tType != ItemType.EMOJI) {
					_panes.addPane(WorldPaneManager.itemTypeToFilterId(tType), _setupItemPaneForFiltering(tType));
				}
				// Based on what the character is wearing at start, toggle on the appropriate buttons.
				getShopPane(tType).toggleGridButtonWithData( _character.getItemData(tType) );
			}
			
			Fewf.dispatcher.addEventListener(ConstantsApp.DOWNLOAD_ITEM_DATA_IMAGE, _onSaveItemDataAsImage);
			
			/////////////////////////////
			// Static Panes
			/////////////////////////////
			// Color Picker Pane
			_panes.addPane(WorldPaneManager.COLOR_PANE, new ColorPickerTabPane())
				.on(ColorPickerTabPane.EVENT_COLOR_PICKED, _onColorPickChanged)
				.on(ColorPickerTabPane.EVENT_PREVIEW_COLOR, _onColorPickHoverPreview)
				.on(Event.CLOSE, _onColorPickerBackClicked)
				.on(ColorPickerTabPane.EVENT_ITEM_ICON_CLICKED, function(e){
					_onColorPickerBackClicked(e);
					_removeItem(_panes.colorPickerPane.infobar.itemData.type);
				});
			
			// Color Finder Pane
			_panes.addPane(WorldPaneManager.COLOR_FINDER_PANE, new ColorFinderPane())
				.on(Event.CLOSE, _onColorFinderBackClicked)
				.on(ColorFinderPane.EVENT_ITEM_ICON_CLICKED, function(e){
					_onColorFinderBackClicked(e);
					_removeItem(_panes.colorFinderPane.infobar.itemData.type);
				});
				
			// Config Pane
			if(ConstantsApp.CONFIG_TAB_ENABLED) {
				_panes.addPane(WorldPaneManager.CONFIG_PANE, new ConfigTabPane(_onShareCodeEntered))
					.on(ConfigTabPane.LOOK_CODE_SELECTED, function(e:FewfEvent):void{ _useOutfitShareCode(e.data as String); });
			}
			
			// "Other" Pane
			_panes.addPane(WorldPaneManager.OTHER_PANE, new OtherTabPane(_character))
				.on(OtherTabPane.CUSTOM_SHAMAN_COLOR_CLICKED, function(e:Event):void{ _shamanColorButtonClicked(); })
				.on(OtherTabPane.SHAMAN_COLOR_PICKED, function(e:FewfEvent):void{ _setConfigShamanColor(e.data as int); })
				.on(OtherTabPane.SHAMAN_MODE_CHANGED, function(e:FewfEvent):void{
					_character.outfitData.shamanMode = e.data.shamanMode;
					_panes.otherPane.updateButtonsBasedOnCurrentData();
				})
				.on(OtherTabPane.DISABLE_SKILLS_MODE_CHANGED, function(e:FewfEvent):void{
					_character.outfitData.disableSkillsMode = e.data.disableSkillsMode;
					// If disable skill mode was just enabled but there's not currently a shaman mode set then
					// toggle on shaman mode automatically so user doesn't think the button is busted
					if(_character.outfitData.disableSkillsMode && _character.outfitData.shamanMode == ShamanMode.OFF) {
						_character.outfitData.shamanMode = ShamanMode.NORMAL;
					}
					_panes.otherPane.updateButtonsBasedOnCurrentData();
				})
				.on(OtherTabPane.ITEM_TOGGLED, _otherTabItemToggled)
				.on(OtherTabPane.EYE_DROPPER_CLICKED, function(e:FewfEvent){ _openColorFinderWithItemData(e.data.itemData); })
				.on(OtherTabPane.FILTER_MODE_CLICKED, function(e:Event){ _getAndOpenItemFilteringSelectionMode(); })
				.on(OtherTabPane.EMOJI_CLICKED, function(e:Event){ _panes.openShopPane(ItemType.EMOJI); })
				.on(OtherTabPane.CHEESE_CLICKED, function(e:Event){ _panes.openShopPane(ItemType.BACK); })
				.on(OtherTabPane.SAVE_MOUSE_HEAD_CLICKED, _onSaveMouseHeadClicked);
			
			// "Other" Tab Color Picker Pane
			_panes.addPane(WorldPaneManager.OTHER_COLOR_PANE, new ColorPickerTabPane({ hide_default:true, hideItemPreview:true }))
				.on(ColorPickerTabPane.EVENT_COLOR_PICKED, _onConfigColorPickChanged)
				.on(Event.CLOSE, function(e:Event){ _panes.openPane(WorldPaneManager.OTHER_PANE); });
			
			// Outfit Pane
			_panes.addPane(WorldPaneManager.OUTFITS_PANE, new OutfitManagerTabPane(function(){ return _character.outfitData.stringify_tfmOfficialSyntax() }))
				.on(OutfitManagerTabPane.LOOK_CODE_SELECTED, function(e:FewfEvent){ _useOutfitShareCode(e.data as String) })
				.on(Event.CLOSE, function(e:Event){ _panes.openPane(_shopTabs.getSelectedTabId()); });
			
			// Worn Items Pane
			_panes.addPane(WorldPaneManager.WORN_ITEMS_PANE, new WornItemsPane())
				.on(WornItemsPane.ITEM_CLICKED, function(e:ItemDataEvent){ _goToItemColorPicker(e.itemData); })
				.on(Event.CLOSE, function(e:Event){ _panes.openPane(WorldPaneManager.OTHER_PANE); });
			
			// Favorites Pane
			_panes.addPane(WorldPaneManager.FAVORITES_PANE, new FavoritesTabPane(function(pItemData:ItemData):Boolean{ return pItemData.matches(_character.getItemData(pItemData.type)); }))
				.on(Event.CLOSE, function(e){ _panes.openPane(_shopTabs.getSelectedTabId()); })
				.on(FavoritesTabPane.ITEMDATA_SELECTED, function(e:ItemDataEvent){
					var itemData:ItemData = e.itemData;
					_character.setItemData(itemData);
					_updateUIBasedOnCharacter();
					
					getShopPane(itemData.type).toggleGridButtonWithData( itemData, true );
				})
				.on(FavoritesTabPane.ITEMDATA_REMOVED, function(e:ItemDataEvent){ _removeItem(e.itemData.type); })
				.on(FavoritesTabPane.ITEMDATA_GOTO, function(e:ItemDataEvent){ _goToItem(e.itemData); _goToItemColorPicker(e.itemData); });
			
			// Select First Pane
			_shopTabs.toggleOnFirstTab();
		}

		private function _setupItemPane(pType:ItemType) : ShopCategoryPane {
			var tPane:ShopCategoryPane = new ShopCategoryPane(pType);
			tPane.on(ShopCategoryPane.ITEM_TOGGLED, _onItemToggled);
			tPane.on(ShopCategoryPane.FLAG_WAVE_CODE_CHANGED, function(e:FewfEvent){ _character.outfitData.flagWavingCode = e.data.code; });
			
			tPane.infobar.on(Infobar.COLOR_WHEEL_CLICKED, function(){ _colorButtonClicked(pType); });
			tPane.infobar.on(Infobar.ITEM_PREVIEW_CLICKED, function(){ _removeItem(pType); });
			tPane.infobar.on(Infobar.EYE_DROPPER_CLICKED, function(){ _eyeDropButtonClicked(pType); });
			tPane.infobar.on(GridManagementWidget.RANDOMIZE_CLICKED, function(){ _randomItemOfType(pType); });
			tPane.infobar.on(GridManagementWidget.RANDOMIZE_LOCK_CLICKED, function(e:FewfEvent){
				_character.setItemTypeLock(pType, e.data.locked);
				_updateTabListLockByItemType(pType);
			});
			if(ItemType.OTHER_PANE_ITEM_TYPES.indexOf(pType) > -1) {
				tPane.infobar.on(Infobar.BACK_CLICKED, function(){ _panes.openPane(WorldPaneManager.OTHER_PANE); });
			}
			return tPane;
		}
		private function getShopPane(pType:ItemType) : ShopCategoryPane { return _panes.getShopPane(pType); }
		
		private function _shouldShowShopTab(type:ItemType) : Boolean {
			// Skin & pose have defaults, so always show - also need to list before other check since poses don't have filtering
			return type == ItemType.POSE || type == ItemType.SKIN
				|| !_itemFiltering_filterEnabled || ShareCodeFilteringData.getSelectedIds(type).length > 0;
		}
		
		private function _populateShopTabs() {
			_shopTabs.reset(); // Reset so we start with an empty list
			
			if(_itemFiltering_selectionModeOn && !_itemFiltering_filterEnabled) {
				_shopTabs.addTab("tab_furs", WorldPaneManager.itemTypeToFilterId(ItemType.SKIN));
				_shopTabs.addTab("tab_head", WorldPaneManager.itemTypeToFilterId(ItemType.HEAD));
				_shopTabs.addTab("tab_ears", WorldPaneManager.itemTypeToFilterId(ItemType.EARS));
				_shopTabs.addTab("tab_eyes", WorldPaneManager.itemTypeToFilterId(ItemType.EYES));
				_shopTabs.addTab("tab_mouth", WorldPaneManager.itemTypeToFilterId(ItemType.MOUTH));
				_shopTabs.addTab("tab_neck", WorldPaneManager.itemTypeToFilterId(ItemType.NECK));
				_shopTabs.addTab("tab_tail", WorldPaneManager.itemTypeToFilterId(ItemType.TAIL));
				_shopTabs.addTab("tab_hair", WorldPaneManager.itemTypeToFilterId(ItemType.HAIR));
				_shopTabs.addTab("tab_contacts", WorldPaneManager.itemTypeToFilterId(ItemType.CONTACTS));
				_shopTabs.addTab("tab_tattoo", WorldPaneManager.itemTypeToFilterId(ItemType.TATTOO));
				_shopTabs.addTab("tab_hand", WorldPaneManager.itemTypeToFilterId(ItemType.HAND));
			} else {
				if(ConstantsApp.CONFIG_TAB_ENABLED && !_itemFiltering_filterEnabled) _shopTabs.addTab("tab_config", WorldPaneManager.CONFIG_PANE);
				
				for each(var type:ItemType in ItemType.TYPES_WITH_SHOP_PANES) {
					if(ItemType.OTHER_PANE_ITEM_TYPES.indexOf(type) > -1 || !_shouldShowShopTab(type)) continue;
					// Some i18n ids don't match the type string, so manually handling it here
					var i18nStr : String = type == ItemType.SKIN ? 'furs' : type == ItemType.HAND ? 'hand' : type == ItemType.POSE ? 'poses' : type.toString();
					_shopTabs.addTab("tab_"+i18nStr, WorldPaneManager.itemTypeToId(type));
					// .addIcon(
					// 	type == ItemType.SKIN ? "http://www.transformice.com/images/x_transformice/x_interface/x_souris.png?d=855" : 
					// 	type == ItemType.EYES ? "http://www.transformice.com/images/x_transformice/x_interface/glasses.png?d=855" : 
					// 	type == ItemType.CONTACTS ? "http://www.transformice.com/images/x_transformice/x_interface/eye.png?d=855" : 
					// 	type == ItemType.MOUTH ? "http://www.transformice.com/images/x_transformice/x_interface/mouth.png?d=855" : 
					// 	type == ItemType.HAND ? "http://www.transformice.com/images/x_transformice/x_interface/glove.png?d=855" : 
					// 	type == ItemType.NECK ? "http://www.transformice.com/images/x_transformice/x_interface/scarf.png?d=855" : 
					// 	type == ItemType.HEAD ? "http://www.transformice.com/images/x_transformice/x_interface/hat.png?d=855" : 
					// 	type == ItemType.EARS ? "http://www.transformice.com/images/x_transformice/x_interface/earrings.png?d=855" : 
					// 	type == ItemType.TAIL ? "http://www.transformice.com/images/x_transformice/x_interface/tail.png?d=855" : 
					// 	type == ItemType.HAIR ? "http://www.transformice.com/images/x_transformice/x_interface/wig.png?d=855" : 
					// 	type == ItemType.TATTOO ? "http://www.transformice.com/images/x_transformice/x_interface/tatoo.png?d=855" : 
					// 	null
					// );
					_updateTabListLockByItemType(type);
					_updateTabListItemIndicatorByType(type);
				}
				_shopTabs.addTab("tab_other", WorldPaneManager.OTHER_PANE);
			}
		}
		private function _updateTabListLockByItemType(pType:ItemType) {
			if(ItemType.OTHER_PANE_ITEM_TYPES.indexOf(pType) > -1) return;
			_shopTabs.getTabButton(WorldPaneManager.itemTypeToId(pType)).setLocked(_character.isItemTypeLocked(pType));
		}
		private function _updateTabListItemIndicatorByType(pType:ItemType) {
			if(ItemType.OTHER_PANE_ITEM_TYPES.indexOf(pType) > -1) return;
			
			var tItemData:ItemData = _character.getItemData(pType);
			var tHadIndicator:Boolean = !!tItemData && !tItemData.matches(GameAssets.defaultSkin) && !tItemData.matches(GameAssets.defaultPose);
			_shopTabs.getTabButton(WorldPaneManager.itemTypeToId(pType)).setItemIndicator(tHadIndicator);
		}

		private function _onMouseWheel(pEvent:MouseEvent) : void {
			if(this.mouseX < _shopTabs.x) {
				_toolbox.scaleSlider.updateViaMouseWheelDelta(pEvent.delta);
				_character.scale = _toolbox.scaleSlider.value;
				_character.clampCoordsToDragBounds();
			}
		}

		private function _onKeyDownListener(e:KeyboardEvent) : void {
			if (e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN){
				var pane:SidePane = _panes.getOpenPane();
				if(pane && pane is ButtonGridSidePane) {
					(pane as ButtonGridSidePane).handleKeyboardDirectionalInput(e.keyCode);
				}
				else if(pane && pane is ColorPickerTabPane) {
					if (e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN) {
						(pane as ColorPickerTabPane).nextSwatch(e.keyCode == Keyboard.DOWN);
					}
				}
			}
		}

		private function _onScaleSliderChange(e:Event):void {
			_character.scale = _toolbox.scaleSlider.value;
			_character.clampCoordsToDragBounds();
		}

		private function _onScaleSliderDefaultClicked(e:Event):void {
			_character.scale = _toolbox.scaleSlider.value = ConstantsApp.DEFAULT_CHARACTER_SCALE;
			_character.clampCoordsToDragBounds();
		}

		private function _onShareCodeEntered(code:String, pProgressCallback:Function):void {
			if(!code || code == "") { return; pProgressCallback("placeholder"); }
			
			try {
				pProgressCallback("loading");
				_useUnknownShareCode(code, function(parseSuccess){
					// Now tell code box that we are done
					pProgressCallback(parseSuccess ? "success" : "invalid");
				});
			}
			catch (error:Error) {
				pProgressCallback("invalid");
			};
		}
		private function _useUnknownShareCode(code:String, callback:Function) : void {
			code = FewfUtils.trim(code);
			if(ShareCodeFilteringData.isValidCode(code)) {
				_useItemFilterShareCode(code, callback);
			} else {
				callback( _useOutfitShareCode(code) );
			}
		}
		
		private function _useOutfitShareCode(code:String) : Boolean {
			code = FewfUtils.trim(code);
			if(code.indexOf("?") > -1) {
				code = code.substr(code.indexOf("?") + 1, code.length);
			}
		
			// First remove old stuff to prevent conflicts
			_character.outfitData.shamanMode = ShamanMode.OFF;
			for each(var tLayerType:ItemType in ItemType.ALL) {
				if(!_character.isItemTypeLocked((tLayerType))) _removeItem(tLayerType);
			}
			
			var parseSuccess:Boolean = _character.outfitData.parseShareCode(code);
			
			_character.updatePose();
			
			for each(var tType:ItemType in ItemType.TYPES_WITH_SHOP_PANES) {
				if(!_character.isItemTypeLocked(tType)) _refreshButtonCustomizationForItemData(_character.getItemData(tType));
			}
			
			// now update the infobars
			_updateUIBasedOnCharacter();
			_panes.otherPane.updateButtonsBasedOnCurrentData();
			
			return parseSuccess;
		}
		
		private function _useItemFilterShareCode(code:String, callback:Function) : void {
			code = FewfUtils.trim(code);
			
			var pastebinKey = ShareCodeFilteringData.checkIfPastebin(code);
			if(pastebinKey) {
				var fetchpastebin_url:String = Fewf.assets.getData("config").fetchpastebin_url;
				if(!fetchpastebin_url) { callback(false); return; }
				
				var url:String = fetchpastebin_url+"?key="+pastebinKey;
				Fewf.assets.loadWithCallback([ [url, { type:"txt", name:pastebinKey }] ], function():void{
					_useItemFilterShareCode(Fewf.assets.getData(pastebinKey), callback);
				});
				return;
			}
		
			try {
				// First remove old stuff to prevent conflicts
				_character.outfitData.shamanMode = ShamanMode.OFF;
				for each(var tLayerType:ItemType in ItemType.ALL) { _removeItem(tLayerType); }
				
				// If selection mode is active, end it
				_itemFiltering_selectionModeOn = false;
				_toggleFilterSelectionModeTray();
				
				// Parse actual code
				var parseSuccess:Boolean = ShareCodeFilteringData.parseShareCode(code);
				if(parseSuccess) {
					_enableFilterMode();
					
					_character.updatePose();
					
					for each(var tType:ItemType in ItemType.TYPES_WITH_SHOP_PANES) { _refreshButtonCustomizationForItemData(_character.getItemData(tType)); }
					
					// now update the infobars
					_updateUIBasedOnCharacter();
					_panes.otherPane.updateButtonsBasedOnCurrentData();
				}
			
				callback(parseSuccess);
			}
			catch (err:Error) {
				_exitFilterMode();
				callback(false);
			};
		}
		
		private function _updateAllShopPaneFilters() : void {
			for each(var tType:ItemType in ItemType.TYPES_WITH_SHARE_FILTER_PANES) {
				// Remove encase existing item is a filtered one
				_removeItem(tType);
				
				var ids : Vector.<String> = ShareCodeFilteringData.getSelectedIds(tType).concat();
				if(_itemFilterBanner.onlyShowCustomizableItemsToggleOn && tType != ItemType.SKIN) { // Skins don't have customizations
					ids = ids.filter(function(id:String,i,a):Boolean{ return ShareCodeFilteringData.isCustomizableId(tType, id); });
				}
				if(tType == ItemType.SKIN && ids.length == 0) {
					ids.push(GameAssets.defaultSkin.id);
				}
				getShopPane(tType).filterItemIds(ids);
				// Remove everything again to make sure "defaults" are correctly selected (ex: if fur 0 isn't a selected one)
				_removeItem(tType);
			}
		}
		
		private function _clearItemFiltering() : void {
			for each(var tType:ItemType in ItemType.TYPES_WITH_SHOP_PANES) {
				getShopPane(tType).filterItemIds(null);
			}
		}
		
		private function _onCharacterPoseUpdated(e:Event) : void {
			_animationControls.setTargetMovieClip(_character.pose.poseMC);
			Fewf.sharedObject.setData(ConstantsApp.SHARED_OBJECT_KEY_AUTO_SAVE_LOOK, _character.outfitData.stringify_fewfreSyntax());
			_removeRestoreAutoSaveButton();
			
			if(_panes.wornItemsPane && _panes.wornItemsPane.flagOpen) _panes.wornItemsPane.init(_character.outfitData);
		}
		
		private function _addRestoreAutoSaveButtonIfNeeded(autoSavedLook:String) : void {
			// Don't show button if it's the default look
			if(autoSavedLook && autoSavedLook != "s=1&p=Statique") {
				// Make it a timeout so it's added after the initial character pose update event fires
				setTimeout(function():void{
					// If auto saved outfit, prompt user to use or not
					(_restoreAutoSaveBtn = new GameButton(120, 16)).setText("restore_auto_save_btn", { size:10 }).setOrigin(0.5).move(185, 90).setData({ look:autoSavedLook }).appendTo(_leftSideTray)
						.onButtonClick(function(e:FewfEvent):void{ _useOutfitShareCode(e.data.look); });
				}, 100);
			}
		}
		private function _removeRestoreAutoSaveButton() : void {
			if(_restoreAutoSaveBtn) {
				_restoreAutoSaveBtn.removeSelf();
				_restoreAutoSaveBtn = null;
			}
		}

		private function _onPlayerAnimationToggle(e:Event):void {
			if(!_animationControls.visible) {
				_animationControls.show();
				_animationControls.setTargetMovieClip(_character.pose.poseMC);
			} else {
				_animationControls.hide();
			}
		}
		public function isCharacterAnimating() : Boolean {
			return _animationControls.visible;
		}
		
	//#region Saving
		private function _getHardcodedSaveScale() : Number {
			var hardcodedSaveScale:Object = Fewf.sharedObject.getData(ConstantsApp.SHARED_OBJECT_KEY_HARDCODED_SAVE_SCALE);
			return hardcodedSaveScale ? hardcodedSaveScale as Number : 0;
		}

		private function _onSaveClicked(pEvent:Event) : void {
			_saveAsPNG(_character.pose, "character", _character.pose.scaleX);
		}
		
		private function _saveAsAnimation(pFormat:String=null) : void {
			if(!ConstantsApp.ANIMATION_DOWNLOAD_ENABLED) return _onSaveClicked(null);
			
			// FewfDisplayUtils.saveAsSpriteSheet(_character.copy().outfit.pose, "spritesheet", this.character.outfit.scaleX);
			_toolbox.downloadButtonEnable(false);
			FewfDisplayUtils.saveAsAnimatedGif(new Pose().applyOutfitData(_character.outfitData).poseMC, "character", _getHardcodedSaveScale() || _character.pose.scaleX, pFormat, function(){
				_toolbox.downloadButtonEnable(true);
			});
		}
		
		private function _onSaveItemDataAsImage(e:ItemDataEvent) : void {
			if(!e.itemData) { return; }
			var itemData:ItemData = e.itemData;
			var tName:String = "shop-"+itemData.type+itemData.id;
			var tScale:int = ConstantsApp.ITEM_SAVE_SCALE;
			if(itemData.type == ItemType.CONTACTS) { tScale *= 2; }
			_saveAsPNG(GameAssets.getColoredItemImage(itemData), tName, tScale);
		}
		
		private function _saveAsPNG(pObj:DisplayObject, pName:String, pScale:Number) : void {
			var hardcodedCanvasSaveSize:Object = Fewf.sharedObject.getData(ConstantsApp.SHARED_OBJECT_KEY_HARDCODED_CANVAS_SAVE_SIZE);
			if(!hardcodedCanvasSaveSize) {
				FewfDisplayUtils.saveAsPNG(pObj, pName, _getHardcodedSaveScale() || pScale);
			} else {
				var tOffsetY:Number = 0;
				if(pName === 'character' && pObj is Pose) tOffsetY = Math.floor(8*(pObj as Pose).scaleX); // Since the feet aren't in the center; rough calc but gets it closer to center
				FewfDisplayUtils.saveAsPNGWithFixedCanvasSize(pObj, pName, hardcodedCanvasSaveSize as Number, 0, tOffsetY);
			}
		}

		private function _onClipboardButtonClicked(e:Event) : void {
			try {
				if(ConstantsApp.ANIMATION_DOWNLOAD_ENABLED && isCharacterAnimating()) {
					FewfDisplayUtils.copyToClipboardAnimatedGif(new Pose().applyOutfitData(_character.outfitData).poseMC, 1, function(){
						_toolbox.updateClipboardButton(false, false);
					})
				} else {
					FewfDisplayUtils.copyToClipboard(_character.pose, _getHardcodedSaveScale() || _character.pose.scaleX);
					_toolbox.updateClipboardButton(false, true);
				}
			} catch(e) {
				_toolbox.updateClipboardButton(false, false);
			}
			setTimeout(function(){ _toolbox.updateClipboardButton(true); }, 750);
		}
		
		private function _onSaveMouseHeadClicked(pEvent:FewfEvent) {
			FewfDisplayUtils.saveAsPNG(pEvent.data as Sprite, 'mouse_head', _character.pose.scaleX);
		}
	//#endregion Saving

	//#region Item Change Logic
		// Note: does not automatically de-select previous buttons / infobars; do that before calling this
		// This function is required when setting data via parseParams
		private function _updateUIBasedOnCharacter() : void {
			var tPane:ShopCategoryPane;
			for each(var tType:ItemType in ItemType.TYPES_WITH_SHOP_PANES) {
				tPane = getShopPane(tType);
				// Based on what the character is wearing at start, toggle on the appropriate buttons.
				tPane.toggleGridButtonWithData( _character.getItemData(tType), true );
			}
			getShopPane(ItemType.POSE).flagWaveInput.text = _character.outfitData.flagWavingCode || "";
		}

		private function _onItemToggled(e:ItemDataEvent) : void {
			var tItemData:ItemData = e.itemData;

			// De-select all buttons that aren't the clicked one.
			var tPane:ShopCategoryPane = getShopPane(tItemData.type), tInfobar:Infobar = tPane.infobar;
			var tButton:PushButton = tPane.getButtonWithItemData(tItemData);
			// If clicked button is toggled on, equip it. Otherwise remove it.
			if(tButton.pushed) {
				var showColorWheel : Boolean = tItemData.isCustomizable;
				if(showColorWheel) {
					if(_itemFiltering_filterEnabled) {
						showColorWheel = ShareCodeFilteringData.isCustomizable(tItemData);
						// If the item can normally be customized but they're turned off by filtering, force reset the color to default
						if(!showColorWheel) {
							tItemData.setColorsToDefault();
						}
					}
				}
				_character.setItemData(tItemData);
				tInfobar.addInfo( tItemData, GameAssets.getColoredItemImage(tItemData) );
				tInfobar.showColorWheel(showColorWheel);
			} else {
				_removeItem(tItemData.type);
			}
			_updateTabListItemIndicatorByType(tItemData.type);
		}

		private function _otherTabItemToggled(e:FewfEvent) : void { _toggleItemSelectionOneOff(e.data.type, e.data.itemData); }
		private function _toggleItemSelectionOneOff(pType:ItemType, pItemData:ItemData) : void {
			if (pItemData) {
				_character.setItemData( pItemData );
			} else {
				_character.removeItem(pType);
			}
		}

		private function _removeItem(pType:ItemType) : void {
			if(ItemType.OTHER_PANE_ITEM_TYPES_WITH_NO_SUB_PANE.indexOf(pType) > -1) {
				_character.removeItem(pType);
			}
			var tPane:ShopCategoryPane = getShopPane(pType);
			if(!tPane || tPane.infobar.hasData == false) { return; }

			// If item has a default value, toggle it on. otherwise remove item.
			if(!!tPane.defaultItemData) {
				tPane.getButtonWithItemData(tPane.defaultItemData).toggleOn();
			} else {
				var tOldData:ItemData = _character.getItemData(pType);
				_character.removeItem(pType);
				tPane.infobar.removeInfo();
				if(tOldData) tPane.getButtonWithItemData(tOldData).toggleOff();
			}
			_updateTabListItemIndicatorByType(pType);
		}
		
		private function _onTabClicked(pEvent:FewfEvent) : void {
			_panes.openPane(pEvent.data.toString());
		}

		private function _onRandomizeDesignClicked(pEvent:Event) : void {
			for each(var tType:ItemType in ItemType.TYPES_WITH_SHOP_PANES) {
				if(tType == ItemType.EMOJI || tType == ItemType.BACK) { _removeItem(tType); continue; }
				var odds:Number = tType == ItemType.POSE ? 0.5 : 0.65;
				_randomItemOfType(tType, Math.random() <= odds);
			}
			_panes.otherPane.updateButtonsBasedOnCurrentData();
		}

		private function _randomItemOfType(pType:ItemType, pSetToDefault:Boolean=false) : void {
			var pane:ShopCategoryPane = getShopPane(pType);
			if(_character.isItemTypeLocked(pType) || !pane.buttons.length) { return; }
			
			if(!pSetToDefault) {
				pane.chooseRandomItem();
			} else {
				_removeItem(pType);
				// Set to default values for required types
				if(!!pane.defaultItemData) {
					if(pane.flagOpen) pane.scrollItemIntoView(pane.getCellWithItemData(pane.defaultItemData));
				}
			}
		}
		
		private function _goToItem(pItemData:ItemData) : void {
			var itemType:ItemType = pItemData.type;
			
			// These are special types that don't have thier own unique panes
			if(ItemType.OTHER_PANE_ITEM_TYPES_WITH_NO_SUB_PANE.indexOf(itemType) > -1) {
				_shopTabs.toggleTabOn(WorldPaneManager.OTHER_PANE);
				_character.setItemData(pItemData);
				_panes.otherPane.updateButtonsBasedOnCurrentData();
				return;
			}
			
			if(ItemType.OTHER_PANE_ITEM_TYPES.indexOf(itemType) > -1) {
				_shopTabs.toggleTabOn(WorldPaneManager.OTHER_PANE);
				_panes.openShopPane(itemType);
			} else {
				_shopTabs.toggleTabOn(WorldPaneManager.itemTypeToId(itemType));
			}
			getShopPane(itemType).toggleGridButtonWithData( _character.getItemData(itemType), true );
		}
		
		private function _goToItemColorPicker(pItemData:ItemData) : void {
			_goToItem(pItemData);
			var tPane:ShopCategoryPane = getShopPane(pItemData.type);
			if(tPane && tPane.infobar && tPane.infobar.colorWheelEnabled) _colorButtonClicked(pItemData.type);
		}
	//#endregion Item Change Logic
		
	//#region Screen Logic
		private function _onShareButtonClicked(e:Event) : void {
			var tURL = "", tOfficialCode = "";
			try {
				if(Fewf.isExternallyLoaded || !Fewf.isBrowserLoaded) {
					tURL = _character.outfitData.stringify_fewfreSyntax();
				} else {
					tURL = ExternalInterface.call("eval", "window.location.origin+window.location.pathname");
					tURL += "?"+_character.outfitData.stringify_fewfreSyntax();
				}
			} catch (error:Error) {
				tURL = "<error creating link>";
			};
			
			try {
				tOfficialCode = _character.outfitData.stringify_tfmOfficialSyntax();
			} catch (error:Error) {
				tOfficialCode = "<error creating link>";
			};

			_shareScreen.open(tURL, tOfficialCode, _character.pose);
			addChild(_shareScreen);
		}
		private function _onShareScreenClosed(e:Event) : void { removeChild(_shareScreen); }

		private function _onTrashButtonClicked(e:Event) : void { addChild(trashConfirmScreen); }
		private function _onTrashConfirmScreenClosed(e:Event) : void { removeChild(trashConfirmScreen); }

		private function _onLangButtonClicked(e:Event) : void { _langScreen.open(); addChild(_langScreen); }
		private function _onLangScreenClosed(e:Event) : void { removeChild(_langScreen); }

		private function _onAboutButtonClicked(e:Event) : void { _aboutScreen.open(); addChild(_aboutScreen); }
		private function _onAboutScreenClosed(e:Event) : void { removeChild(_aboutScreen); }
		
		private function _onTrashConfirmScreenConfirm(e:Event) : void {
			_character.outfitData.shamanMode = ShamanMode.OFF;
			// Remove items
			for each(var tLayerType:ItemType in ItemType.ALL) { _removeItem(tLayerType); }
			
			// Refresh panes
			for each(var tType:ItemType in ItemType.TYPES_WITH_SHOP_PANES) {
				var pane:ShopCategoryPane = getShopPane(tType);
				pane.infobar.unlockRandomizeButton(); // this will also update `_character.setItemTypeLock()`
				
				// Reset customizations
				if(tType != ItemType.POSE) {
					var dataList:Vector.<ItemData> = GameAssets.getItemDataListByType(tType);
					
					for(var i:int = 0; i < dataList.length; i++){
						if(dataList[i].hasModifiedColors()) {
							dataList[i].setColorsToDefault();
							_refreshButtonCustomizationForItemData(dataList[i]);
						}
					}
				}
				
			}
			_panes.otherPane.updateButtonsBasedOnCurrentData();
			LockHistoryMap.deleteAllLockHistory();
		}
	//#endregion Screen Logic
	
	//#region Item Filter Mode
		// Enables it using data already in ShareCodeFilteringData
		private function _enableFilterMode() : void {
			_itemFiltering_filterEnabled = true;
			_itemFilterBanner.show();
			_populateShopTabs();
			_updateAllShopPaneFilters();
			_toggleFilterSelectionModeTray();
			// Select first tab available
			_shopTabs.toggleOnFirstTab();
		}
		
		private function _onExitItemFilteringMode(e:Event) : void { _exitFilterMode(); };
		private function _exitFilterMode() : void {
			_itemFiltering_filterEnabled = false;
			_itemFilterBanner.hide();
			_populateShopTabs();
			_clearItemFiltering();
			_toggleFilterSelectionModeTray();
			// Select first tab available (needed since tabs repopulated)
			_shopTabs.toggleOnFirstTab();
		}
		
		private function _toggleItemFilterModeToOnlyShowCustomizableItems(e:Event) : void {
			_updateAllShopPaneFilters();
		}
	//#endregion Item Filter Mode
	
	//#region Item Filtering Selection Mode
		private function _initFilterSelectionModeTray() : void {
			_filterModeTray = DisplayWrapper.wrap(new Sprite(), this).toVisible(false).asSprite;
			
			_filterSelectionModeInfoAside = new FilterSelectionModeInfoAside().appendTo(_filterModeTray)
				.on(FilterSelectionModeInfoAside.EVENT_PREVIEW_ENABLED, function(e:FewfEvent){ _enableFilterMode(); })
				.on(FilterSelectionModeInfoAside.EVENT_STOP_FILTERING, function(e:FewfEvent){ _closeItemFilteringSelectionPane(); })
				.on(FilterSelectionModeInfoAside.EVENT_RESET_FILTERING, function(e:FewfEvent){ _resetItemFilteringSelectionPane(); });
		}
		private function _toggleFilterSelectionModeTray() : void {
			_filterModeTray.visible = _itemFiltering_selectionModeOn && !_itemFiltering_filterEnabled;
			_leftSideTray.visible = !_filterModeTray.visible;
		}

		private function _setupItemPaneForFiltering(pType:ItemType) : ShopCategoryPaneForFilteringSelection {
			var tPane:ShopCategoryPaneForFilteringSelection = new ShopCategoryPaneForFilteringSelection(pType);
			tPane.on(ShopCategoryPane.ITEM_TOGGLED, function(e:ItemDataEvent):void{
				_refreshItemFilteringSelectionMode();
			});
			
			// Grid Management Events
			tPane.infobar.on(GridManagementWidget.RANDOMIZE_CLICKED, function(){ _randomItemOfType(pType); });
			return tPane;
		}
		private function _dirtyAllItemFilteringPanes() : void {
			for each(var tType:ItemType in ItemType.TYPES_WITH_SHARE_FILTER_PANES) {
				var pane:ShopCategoryPaneForFilteringSelection = _panes.getFilterSelectionShopPane(tType);
				pane.makeDirty();
			}
		}
	
		private function _getAndOpenItemFilteringSelectionMode() : void {
			_itemFiltering_selectionModeOn = true;
			_exitFilterMode(); // If user is in filter mode but filter pane (thus going into selection mode), then exit filter mode
			_populateShopTabs();
			_dirtyAllItemFilteringPanes();
			_toggleFilterSelectionModeTray();
			_filterSelectionModeInfoAside.update();
			_shopTabs.toggleOnFirstTab();
		}
		private function _refreshItemFilteringSelectionMode() : void {
			_filterSelectionModeInfoAside.update();
		}
		private function _closeItemFilteringSelectionPane() : void {
			_itemFiltering_selectionModeOn = false;
			_clearItemFiltering();
			_populateShopTabs();
			_toggleFilterSelectionModeTray();
			_shopTabs.toggleTabOn(WorldPaneManager.OTHER_PANE);
		}
		private function _resetItemFilteringSelectionPane() : void {
			ShareCodeFilteringData.reset();
			ShareCodeFilteringData.clearShareCodeCache();
			_clearItemFiltering();
			_getAndOpenItemFilteringSelectionMode();
		}
	//#endregion Item Filtering Selection Mode

	//#region Color Tab
		private function _onColorPickChanged(e:FewfEvent):void {
			if(e.data.allUpdated) {
				_character.getItemData(this.currentlyColoringType).colors = e.data.allColors;
			} else {
				_character.getItemData(this.currentlyColoringType).colors[e.data.colorIndex] = uint(e.data.color);
			}
			_refreshSelectedItemColor(this.currentlyColoringType);
		}

		private function _onColorPickHoverPreview(pEvent:FewfEvent) : void {
			// Updated preview data
			GameAssets.swatchHoverPreviewData = pEvent.data;
			// refresh render for anything that uses it
			_refreshSelectedItemColor(this.currentlyColoringType);
		}
		
		private function _refreshSelectedItemColor(pType:ItemType) : void {
			_character.updatePose();
			
			var tPane:ShopCategoryPane = getShopPane(pType);
			var tItemData:ItemData = _character.getItemData(pType);
			if(!tItemData) { return; }
			
			_refreshButtonCustomizationForItemData(tItemData);
			tPane.infobar.refreshItemImageUsingCurrentItemData();
			_panes.colorPickerPane.infobar.refreshItemImageUsingCurrentItemData();
		}
		
		private function _refreshButtonCustomizationForItemData(pItemData:ItemData) : void {
			if(!pItemData) { return; }
			var tPane:ShopCategoryPane = getShopPane(pItemData.type);
			tPane.refreshButtonImage(pItemData);
		}

		private function _colorButtonClicked(pType:ItemType) : void {
			if(_character.getItemData(pType) == null) { return; }

			var tData:ItemData = getShopPane(pType).infobar.itemData;
			_panes.colorPickerPane.infobar.addInfo( tData, GameAssets.getItemImage(tData) );
			this.currentlyColoringType = pType;
			_panes.colorPickerPane.init( tData.uniqId(), tData.colors, tData.defaultColors );
			_panes.openPane(WorldPaneManager.COLOR_PANE);
			_refreshSelectedItemColor(pType);
		}

		private function _onColorPickerBackClicked(pEvent:Event):void {
			_panes.openShopPane(_panes.colorPickerPane.infobar.itemData.type);
		}

		private function _eyeDropButtonClicked(pType:ItemType) : void {
			if(_character.getItemData(pType) == null) { return; }
			var tData:ItemData = getShopPane(pType).infobar.itemData;
			_openColorFinderWithItemData(tData);
		}
		private function _openColorFinderWithItemData(pItemData:ItemData) : void {
			var tItem:MovieClip = GameAssets.getColoredItemImage(pItemData);
			var tItem2:MovieClip = GameAssets.getColoredItemImage(pItemData);
			_panes.colorFinderPane.infobar.addInfo( pItemData, tItem );
			this.currentlyColoringType = pItemData.type;
			_panes.colorFinderPane.setItem(tItem2);
			_panes.openPane(WorldPaneManager.COLOR_FINDER_PANE);
		}

		private function _onColorFinderBackClicked(pEvent:Event):void {
			if(ItemType.OTHER_PANE_ITEM_TYPES_WITH_NO_SUB_PANE.indexOf(_panes.colorFinderPane.infobar.itemData.type) > -1) {
				_panes.openPane(WorldPaneManager.OTHER_PANE);
				return;
			}
			_panes.openShopPane(_panes.colorFinderPane.infobar.itemData.type);
		}

		private function _onConfigColorPickChanged(pEvent:FewfEvent):void {
			_setConfigShamanColor(uint(pEvent.data.color));
		}
		
		private function _setConfigShamanColor(val:uint) : void {
			_character.outfitData.shamanColor = val;
			_character.updatePose();
		}

		private function _shamanColorButtonClicked() : void {
			_panes.otherColorPickerPane.init( 'shamancolor', new <uint>[ _character.outfitData.shamanColor ], null );
			_panes.openPane(WorldPaneManager.OTHER_COLOR_PANE);
		}
	//#endregion Color Tab
	}
}
