package lt.objects.ui;

import flixel.text.FlxInputText;

class InputBox extends FlxInputText {
    public var label:Text;
    public var placeholder:Text;
    public function new(nX:Float, nY:Float, nWidth:Float, nText:String = "", nSize:Int = 13) {
        super(nX, nY, Std.int(nWidth),nText, nSize, 0xFFFFFFFF, 0xFF101010);
        fieldBorderColor = 0xFF303030;
        selectionColor = 0xFF757575;
        // flixel.ui.addons.
        font = Assets.font("musticapro");

        placeholder = new Text(nX,nY, "", nSize);
        placeholder.applyUIFont();
        placeholder.alpha = 0.5;
        label = new Text(nX,nY, "", nSize);
        label.applyUIFont();
    }

    override function draw() {
        super.draw();
        if (!hasFocus && text.trim() == ""){
            placeholder.setPosition(x, y);
            placeholder.cameras = cameras;
            placeholder.draw();
        }

        if (label.text != "") {
            label.x = x;
            label.y = y - label.height - 4;
            label.cameras = cameras;
            label.draw();
        }
    }

    override function destroy() {
        placeholder?.destroy();
        label?.destroy();
        super.destroy();
    }
}
