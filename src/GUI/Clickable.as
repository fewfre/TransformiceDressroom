package GUI 
{
    import flash.display.*;
    import flash.events.*;
    import flash.text.*;
    
    public class Clickable extends flash.display.Sprite
    {
        public function Clickable(arg1:Number, arg2:Number, arg3:Number, arg4:Number, arg5:String)
        {
            super();
            this.Width = arg3;
            this.Height = arg4;
            x = arg1;
            y = arg2;
            buttonMode = true;
            useHandCursor = true;
            mouseChildren = false;
            addEventListener(flash.events.MouseEvent.MOUSE_DOWN, this.Mouse_Down);
            addEventListener(flash.events.MouseEvent.MOUSE_UP, this.Mouse_Up);
            addEventListener(flash.events.MouseEvent.CLICK, this.Mouse_Click);
            addEventListener(flash.events.MouseEvent.ROLL_OVER, this.Mouse_Over);
            addEventListener(flash.events.MouseEvent.ROLL_OUT, this.Mouse_Out);
            var loc1:*=new flash.text.TextFormat("Verdana", 11, 12763866);
            this.Text = new flash.text.TextField();
            this.Text.defaultTextFormat = loc1;
            this.Text.autoSize = flash.text.TextFieldAutoSize.CENTER;
            this.Text.text = arg5;
            addChild(this.Text);
            this.Unpressed();
            return;
        }

        public function Unpressed():*
        {
            graphics.clear();
            graphics.moveTo(0, 0);
            graphics.lineStyle(1, 6126992, 1, true);
            graphics.drawRoundRect(0, 0, this.Width - 3, this.Height - 3, 7, 7);
            graphics.lineStyle(1, 1120028, 1, true);
            graphics.drawRoundRect(2, 2, this.Width - 3, this.Height - 3, 7, 7);
            graphics.lineStyle(1, 3952740, 1, true);
            graphics.beginFill(3952740);
            graphics.drawRoundRect(1, 1, this.Width - 3, this.Height - 3, 7, 7);
            graphics.endFill();
            this.Text.x = (this.Width - this.Text.textWidth) / 2 - 2;
            this.Text.y = (this.Height - this.Text.textHeight) / 2 - 2;
            return;
        }

        public function Pressed():*
        {
            graphics.clear();
            graphics.moveTo(0, 0);
            graphics.lineStyle(1, 1120028, 1, true);
            graphics.drawRoundRect(0, 0, this.Width - 3, this.Height - 3, 7, 7);
            graphics.lineStyle(1, 6126992, 1, true);
            graphics.drawRoundRect(2, 2, this.Width - 3, this.Height - 3, 7, 7);
            graphics.lineStyle(1, 3952740, 1, true);
            graphics.beginFill(3952740);
            graphics.drawRoundRect(1, 1, this.Width - 3, this.Height - 3, 7, 7);
            graphics.endFill();
            this.Text.x = (this.Width - this.Text.textWidth) / 2;
            this.Text.y = (this.Height - this.Text.textHeight) / 2;
            return;
        }

        internal function Mouse_Down(arg1:flash.events.MouseEvent):*
        {
            this.Pressed();
            return;
        }

        internal function Mouse_Up(arg1:flash.events.MouseEvent):*
        {
            this.Unpressed();
            return;
        }

        internal function Mouse_Click(arg1:flash.events.MouseEvent):*
        {
            dispatchEvent(new flash.events.Event(BUTTON_CLICK));
            return;
        }

        internal function Mouse_Over(arg1:flash.events.MouseEvent):*
        {
            this.Text.textColor = 74565;
            return;
        }

        internal function Mouse_Out(arg1:flash.events.MouseEvent):*
        {
            this.Text.textColor = 12763866;
            this.Unpressed();
            return;
        }

        public static const BUTTON_CLICK:String="button_click";

        var Text:flash.text.TextField;

        var Height:Number;

        var Width:Number;
    }
}
