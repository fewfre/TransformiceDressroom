package app.ui.panes
{
	import app.data.*;
	import app.ui.buttons.PushButton;
	import app.ui.buttons.SpriteButton;
	import app.ui.common.FancyInput;
	import app.ui.panes.base.SidePane;
	import app.ui.PasteShareCodeInput;
	import app.ui.screens.LoadingSpinner;
	import app.world.data.ItemData;
	import app.world.elements.Character;
	import com.fewfre.display.*;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.utils.AssetManager;
	import com.fewfre.utils.Fewf;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormatAlign;
	
	public class ConfigTabPane extends SidePane
	{
		// Constants
		public static const LOOK_CODE_SELECTED : String = "look_code_selected"; // FewfEvent<String>
		
		// Storage
		public var userOutfitsGrid		: Grid;
		public var usernameInput		: FancyInput;
		public var usernameErrorText	: TextBase;
		public var _loadingUser			: Boolean;
		
		// Constructor
		// pData = { onShareCodeEntered:Function, onUserLookClicked:Function }
		public function ConfigTabPane(pOnShareCodeEntered:Function) {
			super();
			_loadingUser = false;
			
			var i:int = 0, xx:Number = 5, yy:Number = 10, sizex:Number, sizey:Number, spacingx:Number;
			
			// Paste share code
			xx = 15; yy += 14; sizex = ConstantsApp.PANE_WIDTH - 20 - 15;
			new PasteShareCodeInput(sizex).appendTo(this).move(xx + sizex*0.5, yy)
				.on(PasteShareCodeInput.CHANGE, function(e):void{ pOnShareCodeEntered(e.data.code, e.data.update); });
			yy += 14;
			
			if(Fewf.assets.getData("config").username_lookup_url) {
				// Line
				yy += 16;
				GameAssets.createHorizontalRule(10, yy, ConstantsApp.PANE_WIDTH - 15 - 15).appendTo(this);
				yy += 16;
				
				// User look fetcher - Title
				sizey = 20;
				xx = 15-2; yy += sizey*0.5;
				new TextTranslated("user_lookup_title", { x:xx, y:yy-3, originX:0, size:14 }).appendTo(this);
				yy += sizey*0.5 + 3;
				
				// User look fetcher - Search
				sizex = sizey = 18+10; spacingx = 10;
				xx = 15; yy += sizey*0.5;
				
				var fieldWidth = ConstantsApp.PANE_WIDTH*0.65 - spacingx*3 - sizex;
				usernameInput = new FancyInput({ placeholder:"user_lookup_placeholder", x:xx + fieldWidth*0.5, y:yy, width:fieldWidth, height:sizey-10 }).appendTo(this);
				usernameInput.field.addEventListener(KeyboardEvent.KEY_DOWN, function(pEvent){
					if(usernameInput.text != "" && pEvent.charCode == 13) {
						_onFetchUserLooks(null);
					}
				});
				
				// Fetch looks request submit button
				SpriteButton.withObject(new $PlayButton(), 0.5, { width:sizex, height:sizey, origin:0.5 }).appendTo(this)
					.setXY(xx+fieldWidth + spacingx + sizex*0.5, yy).on(MouseEvent.CLICK, _onFetchUserLooks);
				
				yy += sizey*0.5 + 10;
				userOutfitsGrid = new Grid(ConstantsApp.PANE_WIDTH - spacingx*2 - 5, 6).setXY(xx-2,yy).appendTo(this);
				
				// Since we want this to disappear after a search anyways, coop the error text variable
				yy += 2;
				usernameErrorText = new TextTranslated("user_lookup_details", { color:0xAAAAAA, x:xx-2, y:yy, originX:0, originY:0, align:TextFormatAlign.LEFT }).appendToT(this);
			}
		}
		
		/****************************
		* Public
		*****************************/
		public function addLook(lookCode:String) {
			var grid:Grid = this.userOutfitsGrid;
			var character:Character = new Character(new <ItemData>[ GameAssets.defaultPose ], lookCode, true);
			var btn:PushButton = new PushButton({ size:grid.cellSize, obj:character });
			btn.on(MouseEvent.CLICK, function(){
				dispatchEvent(new FewfEvent(LOOK_CODE_SELECTED, lookCode));
				// Hacky way to make push button a normal button
				btn.toggleOff();
			});
			grid.add(btn);
		}
		
		/****************************
		* Private
		*****************************/
		private function _onFetchUserLooks(pEvent) : void {
			if(usernameInput.text == "" || _loadingUser) { return; }
			userOutfitsGrid.reset();
			if(usernameErrorText) {
				removeChild(usernameErrorText);
				usernameErrorText = null;
			}
			var tLoaderDisplay:LoadingSpinner = new LoadingSpinner({ x:5+ConstantsApp.PANE_WIDTH*0.5, y:userOutfitsGrid.y+50 }).appendTo(this);
			
			if(usernameInput.text.indexOf("#") == -1) {
				usernameInput.text += "#0000";
			}
			var username:String = usernameInput.text.replace("#", "%23");
			
			var url = Fewf.assets.getData("config").username_lookup_url.replace("$1", username);
			_loadingUser = true;
			Fewf.assets.load([
				[ url+"&cb="+String( new Date().getTime() ), { type:"json" } ],
			]);
			Fewf.assets.addEventListener(AssetManager.LOADING_FINISHED, function(e:Event){
				_loadingUser = false;
				Fewf.assets.removeEventListener(AssetManager.LOADING_FINISHED, arguments.callee);
				tLoaderDisplay.destroy();
				removeChild( tLoaderDisplay );
				tLoaderDisplay = null;
				
				var data = Fewf.assets.getData("fetchlooknickname");
				if(!data) {
					_setFetchUserError("##Unknown Error");
				} else if(data.error) {
					_setFetchUserError(data.error);
				} else {
					_parseUser(data);
				}
			});
		}
		
		private function _setFetchUserError(message:String) {
			usernameErrorText = new TextBase(message, { color:0xFF0000, x:5+ConstantsApp.PANE_WIDTH*0.5, y:userOutfitsGrid.y+25 }).appendTo(this);
		}
		
		private function _parseUser(pData:Object) {
			var looks:Array = pData.looks;
			
			for(var i:int = 0; i < looks.length; i++) {
				var look = looks[i];
				addLook(look);
			}
		}
	}
}
