package lt.objects.ui;

class Checkbox extends Text {
    var check:Sprite;
    var checkOutline:Sprite;
    var nWidth:Int = 0;

    public var onChanged:Bool -> Void = (wa:Bool)->{};
    public var checked(default, set):Bool = false;
    var __skipCall:Bool = false;
    function set_checked(val:Bool):Bool {
        checked = val;
        if (!__skipCall) onChanged(checked);
        return val;
    }
    public function new(nX:Float, nY:Float, nText:String, nWidth:Float = 200, ?checked:Bool = false) {
        super(nX,nY,nText,16);
        __skipCall = true;
        this.checked = checked;
        __skipCall = false;
        this.nWidth = Std.int(nWidth);
        setFont("musticapro");
        check = new Sprite().makeGraphic(20,20,0xFFFFFFFF);
        checkOutline = new Sprite().loadGraphic(check.graphic);
        checkOutline.setScale(1.1);
    }

    override function draw() {
        super.draw();
        if (FlxG.mouse.overlaps(check) && FlxG.mouse.justPressed) {
            checked = !checked;
        }
        check.color = checked ? 0xFFFFFFFF : 0xFF000000;
        check.x = x + (width - check.width);
        check.y = y + (height - check.height) * 0.5;

        checkOutline.x = check.x + (check.width - checkOutline.width) * 0.5;
        checkOutline.y = check.y + (check.width - checkOutline.width) * 0.5;
        checkOutline.draw();
        check.draw();
    }

    override function get_width():Float {
        super.get_width();
        return nWidth;
    }

    override function destroy() {
        check?.destroy();
        checkOutline?.destroy();
        super.destroy();
    }
}