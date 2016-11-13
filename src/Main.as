package
{
	import com.adobe.images.*;
	import com.piterwilson.utils.*;
	import com.fewfre.utils.AssetManager;
	import com.fewfre.display.*;
	import com.fewfre.events.*;
	import com.fewfre.utils.*;

	import dressroom.ui.*;
	import dressroom.ui.panes.*;
	import dressroom.ui.buttons.*;
	import dressroom.data.*;
	import dressroom.world.data.*;
	import dressroom.world.elements.*;

	import fl.controls.*;
	import fl.events.*;
	import flash.display.*;
	import flash.text.*;
	import flash.events.*
	import flash.external.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.utils.*;

	public class Main extends MovieClip
	{
		// Storage
		private const _LOAD_LOCAL:Boolean = true;

		public static var assets	: AssetManager;
		public static var costumes	: Costumes;

		internal var character		: Character;
		internal var loaderDisplay	: LoaderDisplay;
		internal var _paneManager	: PaneManager;

		internal var shopTabs		: ShopTabContainer;
		internal var _toolbox		: Toolbox;
		internal var linkTray		: LinkTray;

		internal var button_hand	: PushButton;
		internal var button_back	: PushButton;
		internal var button_backHand: PushButton;

		internal var currentlyColoringType:String="";
		internal var configCurrentlyColoringType:String;
		
		// Constants
		public static const COLOR_PANE_ID = "colorPane";
		public static const TAB_OTHER:String = "other";
		public static const CONFIG_COLOR_PANE_ID = "configColorPane";
		
		// Constructor
		public function Main()
		{
			super();

			assets = new AssetManager();
			assets.load([
				_LOAD_LOCAL ? "resources/x_meli_costumes.swf" : "http://www.transformice.com/images/x_bibliotheques/x_meli_costumes.swf",
				_LOAD_LOCAL ? "resources/x_fourrures.swf" : "http://www.transformice.com/images/x_bibliotheques/x_fourrures.swf",
				_LOAD_LOCAL ? "resources/x_fourrures2.swf" : "http://www.transformice.com/images/x_bibliotheques/x_fourrures2.swf",
				_LOAD_LOCAL ? "resources/x_fourrures3.swf" : "http://www.transformice.com/images/x_bibliotheques/x_fourrures3.swf",
				"resources/poses.swf",
			]);
			assets.addEventListener(AssetManager.LOADING_FINISHED, _onLoadComplete);

			loaderDisplay = addChild( new LoaderDisplay({ x:stage.stageWidth * 0.5, y:stage.stageHeight * 0.5, assetManager:assets }) );

			stage.align = StageAlign.TOP;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 16;

			BrowserMouseWheelPrevention.init(stage);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel);
		}

		internal function _onLoadComplete(event:Event) : void
		{
			loaderDisplay.destroy();
			removeChild( loaderDisplay );
			loaderDisplay = null;

			costumes = new Costumes( assets );
			costumes.init();

			/****************************
			* Create Character
			*****************************/
			var parms:flash.net.URLVariables = null;
			try {
				var urlPath:String = ExternalInterface.call("eval", "window.location.href");
				if(urlPath && urlPath.indexOf("?") > 0) {
					urlPath = urlPath.substr(urlPath.indexOf("?") + 1, urlPath.length);
					parms = new flash.net.URLVariables();
					parms.decode(urlPath);
				}
			} catch (error:Error) { };

			this.character = addChild(new Character({ x:180, y:275,
				skin:costumes.skins[costumes.defaultSkinIndex],
				pose:costumes.poses[costumes.defaultPoseIndex],
				params:parms
			}));

			/****************************
			* Setup UI
			*****************************/
			var tShop:RoundedRectangle = addChild(new RoundedRectangle({ x:450, y:10, width:ConstantsApp.SHOP_WIDTH, height:ConstantsApp.APP_HEIGHT }));
			tShop.drawSimpleGradient(ConstantsApp.COLOR_TRAY_GRADIENT, 15, ConstantsApp.COLOR_TRAY_B_1, ConstantsApp.COLOR_TRAY_B_2, ConstantsApp.COLOR_TRAY_B_3);
			_paneManager = tShop.addChild(new PaneManager());
			
			this.shopTabs = addChild(new ShopTabContainer({ x:380, y:10, width:60, height:ConstantsApp.APP_HEIGHT,
				tabs:[
					{ text:"Head", event:ITEM.HAT },
					{ text:"Hair", event:ITEM.HAIR },
					{ text:"Ears", event:ITEM.EARS },
					{ text:"Eyes", event:ITEM.EYES },
					{ text:"Mouth", event:ITEM.MOUTH },
					{ text:"Neck", event:ITEM.NECK },
					{ text:"Tail", event:ITEM.TAIL },
					{ text:"Furs", event:ITEM.SKIN },
					{ text:"Pose", event:ITEM.POSE },
					{ text:"Other", event:"other" }
				]
			}));
			this.shopTabs.addEventListener(ShopTabContainer.EVENT_SHOP_TAB_CLICKED, _onTabClicked);

			// Toolbox
			_toolbox = addChild(new Toolbox({
				x:188, y:28, character:character,
				onSave:_onSaveClicked, onAnimate:_onPlayerAnimationToggle, onRandomize:_onRandomizeDesignClicked,
				onShare:_onShareButtonClicked, onScale:_onScaleSliderChange
			}));
			linkTray = new LinkTray({ x:stage.stageWidth * 0.5, y:stage.stageHeight * 0.5 });
			linkTray.addEventListener(LinkTray.CLOSE, _onShareTrayClosed);

			/****************************
			* Create tabs and panes
			*****************************/
			var tPane = null;
			
			tPane = _paneManager.addPane(COLOR_PANE_ID, new ColorPickerTabPane({}));
			tPane.addEventListener(ColorPickerTabPane.EVENT_COLOR_PICKED, _onColorPickChanged);
			tPane.addEventListener(ColorPickerTabPane.EVENT_DEFAULT_CLICKED, _onDefaultsButtonClicked);
			tPane.addEventListener(ColorPickerTabPane.EVENT_EXIT, _onColorPickerBackClicked);

			// Create the panes
			var tTypes = [ ITEM.HAT, ITEM.HAIR, ITEM.EARS, ITEM.EYES, ITEM.MOUTH, ITEM.NECK, ITEM.TAIL, ITEM.SKIN, ITEM.POSE ], tData:ItemData, tType:String;
			for(var i:int = 0; i < tTypes.length; i++) { tType = tTypes[i];
				tPane = _paneManager.addPane(tType, _setupPane(tType));
				// Based on what the character is wearing at start, toggle on the appropriate buttons.
				tData = character.getItemData(tType);
				if(tData) {
					var tIndex:int = FewfUtils.getIndexFromArrayWithKeyVal(costumes.getArrayByType(tType), "id", tData.id);
					tPane.buttons[ tIndex ].toggleOn();
				}
			}
			_paneManager.addPane(ITEM.SKIN_COLOR, _paneManager.getPane(ITEM.SKIN));
			
			/****************************
			* Other Pane
			*****************************/
			tPane = _paneManager.addPane(TAB_OTHER, new ConfigTabPane(character));
			tPane.button_hand.addEventListener(PushButton.STATE_CHANGED_AFTER, this.buttonHandClickAfter);
			tPane.button_back.addEventListener(PushButton.STATE_CHANGED_AFTER, this.buttonBackClickAfter);
			tPane.button_backHand.addEventListener(PushButton.STATE_CHANGED_AFTER, this.buttonBackHandClickAfter);
			tPane.shamanColorPickerButton.addEventListener(ButtonBase.CLICK, function(pEvent:Event){ _shamanColorButtonClicked(); });
			
			tPane = _paneManager.addPane(CONFIG_COLOR_PANE_ID, new ColorPickerTabPane({ hide_default:true }));
			tPane.addEventListener(ColorPickerTabPane.EVENT_COLOR_PICKED, _onConfigColorPickChanged);
			tPane.addEventListener(ColorPickerTabPane.EVENT_EXIT, function(pEvent:Event){ _paneManager.openPane(TAB_OTHER); });
			
			// Select First Pane
			shopTabs.tabs[0].toggleOn();
			
			tPane = null;
			tTypes = null;
			tData = null;
		}

		private function _setupPane(pType:String) : TabPane {
			var tPane:TabPane = new TabPane();
			tPane.addInfoBar( new ShopInfoBar({}) );
			_setupPaneButtons(pType, tPane, costumes.getArrayByType(pType));
			tPane.infoBar.colorWheel.addEventListener(ButtonBase.CLICK, function(){ _colorButtonClicked(pType); });
			tPane.infoBar.imageCont.addEventListener(MouseEvent.CLICK, function(){ _removeItem(pType); });
			tPane.infoBar.refreshButton.addEventListener(ButtonBase.CLICK, function(){ _randomItemOfType(pType); });
			return tPane;
		}

		private function _setupPaneButtons(pType:String, pPane:TabPane, pItemArray:Array) : void {
			var buttonPerRow = 6;
			var scale = 1;
			if(pType == ITEM.SKIN || pType == ITEM.POSE) {
					buttonPerRow = 5;
					scale = 1;
			}

			var grid:Grid = pPane.grid;
			if(!grid) { grid = pPane.addGrid( new Grid({ x:15, y:5, width:385, columns:buttonPerRow, margin:5 }) ); }
			grid.reset();

			var shopItem : MovieClip;
			var shopItemButton : PushButton;
			var i = -1;
			while (i < pItemArray.length-1) { i++;
				shopItem = costumes.getItemImage(pItemArray[i]);
				shopItem.scaleX = shopItem.scaleY = scale;

				shopItemButton = new PushButton({ width:grid.radius, height:grid.radius, obj:shopItem, id:i, data:{ type:pType, id:i } });
				grid.add(shopItemButton);
				pPane.buttons.push(shopItemButton);
				shopItemButton.addEventListener(PushButton.STATE_CHANGED_AFTER, _onItemToggled);
			}
			pPane.UpdatePane();
		}

		private function handleMouseWheel(pEvent:MouseEvent) : void {
			if(this.mouseX < this.shopTabs.x) {
				_toolbox.scaleSlider.updateViaMouseWheelDelta(pEvent.delta);
				character.scale = _toolbox.scaleSlider.getValueAsScale();
			}
		}

		private function _onScaleSliderChange(pEvent:Event):void {
			character.scale = _toolbox.scaleSlider.getValueAsScale();
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
			Main.costumes.saveMovieClipAsBitmap(this.character, "character");
		}

		private function _onItemToggled(pEvent:FewfEvent) : void {
			var tType = pEvent.data.type;
			var tItemArray:Array = costumes.getArrayByType(tType);
			var tInfoBar:ShopInfoBar = getInfoBarByType(tType);

			// De-select all buttons that aren't the clicked one.
			var tButtons:Array = getButtonArrayByType(tType);
			for(var i:int = 0; i < tButtons.length; i++) {
				if(tButtons[i].data.id != pEvent.data.id) {
					if (tButtons[i].pushed)  { tButtons[i].toggleOff(); }
				}
			}

			var tButton:PushButton = tButtons[pEvent.data.id];
			var tData:ItemData;
			// If clicked button is toggled on, equip it. Otherwise remove it.
			if(tButton.pushed) {
				tData = tItemArray[pEvent.data.id];
				setCurItemID(tType, tButton.id);
				this.character.setItemData(tData);

				tInfoBar.addInfo( tData, costumes.getItemImage(tData) );
				tInfoBar.showColorWheel(costumes.getNumOfCustomColors(tButton.Image) > 0);
			} else {
				_removeItem(tType);
			}
		}

		public function buttonHandClickAfter(pEvent:Event):void {
			toggleItemSelectionOneOff(ITEM.PAW, pEvent.target, costumes.hand);
		}

		public function buttonBackClickAfter(pEvent:Event):void {
			toggleItemSelectionOneOff(ITEM.BACK, pEvent.target, costumes.fromage);
		}

		public function buttonBackHandClickAfter(pEvent:Event):void {
			toggleItemSelectionOneOff(ITEM.PAW_BACK, pEvent.target, costumes.backHand);
		}

		private function toggleItemSelectionOneOff(pType:String, pButton:PushButton, pItemData:ItemData) : void {
			if (pButton.pushed) {
				this.character.setItemData( pItemData );
			} else {
				this.character.removeItem(pType);
			}
		}

		private function _removeItem(pType:String) : void {
			var tTabPane = getTabByType(pType);
			if(tTabPane.infoBar.hasData == false) { return; }

			// If item has a default value, toggle it on. otherwise remove item.
			if(pType == ITEM.SKIN || pType == ITEM.POSE) {
				var tDefaultIndex = (pType == ITEM.POSE ? costumes.defaultPoseIndex : costumes.defaultSkinIndex);
				tTabPane.buttons[tDefaultIndex].toggleOn();
			} else {
				this.character.removeItem(pType);
				tTabPane.infoBar.removeInfo();
				tTabPane.buttons[ tTabPane.selectedButtonIndex ].toggleOff();
			}
		}
		
		private function _onTabClicked(pEvent:flash.events.DataEvent) : void {
			_paneManager.openPane(pEvent.data);
		}

		private function _onRandomizeDesignClicked(pEvent:Event) : void {
			for(var i:int = 0; i < ITEM.LAYERING.length; i++) {
				if(ITEM.LAYERING[i] == ITEM.PAW || ITEM.LAYERING[i] == ITEM.BACK || ITEM.LAYERING[i] == ITEM.PAW_BACK || ITEM.LAYERING[i] == ITEM.SKIN_COLOR) continue;
				_randomItemOfType(ITEM.LAYERING[i]);
			}
			_randomItemOfType(ITEM.POSE);
		}

		private function _randomItemOfType(pType:String) : void {
			var tButtons = getButtonArrayByType(pType);
			var tLength = tButtons.length;
			tButtons[ Math.floor(Math.random() * tLength) ].toggleOn();
		}

		private function _onShareButtonClicked(pEvent:Event) : void {
			var tURL = "";
			try {
				tURL = ExternalInterface.call("eval", "window.location.origin+window.location.pathname");
				tURL += "?"+this.character.getParams();
			} catch (error:Error) {
				tURL = "<error creating link>";
			};

			linkTray.open(tURL);
			addChild(linkTray);
		}

		private function _onShareTrayClosed(pEvent:Event) : void {
			removeChild(linkTray);
		}

		//{REGION Get TabPane data
			private function getTabByType(pType:String) : TabPane {
				return _paneManager.getPane(pType);
			}

			private function getInfoBarByType(pType:String) : ShopInfoBar {
				return getTabByType(pType).infoBar;
			}

			private function getButtonArrayByType(pType:String) : Array {
				return getTabByType(pType).buttons;
			}

			private function getCurItemID(pType:String) : int {
				return getTabByType(pType).selectedButtonIndex;
			}

			private function setCurItemID(pType:String, pID:int) : void {
				getTabByType(pType).selectedButtonIndex = pID;
			}
		//}END Get TabPane data

		//{REGION Color Tab
			private function _onColorPickChanged(pEvent:flash.events.DataEvent):void
			{
				var tVal:uint = uint(pEvent.data);
				this.character.getItemData(this.currentlyColoringType).colors[_paneManager.getPane(COLOR_PANE_ID).selectedSwatch] = tVal;
				_refreshSelectedItemColor();
			}

			private function _onDefaultsButtonClicked(pEvent:Event) : void
			{
				this.character.getItemData(this.currentlyColoringType).setColorsToDefault();
				_refreshSelectedItemColor();
				_paneManager.getPane(COLOR_PANE_ID).setupSwatches( this.character.getColors(this.currentlyColoringType) );
			}
			
			private function _refreshSelectedItemColor() : void {
				character.updatePose();
				
				var tItemData = this.character.getItemData(this.currentlyColoringType);
				var tItem:MovieClip = costumes.colorItem({ obj:new (tItemData.itemClass)(), colors:tItemData.colors });
				costumes.copyColor(tItem, getButtonArrayByType(this.currentlyColoringType)[ getCurItemID(this.currentlyColoringType) ].Image );
				costumes.copyColor(tItem, getInfoBarByType( this.currentlyColoringType ).Image );
				costumes.copyColor(tItem, _paneManager.getPane(COLOR_PANE_ID).infoBar.Image);
				/*var tMC:MovieClip = this.character.getItemFromIndex(this.currentlyColoringType);
				if (tMC != null)
				{
					costumes.colorDefault(tMC);
					costumes.copyColor( tMC, getButtonArrayByType(this.currentlyColoringType)[ getCurItemID(this.currentlyColoringType) ].Image );
					costumes.copyColor(tMC, getInfoBarByType(this.currentlyColoringType).Image);
					costumes.copyColor(tMC, _paneManager.getPane(COLOR_PANE_ID).infoBar.Image);
					
				}*/
			}

			private function _colorButtonClicked(pType:String) : void {
				if(this.character.getItemData(pType) == null) { return; }

				var tData:ItemData = getInfoBarByType(pType).data;
				_paneManager.getPane(COLOR_PANE_ID).infoBar.addInfo( tData, costumes.getItemImage(tData) );
				this.currentlyColoringType = pType;
				_paneManager.getPane(COLOR_PANE_ID).setupSwatches( this.character.getColors(pType) );
				_paneManager.openPane(COLOR_PANE_ID);
			}

			private function _onColorPickerBackClicked(pEvent:Event):void {
				_paneManager.openPane(_paneManager.getPane(COLOR_PANE_ID).infoBar.data.type);
			}

			private function _onConfigColorPickChanged(pEvent:flash.events.DataEvent):void
			{
				var tVal:uint = uint(pEvent.data);
				/*_paneManager.getPane(TAB_OTHER).updateCustomColor(configCurrentlyColoringType, tVal);*/
				costumes.shamanColor = tVal;
				character.updatePose();
			}

			private function _shamanColorButtonClicked(/*pType:String, pColor:int*/) : void {
				/*this.configCurrentlyColoringType = pType;*/
				_paneManager.getPane(CONFIG_COLOR_PANE_ID).setupSwatches( [ costumes.shamanColor ] );
				_paneManager.openPane(CONFIG_COLOR_PANE_ID);
			}
		//}END Color Tab
	}
}
