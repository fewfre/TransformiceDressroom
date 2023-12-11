package app.ui.panes
{
	
	import app.ui.ShopInfoBar;
	import app.data.ItemType;
	import app.data.GameAssets;
	import flash.display.MovieClip;
	import app.ui.buttons.PushButton;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.display.ButtonBase;
	import app.ui.buttons.ScaleButton;
	import flash.events.Event;
	import app.world.data.ItemData;
	import com.fewfre.display.Grid;
	import app.ui.common.FancyInput;
	import flash.events.TextEvent;
	import flash.events.KeyboardEvent;
	import flash.events.FocusEvent;
	import flash.text.TextFormat;

	public class ShopCategoryPane extends TabPane
	{
		private var _type: ItemType;
		private var _defaultSkinColorButton: ScaleButton;
		private var _flagWaveInput: FancyInput;
		public function get flagWaveInput() : FancyInput { return _flagWaveInput; }
		
		public function get type():ItemType { return _type; }
		
		public static const ITEM_TOGGLED : String = 'ITEM_TOGGLED';
		public static const DEFAULT_SKIN_COLOR_BTN_CLICKED : String = 'DEFAULT_SKIN_COLOR_BTN_CLICKED';
		public static const FLAG_WAVE_CODE_CHANGED : String = 'FLAG_WAVE_CODE_CHANGED';
		
		// Constructor
		public function ShopCategoryPane(pType:ItemType) {
			super();
			this._type = pType;
			this.addInfoBar( new ShopInfoBar({ showEyeDropButton:_type!=ItemType.POSE, showGridManagementButtons:true }) );
			_setupGrid(GameAssets.getItemDataListByType(_type));
			
			infoBar.reverseButton.addEventListener(ButtonBase.CLICK, _onReverseGrid);
		}
		
		/****************************
		* Public
		*****************************/
		public override function open() : void {
			super.open();
		}
		
		public function toggleGridButtonWithData(pData:ItemData) : PushButton {
			if(pData) {
				var tIndex:int = GameAssets.getItemIndexFromTypeID(_type, pData.id);
				buttons[ tIndex ].toggleOn();
				return buttons[tIndex];
			}
			return null;
		}
		
		/****************************
		* Private
		*****************************/
		private function _setupGrid(pItemList:Vector.<ItemData>) : void {
			var buttonPerRow:int = 6;
			var scale:Number = 1;
			if(_type == ItemType.SKIN || _type == ItemType.POSE) {
					buttonPerRow = 5;
					scale = 1;
			}

			var grid:Grid = this.grid;
			if(!grid) { grid = this.addGrid( new Grid(385, buttonPerRow) ).setXY(15, 5); }
			grid.reset();

			var shopItem : MovieClip;
			var shopItemButton : PushButton;
			var i:int = -1;
			while (i < pItemList.length-1) { i++;
				shopItem = GameAssets.getItemImage(pItemList[i]);
				shopItem.scaleX = shopItem.scaleY = scale;

				shopItemButton = new PushButton({ width:grid.cellSize, height:grid.cellSize, obj:shopItem, id:i, data:{ type:_type, id:i } });
				grid.add(shopItemButton);
				this.buttons.push(shopItemButton);
				shopItemButton.addEventListener(PushButton.STATE_CHANGED_AFTER, _onItemToggled);
			}
			
			if(_type !== ItemType.POSE) {
				// Start these ones reversed by default
				grid.reverse();
			}
			_addDefaultSkinColorButtonIfSkinPane();
			
			this.UpdatePane();
		}
		
		private function _addDefaultSkinColorButtonIfSkinPane() : void {
			if(_type == ItemType.SKIN) {
				// Customizeable fur color button
				// cannot attach to button due to main button eating mouse events
				_defaultSkinColorButton = grid.addChild(new ScaleButton({ obj:new $ColorWheel(), obj_scale:0.5 })) as ScaleButton;
				_defaultSkinColorButton.addEventListener(ButtonBase.CLICK, function():void{
					buttons[GameAssets.defaultSkinIndex].toggleOn();
					dispatchEvent(new Event(DEFAULT_SKIN_COLOR_BTN_CLICKED));
				});
				_repositionDefaultSkinColorButtonIfExists();
			}
			if(_type == ItemType.POSE) {
				// Flag waving code text field
				// cannot attach to button due to main button eating mouse events
				_flagWaveInput = new FancyInput({ width:grid.cellSize-8, height:16, padding:2 });
				
				// Placeholder
				_flagWaveInput.placeholderTextBase.setUntranslatedText('/f __');
				_flagWaveInput.placeholderTextBase.x += 14;
				
				// Center Text
				var tFormat:TextFormat = new TextFormat();
				tFormat.align = 'center';
				_flagWaveInput.field.defaultTextFormat = tFormat;
				
				grid.addChild(_flagWaveInput);
				_flagWaveInput.field.addEventListener(KeyboardEvent.KEY_UP, function(e):void{
					dispatchEvent(new FewfEvent(FLAG_WAVE_CODE_CHANGED, { code:_flagWaveInput.text }));
				});
				// paste support
				_flagWaveInput.field.addEventListener(TextEvent.TEXT_INPUT, function(e):void{
					if(e.text.length <= 1) return;
					dispatchEvent(new FewfEvent(FLAG_WAVE_CODE_CHANGED, { code:e.text }));
				});
				// select pose if textbox clicked
				_flagWaveInput.field.addEventListener(FocusEvent.FOCUS_IN, function():void{
					buttons[18].toggleOn();
				});
				_repositionDefaultSkinColorButtonIfExists();
			}
		}
		private function _repositionDefaultSkinColorButtonIfExists() : void {
			if(_defaultSkinColorButton) {
				var tSkinButton = buttons[GameAssets.defaultSkinIndex];
				_defaultSkinColorButton.x = tSkinButton.x + 60;
				_defaultSkinColorButton.y = tSkinButton.y + 12;
			}
			if(_flagWaveInput) {
				var tPoseButton = buttons[18];
				_flagWaveInput.x = tPoseButton.x + grid.cellSize/2 + 0.5;
				_flagWaveInput.y = tPoseButton.y + 12;
			}
		}
		
		/****************************
		* Events
		*****************************/
		private function _onItemToggled(e:FewfEvent) : void {
			dispatchEvent(new FewfEvent(ITEM_TOGGLED, e.data));
		}
		
		private function _onReverseGrid(e:Event) : void {
			this.grid.reverse();
			_repositionDefaultSkinColorButtonIfExists();
		}
	}
}
