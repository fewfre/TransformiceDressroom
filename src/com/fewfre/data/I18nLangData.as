package com.fewfre.data
{
	import com.fewfre.utils.Fewf;
	import flash.display.Sprite;

	public class I18nLangData
	{
		private var _code : String;
		private var _name : String;
		private var _flagAssetName : String;
		
		public function get code() : String { return _code; }
		public function get name() : String { return _name; }
		public function get assetName() : String { return _flagAssetName; }
		
		function I18nLangData(pJsonData:Object) {
			_code = pJsonData.code;
			_name = pJsonData.name;
			_flagAssetName = pJsonData.flags_swf_linkage;
		}
		
		public function newFlagSprite() : Sprite {
			var tHolder:Sprite = new Sprite();
			var tFlag:Sprite = tHolder.addChild(Fewf.assets.getLoadedMovieClip(_flagAssetName)) as Sprite;
			tFlag.x -= tFlag.width*0.5;
			tFlag.y -= tFlag.height*0.5;
			return tHolder;
		}
	}
}