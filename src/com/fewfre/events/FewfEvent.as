package com.fewfre.events
{
	import flash.events.Event;
	
	/*
	* A _good_ DataEvent that actually accepts, well, data. Not just a string.
	*/
	public class FewfEvent extends Event
	{
		public var data:Object;
		
		public function FewfEvent( pType:String, pData:Object = null, pBubbles:Boolean = false, pCancelable:Boolean = false )
		{
			super( pType, pBubbles, pCancelable );
			this.data = pData;
		}
		
		public override function clone():Event
		{
			return new FewfEvent( type, this.params, bubbles, cancelable );
		}
		
		public override function toString():String
		{
			return formatToString( "FewfEvent", "data", "type", "bubbles", "cancelable" );
		}
	}
}