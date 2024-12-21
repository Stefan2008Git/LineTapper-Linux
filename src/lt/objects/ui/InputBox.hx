package lt.objects.ui;

import flixel.addons.ui.FlxInputText;

class InputBox extends FlxInputText {
    public var placeholder:Text;
    public function new(nX:Float, nY:Float, nWidth:Float, nText:String = "", nSize:Int = 13) {
        super(nX, nY, Std.int(nWidth),nText, nSize, 0xFFFFFFFF, 0xFF101010);
        fieldBorderColor = 0xFF303030;
        font = Assets.font("musticapro");

        placeholder = new Text(nX,nY, "", nSize);
        placeholder.setFont("musticapro");
        placeholder.alpha = 0.5;
    }

    override function draw() {
        super.draw();
        if (!hasFocus && text.trim() == ""){
            placeholder.setPosition(x, y);
            placeholder.draw();
        }

    }

    override function update(elapsed:Float) {
        if (hasFocus) {

        }
        super.update(elapsed);
    }
}
