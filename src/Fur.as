package 
{
	import flash.display.*;
	import flash.display.MovieClip;
	import flash.geom.*;
	
	public class Fur extends MovieClip
	{
		// Storage
		public var current_fur:int=0;
		
		internal var data:FurData;
		
		public var earFar:MovieClip;
		public var footFar:MovieClip;
		public var legFar:MovieClip;
		public var armFar:MovieClip;
		public var footClose:MovieClip;
		public var tailOrnament:MovieClip;
		public var wings:MovieClip;
		public var body:MovieClip;
		public var tail:MovieClip;
		public var legClose:MovieClip;
		public var armClose:MovieClip;
		public var face:MovieClip;
		public var eyes:MovieClip;
		public var earClose:MovieClip;
		
		// Constructor
		public function Fur(pData:FurData) {
			super();
			
			data = pData;
			
			this.setup_fur_base();
			if(data.color != "") { this.colorFur(data.color); }
		}
		
		internal function setup_fur_base() : void {
			earFar = new data.earFar();
			earFar.x = 5.75;
			earFar.y = -22.8;
			addChild(earFar);
			
			footFar = new data.footFar();
			footFar.name = "nocolor";
			footFar.x = 3.95;
			footFar.y = 13.05;
			addChild(footFar);
			
			legFar = new data.legFar();
			legFar.x = 1.4;
			legFar.y = 5.95;
			addChild(legFar);
			
			armFar = new data.armFar();
			armFar.x = 8.3;
			armFar.y = 1.05;
			addChild(armFar);
			
			footClose = new data.footClose();
			footClose.name = "nocolor";
			footClose.x = -4.25;
			footClose.y = 14.2;
			addChild(footClose);
			
			tailOrnament = new data.tailOrnament();
			tailOrnament.name = "nocolor";
			tailOrnament.x = -23.35;
			tailOrnament.y = -16.35;
			addChild(tailOrnament);
			
			if(data.wings != null) {
				wings = new data.wings();
				wings.x = -2.8;
				wings.y = -2.0;
				addChild(wings);
			}
			
			body = new data.body();
			body.x = -0.8;
			body.y = 3.5;
			addChild(body);
			
			tail = new data.tail();
			tail.name = "nocolor";
			tail.x = -13.5;
			tail.y = -8.05;
			addChild(tail);
			
			legClose = new data.legClose();
			legClose.x = -4.5;
			legClose.y = 7.3;
			addChild(legClose);
			
			armClose = new data.armClose();
			armClose.x = 1.85;
			armClose.y = 1.7;
			addChild(armClose);
			
			face = new data.face();
			face.x = 4.9;
			face.y = -9.6;
			addChild(face);
			
			eyes = new data.eyes();
			eyes.name = "nocolor";
			eyes.x = 4.75;
			eyes.y = -10.85;
			addChild(eyes);
			
			earClose = new data.earClose();
			earClose.x = -6.2;
			earClose.y = -16.6;
			addChild(earClose);
		}

		public function colorFur(arg1:String):*
		{
			var loc2:*=undefined;
			var loc3:*=0;
			var loc4:*=undefined;
			var loc5:*=0;
			var loc6:*=0;
			var loc7:*=0;
			var loc8:*=0;
			var loc9:*=null;
			var loc10:*=0;
			var loc11:*=0;
			var loc12:*=0;
			var loc13:*=0;
			var loc14:*=null;
			var loc1:*=0;
			while (loc1 < this.numChildren) 
			{
				loc2 = this.getChildAt(loc1);
				if (loc2.name != "nocolor") 
				{
					if (loc2.numChildren > 1) 
					{
						loc3 = 0;
						while (loc3 < loc2.numChildren) 
						{
							if ((loc4 = loc2.getChildAt(loc3)).name == "c0") 
							{
								loc6 = (loc5 = int("0x" + arg1)) >> 16 & 255;
								loc7 = loc5 >> 8 & 255;
								loc8 = loc5 & 255;
								loc9 = new flash.geom.ColorTransform(loc6 / 128, loc7 / 128, loc8 / 128);
								loc4.transform.colorTransform = loc9;
							}
							++loc3;
						}
					}
					else 
					{
						loc11 = (loc10 = int("0x" + arg1)) >> 16 & 255;
						loc12 = loc10 >> 8 & 255;
						loc13 = loc10 & 255;
						loc14 = new flash.geom.ColorTransform(loc11 / 128, loc12 / 128, loc13 / 128);
						loc2.transform.colorTransform = loc14;
					}
				}
				++loc1;
			}
			return;
		}
	}
}
