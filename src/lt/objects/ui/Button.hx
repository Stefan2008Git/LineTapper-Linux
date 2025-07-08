package lt.objects.ui;

enum abstract ButtonAlignment(String) from String to String {
    var LEFT = 'left';
    var CENTER = 'center';
    var RIGHT = 'right';
}
class Button extends Panel {
    public var label:Text;
    public var align:ButtonAlignment = CENTER;
    public var toggled:Bool = true;

    public var nWidth:Float = -1;
    public var isToggle:Bool = false;
    public var onClick:Bool->Void = (status:Bool = false)->{};
    public function new(nX:Float, nY:Float, nWidth:Float = -1, text:String, onClick:Bool->Void) {
        super(nX, nY, 20, 20);
        this.nWidth = nWidth;
        this.onClick = onClick;
        label = new Text(0,0,text,13, CENTER);
        label.applyUIFont();
    }

    override function draw():Void {
        if (nWidth < 0)
            width = label.width + 2;
        else
            width = nWidth;

        height = label.height + 2;

        switch (align) {
            case CENTER:
                label.x = x + (width - label.width) * 0.5;
            case LEFT:
                label.x = x + 2;
            case RIGHT:
                label.x = x + (width - label.width) - 2;
        }
        label.y = y + (height - label.height) * 0.5;

        if (isToggle) {
            label.alpha = toggled ? 1 : 0.5;
        }

        if (isToggle)
            alpha = toggled ? 1 : 0.5;
        else
            alpha = 0.7;
        if (FlxG.mouse.overlaps(this, cameras[0])) {
            alpha = FlxG.mouse.pressed ? 0.7 : 1;
            if (FlxG.mouse.justReleased) {
                if (isToggle) toggled = !toggled; // Toggle state
                onClick(toggled);
            }
        }
        
        label.cameras = cameras;
        super.draw();
        label.draw();
    }
}