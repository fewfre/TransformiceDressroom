package com.fewfre.utils
{
	import flash.external.ExternalInterface;
	import flash.display.Stage;

	public class BrowserMouseWheelPrevention
	{
		public static function init(pStage:Stage):void {
			// Only works on server
			if(ExternalInterface.available) {
				ExternalInterface.call(CODE);
			}
		}
		
		// http://snipplr.com/view/63718/disable-document-scrolling-when-using-mousewheel-in-flash-elements/
		private static const CODE : XML =
		<script><![CDATA[
			function() {
				function addEventListener(event, elem, func) {
					if (elem.addEventListener) {
						return elem.addEventListener(event, func, false);
					}
					else if (elem.attachEvent) {
						return elem.attachEvent("on" + event, func);
					}
				}
				
				function disableMouseWheel (event) {
					if(event.target.nodeName.toLowerCase().match(/embed|object/)) {
						event.preventDefault();
						event.stopImmediatePropagation();
						return false;
					}
				}
				
				var events = ['DOMMouseScroll', 'mousewheel'];
				for(var i = 0; i < events.length; i++) {
					addEventListener(events[i], document.body, disableMouseWheel);
				}
			}
		]]></script>;
	}
}
