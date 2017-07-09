package app.ui.lang
{
	import com.fewfre.display.*;
	import com.fewfre.events.*;
	import com.fewfre.utils.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import flash.display.*;
	import flash.text.*;
	import flash.events.MouseEvent;
	
	public class LangButton extends SpriteButton
	{
		// Storage
		
		// Constructor
		// pData = { x:Number, y:Number, width:Number, height:Number, ?obj:DisplayObject, ?obj_scale:Number, ?id:int, ?text:String, ?origin:Number, ?originX:Number, ?originY:Number }
		public function LangButton(pData:Object)
		{
			pData.obj = new MovieClip();
			pData.obj_scale = 0.18;
			super(pData);
			_changeImageToCurrentLanguage();
			
			Fewf.dispatcher.addEventListener(I18n.FILE_UPDATED, _onFileUpdated);
		}
		
		private function _changeImageToCurrentLanguage() {
			var tLangData = Fewf.i18n.getConfigLangData();
			ChangeImage(new (Fewf.assets.getLoadedClass(tLangData.flags_swf_linkage))());
			this.Image.x -= this.Image.width*0.5;
			this.Image.y -= this.Image.height*0.5;
		}

		/****************************
		* Events
		*****************************/
		protected function _onFileUpdated(e:FewfEvent) : void {
			_changeImageToCurrentLanguage();
		}
	}
}
