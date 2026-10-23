package app.ui.panes
{
	import app.data.GameAssets;
	import app.data.ItemType;
	import app.ui.PasteShareCodeInput;
	import app.ui.buttons.PushButton;
	import app.world.data.ItemData;
	import app.world.data.OutfitData;

	import com.fewfre.display.Grid;
	import com.fewfre.display.TextTranslated;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.utils.FewfUtils;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;

	public class PoseShopCategoryPane extends ShopCategoryPane
	{
		public static const PARTNER_OUTFIT_CHANGED:String = "partner_outfit_changed";

		private var _pairedSection:Sprite;
		private var _pairedGrid:Grid;
		private var _partnerOutfitData:OutfitData;
		private var _partnerVisible:Boolean = true;
		private var _partnerVisibilityButton:PushButton;

		public function get partnerOutfitData():OutfitData { return _partnerOutfitData; }
		public function syncPartnerOutfitData(pOutfitData:OutfitData) : void {
			_partnerOutfitData = pOutfitData || new OutfitData(true).setItemDataVector(new <ItemData>[GameAssets.defaultSkin, GameAssets.defaultPose]);
		}

		public function PoseShopCategoryPane(pPartnerOutfitData:OutfitData=null) {
			super(ItemType.POSE);

			_partnerOutfitData = pPartnerOutfitData || new OutfitData(true).setItemDataVector(new <ItemData>[GameAssets.defaultSkin, GameAssets.defaultPose]);
			_pairedSection = new Sprite();
			_pairedGrid = new Grid(385, 5).move(15, 30).appendTo(_pairedSection);
			new TextTranslated("duo_poses", { size:12, bold:true }).setOrigin(0, 0.5).move(15, 12).appendTo(_pairedSection);
			var xx:Number = 245;
			new PasteShareCodeInput(250, "duo_poses_paste_share").move(xx, 12).appendTo(_pairedSection).on(PasteShareCodeInput.CHANGE, _onPartnerShareCodePasted);
			xx += (250/2) + 24/2 + 7;
			(_partnerVisibilityButton = new PushButton(24)).setImage(new $HideEyeIcon(), 0.35).setOrigin(0.5, 0.5).move(xx, 12).appendTo(_pairedSection);
			_partnerVisibilityButton.onToggle(_onPartnerVisibilityToggled);
			_scrollbox.add(_pairedSection);
			_setupGrid(GameAssets.getItemDataListByType(ItemType.POSE));
		}

		protected override function _setupGrid(pItemList:Vector.<ItemData>) : void {
			if(!_pairedSection) {
				super._setupGrid(pItemList);
				return;
			}

			var regularPoses:Vector.<ItemData> = new Vector.<ItemData>();
			var pairedPoses:Vector.<ItemData> = new Vector.<ItemData>();
			for each(var itemData:ItemData in pItemList) {
				(itemData.hasPartnerPose ? pairedPoses : regularPoses).push(itemData);
			}

			super._setupGrid(regularPoses);
			_pairedGrid.reset();
			for each(itemData in pairedPoses) {
				_addPairedPoseButton(itemData);
			}
			_pairedSection.y = grid.y + grid.calculatedHeight + 10;
			_pairedSection.visible = pairedPoses.length > 0;
			refreshScrollbox();
		}

		public override function chooseRandomItem() : void {
			if(!buttons.length) return;
			var button:PushButton = buttons[Math.floor(Math.random() * buttons.length)];
			button.toggleOn();
			if(flagOpen) scrollItemIntoView(button.parent);
		}

		protected override function _getCellWithItemData(itemData:ItemData) : DisplayObject {
			for each(var cell:DisplayObject in _pairedGrid.cells) {
				if(itemData && itemData.matches(_findPushButtonInCell(cell).data.itemData)) return cell;
			}
			return super._getCellWithItemData(itemData);
		}

		protected override function _onCellPushButtonToggled(e:FewfEvent) : void {
			super._onCellPushButtonToggled(e);
			var activeButton:PushButton = e.currentTarget as PushButton;
			if(!activeButton.pushed) return;

			for each(var cell:DisplayObject in _pairedGrid.cells) {
				var otherButton:PushButton = _findPushButtonInCell(cell);
				if(otherButton != activeButton && otherButton.pushed) otherButton.toggleOff();
			}
		}

		private function _addPairedPoseButton(itemData:ItemData) : void {
			var image:MovieClip = GameAssets.getColoredItemImage(itemData);
			var cell:Sprite = new Sprite();
			var button:PushButton = new PushButton(_pairedGrid.cellSize)
				.setImage(image)
				.setData({ type:ItemType.POSE, itemID:itemData.id, itemData:itemData }) as PushButton;
			button.on(PushButton.TOGGLE, _onCellPushButtonToggled);
			cell.addChild(button);
			var emoteIcon:Sprite = GameAssets.getEmoteIconFromPoseId(itemData.id);
			if(emoteIcon) {
				emoteIcon.scaleX = emoteIcon.scaleY = 0.8;
				emoteIcon.x = _pairedGrid.cellSize - 18;
				emoteIcon.y = _pairedGrid.cellSize - 18;
				emoteIcon.mouseEnabled = false;
				cell.addChild(emoteIcon);
			}
			_pairedGrid.add(cell);
			buttons.push(button);
		}

		private function _onPartnerShareCodePasted(e:FewfEvent) : void {
			var code:String = FewfUtils.trim(e.data.code);
			if(code.indexOf("?") > -1) code = code.substr(code.indexOf("?") + 1);

			var outfit:OutfitData = new OutfitData(true).setItemDataVector(new <ItemData>[GameAssets.defaultSkin, GameAssets.defaultPose]);
			var success:Boolean = outfit.parseShareCode(code);
			e.data.update(success ? "success" : "invalid");
			if(!success) return;

			_partnerOutfitData = outfit;
			_partnerVisible = true;
			_partnerVisibilityButton.toggleOff(false);
			_dispatchPartnerOutfitChanged();
		}

		private function _onPartnerVisibilityToggled(e:FewfEvent) : void {
			_partnerVisible = !(e.currentTarget as PushButton).pushed;
			_dispatchPartnerOutfitChanged();
		}

		private function _dispatchPartnerOutfitChanged() : void {
			dispatchEvent(new FewfEvent(PARTNER_OUTFIT_CHANGED, { outfitData:_partnerVisible ? _partnerOutfitData : null }));
		}
	}
}
