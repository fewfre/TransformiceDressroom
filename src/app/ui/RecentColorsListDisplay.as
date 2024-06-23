package app.ui
{
	import com.piterwilson.utils.*;
	import com.fewfre.display.*;
	import com.fewfre.events.FewfEvent;
	import app.data.ConstantsApp;
	import app.ui.buttons.*;
	import app.ui.common.*;
	import flash.display.*;
	import ext.ParentApp;
	
	public class RecentColorsListDisplay extends Sprite
	{
		// Constants
		public static const EVENT_COLOR_PICKED		: String = "event_color_picked";
		
		// Static
		public static var RECENTS					: Array = null;
		
		// Storage
		private var _recentColorButtons	: Vector.<ColorButton>;
		private var _deleteToggleButton	: DeleteButton;
		private var _bg : RoundedRectangle;
		private var _verticalRule : Shape;
		
		public function get isDeleteModeOn():Boolean { return _deleteToggleButton.pushed; }
		
		// Constructor
		public function RecentColorsListDisplay(pData:Object)
		{
			super();
			this.visible = false; // turned on in render()
			
			if(!RECENTS) {
				RECENTS = ParentApp.sharedData.recentColors || [];
				ParentApp.sharedData.recentColors = RECENTS;
			}
			this.x = pData.x;
			this.y = pData.y;
			
			_recentColorButtons = new Vector.<ColorButton>();
			
			var deleteWidth:Number = 50;
			var bgWidth:Number = ConstantsApp.PANE_WIDTH - 20 - deleteWidth, bgHeight = 24;
			
			_deleteToggleButton = new DeleteButton({ x:bgWidth*0.5-25-2, width:deleteWidth, height:bgHeight, obj:new $Trash(), obj_scale:0.85 });;
			_deleteToggleButton.y += -_deleteToggleButton.Height * 0.5;
			_deleteToggleButton.addEventListener(PushButton.STATE_CHANGED_AFTER, function():void{ render(); });
			addChild(_deleteToggleButton);
			
			// Add BG
			_bg = new RoundedRectangle(bgWidth, bgHeight, { x:-deleteWidth*0.5+2, origin:0.5 });
			addChild(_bg);
			
			_verticalRule = new Shape();
			_verticalRule.x = _bg.Width*0.5 - 2.5;
			_verticalRule.y = -_bg.Height*0.5 + 2.5;
			_bg.addChild(_verticalRule);
		}
		
		/****************************
		* Public
		*****************************/
		public function addColor(color:uint) : void {
			_toggleDeleteMode(false);
			// Remove old value if there is one, and move it to front of the list
			if(RECENTS.indexOf(color) != -1) {
				RECENTS.splice(RECENTS.indexOf(color), 1);
			}
			RECENTS.unshift(color);
			render();
		}
		
		public function render() : void {
			// Clear old buttons
			_recentColorButtons.forEach(function(o:*,i:int,a:*):void{ removeChild(o); });
			_recentColorButtons = new Vector.<ColorButton>();
			
			this.visible = RECENTS.length > 0;
			var bgBorderColor = isDeleteModeOn ? 0x780f11 : 0;//0x0f474f;
			_bg.draw(0x6f6b64, 5, bgBorderColor);
			
			_verticalRule.graphics.clear();
			_verticalRule.graphics.lineStyle(5, bgBorderColor, 1, false, "normal", "square");
			_verticalRule.graphics.moveTo(0, 0);
			_verticalRule.graphics.lineTo(0, _bg.Height-5);
			
			// Render new buttons
			var maxColors = 12;
			var len = Math.min(RECENTS.length, maxColors);
			var tTrayWidth = _bg.Width - 5, tSpacingX = 2.5, tBtnWidth = (tTrayWidth-(tSpacingX*maxColors)-tSpacingX*2)/maxColors,
			tX = _bg.x-_bg.Width/2 + tBtnWidth*0.5 + tSpacingX*2;
			for(var i:int = 0; i < len; i++) {
				var color:int = RECENTS[i];
				
				var btn = new ColorButton({ x:tX + (i*(tBtnWidth+tSpacingX)), width:tBtnWidth, height:17, color:color });
				if(isDeleteModeOn) {
					(function(btn){
						var nou:MovieClip = new $No();
						nou.scaleX = nou.scaleY = 0.2;
						nou.alpha = 0;
						btn.addChild(nou);
						btn.addEventListener(ButtonBase.OVER, function(){ nou.alpha = 0.5 });
						btn.addEventListener(ButtonBase.OUT, function(){ nou.alpha = 0 });
					})(btn);
				}
				btn.addEventListener(ButtonBase.CLICK, _onRecentColorBtnClicked);
				addChild(btn);
				_recentColorButtons.push(btn);
			}
		}
		
		public function toggleOffDeleteMode() : void {
			_toggleDeleteMode(false);
		}
		
		/****************************
		* Private
		*****************************/
		
		private function _dispatchColorChange(color:uint) {
			dispatchEvent(new FewfEvent(EVENT_COLOR_PICKED, color));
		}
		
		private function _deleteRecentColor(color:int) {
			if(RECENTS.indexOf(color) != -1) {
				RECENTS.splice(RECENTS.indexOf(color), 1);
			}
			render();
		}
		
		private function _toggleDeleteMode(on:Boolean) {
			_deleteToggleButton.toggle(on);
		}
		
		/****************************
		* Events
		*****************************/
		private function _onRecentColorBtnClicked(pEvent) : void {
			var color:uint = uint(pEvent.data);
			
			if(isDeleteModeOn) {
				_deleteRecentColor(color);
			} else {
				// We just want to move the color in recents list to front when clicked
				addColor(color);
				_dispatchColorChange(color);
			}
		}
	}
}

import app.ui.buttons.PushButton;
class DeleteButton extends PushButton
{
		public function DeleteButton(pData) {
			super(pData);
		}
		/****************************
		* Render
		*****************************/
		override protected function _renderUp() : void {
			if (this.pushed == false) {
				_bg.draw(0xeb9d9e, 5, 0xFF0000);
			} else {
				_bg.draw(0xFF0000, 5, 0x780f11);
			}
		}
		
		override protected function _renderDown() : void {
			_renderOver();
		}
		
		override protected function _renderOver() : void {
			if (this.pushed == false) {
				_bg.draw(0xf57375, 5, 0xFF0000);
			} else {
				_bg.draw(0xDD0000, 5, 0x780f11);
			}
		}
		
		override protected function _renderOut() : void {
			_renderUp();
		}

		override protected function _renderUnpressed() : void {
			_renderUp();
		}

		override protected function _renderPressed() : void {
			_bg.draw(0xFF0000, 5, 0x780f11);
		}
}