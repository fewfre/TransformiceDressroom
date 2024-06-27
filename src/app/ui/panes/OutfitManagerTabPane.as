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
	import flash.display.*;
	import flash.events.*;
	import flash.display.MovieClip;
	import flash.utils.ByteArray;
	import flash.net.FileReference;
	import flash.net.FileFilter;
	import flash.utils.setTimeout;
	import app.world.data.ItemData;
	import app.ui.panes.base.ButtonGridSidePane;
	import com.fewfre.utils.FewfUtils;
	import app.ui.panes.infobar.GridManagementWidget;
	import app.ui.panes.infobar.Infobar;
	
	public class OutfitManagerTabPane extends ButtonGridSidePane
	{
		// Storage
		private var _character : Character;
		
		private var _deleteBtnGrid     : Grid;
		private var _onUserLookClicked : Function;
		private var _exportButton      : SpriteButton;
		private var _importButton      : SpriteButton;
		
		private var _addOutfitButtonHolder : Sprite;
		private var _addOutfitDeleteButton : Sprite;
		
		// Constructor
		public function OutfitManagerTabPane(pCharacter:Character, pOnUserLookClicked:Function) {
			super(5);
			_character = pCharacter;
			_onUserLookClicked = pOnUserLookClicked;
			
			this.addInfoBar( new Infobar({ showBackButton:true, hideItemPreview:true, gridManagement:{ hideRandomizeLock:true } }) )
				.on(Infobar.BACK_CLICKED, function(e):void{ dispatchEvent(new Event(Event.CLOSE)); });
			
			_deleteBtnGrid = _scrollbox.add(new Grid(385, 5).setXY(15,5)) as Grid;
			
			this.grid.reverse(); // Start reversed so that new outfits get added to start of list
			_deleteBtnGrid.reverse();
			this.infoBar.on(GridManagementWidget.RANDOMIZE_CLICKED, function(){ selectRandomOutfit(); });
			
			// Custom infobar buttons
			var size = 40, xx = ConstantsApp.PANE_WIDTH - size, yy = 11;
			
			_importButton = new SpriteButton({ x:xx, y:yy, width:size, height:size, obj:new $Folder() });
			_importButton.addEventListener(MouseEvent.CLICK, _onImportClicked);
			addChild(_importButton);
			
			xx -= size + 5;
			
			_exportButton = new SpriteButton({ x:xx, y:yy, width:size, height:size, obj:new $SimpleDownload(), obj_scale:0.7 });
			_exportButton.addEventListener(MouseEvent.CLICK, _onExportClicked);
			addChild(_exportButton);
		}
		
		/****************************
		* Public
		*****************************/
		public override function open() : void {
			super.open();
			
			_renderOutfits();
		}
		
		public function addNewLook(lookCode:String) : void {
			trace('addNewLook', lookCode);
			var looks:Array = getStoredLookCodes();
			looks.push(lookCode);
			Fewf.sharedObject.setData(ConstantsApp.SHARED_OBJECT_KEY_OUTFITS, looks);
			
			// Add it to grid - do it manually to avoid re-rendering whole list
			toggleExportButton(looks.length > 0);
			_addLookButton(lookCode, looks.length-1);
			_addNewOutfitButton();
			refreshScrollbox();
		}
		
		public function deleteLookByIndex(i:int) : void {
			var looks:Array = getStoredLookCodes();
			var oldCode:String = looks[i];
			looks.splice(i, 1);
			Fewf.sharedObject.setData(ConstantsApp.SHARED_OBJECT_KEY_OUTFITS, looks);
			
			// Remove it from grid - do it manually to avoid re-rendering whole list
			toggleExportButton(looks.length > 0);
			// The "add outfit button" can shift over cell index by 1 if grid is not reversed, since it's always added to top left
			var btnI = grid.reversed ? i : i+1;
			grid.remove(grid.cells[btnI]);
			_deleteBtnGrid.remove(_deleteBtnGrid.cells[btnI]);
			// We have to update the delete index for other delete buttons
			var delBtn:ScaleButton;
			for(var di:int = btnI; di < _deleteBtnGrid.cells.length; di++) {
				// If child doesn't exist (such as "add new look" one which is empty") ignore
				if((_deleteBtnGrid.cells[di] as Sprite).numChildren > 0) {
					delBtn = (_deleteBtnGrid.cells[di] as Sprite).getChildAt(0) as ScaleButton; // Delete button holder only ever has 1 child
					delBtn.data.lookIndex--;
				}
			}
			refreshScrollbox();
		}
		
		public function selectRandomOutfit() : void {
			var btn = buttons[ Math.floor(Math.random() * buttons.length) ];
			btn.toggleOn();
			if(this.flagOpen) this.scrollItemIntoView(btn);
		}
		
		/****************************
		* Private
		*****************************/
		private function getStoredLookCodes() : Array {
			return Fewf.sharedObject.getData(ConstantsApp.SHARED_OBJECT_KEY_OUTFITS) || [];
		}
		
		private function _renderOutfits() : void {
			var looks:Array = getStoredLookCodes();
			
			toggleExportButton(looks.length > 0);
			clearButtons();
			_deleteBtnGrid.reset();
			
			for(var i:int = 0; i < looks.length; i++) {
				var look = looks[i];
				_addLookButton(look, i);
			}
			
			_addNewOutfitButton();
			refreshScrollbox();
		}
		
		public function _addLookButton(lookCode:String, i:int) : void {
			var lookMC = new Character(new <ItemData>[ GameAssets.defaultPose ], lookCode, true);
			
			var btn:PushButton = new PushButton({ width:grid.cellSize, height:grid.cellSize, obj:lookMC }) as PushButton;
			btn.addEventListener(PushButton.STATE_CHANGED_AFTER, function(){
				_onUserLookClicked(lookCode);
				
				_untoggleAll(buttons, btn);
			});
			addButton(btn);
			
			// Corresponding Delete Button
			var deleteBtnHolder = new Sprite(); deleteBtnHolder.alpha = 0;
			var deleteBtn:ScaleButton = deleteBtnHolder.addChild(new ScaleButton({ x:grid.cellSize-5, y:5, obj:new $Trash(), obj_scale:0.4, data:{ lookIndex:i } })) as ScaleButton;
			// We have to delete by the index (instead of a code) since if someone added the same look twice but in different spots, this could delete the one in the wrong spot
			deleteBtn.addEventListener(MouseEvent.CLICK, function(e){ deleteLookByIndex(deleteBtn.data.lookIndex); });
			_deleteBtnGrid.add(deleteBtnHolder);
			
			deleteBtn.addEventListener(MouseEvent.MOUSE_OVER, function(e){ deleteBtnHolder.alpha = 1; });
			deleteBtn.addEventListener(MouseEvent.MOUSE_OUT, function(e){ deleteBtnHolder.alpha = 0; });
			
			btn.addEventListener(MouseEvent.MOUSE_OVER, function(e){ deleteBtnHolder.alpha = 1; });
			btn.addEventListener(MouseEvent.MOUSE_OUT, function(e){ deleteBtnHolder.alpha = 0; });
		}
		
		private function _addNewOutfitButton() : void {
			var tAddToTopOfList:Boolean = !grid.reversed;
			if(_addOutfitButtonHolder) _grid.remove(_addOutfitButtonHolder);
			if(_addOutfitDeleteButton) _deleteBtnGrid.remove(_addOutfitDeleteButton);
			var holder = new Sprite();
			new ScaleButton({ x:grid.cellSize*0.5, y:grid.cellSize*0.5, width:grid.cellSize, height:grid.cellSize, obj:new $OutfitAdd() })
			.appendTo(holder).on(MouseEvent.CLICK, function(e){ addNewLook(_character.getParamsTfmOfficialSyntax()) });
			
			_addOutfitButtonHolder = holder;
			_addOutfitDeleteButton = new Sprite();
			this.grid.add(_addOutfitButtonHolder, tAddToTopOfList);
			_deleteBtnGrid.add(_addOutfitDeleteButton, tAddToTopOfList); // empty spot since no delete button for this
			// this.buttons.push(tNewOutfitBtn);// DO NOT ADD TO BUTTONS! only add to grid; this avoids issue when clicking "random" button
		}

		private function _untoggleAll(pList:Vector.<PushButton>, pExcepotButton:PushButton=null) : void {
			for(var i:int = 0; i < pList.length; i++) {
				if (pList[i].pushed && pList[i] != pExcepotButton) {
					pList[i].toggleOff();
				}
			}
		}
		
		private function toggleExportButton(pShow:Boolean) : void {
			if(pShow) {
				_exportButton.enable().alpha = 1;
			} else {
				_exportButton.disable().alpha = 0;
			}
		}
		
		/****************************
		* Events
		*****************************/
		private function _onExportClicked(e:MouseEvent) : void {
			var looks:Array = getStoredLookCodes();
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
				var oldLooks:Array = getStoredLookCodes();
				for(var i:int = importedLooks.length-1; i >= 0; i--) {
					// Don't allow an import file with invalid code
					if(this._character.parseParams(importedLooks[i]) === false) {
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
		
		protected override function _onInfobarReverseGridClicked(e:Event) : void {
			grid.reverse(); _deleteBtnGrid.reverse();
			_addNewOutfitButton();
			refreshScrollbox();
		}
	}
}
