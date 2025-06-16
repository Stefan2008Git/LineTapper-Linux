package lt.objects.ui;

import flixel.FlxG;

class Button extends Sprite {
    public var outline:Sprite;
    public var label:Text;
    public var onClick:Bool->Void;

    public var toggle:Bool = false;
    public var toggled:Bool = false;

    public function new(nX:Float, nY:Float, text:String, w:Float = 150, h:Float = 20, isToggle:Bool = false, ?onClick:Bool->Void) {
        super();
        this.onClick = onClick;
        toggle = isToggle;

        x = nX;
        y = nY;

        makeGraphic(1, 1, 0xFF101010);
        outline = new Sprite();
        outline.makeGraphic(1, 1, 0xFF303030);

        label = new Text(0, 0, text, 13);
        label.setFont("musticapro");
        label.alignment = "center";
        label.color = 0xFFFFFFFF;

        setSize(w, h);
    }

    override public function setSize(w:Float, h:Float):Void {
        setGraphicSize(Std.int(w), Std.int(h));
        updateHitbox();

        outline.setGraphicSize(Std.int(w + 2), Std.int(h + 2));
        outline.updateHitbox();

        label.setPosition(
            x + (w - label.width) * 0.5,
            y + (h - label.height) * 0.5
        );
    }

    override function update(elapsed:Float):Void {
        super.update(elapsed);

        var hovered:Bool = FlxG.mouse.overlaps(this);

        if (hovered && FlxG.mouse.justPressed) {
            if (toggle) toggled = !toggled;
            if (onClick!=null) onClick(toggle ? toggled : true);
        }

        alpha = hovered ? 1.0 : 0.9;
    }

    override function draw():Void {
        outline.setPosition(
            x + (width - outline.width) * 0.5,
            y + (height - outline.height) * 0.5
        );
        outline.cameras = cameras;
        outline.alpha = alpha;
        outline.draw();

        super.draw();

        label.setPosition(
            x + (width - label.width) * 0.5,
            y + (height - label.height) * 0.5
        );
        label.cameras = cameras;
        label.alpha = alpha;
        label.draw();
    }

    override function destroy():Void {
        outline?.destroy();
        label?.destroy();
        super.destroy();
    }
}
