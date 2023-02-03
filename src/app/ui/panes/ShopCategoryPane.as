package app.ui.panes
{
	
	import app.ui.ShopInfoBar;
	import app.data.ItemType;
	import app.data.GameAssets;
	import app.ui.Grid;
	import flash.display.MovieClip;
	import app.ui.buttons.PushButton;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.display.ButtonBase;
	import app.ui.buttons.ScaleButton;
	import flash.events.Event;

	public class ShopCategoryPane extends TabPane
	{
		private var _type: ItemType;
		
		public function get type():ItemType { return _type; }
		
		public static const ITEM_TOGGLED : String = 'ITEM_TOGGLED';
		public static const DEFAULT_SKIN_COLOR_BTN_CLICKED : String = 'DEFAULT_SKIN_COLOR_BTN_CLICKED';
		
		// Constructor
		public function ShopCategoryPane(pType:ItemType) {
			super();
			this._type = pType;
			this.addInfoBar( new ShopInfoBar({ showEyeDropButton:_type!=ItemType.POSE, showGridManagementButtons:true }) );
			_setupGrid(_type, this, GameAssets.getArrayByType(_type));
			
			infoBar.reverseButton.addEventListener(ButtonBase.CLICK, _onReverseGrid);
		}
		
		/****************************
		* Public
		*****************************/
		public override function open() : void {
			super.open();
		}
		
		/****************************
		* Private
		*****************************/
		private function _setupGrid(pType:ItemType, pPane:TabPane, pItemArray:Array) : void {
			var buttonPerRow = 6;
			var scale = 1;
			if(pType == ItemType.SKIN || pType == ItemType.POSE) {
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
				shopItem = GameAssets.getItemImage(pItemArray[i]);
				shopItem.scaleX = shopItem.scaleY = scale;

				shopItemButton = new PushButton({ width:grid.radius, height:grid.radius, obj:shopItem, id:i, data:{ type:pType, id:i } });
				grid.add(shopItemButton);
				pPane.buttons.push(shopItemButton);
				shopItemButton.addEventListener(PushButton.STATE_CHANGED_AFTER, _onItemToggled);
			}
			if(pType !== ItemType.POSE) {
				// Start these ones reversed by default
				grid.reverse();
				_addDefaultSkinColorButtonIfSkinPane(pType);
			}
			pPane.UpdatePane();
		}
		
		private function _addDefaultSkinColorButtonIfSkinPane(pType:ItemType) {
			// Customizeable fur color button
			// cannot attach to button due to main button eating mouse events
			if(pType == ItemType.SKIN) {
				var tSkinButton = buttons[GameAssets.defaultSkinIndex];
				var tColorWheel = tSkinButton.parent.addChild(new ScaleButton({ x:tSkinButton.x + 60, y:tSkinButton.y + 12, obj:new $ColorWheel(), obj_scale:0.5 }));
				tColorWheel.addEventListener(ButtonBase.CLICK, function(){
					tSkinButton.toggleOn();
					dispatchEvent(new Event(DEFAULT_SKIN_COLOR_BTN_CLICKED));
				});
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
			_addDefaultSkinColorButtonIfSkinPane(_type);
		}
	}
}
