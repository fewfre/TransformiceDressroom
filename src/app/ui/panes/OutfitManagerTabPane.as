package app.ui.panes
{
	import com.fewfre.display.*;
	import com.fewfre.utils.Fewf;
	import com.fewfre.utils.FewfDisplayUtils;
	import com.fewfre.events.FewfEvent;
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import app.world.elements.*;
	import fl.containers.*;
	import flash.display.*;
	import flash.events.*;
	import flash.display.MovieClip;
	import flash.utils.ByteArray;
	import flash.net.FileReference;
	import flash.net.FileFilter;
	import flash.utils.setTimeout;
	
	public class OutfitManagerTabPane extends TabPane
	{
		// Storage
		public var character : Character;
		
		private var _deleteBtnGrid		: Grid;
		private var _onUserLookClicked	: Function;
		private var _exportButton	: SpriteButton;
		private var _importButton	: SpriteButton;
		
		// Constructor
		public function OutfitManagerTabPane(pCharacter:Character, pOnUserLookClicked:Function) {
			super();
			character = pCharacter;
			_onUserLookClicked = pOnUserLookClicked;
			
			this.addInfoBar( new ShopInfoBar({ showBackButton:true, showGridManagementButtons:true }) );
			this.addGrid( new Grid({ x:15, y:5, width:385, columns:5, margin:5 }) );
			_deleteBtnGrid = addItem(new Grid({ x:15, y:5, width:385, columns:5, margin:5 })) as Grid;
			this.infoBar.hideImageCont();
			
			this.grid.reverse(); // Start reversed so that new outfits get added to start of list
			_deleteBtnGrid.reverse();
			this.infoBar.randomizeButton.addEventListener(ButtonBase.CLICK, function(){ selectRandomOutfit(); });
			this.infoBar.reverseButton.addEventListener(ButtonBase.CLICK, function(){ grid.reverse(); _renderOutfits(); });
			
			// Custom infobar buttons
			var size = 40, xx = ConstantsApp.PANE_WIDTH - size - 5, yy = 6;
			
			_importButton = new SpriteButton({ x:xx, y:yy, width:size, height:size, obj:new $Folder() });
			_importButton.addEventListener(MouseEvent.CLICK, _onImportClicked);
			addChild(_importButton);
			
			xx -= size + 5;
			
			_exportButton = new SpriteButton({ x:xx, y:yy, width:size, height:size, obj:new $SimpleDownload(), obj_scale:0.7 });
			_exportButton.addEventListener(MouseEvent.CLICK, _onExportClicked);
			addChild(_exportButton);
			
			UpdatePane();
		}
		
		/****************************
		* Public
		*****************************/
		public override function open() : void {
			super.open();
			
			_renderOutfits();
		}
		
		public function addNewLook(lookCode:String) : void {
			var looks:Array = Fewf.sharedObject.getData(ConstantsApp.SHARED_OBJECT_KEY_OUTFITS) || [];
			looks.push(lookCode);
			Fewf.sharedObject.setData(ConstantsApp.SHARED_OBJECT_KEY_OUTFITS, looks);
			
			_renderOutfits();
		}
		
		public function deleteLookByIndex(i:int) : void {
			var looks:Array = Fewf.sharedObject.getData(ConstantsApp.SHARED_OBJECT_KEY_OUTFITS) || [];
			looks.splice(i, 1);
			Fewf.sharedObject.setData(ConstantsApp.SHARED_OBJECT_KEY_OUTFITS, looks);
			
			_renderOutfits();
		}
		
		public function selectRandomOutfit() : void {
			var btn = buttons[ Math.floor(Math.random() * buttons.length) ];
			btn.toggleOn();
			if(this.flagOpen) this.scrollItemIntoView(btn);
		}
		
		/****************************
		* Private
		*****************************/
		private function _renderOutfits() : void {
			var looks:Array = Fewf.sharedObject.getData(ConstantsApp.SHARED_OBJECT_KEY_OUTFITS) || [];
			
			if(looks.length > 0) {
				_exportButton.enable().alpha = 1;
			} else {
				_exportButton.disable().alpha = 0;
			}
			
			
			// keep track of last grid reversed state
			var wasReversed = grid.reversed;
			
			grid.reset();
			_deleteBtnGrid.reset();
			buttons = [];
			
			// if(!wasReversed) _addNewOutfitButton();
			
			for(var i:int = 0; i < looks.length; i++) {
				var look = looks[i];
				_addLookButton(look, i);
			}
				_addNewOutfitButton();
			
			if(wasReversed) {
				grid.reverse();
				_deleteBtnGrid.reverse();
			}
			
			UpdatePane();
		}
		
		public function _addLookButton(lookCode:String, i:int) : void {
			var character = new Character({
				params:lookCode,
				pose:GameAssets.poses[GameAssets.defaultPoseIndex]
			});
			character.parseParams(lookCode);
			var btn:PushButton = new PushButton({ width:grid.radius, height:grid.radius, obj:character, id:i }) as PushButton;
			btn.addEventListener(PushButton.STATE_CHANGED_AFTER, function(){
				_onUserLookClicked(lookCode);
				
				_untoggleAll(buttons, btn);
			});
			buttons.push(btn);
			grid.add(btn);
			
			// Corresponding Delete Button
			var deleteBtnHolder = new Sprite(); deleteBtnHolder.alpha = 0;
			var deleteBtn = deleteBtnHolder.addChild(new ScaleButton({ x:grid.radius-5, y:5, obj:new $Trash(), obj_scale:0.4 }));
			deleteBtn.addEventListener(MouseEvent.CLICK, function(e){ deleteLookByIndex(i); });
			_deleteBtnGrid.add(deleteBtnHolder);
			
			deleteBtn.addEventListener(MouseEvent.MOUSE_OVER, function(e){ deleteBtnHolder.alpha = 1; });
			deleteBtn.addEventListener(MouseEvent.MOUSE_OUT, function(e){ deleteBtnHolder.alpha = 0; });
			
			btn.addEventListener(MouseEvent.MOUSE_OVER, function(e){ deleteBtnHolder.alpha = 1; });
			btn.addEventListener(MouseEvent.MOUSE_OUT, function(e){ deleteBtnHolder.alpha = 0; });
		}
		
		private function _addNewOutfitButton() : void {
			var holder = new Sprite();
			var tNewOutfitBtn = holder.addChild(new ScaleButton({ x:grid.radius*0.5, y:grid.radius*0.5, width:this.grid.radius, height:this.grid.radius, obj:new $OutfitAdd() }));
			tNewOutfitBtn.addEventListener(MouseEvent.CLICK, function(e){ addNewLook(character.getParamsTfmOfficialSyntax()) });
			this.grid.add(holder);
			_deleteBtnGrid.add(new Sprite()); // empty spot since no delete button for this
			// this.buttons.push(tNewOutfitBtn);// DO NOT ADD TO BUTTONS! only add to grid; this avoids issue when clicking "random" button
		}

		private function _untoggleAll(pList:Array, pExcepotButton:PushButton=null) : void {
			for(var i:int = 0; i < pList.length; i++) {
				if (pList[i].pushed && pList[i] != pExcepotButton) {
					pList[i].toggleOff();
				}
			}
		}
		
		/****************************
		* Events
		*****************************/
		private function _onExportClicked(e:MouseEvent) : void {
			var looks:Array = Fewf.sharedObject.getData(ConstantsApp.SHARED_OBJECT_KEY_OUTFITS) || [];
			var csv:String = looks.join('\n');
			
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(csv);
			( new FileReference() ).save( bytes, "saved-outfits-backup.csv" );
		}
		
		private function _onImportClicked(e:MouseEvent) : void {
			var fileRef : FileReference = new FileReference();
			fileRef.addEventListener(Event.SELECT, function(){ fileRef.load(); });
			fileRef.addEventListener(Event.COMPLETE, _onImportSelected);
			
			fileRef.browse([new FileFilter("Saved Outfits File", "*.csv")]);
		}
		
		private function _onImportSelected(e:Event) : void {
			try {
				var importedLooks = e.target.data.toString().split('\n');
				var oldLooks:Array = Fewf.sharedObject.getData(ConstantsApp.SHARED_OBJECT_KEY_OUTFITS) || [];
				for(var i:int = importedLooks.length-1; i >= 0; i--) {
					// Don't allow an import file with invalid code
					if(this.character.parseParams(importedLooks[i]) === false) {
						throw 'Invalid code in list';
					}
					// Remove duplicates being imported
					if(oldLooks.indexOf(importedLooks[i]) > -1) {
						importedLooks.splice(i, 1);
					}
				}
				var final = oldLooks.concat(importedLooks);
				Fewf.sharedObject.setData(ConstantsApp.SHARED_OBJECT_KEY_OUTFITS, final);
				
				_renderOutfits();
			} catch(e) {
				trace('Import Error: ', e);
				_importButton.ChangeImage(new $No());
				setTimeout(function(){
					_importButton.ChangeImage(new $Folder());
				}, 2000);
			}
		}
	}
}
