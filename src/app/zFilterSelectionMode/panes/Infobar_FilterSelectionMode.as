package app.zFilterSelectionMode.panes
{
	import app.data.ConstantsApp;
	import app.ui.buttons.GameButton;
	import app.ui.buttons.PushButton;
	import app.ui.panes.infobar.Infobar;
	import app.zFilterSelectionMode.data.SortType_FilterSelectionMode;

	import com.fewfre.display.DisplayWrapper;
	import com.fewfre.events.FewfEvent;

	import flash.display.Sprite;
	import flash.events.Event;

	public class Infobar_FilterSelectionMode extends Infobar
	{
		// Constants
		public static const REVERSE_CLICKED : String = "flm_reverse_clicked";
		public static const SORT_TYPE_CHANGED : String = "flm_sort_type_changed"; // FewfEvent<{ sortType:SortType_FilterSelectionMode }>
		
		// Constructor
		public function Infobar_FilterSelectionMode() {
			super({ hideItemPreview:true });
			DisplayWrapper.wrap(_initGridManagementWidget(), this).move(ConstantsApp.SHOP_WIDTH/2, 50/2).alignChildrenAroundAnchor();
		}
		
		private function _initGridManagementWidget() : Sprite {
			var tTray:Sprite = new Sprite();
			var xx:Number = ConstantsApp.SHOP_WIDTH/2, yy:Number = 50/2-24/2, spacing:Number = 5, bsize:Number = 24;
			
			// List reversal button
			new GameButton(bsize).setImage(new $FlipIcon(), 0.7).move(xx, yy).appendTo(tTray).onButtonClick(dispatchEventHandler(REVERSE_CLICKED));
			xx += bsize + spacing;
			
			// Add sort options
			var sortOptions:Vector.<PushButton> = new <PushButton>[
				new PushButton(bsize).setTextUntranslated('#').setData(SortType_FilterSelectionMode.ID).appendTo(tTray) as PushButton,
				new PushButton(bsize).setImage(new $Outfit(), 0.35).setData(SortType_FilterSelectionMode.OWNED).appendTo(tTray) as PushButton,
				new PushButton(bsize).setImage(new $ColorWheel(), 0.5).setData(SortType_FilterSelectionMode.CUSTOMIZABLE).appendTo(tTray) as PushButton,
			];
			sortOptions[0].toggleOn(false); // Default to ID sorting
			for each(var button:PushButton in sortOptions) {
				button.setAllowToggleOff(false).move(xx, yy);
				xx += bsize + 0.25;
				button.onToggle(function(e:Event):void {
					var eventButton:PushButton = e.currentTarget as PushButton;
					dispatchEvent(new FewfEvent(SORT_TYPE_CHANGED, { sortType:eventButton.data } ));
					PushButton.untoggleAll(sortOptions, eventButton);
				});
			}
			return tTray;
		}
		
		///////////////////////
		// Private
		///////////////////////
		private function dispatchEventHandler(pEventName:String) : Function {
			return function(e):void{ dispatchEvent(new Event(pEventName)); };
		}
	}
}