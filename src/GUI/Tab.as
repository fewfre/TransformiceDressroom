package GUI 
{
	import fl.containers.*;
	import flash.display.*;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	public class Tab extends MovieClip
	{
		// Storage
		public var active : Boolean;
		public var infoBar : ShopInfoBar;
		public var buttons : Array;
		public var selectedButton : int;
		
		var Pane:fl.containers.ScrollPane;
		var content:MovieClip;
		
		// Constructor
		public function Tab()
		{
			super();
			active = false;
			infoBar = null;
			buttons = [];
			selectedButton = -1;
			this.content = new MovieClip();
		}

		public function addItem(pItem:Sprite):void
		{
			this.content.addChild(pItem);
		}

		public function addInfoBar(pBar:ShopInfoBar):void
		{
			this.infoBar = pBar;
			//infoBar.y = -35;
			this.addChild(pBar);
		}

		public function UpdatePane(pItemPane:Boolean=true):*
		{
			this.x = 5;
			this.y = 5;//40;
			if (pItemPane) 
			{
				this.content.graphics.beginFill(0, 0);
				this.content.graphics.drawRect(0, 0, this.content.width + 30, this.content.height + 20);
				this.content.graphics.endFill();
			}
			var loc1:*=new MovieClip();
			loc1.graphics.clear();
			this.Pane = new fl.containers.ScrollPane();
			this.Pane.source = this.content;
			this.Pane.setStyle("upSkin", loc1);
			this.Pane.setSize(ConstantsApp.PANE_WIDTH, 330);//350);
			this.Pane.move(0, this.infoBar==null ? 0 : 60);
			this.Pane.verticalLineScrollSize = 25;
			this.Pane.verticalPageScrollSize = 25;
			
			addChild(this.Pane);
			return;
		}
	}
}
