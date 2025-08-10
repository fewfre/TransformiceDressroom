package app.ui.panes
{
	import app.data.*;
	import app.ui.buttons.*;
	import app.ui.panes.base.ButtonGridSidePane;
	import app.ui.panes.infobar.GridManagementWidget;
	import app.ui.panes.infobar.Infobar;
	import app.world.data.ItemData;
	import app.world.data.OutfitData;
	import app.world.elements.Pose;
	import com.fewfre.display.TextTranslated;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.utils.Fewf;
	import com.fewfre.utils.FewfDisplayUtils;
	import com.fewfre.utils.FewfUtils;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	public class OutfitManagerTabPane extends ButtonGridSidePane
	{
		// Constants
		public static const LOOK_CODE_SELECTED : String = "look_code_selected"; // FewfEvent<string>
		
		// Storage
		private var _getLookCodeForCurrentOutfit : Function;
		private var _exportButton      : GameButton;
		private var _importButton      : GameButton;
		
		private var _newOutfitButtonHolder : Sprite;
		private var _deletedLooks      : Vector.<String>;
		private var _undoButton        : GameButton;
		private var _helpText          : TextTranslated;
		
		// Constructor
		public function OutfitManagerTabPane(pGetLookCodeForCurrentOutfit:Function) {
			super(5);
			_getLookCodeForCurrentOutfit = pGetLookCodeForCurrentOutfit;
			
			this.addInfobar( new Infobar({ showBackButton:true, hideItemPreview:true, gridManagement:{ hideRandomizeLock:true } }) )
				.on(Infobar.BACK_CLICKED, function(e):void{ dispatchEvent(new Event(Event.CLOSE)); });
			
			this.grid.reverse(); // Start reversed so that new outfits get added to start of list
			this.infobar.on(GridManagementWidget.RANDOMIZE_CLICKED, function(){ selectRandomOutfit(); });
			
			// Custom infobar buttons
			var size = 40, xx = -size - 5, yy = 25;
			
			_importButton = new GameButton(size).setImage(new $Folder()).setOrigin(0, 0.5).move(xx, yy)
				.onButtonClick(_onImportClicked) as GameButton;
			infobar.addCustomObjectToRightSideTray(_importButton);
			
			xx -= size + 5;
			
			_exportButton = new GameButton(size).setImage(new $SimpleDownload(), 0.7).setOrigin(0, 0.5).move(xx, yy)
				.onButtonClick(_onExportClicked).appendTo(infobar) as GameButton;
			infobar.addCustomObjectToRightSideTray(_exportButton);
			
			_helpText = new TextTranslated("outfit_manager_help").moveT(ConstantsApp.PANE_WIDTH/2+5, 190); // Don't append, let _updateHelpTextVisibility do that
			_helpText.enableWordWrapUsingWidth(ConstantsApp.PANE_WIDTH-80);
			
			_deletedLooks = new Vector.<String>();
			(_undoButton = new GameButton(24)).setImage(new $UndoArrow(), 0.5).move(ConstantsApp.SHOP_WIDTH/2-35, -1).appendTo(this.infobar).setVisible(false)
				.onButtonClick(function(e:Event):void{
					addNewLook(_deletedLooks.pop());
					if(!_deletedLooks.length) _undoButton.visible = false;
				});
		}
		
		/****************************
		* Public
		*****************************/
		public override function open() : void {
			super.open();
			
			_initLookCodesVector();
			_renderOutfits();
		}
		
		public function addNewLook(lookCode:String) : void {
			trace('addNewLook', lookCode);
			var entry:LookEntry = _addNewLookCodeAsEntryAndSave(lookCode);
			
			// Add it to grid - do it manually to avoid re-rendering whole list
			toggleExportButton(_lookCodesEntries.length > 0);
			_addLookButton(entry);
			_addNewOutfitButton();
			refreshScrollbox();
		}
		
		public function deleteLookById(entryId:Number) : void {
			var removedEntry:LookEntry = _deleteLookEntryIdAndSave(entryId);
			
			_deletedLooks.push(removedEntry.lookCode);
			_undoButton.visible = true;
			
			toggleExportButton(_lookCodesEntries.length > 0);
			if(removedEntry) {
				for(var i:int = 0; i < grid.cells.length; i++) {
					var btn:PushButton = _findPushButtonInCell(grid.cells[i]);
					if(btn && btn.data.entryId != null && btn.data.entryId == removedEntry.id) {
						grid.remove(grid.cells[i]);
						refreshScrollbox();
						return;
					}
				}
			}
		}
		
		public function selectRandomOutfit() : void {
			var looksCount = grid.cells.length-1; // ignore cell for "add new outfit"
			var i = Math.floor(Math.random() * looksCount);
			if(!grid.reversed) i++ // offset it so we don't select "add new outfit"
			_activatePushButtonGridCell(grid.cells[i]);
		}
		
		/****************************
		* Private
		*****************************/
		private function _renderOutfits() : void {
			toggleExportButton(_lookCodesEntries.length > 0);
			resetGrid();
			
			for each(var lookEntry:LookEntry in _lookCodesEntries){
				_addLookButton(lookEntry);
			}
			
			_addNewOutfitButton();
			refreshScrollbox();
		}
		
		public function _addLookButton(lookEntry:LookEntry) : void {
			var lookMC:Pose = new Pose().applyOutfitData(new OutfitData(true).setItemData(GameAssets.defaultPose).parseShareCodeSelf(lookEntry.lookCode, true));
			
			var cell:Sprite = new Sprite();
			var actionTray:Sprite = new Sprite(); actionTray.alpha = 0;
			cell.addEventListener(MouseEvent.MOUSE_OVER, function(e){ actionTray.alpha = 1; });
			cell.addEventListener(MouseEvent.MOUSE_OUT, function(e){ actionTray.alpha = 0; });
			
			var btn:PushButton = new PushButton(grid.cellSize).setImage(lookMC, 3).setData({ entryId:lookEntry.id }).appendTo(cell) as PushButton;
			btn.on(PushButton.TOGGLE, function(){
				dispatchEvent(new FewfEvent(LOOK_CODE_SELECTED, lookEntry.lookCode));
			});
			
			// Add on top of main button
			cell.addChild(actionTray);
			
			// Corresponding Delete Button
			var deleteBtn:ScaleButton = new ScaleButton(new $Trash(), 0.4).move(grid.cellSize-5, 5).appendTo(actionTray) as ScaleButton;
			// We have to delete by the index (instead of a code) since if someone added the same look twice but in different spots, this could delete the one in the wrong spot
			deleteBtn.on(MouseEvent.CLICK, function(e){ deleteLookById(lookEntry.id); });
			
			// Finally add to grid (do it at end so auto event handlers can be hooked up properly)
			addToGrid(cell);
		}
		
		private function _addNewOutfitButton() : void {
			var tAddToTopOfList:Boolean = !grid.reversed;
			if(_newOutfitButtonHolder) _grid.remove(_newOutfitButtonHolder);
			_newOutfitButtonHolder = new Sprite();
			
			// We do this so grid traversal works
			var fakePushBtn:PushButton = new PushButton(0).setData({ entryId:null }).appendTo(_newOutfitButtonHolder) as PushButton;
			fakePushBtn.visible=false;
			
			new ScaleButton(new $OutfitAdd()).move(grid.cellSize*0.5, grid.cellSize*0.5).appendTo(_newOutfitButtonHolder)
				.on(MouseEvent.CLICK, function(e){ addNewLook(_getLookCodeForCurrentOutfit()) });
			
			// Finally add to grid (do it at end so auto event handlers can be hooked up properly)
			addToGrid(_newOutfitButtonHolder, tAddToTopOfList);
		}
		
		private function toggleExportButton(pShow:Boolean) : void {
			if(pShow) {
				_exportButton.enable().setAlpha(1);
			} else {
				_exportButton.disable().setAlpha(0);
			}
		}
		
		private function _updateHelpTextVisibility() : void {
			var show:Boolean = _lookCodesEntries.length <= this.grid.columns-1;
			if(show && !_helpText.parent) {
				this.addChild(_helpText);
			}
			else if(!show && !!_helpText.parent) {
				_helpText.parent.removeChild(_helpText);
			}
		}
		
		/****************************
		* Private - Look code stuff
		*****************************/
		private var _lookCodesEntries : Vector.<LookEntry>;
		private function _initLookCodesVector() : void {
			_lookCodesEntries = new Vector.<LookEntry>();
			var list:Array = Fewf.sharedObject.getData(ConstantsApp.SHARED_OBJECT_KEY_OUTFITS) || [];
			for each(var look:String in list) {
				_lookCodesEntries.push(new LookEntry(look, _getNewEntryId()));
			}
		}
		
		private var __uniqIdIndex:int = 0;
		private function _getNewEntryId() : int { return __uniqIdIndex++; }
		
		private function _addNewLookCodeAsEntryAndSave(look:String) : LookEntry {
			var entry:LookEntry = new LookEntry(look, _getNewEntryId());
			_lookCodesEntries.push(entry);
			_saveCodeEntriesVector();
			return entry;
		}
		
		private function _deleteLookEntryIdAndSave(id:int) : LookEntry {
			// We need to delete by id here encase there's multiple of same look code
			// By finding the index of the id, we can find the real index of the look code instance associated with the index of the button
			var i:int = FewfUtils.getIndexFromVectorWithKeyVal(_lookCodesEntries, "id", id);
			if(i > -1) {
				var oldEntry:LookEntry = _lookCodesEntries[i];
				_lookCodesEntries.splice(i, 1);
				_saveCodeEntriesVector();
				return oldEntry;
			}
			return null;
		}
		
		private function _saveCodeEntriesVector() : void {
			var list:Array = [];
			for each(var entry:LookEntry in _lookCodesEntries) {
				list.push(entry.lookCode);
			}
			Fewf.sharedObject.setData(ConstantsApp.SHARED_OBJECT_KEY_OUTFITS, list);
		}
		
		/****************************
		* Events
		*****************************/
		private function _onExportClicked(e:Event) : void {
			var looks:Array = Fewf.sharedObject.getData(ConstantsApp.SHARED_OBJECT_KEY_OUTFITS) || [];
			var csv:String = looks.join('\n');
			
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(csv);
			( new FileReference() ).save( bytes, "saved-outfits-backup.csv" );
		}
		
		private function _onImportClicked(e:Event) : void {
			var fileRef : FileReference = new FileReference();
			fileRef.addEventListener(Event.SELECT, function(){ fileRef.load(); });
			fileRef.addEventListener(Event.COMPLETE, _onImportSelected);
			
			fileRef.browse([new FileFilter("Saved Outfits File", "*.csv")]);
		}
		
		private function _onImportSelected(e:Event) : void {
			try {
				var tempOutfitDataForTesting:OutfitData = new OutfitData();
				var importedLooks = e.target.data.toString().split('\n');
				var oldLooks:Array = Fewf.sharedObject.getData(ConstantsApp.SHARED_OBJECT_KEY_OUTFITS) || [];
				for(var i:int = importedLooks.length-1; i >= 0; i--) {
					// Don't allow an import file with invalid code
					if(tempOutfitDataForTesting.parseShareCode(importedLooks[i]) === false) {
						throw 'Invalid code in list';
					}
					// Remove duplicates being imported
					if(oldLooks.indexOf(importedLooks[i]) > -1) {
						importedLooks.splice(i, 1);
					}
				}
				var final = oldLooks.concat(importedLooks);
				Fewf.sharedObject.setData(ConstantsApp.SHARED_OBJECT_KEY_OUTFITS, final);
				
				_initLookCodesVector();
				_renderOutfits();
			} catch(e) {
				trace('Import Error: ', e);
				_importButton.setImage(new $No());
				setTimeout(function(){
					_importButton.setImage(new $Folder());
				}, 2000);
			}
		}
		
		protected override function _onInfobarReverseGridClicked(e:Event) : void {
			grid.reverse();
			_addNewOutfitButton();
			refreshScrollbox();
		}
		
		public override function refreshScrollbox() : void {
			super.refreshScrollbox();
			_updateHelpTextVisibility();
		}
	}
}

// This stupid thing is needed since the user can potentially have multiple copies of the same look, and deleteing one could delete it in the "wrong spot"
internal class LookEntry {
	public var lookCode:String;
	public var id:int;
	
	public function LookEntry(pLookCode:String, pId:int) {
		lookCode = pLookCode;
		id = pId;
	}
}