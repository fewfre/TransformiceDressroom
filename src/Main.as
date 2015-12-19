package 
{
	import GUI.*;
	import data.*;
	import com.adobe.images.*;
	import com.piterwilson.utils.*;
	import fl.controls.*;
	import fl.events.*;
	import flash.display.*;
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.events.Event
	import flash.events.MouseEvent;
	import flash.external.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.utils.*;
	
	public class Main extends MovieClip
	{
		// Settings
		private const _LOAD_LOCAL:Boolean = true;
		
		// Storage
		public static var costumes	: Costumes;
		
		internal var the_mouse		: TheMouse;
		
		internal var shop			: RoundedRectangle;
		internal var shopTabs		: GUI.ShopTabContainer;
		internal var psColorPick	: com.piterwilson.utils.ColorPicker;
		public var scaleSlider		: fl.controls.Slider;
		
		internal var loaders:Array;
		internal var viewLoader:Loader;
		internal var viewLoader2:Loader;
		internal var viewLoader3:Loader;
		internal var loadingSpinner:MovieClip;
		
		internal var loaded_MCs:Array;
		
		internal var buttons_head:Array;
		internal var buttons_eyes:Array;
		internal var buttons_ears:Array;
		internal var buttons_mouth:Array;
		internal var buttons_neck:Array;
		internal var buttons_furs:Array;
		internal var buttons_hair:Array;
		internal var buttons_tail:Array;
		internal var button_hand	: GUI.SpritePushButton;
		internal var button_back	: GUI.SpritePushButton;
		internal var button_backHand: GUI.SpritePushButton;
		
		internal var currentlyColoringType:String="";
		
		internal var selectedSwatch:int=0;
		internal var colorSwatches:Array;
		
		internal var ducking:Boolean=false;
		
		internal var tabPanes:Array;
		internal var tabPanesMap:Object;
		internal var otherPaneI:int;
		internal var tabColorPane:GUI.Tab;
		
		internal var hatButtonPushed:int=-1;
		internal var eyeButtonPushed:int=-1;
		internal var earButtonPushed:int=-1;
		internal var mouthButtonPushed:int=-1;
		internal var neckButtonPushed:int=-1;
		internal var hairButtonPushed:int=-1;
		internal var tailButtonPushed:int=-1;
		internal var furButtonPushed:int=-1;
		
		// Constructor
		public function Main()
		{
			super();
			this.buttons_head = new Array();
			this.buttons_eyes = new Array();
			this.buttons_ears = new Array();
			this.buttons_mouth = new Array();
			this.buttons_neck = new Array();
			this.buttons_furs = new Array();
			this.buttons_hair = new Array();
			this.buttons_tail = new Array();
			
			this.loaded_MCs = new Array();
			
			stage.align = flash.display.StageAlign.TOP;
			stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
			
			var i = -1;
			loaders = new Array();
			
			i++;
			loaders.push( new Loader() );
			loaders[i].contentLoaderInfo.addEventListener(Event.INIT, this.dataLoaded);
			loaders[i].load(new flash.net.URLRequest(_LOAD_LOCAL ? "resources/x_meli_costumes.swf" : "http://www.transformice.com/images/x_bibliotheques/x_meli_costumes.swf"));
			i++;
			loaders.push( new Loader() );
			loaders[i].contentLoaderInfo.addEventListener(Event.INIT, this.dataLoaded);
			loaders[i].load(new flash.net.URLRequest(_LOAD_LOCAL ? "resources/x_fourrures.swf" : "http://www.transformice.com/images/x_bibliotheques/x_fourrures.swf"));
			i++;
			loaders.push( new Loader() );
			loaders[i].contentLoaderInfo.addEventListener(Event.INIT, this.dataLoaded);
			loaders[i].load(new flash.net.URLRequest(_LOAD_LOCAL ? "resources/x_fourrures2.swf" : "http://www.transformice.com/images/x_bibliotheques/x_fourrures2.swf"));
			
			loadingSpinner = new $Loader();
			addChild( loadingSpinner );
			loadingSpinner.x = 900 * 0.5;
			loadingSpinner.y = 425 * 0.5;
			loadingSpinner.scaleX = 2;
			loadingSpinner.scaleY = 2;
			
			addEventListener("enterFrame", this.Update, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel);
			
			this.__setProp_scaleSlider_Scene1_Layer1_0();
		}
		
		internal function dataLoaded(event:Event) : void {
			this.loaded_MCs.push( MovieClip(event.target.content) );
			
			checkIfLoadingDone();
		}
		
		internal function checkIfLoadingDone() : void {
			if(this.loaded_MCs.length >= 3) {
				creatorLoaded();
				
				for(var i = 0; i < loaders.length; i++) {
					loaders[i].contentLoaderInfo.removeEventListener(Event.INIT, this.dataLoaded);
					loaders[i] = null;
				}
				loaders = null;
				
				removeChild( loadingSpinner );
				loadingSpinner = null;
			}
		}
		
		internal function creatorLoaded():*//event:Event):*
		{
			var didDecode:Boolean;
			var sSlider:fl.controls.Slider = null;
			var defaults_btn:GUI.Clickable;
			var i:int;
			var urlPath:String = null;
			var parms:flash.net.URLVariables = null;
			var clothes:String = null;
			var cid:Array = null;
			
			var h_id:int = 0;
			var ey_id:int = 0;
			var ear_id:int = 0;
			var m_id:int = 0;
			var n_id:int = 0;
			
			var hide_head:Boolean = false;
			var hide_eye:Boolean = false;
			var hide_ear:Boolean = false;
			var hide_mouth:Boolean = false;
			var hide_neck:Boolean = false;

			var loc1:*;
			
			trace("resources loaded...");
			costumes = new Costumes( this.loaded_MCs );
			costumes.init();
			didDecode = false;
			try {
				urlPath = flash.external.ExternalInterface.call("function () { return window.location.href; }");
				parms = new flash.net.URLVariables();
				urlPath = urlPath.substr(urlPath.indexOf("?") + 1, urlPath.length);
				parms.decode(urlPath);
				didDecode = true;
			} catch (error:Error) { };
			
			if (didDecode && !(parms.cid == null)) 
			{
				clothes = parms.cid;
				cid = clothes.split(";");
				trace(cid.length);
				if (cid.length < 5) 
				{
					this.the_mouse = new TheMouse(new costumes.head[0].itemClass(), new costumes.eyes[0].itemClass(), new costumes.ears[0].itemClass(), new costumes.mouth[0].itemClass(), new costumes.neck[0].itemClass(), new costumes.hair[0].itemClass(), new costumes.tail[0].itemClass(), new costumes.hand(), new costumes.fromage(), new costumes.backHand());
				}
				else 
				{
					h_id = parseInt(cid[0]);
					ey_id = parseInt(cid[1]);
					ear_id = parseInt(cid[2]);
					m_id = parseInt(cid[3]);
					n_id = parseInt(cid[4]);
					if (isNaN(h_id) || h_id < 0 || h_id > costumes.head.length || isNaN(ey_id) || ey_id < 0 || ey_id > costumes.eyes.length || isNaN(ear_id) || ear_id < 0 || ear_id > costumes.ears.length || isNaN(m_id) || m_id < 0 || m_id > costumes.mouth.length || isNaN(n_id) || n_id < 0 || n_id > costumes.neck.length) 
					{
						this.the_mouse = new TheMouse(new costumes.head[0].itemClass(), new costumes.eyes[0].itemClass(), new costumes.ears[0].itemClass(), new costumes.mouth[0].itemClass(), new costumes.neck[0].itemClass(), new costumes.hair[0].itemClass(), new costumes.tail[0].itemClass(), new costumes.hand(), new costumes.fromage(), new costumes.backHand());
					}
					else 
					{
						hide_head = false;
						hide_eye = false;
						hide_ear = false;
						hide_mouth = false;
						hide_neck = false;
						if (h_id == 0) 
						{
							h_id = 1;
							hide_head = true;
						}
						if (ey_id == 0) 
						{
							ey_id = 1;
							hide_eye = true;
						}
						if (ear_id == 0) 
						{
							ear_id = 1;
							hide_ear = true;
						}
						if (m_id == 0) 
						{
							m_id = 1;
							hide_mouth = true;
						}
						if (n_id == 0) 
						{
							n_id = 1;
							hide_neck = true;
						}
						this.the_mouse = new TheMouse(new costumes.head[(h_id - 1)].itemClass(), new costumes.eyes[(ey_id - 1)].itemClass(), new costumes.ears[(ear_id - 1)].itemClass(), new costumes.mouth[(m_id - 1)].itemClass(), new costumes.neck[(n_id - 1)].itemClass(), new costumes.hair[0].itemClass(), new costumes.tail[0].itemClass(), new costumes.hand(), new costumes.fromage(), new costumes.backHand(), hide_head, hide_eye, hide_ear, hide_mouth, hide_neck);
					}
				}
			}
			else 
			{
				this.the_mouse = new TheMouse(new costumes.head[0].itemClass(), new costumes.eyes[0].itemClass(), new costumes.ears[0].itemClass(), new costumes.mouth[0].itemClass(), new costumes.neck[0].itemClass(), new costumes.hair[0].itemClass(), new costumes.tail[0].itemClass(), new costumes.hand(), new costumes.fromage(), new costumes.backHand());
			}
			addChild(this.the_mouse);
			var btn:SpriteButton = new SpriteButton(5, 5, 60, 60, new $LargeDownload(), 1);
			btn.doMouseover = true;
			//btn.x = 10;
			//btn.y = 10;
			btn.Image.scaleX = btn.Image.scaleY = 1;
			//btn.buttonMode = true;
			addChild(btn);
			btn.addEventListener(flash.events.MouseEvent.MOUSE_UP, function():void { saveScreenshot(); });
			
			sSlider = this.scaleSlider;
			sSlider.addEventListener(fl.events.SliderEvent.CHANGE, function():*
			{
				the_mouse.mouse.scaleX = sSlider.value;
				the_mouse.mouse.scaleY = sSlider.value;
				return;
			})
			sSlider.addEventListener(fl.events.SliderEvent.THUMB_DRAG, function():*
			{
				the_mouse.mouse.scaleX = sSlider.value;
				the_mouse.mouse.scaleY = sSlider.value;
				return;
			})
			
			this.shop = new GUI.RoundedRectangle(450, 10, ConstantsApp.SHOP_WIDTH, ConstantsApp.APP_HEIGHT);//GUI.ShopTabContainer(450, 10, 440, ConstantsApp.APP_HEIGHT);
			this.shop.drawSimpleGradient([ 0x112528, 0x1E3D42 ], 15, 6983586, 1120028, 3294800);
			addChild(this.shop);
			this.shopTabs = new GUI.ShopTabContainer(380, 10, 60, ConstantsApp.APP_HEIGHT);
			addChild(this.shopTabs);
			
			this.tabPanes = new Array();
			this.tabPanesMap = new Object();
			for(var i = 0; i < 9; i++) { this.tabPanes.push( new GUI.Tab() ); }
			this.tabPanes[0].active = true;
			
			_setupColorPickerPane();
			
			this.shopTabs.addEventListener(ShopTabContainer.TAB_HEAD_CLICK, this.tabHeadClicked, false, 0, true);
			this.shopTabs.addEventListener(ShopTabContainer.TAB_EYES_CLICK, this.tabEyesClicked, false, 0, true);
			this.shopTabs.addEventListener(ShopTabContainer.TAB_EARS_CLICK, this.tabEarsClicked, false, 0, true);
			this.shopTabs.addEventListener(ShopTabContainer.TAB_MOUTH_CLICK, this.tabMouthClicked, false, 0, true);
			this.shopTabs.addEventListener(ShopTabContainer.TAB_NECK_CLICK, this.tabNeckClicked, false, 0, true);
			this.shopTabs.addEventListener(ShopTabContainer.TAB_FUR_CLICK, this.tabFurClicked, false, 0, true);
			this.shopTabs.addEventListener(ShopTabContainer.TAB_OTHER_CLICK, this.tabOtherClicked, false, 0, true);
			this.shopTabs.addEventListener(ShopTabContainer.TAB_TAIL_CLICK, this.tabTailClicked, false, 0, true);
			this.shopTabs.addEventListener(ShopTabContainer.TAB_HAIR_CLICK, this.tabHairClicked, false, 0, true);
			
			
			var shopItem : MovieClip;
			var shopItemButton : GUI.SpritePushButton;
			var xoff:Number = 15;
			var yoff:Number = 15;
			var wCtr:int;
			var w:int;
			var h:int;
			
			i = 0;
			_setupPane(this.tabPanes[i], costumes.head, this.buttons_head, this.buttonClickAfter);
			this.tabPanes[i].infoBar.colorWheel.addEventListener(MouseEvent.MOUSE_UP, this.colorBtnHatClicked, false, 0, true);
			this.tabPanes[i].infoBar.imageCont.addEventListener(MouseEvent.MOUSE_UP, this.removeHatClicked, false, 0, true);
			tabPanesMap[ItemType.HAT] = this.tabPanes[i];
			this.shop.addChild(this.tabPanes[i]);
			
			i = 1;
			_setupPane(this.tabPanes[i], costumes.eyes, this.buttons_eyes, this.buttonEyesClickAfter);
			this.tabPanes[i].infoBar.colorWheel.addEventListener(MouseEvent.MOUSE_UP, this.colorBtnEyesClicked, false, 0, true);
			this.tabPanes[i].infoBar.imageCont.addEventListener(MouseEvent.MOUSE_UP, this.removeEyesClicked, false, 0, true);
			tabPanesMap[ItemType.EYES] = this.tabPanes[i];
			
			i = 2;
			_setupPane(this.tabPanes[i], costumes.ears, this.buttons_ears, this.buttonEarsClickAfter);
			this.tabPanes[i].infoBar.colorWheel.addEventListener(MouseEvent.MOUSE_UP, this.colorBtnEarsClicked, false, 0, true);
			this.tabPanes[i].infoBar.imageCont.addEventListener(MouseEvent.MOUSE_UP, this.removeEarsClicked, false, 0, true);
			tabPanesMap[ItemType.EARS] = this.tabPanes[i];
			
			i = 3;
			_setupPane(this.tabPanes[i], costumes.mouth, this.buttons_mouth, this.buttonMouthClickAfter);
			this.tabPanes[i].infoBar.colorWheel.addEventListener(MouseEvent.MOUSE_UP, this.colorBtnMouthClicked, false, 0, true);
			this.tabPanes[i].infoBar.imageCont.addEventListener(MouseEvent.MOUSE_UP, this.removeMouthClicked, false, 0, true);
			tabPanesMap[ItemType.MOUTH] = this.tabPanes[i];
			
			i = 4;
			_setupPane(this.tabPanes[i], costumes.neck, this.buttons_neck, this.buttonNeckClickAfter);
			this.tabPanes[i].infoBar.colorWheel.addEventListener(MouseEvent.MOUSE_UP, this.colorBtnNeckClicked, false, 0, true);
			this.tabPanes[i].infoBar.imageCont.addEventListener(MouseEvent.MOUSE_UP, this.removeNeckClicked, false, 0, true);
			tabPanesMap[ItemType.NECK] = this.tabPanes[i];
			
			i = 5;
			_setupPane(this.tabPanes[i], costumes.hair, this.buttons_hair, this.buttonHairClickAfter);
			this.tabPanes[i].infoBar.colorWheel.addEventListener(MouseEvent.MOUSE_UP, this.colorBtnHairClicked, false, 0, true);
			this.tabPanes[i].infoBar.imageCont.addEventListener(MouseEvent.MOUSE_UP, this.removeHairClicked, false, 0, true);
			tabPanesMap[ItemType.HAIR] = this.tabPanes[i];
			
			i = 6;
			_setupPane(this.tabPanes[i], costumes.tail, this.buttons_tail, this.buttonTailClickAfter);
			this.tabPanes[i].infoBar.colorWheel.addEventListener(MouseEvent.MOUSE_UP, this.colorBtnTailClicked, false, 0, true);
			this.tabPanes[i].infoBar.imageCont.addEventListener(MouseEvent.MOUSE_UP, this.removeTailClicked, false, 0, true);
			tabPanesMap[ItemType.TAIL] = this.tabPanes[i];
			
			i = 7;
			_setupPane(this.tabPanes[i], costumes.furs, this.buttons_furs, this.buttonFursClickAfter, true);
			this.tabPanes[i].infoBar.imageCont.addEventListener(MouseEvent.MOUSE_UP, this.removeFurClicked, false, 0, true);
			this.tabPanes[i].infoBar.colorWheelEnabled = false;
			//this.tabPanes[i].infoBar.colorWheel.addEventListener(MouseEvent.MOUSE_UP, this.colorBtn6Clicked, false, 0, true);
			this.tabPanes[i].infoBar.addInfo(costumes.furs[ConstantsApp.DEFAULT_SKIN_INDEX], new Fur( costumes.furs[ConstantsApp.DEFAULT_SKIN_INDEX] ));
			this.buttons_furs[ConstantsApp.DEFAULT_SKIN_INDEX].ToggleOn();
			tabPanesMap[ItemType.FUR] = this.tabPanes[i];
			
			i = 8;
			wCtr = 0;
			w = 0;
			h = 0;
			var ii = 0;
			this.button_hand = new GUI.SpritePushButton(xoff + 55 * w, yoff + 55 * h, 50, 50, new costumes.hand(), ii);
			this.tabPanes[i].addItem(this.button_hand);
			this.button_hand.addEventListener("state_changed_after", this.buttonHandClickAfter, false, 0, true);
			++ii;
			++w;
			this.button_back = new GUI.SpritePushButton(xoff + 55 * w, yoff + 55 * h, 50, 50, new costumes.fromage(), ii);
			this.tabPanes[i].addItem(this.button_back);
			this.button_back.addEventListener("state_changed_after", this.buttonBackClickAfter, false, 0, true);
			++ii;
			++w;
			this.button_backHand = new GUI.SpritePushButton(xoff + 55 * w, yoff + 55 * h, 50, 50, new costumes.backHand(), ii);
			this.tabPanes[i].addItem(this.button_backHand);
			this.button_backHand.addEventListener("state_changed_after", this.buttonBackHandClickAfter, false, 0, true);
			
			this.tabPanes[i].UpdatePane();
			tabPanesMap["other"] = this.tabPanes[i];
		}
		
		private function _setupPane(pPane:GUI.Tab, pItemArray:Array, pButtonArray:Array, pChangeListener:Function, pIsFur:Boolean=false) : int {
			var shopItem : MovieClip;
			var shopItemButton : GUI.SpritePushButton;
			
			pPane.addInfoBar( new ShopInfoBar({}) );
			
			var xoff = 15;
			var yoff = 5;//15;
			var wCtr = 0;
			var w = 0;
			var h = 0;
			var i = 0;
			while (i < pItemArray.length) 
			{
				if(pIsFur) {
					shopItem = new Fur(costumes.furs[i]);
				} else {
					shopItem = new pItemArray[i].itemClass();
					costumes.colorDefault(shopItem);
				}
				shopItemButton = new GUI.SpritePushButton(xoff + 65 * w, yoff + 65 * h, 60, 60, shopItem, i);
				pPane.addItem(shopItemButton);
				pButtonArray.push(shopItemButton);
				shopItemButton.addEventListener("state_changed_after", pChangeListener, false, 0, true);
				++wCtr;
				++w;
				if (wCtr > 5) 
				{
					w = 0;
					wCtr = 0;
					++h;
				}
				++i;
			}
			pPane.UpdatePane();
			return h;
		}
		
		private function _setupColorPickerPane() : void {
			this.tabColorPane = new GUI.Tab();
			this.tabColorPane.addInfoBar( new ShopInfoBar({ showBackButton:true }) );
			// this.tabColorPane.infoBar.colorWheelEnabled = false;
			this.tabColorPane.infoBar.colorWheel.addEventListener(MouseEvent.MOUSE_UP, this.colorPickerBackClicked, false, 0, true);
			
			this.psColorPick = new com.piterwilson.utils.ColorPicker();
			this.psColorPick.x = 105;
			this.psColorPick.y = 5;
			this.psColorPick.addEventListener(com.piterwilson.utils.ColorPicker.COLOR_PICKED, this.colorPickChanged, false, 0, true);
			this.tabColorPane.addItem(this.psColorPick);
			
			i = -1;
			colorSwatches = new Array();
			i++;
			colorSwatches.push(new GUI.ColorSwatch());
			this.colorSwatches[i].addEventListener(GUI.ColorSwatch.ENTER_PRESSED, this.colorSwatch1OnEnterPressed, false, 0, true);
			this.colorSwatches[i].addEventListener(GUI.ColorSwatch.BUTTON_CLICK, this.colorSwatch1OnClick, false, 0, true);
			i++;
			colorSwatches.push(new GUI.ColorSwatch());
			this.colorSwatches[i].addEventListener(GUI.ColorSwatch.ENTER_PRESSED, this.colorSwatch2OnEnterPressed, false, 0, true);
			this.colorSwatches[i].addEventListener(GUI.ColorSwatch.BUTTON_CLICK, this.colorSwatch2OnClick, false, 0, true);
			i++;
			colorSwatches.push(new GUI.ColorSwatch());
			this.colorSwatches[i].addEventListener(GUI.ColorSwatch.ENTER_PRESSED, this.colorSwatch3OnEnterPressed, false, 0, true);
			this.colorSwatches[i].addEventListener(GUI.ColorSwatch.BUTTON_CLICK, this.colorSwatch3OnClick, false, 0, true);
			i++;
			colorSwatches.push(new GUI.ColorSwatch());
			this.colorSwatches[i].addEventListener(GUI.ColorSwatch.ENTER_PRESSED, this.colorSwatch4OnEnterPressed, false, 0, true);
			this.colorSwatches[i].addEventListener(GUI.ColorSwatch.BUTTON_CLICK, this.colorSwatch4OnClick, false, 0, true);
			i++;
			colorSwatches.push(new GUI.ColorSwatch());
			this.colorSwatches[i].addEventListener(GUI.ColorSwatch.ENTER_PRESSED, this.colorSwatch5OnEnterPressed, false, 0, true);
			this.colorSwatches[i].addEventListener(GUI.ColorSwatch.BUTTON_CLICK, this.colorSwatch5OnClick, false, 0, true);
			i++;
			colorSwatches.push(new GUI.ColorSwatch());
			this.colorSwatches[i].addEventListener(GUI.ColorSwatch.ENTER_PRESSED, this.colorSwatch6OnEnterPressed, false, 0, true);
			this.colorSwatches[i].addEventListener(GUI.ColorSwatch.BUTTON_CLICK, this.colorSwatch6OnClick, false, 0, true);
			i++;
			colorSwatches.push(new GUI.ColorSwatch());
			this.colorSwatches[i].addEventListener(GUI.ColorSwatch.ENTER_PRESSED, this.colorSwatch7OnEnterPressed, false, 0, true);
			this.colorSwatches[i].addEventListener(GUI.ColorSwatch.BUTTON_CLICK, this.colorSwatch7OnClick, false, 0, true);
			i++;
			colorSwatches.push(new GUI.ColorSwatch());
			this.colorSwatches[i].addEventListener(GUI.ColorSwatch.ENTER_PRESSED, this.colorSwatch8OnEnterPressed, false, 0, true);
			this.colorSwatches[i].addEventListener(GUI.ColorSwatch.BUTTON_CLICK, this.colorSwatch8OnClick, false, 0, true);
			i++;
			colorSwatches.push(new GUI.ColorSwatch());
			this.colorSwatches[i].addEventListener(GUI.ColorSwatch.ENTER_PRESSED, this.colorSwatch9OnEnterPressed, false, 0, true);
			this.colorSwatches[i].addEventListener(GUI.ColorSwatch.BUTTON_CLICK, this.colorSwatch9OnClick, false, 0, true);
			
			for(var k = 0; k < colorSwatches.length; k++) {
				this.colorSwatches[k].x = 5;
				this.colorSwatches[k].y = 45 + (k * 30);
				this.tabColorPane.addItem(this.colorSwatches[k]);
			}
			
			//defaults_btn = new GUI.Clickable(6, 325, 100, 22, "Defaults");
			defaults_btn = new GUI.Clickable(6, 10, 100, 22, "Defaults");
			defaults_btn.addEventListener("button_click", this.defaults_btnClicked, false, 0, true);
			this.tabColorPane.addItem(defaults_btn);
			this.tabColorPane.UpdatePane(false);
		}

		public function Update(pEvent:Event):void
		{
			if(this.the_mouse != null) {
				this.the_mouse.Update();
			}
			
			if(loadingSpinner != null) {
				loadingSpinner.rotation += 10;
			}
		}
		
		public function handleMouseWheel(pEvent:MouseEvent) : void {
			if(this.mouseX < this.shopTabs.x) {
				scaleSlider.value += pEvent.delta * 0.1;
				the_mouse.mouse.scaleX = scaleSlider.value;
				the_mouse.mouse.scaleY = scaleSlider.value;
			}
		}

		internal function colorPickChanged(pEvent:flash.events.DataEvent):void
		{
			var tVal:uint = uint(pEvent.data);
			
			colorSwatches[this.selectedSwatch].Value = tVal;
			
			this.the_mouse.colorItem(this.currentlyColoringType, this.selectedSwatch, tVal.toString(16));
			var tItem:MovieClip = this.the_mouse.getItemFromIndex(this.currentlyColoringType);
			if (tItem != null) {
				costumes.copyColor( tItem, getButtonArrayByType(this.currentlyColoringType)[ getCurItemID(this.currentlyColoringType) ].Image );
				costumes.copyColor(tItem, getInfoBarByType( this.currentlyColoringType ).Image );
				costumes.copyColor(tItem, this.tabColorPane.infoBar.Image);
			}
			return;
		}

		internal function saveScreenshot() : void
		{
			var tRect:flash.geom.Rectangle = this.the_mouse.getBounds(this.the_mouse);
			var tBitmap:flash.display.BitmapData = new flash.display.BitmapData(this.the_mouse.width, this.the_mouse.height, true, 16777215);
			tBitmap.draw(this.the_mouse, new flash.geom.Matrix(1, 0, 0, 1, -tRect.left, -tRect.top));
			( new flash.net.FileReference() ).save( com.adobe.images.PNGEncoder.encode(tBitmap), "mouse.png" );
		}

		public function tabHeadClicked(pEvent:Event) : void { _tabClicked( getTabByType(ItemType.HAT) ); }
		public function tabEyesClicked(pEvent:Event) : void { _tabClicked( getTabByType(ItemType.EYES) ); }
		public function tabEarsClicked(pEvent:Event) : void { _tabClicked( getTabByType(ItemType.EARS) ); }
		public function tabMouthClicked(pEvent:Event) : void { _tabClicked( getTabByType(ItemType.MOUTH) ); }
		public function tabNeckClicked(pEvent:Event) : void { _tabClicked( getTabByType(ItemType.NECK) ); }
		public function tabFurClicked(pEvent:Event) : void { _tabClicked( getTabByType(ItemType.FUR) ); }
		public function tabTailClicked(pEvent:Event) : void { _tabClicked( getTabByType(ItemType.TAIL) ); }
		public function tabHairClicked(pEvent:Event) : void { _tabClicked( getTabByType(ItemType.HAIR) ); }
		public function tabOtherClicked(pEvent:Event) : void { _tabClicked( tabPanesMap["other"] ); }
		
		internal function _tabClicked(pTab:GUI.Tab) : void {
			this.HideAllTabs();
			pTab.active = true;
			this.shop.addChild(pTab);
		}

		public function buttonClickAfter(pEvent:Event):void {
			toggleItemSelection(ItemType.HAT, pEvent.target, this.buttons_head, costumes.head, false, getInfoBarByType(ItemType.HAT));
		}

		public function buttonEyesClickAfter(pEvent:Event):void {
			toggleItemSelection(ItemType.EYES, pEvent.target, this.buttons_eyes, costumes.eyes, false, getInfoBarByType(ItemType.EYES));
		}

		public function buttonEarsClickAfter(pEvent:Event):void {
			toggleItemSelection(ItemType.EARS, pEvent.target, this.buttons_ears, costumes.ears, false, getInfoBarByType(ItemType.EARS));
		}

		public function buttonMouthClickAfter(pEvent:Event):void {
			toggleItemSelection(ItemType.MOUTH, pEvent.target, this.buttons_mouth, costumes.mouth, false, getInfoBarByType(ItemType.MOUTH));
		}

		public function buttonNeckClickAfter(pEvent:Event):void {
			toggleItemSelection(ItemType.NECK, pEvent.target, this.buttons_neck, costumes.neck, false, getInfoBarByType(ItemType.NECK));
		}

		public function buttonHairClickAfter(pEvent:Event):void {
			toggleItemSelection(ItemType.HAIR, pEvent.target, this.buttons_hair, costumes.hair, false, getInfoBarByType(ItemType.HAIR));
		}

		public function buttonTailClickAfter(pEvent:Event):void {
			toggleItemSelection(ItemType.TAIL, pEvent.target, this.buttons_tail, costumes.tail, false, getInfoBarByType(ItemType.TAIL));
		}

		public function buttonHandClickAfter(pEvent:Event):void {
			toggleItemSelectionOneOff(ItemType.PAW, this.button_hand, costumes.hand);
		}

		public function buttonBackClickAfter(pEvent:Event):void {
			toggleItemSelectionOneOff(ItemType.BACK, this.button_back, costumes.fromage);
		}

		public function buttonBackHandClickAfter(pEvent:Event):void {
			toggleItemSelectionOneOff(ItemType.PAW_BACK, this.button_backHand, costumes.backHand);
		}
		
		private function toggleItemSelection(pType:String, pTarget:GUI.SpritePushButton, pButtonArray:Array, pItemArray:Array, pColorDefault:Boolean=false, pInfoBar:ShopInfoBar=null) : void {
			var tButton:GUI.SpritePushButton = null;
			var tData:ShopItemData = null;
			
			var i:int=0;
			while (i < pButtonArray.length) 
			{
				tButton = pButtonArray[i] as GUI.SpritePushButton;
				tData = pItemArray[tButton.id];
				
				if (tButton.id != pTarget.id) {
					if (tButton.Pushed)  { tButton.ToggleOff(); }
				}
				else if (tButton.Pushed) {
					setCurItemID(pType, tButton.id);
					this.the_mouse.addItem( pType, costumes.copyColor(tButton.Image, new tData.itemClass()) );
					
					//pTabButt.ChangeImage( costumes.copyColor(tButton.Image, new tData.itemClass()) );
					
					if(pInfoBar != null) {
						pInfoBar.addInfo( tData, costumes.copyColor(tButton.Image, new tData.itemClass()) );
						pInfoBar.colorWheelActive = costumes.getNumOfCustomColors(tButton.Image) > 0;
					}
					
					if(pColorDefault) { this.the_mouse.colorDefault(pType); }
				} else {
					this.the_mouse.removeItem(pType);
					//pTabButt.ChangeImage(new $Cadeau());
					
					if(pInfoBar != null) { pInfoBar.removeInfo(); }
				}
				i++ ;
			}
		}
		
		private function toggleItemSelectionOneOff(pType:String, pButton:GUI.SpritePushButton, pClass:Class) : void {
			if (pButton.Pushed) {
				this.the_mouse.addItem( pType, costumes.copyColor(pButton.Image, new pClass()) );
			} else {
				this.the_mouse.removeItem(pType);
			}
		}

		public function buttonFursClickAfter(pEvent:Event):void {
			var tTarget:GUI.SpritePushButton = pEvent.target as GUI.SpritePushButton;
			var tButton:GUI.SpritePushButton = null;
			
			var i:int = 0;
			while (i < this.buttons_furs.length) {
				tButton = this.buttons_furs[i] as GUI.SpritePushButton;
				
				if (tButton.id != tTarget.id) {
					if (tButton.Pushed) {
						tButton.ToggleOff();
					}
				}
				else if (tButton.Pushed) {
					setCurItemID(ItemType.FUR, tButton.id);
					this.the_mouse.switchFurs(tButton.id);
					getInfoBarByType(ItemType.FUR).addInfo( costumes.furs[tButton.id], new Fur(costumes.furs[tButton.id]) );
					// getInfoBarByType(ItemType.FUR).colorWheelActive = costumes.furs[tButton.id].id == -1;
				} else {
					this.the_mouse.switchFurs(ConstantsApp.DEFAULT_SKIN_INDEX);
					getInfoBarByType(ItemType.FUR).addInfo( costumes.furs[ConstantsApp.DEFAULT_SKIN_INDEX], new Fur(costumes.furs[ConstantsApp.DEFAULT_SKIN_INDEX]) );
					this.buttons_furs[ConstantsApp.DEFAULT_SKIN_INDEX].ToggleOn();
				}
				i++;
			}
		}

		public function buttonClickBefore(pEvent:Event):void { toggleItemBefore(this.buttons_head); }
		public function buttonEyesClickBefore(pEvent:Event):void { toggleItemBefore(this.buttons_eyes); }
		public function buttonEarsClickBefore(pEvent:Event):void { toggleItemBefore(this.buttons_ears); }
		public function buttonMouthClickBefore(pEvent:Event):void { toggleItemBefore(this.buttons_mouth); }
		public function buttonNeckClickBefore(pEvent:Event):void { toggleItemBefore(this.buttons_neck); }
		
		private function toggleItemBefore(pItemArray:Array) : void {
			var tButton:GUI.SpritePushButton = null;
			var i:int = 0;
			while (i < pItemArray.length) {
				tButton = pItemArray[i] as GUI.SpritePushButton;
				if (tButton.Pushed) {
					tButton.Unpressed();
					tButton.Pushed = false;
				}
				++i;
			}
		}

		public function removeHatClicked(pEvent:Event):void { _removeItem(ItemType.HAT); }
		public function removeEyesClicked(pEvent:Event):void { _removeItem(ItemType.EYES); }
		public function removeEarsClicked(pEvent:Event):void { _removeItem(ItemType.EARS); }
		public function removeMouthClicked(pEvent:Event):void { _removeItem(ItemType.MOUTH); }
		public function removeNeckClicked(pEvent:Event):void { _removeItem(ItemType.NECK); }
		public function removeHairClicked(pEvent:Event):void { _removeItem(ItemType.HAIR); }
		public function removeTailClicked(pEvent:Event):void { _removeItem(ItemType.TAIL); }
		
		private function _removeItem(pType:String) : void {
			if(getInfoBarByType(pType).hasData == false) { return; }
			this.the_mouse.removeItem(pType);
			getInfoBarByType(pType).removeInfo();
			getButtonArrayByType(pType)[ getCurItemID(pType) ].ToggleOff();
		}
		public function removeFurClicked(pEvent:Event):void {
			this.the_mouse.switchFurs(ConstantsApp.DEFAULT_SKIN_INDEX);
			getInfoBarByType(ItemType.FUR).addInfo( costumes.furs[ConstantsApp.DEFAULT_SKIN_INDEX], new Fur(costumes.furs[ConstantsApp.DEFAULT_SKIN_INDEX]) );
			getButtonArrayByType(ItemType.FUR)[ getCurItemID(ItemType.FUR) ].ToggleOff();
			this.buttons_furs[ConstantsApp.DEFAULT_SKIN_INDEX].ToggleOn();
		}
		
		private function getCurItemID(pType:String) : int {
			switch(pType) {
				case ItemType.HAT	: return this.hatButtonPushed; break;
				case ItemType.EYES	: return this.eyeButtonPushed; break;
				case ItemType.EARS	: return this.earButtonPushed; break;
				case ItemType.MOUTH	: return this.mouthButtonPushed; break;
				case ItemType.NECK	: return this.neckButtonPushed; break;
				case ItemType.HAIR	: return this.hairButtonPushed; break;
				case ItemType.TAIL	: return this.tailButtonPushed; break;
				case ItemType.FUR	: return this.furButtonPushed; break;
				default: trace("[Main](getCurItemID) Unknown type: "+pType);
			}
		}
		
		private function setCurItemID(pType:String, pID:int) : void {
			switch(pType) {
				case ItemType.HAT	: this.hatButtonPushed = pID; break;
				case ItemType.EYES	: this.eyeButtonPushed = pID; break;
				case ItemType.EARS	: this.earButtonPushed = pID; break;
				case ItemType.MOUTH	: this.mouthButtonPushed = pID; break;
				case ItemType.NECK	: this.neckButtonPushed = pID; break;
				case ItemType.HAIR	: this.hairButtonPushed = pID; break;
				case ItemType.TAIL	: this.tailButtonPushed = pID; break;
				case ItemType.FUR	: this.furButtonPushed = pID; break;
				default: trace("[Main](setCurItemID) Unknown type: "+pType);
			}
		}
		
		private function getTabByType(pType:String) : GUI.Tab {
			return tabPanesMap[pType];
		}
		
		private function getInfoBarByType(pType:String) : GUI.ShopInfoBar {
			return getTabByType(pType).infoBar;
		}
		
		private function getButtonArrayByType(pType:String) : Array {
			switch(pType) {
				case ItemType.HAT	: return this.buttons_head;
				case ItemType.EYES	: return this.buttons_eyes;
				case ItemType.EARS	: return this.buttons_ears;
				case ItemType.MOUTH	: return this.buttons_mouth;
				case ItemType.NECK	: return this.buttons_neck;
				case ItemType.FUR	: return this.buttons_furs;
				case ItemType.HAIR	: return this.buttons_hair;
				case ItemType.TAIL	: return this.buttons_tail;
				default: trace("[Main](getInfoBarByType) Unknown type: "+pType);
			}
			return null;
		}

		public function HideAllTabs() : void
		{
			for(var i = 0; i < this.tabPanes.length; i++) {
				_hideTab(this.tabPanes[ i ]);
			}
			_hideTab(this.tabColorPane);
		}
		
		internal function _hideTab(pTab:GUI.Tab) : void {
			if(!pTab.active) { return; }
			
			pTab.active = false;
			try {
				this.shop.removeChild(pTab);
			} catch (e:Error) { };
		}

		internal function setupSwatches(pSwatches:Array):*
		{
			var tLength:int = pSwatches.length;
			
			for(var i = 0; i < colorSwatches.length; i++) {
				colorSwatches[i].alpha = 0;
				
				if (tLength > i) {
					this.colorSwatches[i].alpha = 1;
					this.colorSwatches[i].Value = pSwatches[i];
					if (this.selectedSwatch == i) {
						this.psColorPick.setCursor(this.colorSwatches[i].TextValue);
					}
				}
			}
			if (tLength > 9) {
				trace("!!! more than 9 colors !!!");
			}
		}

		public function colorBtnHatClicked(pEvent:Event):void { _colorClicked(ItemType.HAT); }
		public function colorBtnEyesClicked(pEvent:Event):void { _colorClicked(ItemType.EYES); }
		public function colorBtnEarsClicked(pEvent:Event):void { _colorClicked(ItemType.EARS); }
		public function colorBtnMouthClicked(pEvent:Event):void { _colorClicked(ItemType.MOUTH); }
		public function colorBtnNeckClicked(pEvent:Event):void { _colorClicked(ItemType.NECK); }
		public function colorBtnHairClicked(pEvent:Event):void { _colorClicked(ItemType.HAIR); }
		public function colorBtnTailClicked(pEvent:Event):void { _colorClicked(ItemType.TAIL); }
		
		private function _colorClicked(pType:String) : void {
			if(this.the_mouse.getItemFromIndex(pType) == null) { return; }
			if(getInfoBarByType(pType).colorWheelActive == false) { return; }
			
			this.selectSwatch(0, false);
			this.HideAllTabs();
			this.tabColorPane.active = true;
			var tData:ShopItemData = getInfoBarByType(pType).data;
			this.tabColorPane.infoBar.addInfo( tData, costumes.copyColor(this.the_mouse.getItemFromIndex(pType), new tData.itemClass()) );
			this.currentlyColoringType = pType;
			this.setupSwatches( this.the_mouse.getColors(pType) );
			this.shop.addChild(this.tabColorPane);
		}

		internal function defaults_btnClicked(pEvent:Event) : void
		{
			var tMC:MovieClip = this.the_mouse.getItemFromIndex(this.currentlyColoringType);
			if (tMC != null) 
			{
				costumes.colorDefault(tMC);
				costumes.copyColor( tMC, getButtonArrayByType(this.currentlyColoringType)[ getCurItemID(this.currentlyColoringType) ].Image );
				costumes.copyColor(tMC, getInfoBarByType(this.currentlyColoringType).Image);
				costumes.copyColor(tMC, this.tabColorPane.infoBar.Image);
				this.setupSwatches( this.the_mouse.getColors(this.currentlyColoringType) );
			}
		}
		
		function colorPickerBackClicked(pEvent:Event):void {
			_tabClicked( getTabByType( this.tabColorPane.infoBar.data.type ) );
		}

		internal function colorSwatch1OnEnterPressed(pEvent:Event) : void { this.selectSwatch(0); }
		internal function colorSwatch2OnEnterPressed(pEvent:Event) : void { this.selectSwatch(1); }
		internal function colorSwatch3OnEnterPressed(pEvent:Event) : void { this.selectSwatch(2); }
		internal function colorSwatch4OnEnterPressed(pEvent:Event) : void { this.selectSwatch(3); }
		internal function colorSwatch5OnEnterPressed(pEvent:Event) : void { this.selectSwatch(4); }
		internal function colorSwatch6OnEnterPressed(pEvent:Event) : void { this.selectSwatch(5); }
		internal function colorSwatch7OnEnterPressed(pEvent:Event) : void { this.selectSwatch(6); }
		internal function colorSwatch8OnEnterPressed(pEvent:Event) : void { this.selectSwatch(7); }
		internal function colorSwatch9OnEnterPressed(pEvent:Event) : void { this.selectSwatch(8); }

		function colorSwatch1OnClick(pEvent:Event):void { this.selectSwatch(0); }
		function colorSwatch2OnClick(pEvent:Event):void { this.selectSwatch(1); }
		function colorSwatch3OnClick(pEvent:Event):void { this.selectSwatch(2); }
		function colorSwatch4OnClick(pEvent:Event):void { this.selectSwatch(3); }
		function colorSwatch5OnClick(pEvent:Event):void { this.selectSwatch(4); }
		function colorSwatch6OnClick(pEvent:Event):void { this.selectSwatch(5); }
		function colorSwatch7OnClick(pEvent:Event):void { this.selectSwatch(6); }
		function colorSwatch8OnClick(pEvent:Event):void { this.selectSwatch(7); }
		function colorSwatch9OnClick(pEvent:Event):void { this.selectSwatch(8); }
		
		internal function selectSwatch(pNum:int, pSetCursor:Boolean=true) : void {
			for(var i = 0; i < colorSwatches.length; i++) {
				colorSwatches[i].unselect();
			}
			this.selectedSwatch = pNum;
			colorSwatches[pNum].select();
			if(pSetCursor) { this.psColorPick.setCursor(this.colorSwatches[pNum].TextValue); }
		}
		
		internal function __setProp_scaleSlider_Scene1_Layer1_0():*
		{
			try {
				this.scaleSlider["componentInspectorSetting"] = true;
			}
			catch (e:Error) { };
			
			this.scaleSlider.direction = "horizontal";
			this.scaleSlider.enabled = true;
			this.scaleSlider.liveDragging = false;
			this.scaleSlider.maximum = 10;
			this.scaleSlider.minimum = 1;
			this.scaleSlider.snapInterval = 0;
			this.scaleSlider.tickInterval = 0;
			this.scaleSlider.value = 6;
			this.scaleSlider.visible = true;
			
			try {
				this.scaleSlider["componentInspectorSetting"] = false;
			}
			catch (e:Error) { };
		}
	}
}
