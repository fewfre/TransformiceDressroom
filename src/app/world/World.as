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
	import app.ui.panes.infobar.GridManagementWidget;
	import app.ui.panes.infobar.Infobar;
	import app.ui.screens.*;
	import app.world.data.*;
	import app.world.elements.*;
	
	import com.fewfre.display.*;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.utils.*;
	import ext.ParentApp;
	
	import flash.display.*;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	import app.world.events.ItemDataEvent;
	
	public class World extends Sprite
	{
		// Storage
		private var character          : Character;
		private var _panes             : WorldPaneManager;

		private var shopTabs           : ShopTabList;
		private var _toolbox           : Toolbox;
		private var _animationControls : AnimationControls;
		
		private var _shareScreen       : ShareScreen;
		private var trashConfirmScreen : TrashConfirmScreen;
		private var _langScreen        : LangScreen;
		private var _aboutScreen       : AboutScreen;

		private var currentlyColoringType:ItemType=null;
		
		private var _itemFiltering_filterEnabled : Boolean = false;
		private var _itemFiltering_selectionModeOn : Boolean = false;
		private var _giantFilterIcon : Sprite;
		
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
			
			/////////////////////////////
			// Create Character
			/////////////////////////////
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
			
			_giantFilterIcon = DisplayWrapper.wrap(new $FilterIcon(), this).toScale(4).move(180, 180 + 50).asSprite;
			_giantFilterIcon.visible = false;
			
			this.character = new Character(new <ItemData>[ GameAssets.defaultSkin, GameAssets.defaultPose ], parms)
				.move(180, 275).setDragBounds(0+4, 73+4, 375-8, Fewf.stage.stageHeight-73-8).appendTo(this);
			this.character.doubleClickEnabled = true;
			this.character.addEventListener(MouseEvent.DOUBLE_CLICK, function(e:MouseEvent){ _panes.openPane(WorldPaneManager.WORN_ITEMS_PANE); })
			this.character.addEventListener(Character.POSE_UPDATED, _onCharacterPoseUpdated);
			
			/////////////////////////////
			// Setup UI
			/////////////////////////////
			var tShop:RoundRectangle = new RoundRectangle(ConstantsApp.SHOP_WIDTH, ConstantsApp.APP_HEIGHT).move(450, 10)
				.appendTo(this).drawAsTray();
			_panes = new WorldPaneManager().appendTo(tShop.root) as WorldPaneManager;
			
			this.shopTabs = new ShopTabList(70, ConstantsApp.APP_HEIGHT).move(375, 10).appendTo(this);
			this.shopTabs.addEventListener(ShopTabList.TAB_CLICKED, _onTabClicked);
			_populateShopTabs();

			/////////////////////////////
			// Top Area
			/////////////////////////////
			_toolbox = new Toolbox(character, _onShareCodeEntered).move(188, 28).appendTo(this)
				.on(Toolbox.SAVE_CLICKED, _onSaveClicked)
				.on(Toolbox.SHARE_CLICKED, _onShareButtonClicked)
				.on(Toolbox.CLIPBOARD_CLICKED, _onClipboardButtonClicked)
				
				.on(Toolbox.SCALE_SLIDER_CHANGE, _onScaleSliderChange)
				
				.on(Toolbox.ANIMATION_TOGGLED, _onPlayerAnimationToggle)
				.on(Toolbox.RANDOM_CLICKED, _onRandomizeDesignClicked)
				.on(Toolbox.TRASH_CLICKED, _onTrashButtonClicked)
				.on(Toolbox.FILTER_BANNER_CLOSED, _onExitItemFilteringMode);
			
			// Outfit Button
			new ScaleButton({ origin:0.5, obj:new $Outfit(), obj_scale:0.4 }).appendTo(this).move(_toolbox.x+167, _toolbox.y+12.5+21)
				.onButtonClick(function(e:Event){ _panes.openPane(WorldPaneManager.OUTFITS_PANE); });
				
			var favButton:ScaleButton = ScaleButton.withObject(new $HeartFull(), 1).appendTo(this).move(_toolbox.x+167 + 1, _toolbox.y+12.5+21 + 23)
				.onButtonClick(function(e:Event){ _panes.openPane(WorldPaneManager.FAVORITES_PANE); }) as ScaleButton;
			favButton.visible = FavoriteItemsLocalStorageManager.getAllFavorites().length > 0;
			Fewf.dispatcher.addEventListener(ConstantsApp.FAVORITE_ADDED_OR_REMOVED, function(e:FewfEvent):void{
				favButton.visible = FavoriteItemsLocalStorageManager.getAllFavorites().length > 0;
			});
			
			_animationControls = new AnimationControls().move(78, pStage.stageHeight - 35/2 - 5).appendTo(this);
			_animationControls.addEventListener(Event.CLOSE, function(e):void{ _toolbox.toggleAnimationButtonOffWithEvent(); });
			
			/////////////////////////////
			// Bottom Left Area
			/////////////////////////////
			var tLangButton:SpriteButton = LangScreen.createLangButton({ width:30, height:25, origin:0.5 })
				.move(22, pStage.stageHeight-17).appendTo(this)
				.onButtonClick(_onLangButtonClicked) as SpriteButton;
			
			// About Screen Button
			var aboutButton:SpriteButton = new SpriteButton({ size:25, origin:0.5 }).appendTo(this)
				.move(tLangButton.x+(tLangButton.Width/2)+2+(25/2), pStage.stageHeight - 17)
				.onButtonClick(_onAboutButtonClicked) as SpriteButton;
			new TextBase("?", { size:22, color:0xFFFFFF, bold:true, origin:0.5 }).move(0, -1).appendTo(aboutButton)
			
			if(!!(ParentApp.reopenSelectionLauncher())) {
				new ScaleButton({ obj:new $BackArrow(), obj_scale:0.5, origin:0.5 }).appendTo(this)
					.move(22, pStage.stageHeight-17-28)
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
				getShopPane(tType).toggleGridButtonWithData( character.getItemData(tType) );
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
			_panes.addPane(WorldPaneManager.OTHER_PANE, new OtherTabPane(character))
				.on(OtherTabPane.CUSTOM_SHAMAN_COLOR_CLICKED, function(e:Event):void{ _shamanColorButtonClicked(); })
				.on(OtherTabPane.SHAMAN_COLOR_PICKED, function(e:FewfEvent):void{ _setConfigShamanColor(e.data as int); })
				.on(OtherTabPane.ITEM_TOGGLED, _otherTabItemToggled)
				.on(OtherTabPane.FILTER_MODE_CLICKED, function(e:Event){ _getAndOpenItemFilteringPane(); })
				.on(OtherTabPane.EMOJI_CLICKED, function(e:Event){ _panes.openShopPane(ItemType.EMOJI); });
			
			// "Other" Tab Color Picker Pane
			_panes.addPane(WorldPaneManager.OTHER_COLOR_PANE, new ColorPickerTabPane({ hide_default:true, hideItemPreview:true }))
				.on(ColorPickerTabPane.EVENT_COLOR_PICKED, _onConfigColorPickChanged)
				.on(Event.CLOSE, function(e:Event){ _panes.openPane(WorldPaneManager.OTHER_PANE); });
			
			// Outfit Pane
			_panes.addPane(WorldPaneManager.OUTFITS_PANE, new OutfitManagerTabPane(character, _useOutfitShareCode, function(){ return character.getParamsTfmOfficialSyntax() }))
				.on(Event.CLOSE, function(e:Event){ _panes.openPane(shopTabs.getSelectedTabEventName()); });
			
			// Worn Items Pane
			_panes.addPane(WorldPaneManager.WORN_ITEMS_PANE, new WornItemsPane(character, _goToItemColorPicker))
				.on(Event.CLOSE, function(e:Event){ _panes.openPane(WorldPaneManager.OTHER_PANE); });
			
			// Item Filtering Pane
			_panes.addPane(WorldPaneManager.ITEM_FILTERING_PANE, new ItemFilteringPane())
				.on(ItemFilteringPane.EVENT_PREVIEW_ENABLED, function(e:FewfEvent){ _enableFilterMode(); })
				.on(ItemFilteringPane.EVENT_STOP_FILTERING, function(e:FewfEvent){ _closeItemFilteringPane(); })
				.on(ItemFilteringPane.EVENT_RESET_FILTERING, function(e:FewfEvent){ _resetItemFilteringPane(); });
			
			// Favorites Pane
			_panes.addPane(WorldPaneManager.FAVORITES_PANE, new FavoritesTabPane())
				.on(Event.CLOSE, function(e){ _panes.openPane(shopTabs.getSelectedTabEventName()); })
				.on(FavoritesTabPane.ITEMDATA_SELECTED, function(e:FewfEvent){
					var itemData:ItemData = e.data as ItemData;
					character.setItemData(itemData);
					_updateUIBasedOnCharacter();
					
					getShopPane(itemData.type).toggleGridButtonWithData( itemData, true );
				});
			
			// Select First Pane
			shopTabs.tabs[0].toggleOn();
		}

		private function _setupItemPane(pType:ItemType) : ShopCategoryPane {
			var tPane:ShopCategoryPane = new ShopCategoryPane(pType);
			tPane.addEventListener(ShopCategoryPane.ITEM_TOGGLED, _onItemToggled);
			tPane.addEventListener(ShopCategoryPane.DEFAULT_SKIN_COLOR_BTN_CLICKED, function(){ _colorButtonClicked(pType); });
			tPane.addEventListener(ShopCategoryPane.FLAG_WAVE_CODE_CHANGED, function(e:FewfEvent){ character.flagWavingCode = e.data.code; });
			
			tPane.infobar.on(Infobar.COLOR_WHEEL_CLICKED, function(){ _colorButtonClicked(pType); });
			tPane.infobar.on(Infobar.ITEM_PREVIEW_CLICKED, function(){ _removeItem(pType); });
			tPane.infobar.on(Infobar.EYE_DROPPER_CLICKED, function(){ _eyeDropButtonClicked(pType); });
			tPane.infobar.on(GridManagementWidget.RANDOMIZE_CLICKED, function(){ _randomItemOfType(pType); });
			return tPane;
		}
		private function getShopPane(pType:ItemType) : ShopCategoryPane { return _panes.getShopPane(pType); }

		private function _setupItemPaneForFiltering(pType:ItemType) : ShopCategoryPaneForFiltering {
			var tPane:ShopCategoryPaneForFiltering = new ShopCategoryPaneForFiltering(pType);
			tPane.addEventListener(ShopCategoryPane.ITEM_TOGGLED, _onItemToggled);
			tPane.addEventListener(ShopCategoryPane.DEFAULT_SKIN_COLOR_BTN_CLICKED, function(){ _colorButtonClicked(pType); });
			
			// Grid Management Events
			tPane.infobar.on(GridManagementWidget.RANDOMIZE_CLICKED, function(){ _randomItemOfType(pType); });
			return tPane;
		}
		
		private function _shouldShowShopTab(type:ItemType) : Boolean {
			// Skin & pose have defaults, so always show - also need to list before other check since poses don't have filtering
			return type == ItemType.POSE || type == ItemType.SKIN
				|| !_itemFiltering_filterEnabled || ShareCodeFilteringData.getSelectedIds(type).length > 0;
		}
		
		private function _populateShopTabs() {
			var tabs:Vector.<Object>;
			if(_itemFiltering_selectionModeOn && !_itemFiltering_filterEnabled) {
				tabs = new <Object>[
					{ text:"tab_filtering", event:WorldPaneManager.ITEM_FILTERING_PANE },
					{ text:"tab_furs", event:WorldPaneManager.itemTypeToFilterId(ItemType.SKIN) },
					{ text:"tab_head", event:WorldPaneManager.itemTypeToFilterId(ItemType.HEAD) },
					{ text:"tab_ears", event:WorldPaneManager.itemTypeToFilterId(ItemType.EARS) },
					{ text:"tab_eyes", event:WorldPaneManager.itemTypeToFilterId(ItemType.EYES) },
					{ text:"tab_mouth", event:WorldPaneManager.itemTypeToFilterId(ItemType.MOUTH) },
					{ text:"tab_neck", event:WorldPaneManager.itemTypeToFilterId(ItemType.NECK) },
					{ text:"tab_tail", event:WorldPaneManager.itemTypeToFilterId(ItemType.TAIL) },
					{ text:"tab_hair", event:WorldPaneManager.itemTypeToFilterId(ItemType.HAIR) },
					{ text:"tab_contacts", event:WorldPaneManager.itemTypeToFilterId(ItemType.CONTACTS) },
					{ text:"tab_tattoo", event:WorldPaneManager.itemTypeToFilterId(ItemType.TATTOO) },
					{ text:"tab_hand", event:WorldPaneManager.itemTypeToFilterId(ItemType.HAND) },
				];
			} else {
				tabs = new Vector.<Object>();
				if(ConstantsApp.CONFIG_TAB_ENABLED && !_itemFiltering_filterEnabled) tabs.push({ text:"tab_config", event:WorldPaneManager.CONFIG_PANE });
				
				for each(var type:ItemType in ItemType.TYPES_WITH_SHOP_PANES) {
					if(type == ItemType.EMOJI || !_shouldShowShopTab(type)) continue;
					// Some i18n ids don't match the type string, so manually handling it here
					var i18nStr : String = type == ItemType.SKIN ? 'furs' : type == ItemType.HAND ? 'hand' : type == ItemType.POSE ? 'poses' : type.toString();
					tabs.push({ text:"tab_"+i18nStr, event:WorldPaneManager.itemTypeToId(type) });
				}
				tabs.push({ text:"tab_other", event:WorldPaneManager.OTHER_PANE });
			}
			
			this.shopTabs.populate(tabs);
		}

		private function _onMouseWheel(pEvent:MouseEvent) : void {
			if(this.mouseX < this.shopTabs.x) {
				_toolbox.scaleSlider.updateViaMouseWheelDelta(pEvent.delta);
				character.scale = _toolbox.scaleSlider.value;
				character.clampCoordsToDragBounds();
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

		private function _onScaleSliderChange(pEvent:Event):void {
			character.scale = _toolbox.scaleSlider.value;
			character.clampCoordsToDragBounds();
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
			character.shamanMode = ShamanMode.OFF;
			for each(var tLayerType:ItemType in ItemType.ALL) { _removeItem(tLayerType); }
			
			var parseSuccess:Boolean = character.parseParams(code);
			
			character.updatePose();
			
			for each(var tType:ItemType in ItemType.TYPES_WITH_SHOP_PANES) { _refreshButtonCustomizationForItemData(character.getItemData(tType)); }
			
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
				character.shamanMode = ShamanMode.OFF;
				for each(var tLayerType:ItemType in ItemType.ALL) { _removeItem(tLayerType); }
				
				// If selection mode is active, end it
				_itemFiltering_selectionModeOn = false;
				_showOrHideGiantFilterIcon();
				
				// Parse actual code
				var parseSuccess:Boolean = ShareCodeFilteringData.parseShareCode(code);
				if(parseSuccess) {
					_enableFilterMode();
					
					character.updatePose();
					
					for each(var tType:ItemType in ItemType.TYPES_WITH_SHOP_PANES) { _refreshButtonCustomizationForItemData(character.getItemData(tType)); }
					
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
		
		// Enables it using data already in ShareCodeFilteringData
		private function _enableFilterMode() : void {
			_itemFiltering_filterEnabled = true;
			_toolbox.showItemFilterBanner();
			_populateShopTabs();
			_updateAllShopPaneFilters();
			_showOrHideGiantFilterIcon();
			// Select first tab available
			shopTabs.tabs[0].toggleOn();
		}
		
		private function _onExitItemFilteringMode(e:Event) : void { _exitFilterMode(); };
		private function _exitFilterMode() : void {
			_itemFiltering_filterEnabled = false;
			_toolbox.hideItemFilterBanner();
			_populateShopTabs();
			_clearItemFiltering();
			_showOrHideGiantFilterIcon();
			// Select first tab available (needed since tabs repopulated)
			shopTabs.tabs[0].toggleOn();
		}
		
		private function _updateAllShopPaneFilters() : void {
			for each(var tType:ItemType in ItemType.TYPES_WITH_SHARE_FILTER_PANES) {
				// Remove encase existing item is a filtered one
				_removeItem(tType);
				
				var ids : Vector.<String> = ShareCodeFilteringData.getSelectedIds(tType).concat();
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
		
		private function _dirtyAllItemFilteringPanes() : void {
			for each(var tType:ItemType in ItemType.TYPES_WITH_SHARE_FILTER_PANES) {
				var pane:ShopCategoryPaneForFiltering = _panes.getFilterShopPane(tType);
				pane.makeDirty();
			}
		}
		
		private function _showOrHideGiantFilterIcon() : void {
			_giantFilterIcon.visible = _itemFiltering_selectionModeOn && !_itemFiltering_filterEnabled;
			character.visible = !_giantFilterIcon.visible;
		}
		
		private function _onCharacterPoseUpdated(e:Event) : void {
			_animationControls.setTargetMovieClip(character.outfit.pose);
		}

		private function _onPlayerAnimationToggle(e:Event):void {
			if(!_animationControls.visible) {
				_animationControls.show();
				_animationControls.setTargetMovieClip(character.outfit.pose);
			} else {
				_animationControls.hide();
			}
		}
		public function isCharacterAnimating() : Boolean {
			return _animationControls.visible;
		}

		private function _onSaveClicked(pEvent:Event) : void {
			if(ConstantsApp.ANIMATION_DOWNLOAD_ENABLED && isCharacterAnimating()) {
				// FewfDisplayUtils.saveAsSpriteSheet(this.character.copy().outfit.pose, "spritesheet", this.character.outfit.scaleX);
				_toolbox.downloadButtonEnable(false);
				FewfDisplayUtils.saveAsAnimatedGif(this.character.copy().outfit.pose, "character", this.character.outfit.scaleX, null, function(){
					_toolbox.downloadButtonEnable(true);
				});
			} else {
				FewfDisplayUtils.saveAsPNG(this.character, "character");
			}
		}
		
		private function _onSaveItemDataAsImage(pEvent:FewfEvent) : void {
			if(!pEvent.data) { return; }
			var itemData:ItemData = pEvent.data as ItemData;
			var tName:String = "shop-"+itemData.type+itemData.id;
			var tScale:int = ConstantsApp.ITEM_SAVE_SCALE;
			if(itemData.type == ItemType.CONTACTS) { tScale *= 2; }
			FewfDisplayUtils.saveAsPNG(GameAssets.getColoredItemImage(itemData), tName, tScale);
		}

		private function _onClipboardButtonClicked(e:Event) : void {
			try {
				if(ConstantsApp.ANIMATION_DOWNLOAD_ENABLED && isCharacterAnimating()) {
					FewfDisplayUtils.copyToClipboardAnimatedGif(character.copy().outfit.pose, 1, function(){
						_toolbox.updateClipboardButton(false, false);
					})
				} else {
					FewfDisplayUtils.copyToClipboard(character);
					_toolbox.updateClipboardButton(false, true);
				}
			} catch(e) {
				_toolbox.updateClipboardButton(false, false);
			}
			setTimeout(function(){ _toolbox.updateClipboardButton(true); }, 750);
		}

		// Note: does not automatically de-select previous buttons / infobars; do that before calling this
		// This function is required when setting data via parseParams
		private function _updateUIBasedOnCharacter() : void {
			var tPane:ShopCategoryPane;
			for each(var tType:ItemType in ItemType.TYPES_WITH_SHOP_PANES) {
				tPane = getShopPane(tType);
				// Based on what the character is wearing at start, toggle on the appropriate buttons.
				tPane.toggleGridButtonWithData( character.getItemData(tType), true );
			}
			getShopPane(ItemType.POSE).flagWaveInput.text = character.flagWavingCode || "";
		}

		private function _onItemToggled(e:ItemDataEvent) : void {
			var tItemData:ItemData = e.itemData;

			// De-select all buttons that aren't the clicked one.
			var tPane:ShopCategoryPane = getShopPane(tItemData.type), tInfoBar:Infobar = tPane.infobar;
			var tButton:PushButton = tPane.getButtonWithItemData(tItemData);
			// If clicked button is toggled on, equip it. Otherwise remove it.
			if(tButton.pushed) {
				tPane.selectedButtonIndex = tButton.id;

				var showColorWheel : Boolean = false;
				if(GameAssets.getNumOfCustomColors(tButton.Image as MovieClip) > 0) {
					showColorWheel = true;
					if(_itemFiltering_filterEnabled) {
						showColorWheel = ShareCodeFilteringData.isCustomizable(tItemData);
						// If the item can normally be customized but they're turned off by filtering, force reset the color to default
						if(!showColorWheel) {
							tItemData.setColorsToDefault();
						}
					}
				}
				this.character.setItemData(tItemData);
				tInfoBar.addInfo( tItemData, GameAssets.getColoredItemImage(tItemData) );
				tInfoBar.showColorWheel(showColorWheel);
			} else {
				_removeItem(tItemData.type);
			}
		}

		private function _otherTabItemToggled(e:FewfEvent) : void { _toggleItemSelectionOneOff(e.data.type, e.data.itemData); }
		private function _toggleItemSelectionOneOff(pType:ItemType, pItemData:ItemData) : void {
			if (pItemData) {
				this.character.setItemData( pItemData );
			} else {
				this.character.removeItem(pType);
			}
		}

		private function _removeItem(pType:ItemType) : void {
			if(pType == ItemType.BACK || pType == ItemType.PAW_BACK || pType == ItemType.OBJECT) {
				this.character.removeItem(pType);
			}
			var tTabPane:ShopCategoryPane = getShopPane(pType);
			if(!tTabPane || tTabPane.infobar.hasData == false) { return; }

			// If item has a default value, toggle it on. otherwise remove item.
			if(!!tTabPane.defaultItemData) {
				tTabPane.getButtonWithItemData(tTabPane.defaultItemData).toggleOn();
			} else {
				this.character.removeItem(pType);
				tTabPane.infobar.removeInfo();
				tTabPane.buttons[ tTabPane.selectedButtonIndex ].toggleOff();
			}
		}
		
		private function _onTabClicked(pEvent:FewfEvent) : void {
			_panes.openPane(pEvent.data.toString());
		}

		private function _onRandomizeDesignClicked(pEvent:Event) : void {
			for each(var tType:ItemType in ItemType.TYPES_WITH_SHOP_PANES) {
				if(tType == ItemType.EMOJI) { _removeItem(ItemType.EMOJI); continue; }
				var odds:Number = tType == ItemType.POSE ? 0.5 : 0.65;
				_randomItemOfType(tType, Math.random() <= odds);
			}
			_panes.otherPane.updateButtonsBasedOnCurrentData();
		}

		private function _randomItemOfType(pType:ItemType, pSetToDefault:Boolean=false) : void {
			var pane:ShopCategoryPane = getShopPane(pType);
			if(pane.infobar.isRefreshLocked || !pane.buttons.length) { return; }
			
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
			
			shopTabs.UnpressAll();
			shopTabs.toggleTabOn(WorldPaneManager.itemTypeToId(itemType));
			var tPane:ShopCategoryPane = getShopPane(itemType);
			var itemBttn:PushButton = tPane.toggleGridButtonWithData( character.getItemData(itemType), true );
		}
		
		private function _goToItemColorPicker(pItemData:ItemData) : void {
			_goToItem(pItemData);
			if(getShopPane(pItemData.type).infobar.colorWheelEnabled) _colorButtonClicked(pItemData.type);
		}
		
		//{REGION Screen Logic
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

				_shareScreen.open(tURL, tOfficialCode, character);
				addChild(_shareScreen);
			}
			private function _onShareScreenClosed(pEvent:Event) : void { removeChild(_shareScreen); }

			private function _onTrashButtonClicked(pEvent:Event) : void { addChild(trashConfirmScreen); }
			private function _onTrashConfirmScreenClosed(e:Event) : void { removeChild(trashConfirmScreen); }

			private function _onLangButtonClicked(e:Event) : void { _langScreen.open(); addChild(_langScreen); }
			private function _onLangScreenClosed(e:Event) : void { removeChild(_langScreen); }

			private function _onAboutButtonClicked(e:Event) : void { _aboutScreen.open(); addChild(_aboutScreen); }
			private function _onAboutScreenClosed(e:Event) : void { removeChild(_aboutScreen); }
			
			private function _onTrashConfirmScreenConfirm(pEvent:Event) : void {
				character.shamanMode = ShamanMode.OFF;
				// Remove items
				for each(var tLayerType:ItemType in ItemType.ALL) { _removeItem(tLayerType); }
				
				// Refresh panes
				for each(var tType:ItemType in ItemType.TYPES_WITH_SHOP_PANES) {
					var pane:ShopCategoryPane = getShopPane(tType);
					pane.infobar.unlockRandomizeButton();
					
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
		//}END Screen Logic
		
		//{REGION ItemFiltering Tab
			private function _getAndOpenItemFilteringPane() : void {
				_itemFiltering_selectionModeOn = true;
				_exitFilterMode(); // If user is in filter mode but filter pane (thus going into selection mode), then exit filter mode
				_populateShopTabs();
				_dirtyAllItemFilteringPanes();
				_showOrHideGiantFilterIcon();
				shopTabs.toggleTabOn(WorldPaneManager.ITEM_FILTERING_PANE);
			}
			private function _closeItemFilteringPane() : void {
				_itemFiltering_selectionModeOn = false;
				_clearItemFiltering();
				_populateShopTabs();
				_showOrHideGiantFilterIcon();
				shopTabs.toggleTabOn(WorldPaneManager.OTHER_PANE);
			}
			private function _resetItemFilteringPane() : void {
				ShareCodeFilteringData.reset();
				_clearItemFiltering();
				_getAndOpenItemFilteringPane();
			}
		//}END ItemFiltering Tab

		//{REGION Color Tab
			private function _onColorPickChanged(e:FewfEvent):void {
				if(e.data.allUpdated) {
					this.character.getItemData(this.currentlyColoringType).colors = e.data.allColors;
				} else {
					this.character.getItemData(this.currentlyColoringType).colors[e.data.colorIndex] = uint(e.data.color);
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
				character.updatePose();
				
				var tPane:ShopCategoryPane = getShopPane(pType);
				var tItemData:ItemData = this.character.getItemData(pType);
				if(pType != ItemType.SKIN) {
					var tItem:MovieClip = GameAssets.getColoredItemImage(tItemData);
					GameAssets.copyColor(tItem, tPane.buttons[ tPane.selectedButtonIndex ].Image as MovieClip );
					GameAssets.copyColor(tItem, tPane.infobar.Image );
					GameAssets.copyColor(tItem, _panes.colorPickerPane.infobar.Image);
				} else {
					_replaceImageWithNewImage(tPane.buttons[ tPane.selectedButtonIndex ], GameAssets.getColoredItemImage(tItemData));
					_replaceImageWithNewImage(tPane.infobar, GameAssets.getColoredItemImage(tItemData));
					_replaceImageWithNewImage(_panes.colorPickerPane.infobar, GameAssets.getColoredItemImage(tItemData));
				}
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
				if(data.isBitmap()) { return; } // Bitmaps have no customization
				
				var pane:ShopCategoryPane = getShopPane(data.type);
				var btn:PushButton = pane.getButtonWithItemData(data);
				
				
				if(data.type != ItemType.SKIN) {
					var tItem:MovieClip = GameAssets.getColoredItemImage(data);
					GameAssets.copyColor(tItem, btn.Image as MovieClip );
				} else {
					_replaceImageWithNewImage(btn, GameAssets.getColoredItemImage(data));
				}
			}

			private function _colorButtonClicked(pType:ItemType) : void {
				if(this.character.getItemData(pType) == null) { return; }

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
				if(this.character.getItemData(pType) == null) { return; }

				var tData:ItemData = getShopPane(pType).infobar.itemData;
				var tItem:MovieClip = GameAssets.getColoredItemImage(tData);
				var tItem2:MovieClip = GameAssets.getColoredItemImage(tData);
				_panes.colorFinderPane.infobar.addInfo( tData, tItem );
				this.currentlyColoringType = pType;
				_panes.colorFinderPane.setItem(tItem2);
				_panes.openPane(WorldPaneManager.COLOR_FINDER_PANE);
			}

			private function _onColorFinderBackClicked(pEvent:Event):void {
				_panes.openShopPane(_panes.colorFinderPane.infobar.itemData.type);
			}

			private function _onConfigColorPickChanged(pEvent:FewfEvent):void {
				_setConfigShamanColor(uint(pEvent.data.color));
			}
			
			private function _setConfigShamanColor(val:uint) : void {
				character.shamanColor = val;
				character.updatePose();
			}

			private function _shamanColorButtonClicked() : void {
				_panes.otherColorPickerPane.init( 'shamancolor', new <uint>[ character.shamanColor ], null );
				_panes.openPane(WorldPaneManager.OTHER_COLOR_PANE);
			}
		//}END Color Tab
	}
}
