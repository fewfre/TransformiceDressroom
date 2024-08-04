package app.world.events
{
	import flash.events.Event;
	import app.world.data.ItemData;
	
	public class ItemDataEvent extends Event
	{
		public var itemData:ItemData;
		
		public function ItemDataEvent(pType:String, pItemData:ItemData, pBubbles:Boolean = false, pCancelable:Boolean = false) {
			super( pType, pBubbles, pCancelable );
			this.itemData = pItemData;
		}
		
		public override function clone():Event {
			return new ItemDataEvent( type, this.itemData, bubbles, cancelable );
		}
		
		public override function toString():String {
			return formatToString( "FewfEvent", "itemData", "type", "bubbles", "cancelable" );
		}
	}
}