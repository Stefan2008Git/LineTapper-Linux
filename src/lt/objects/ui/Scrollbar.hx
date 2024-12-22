package lt.objects.ui;

import flixel.ui.FlxBar;

class Scrollbar extends Text {
    var bar:FlxBar;
    var barHandle:Sprite;
    var valueIndicator:Text;
    var nWidth:Int = 0;

    public var onChanged:Float -> Void = (wa:Float)->{};
    public var value(default,set):Float = 0;
    var __skipCall:Bool = false;
    function set_value(val:Float):Float {
        value = val;
        if (!__skipCall) onChanged(value);
        return val;
    }

    public var suffix:String = "";
    public function new(nX:Float, nY:Float, nText:String, suffix:String = "", nWidth:Float = 200, ?value:Float = 0.5, ?min:Float = 0, ?max:Float = 0) {
        super(nX,nY,nText,16);
        this.suffix = suffix;
        __skipCall = true;
        this.value = value;
        __skipCall = false;
        this.nWidth = Std.int(nWidth);
        setFont("musticapro");

        bar = new FlxBar(0,0,LEFT_TO_RIGHT, Std.int(nWidth), 5, this, "value", min, max);
        bar.createFilledBar(0xFF303030, 0xFFFFFFFF);

        barHandle = new Sprite().makeGraphic(10,10,0xFFFFFFFF);

        valueIndicator = new Text(0,0,"",14, RIGHT);
        valueIndicator.setFont("musticapro");
    }

    override function update(elapsed:Float) {
        bar.update(elapsed);
        super.update(elapsed);
    }

    var moving:Bool = false;
    override function draw() {
        super.draw();
    
        bar.x = x;
        bar.y = y + 30;
        bar.draw();
    
        barHandle.x = bar.x + (Utils.normalize(value, bar.min, bar.max) * bar.width) - (barHandle.width * 0.5);
        barHandle.y = bar.y + (bar.height - barHandle.height) * 0.5;
        barHandle.draw();
    
        if ((FlxG.mouse.overlaps(bar) || FlxG.mouse.overlaps(barHandle)) && FlxG.mouse.justPressed)
            moving = true;
    
        if (moving) {
            var mouseX:Float = Math.max(bar.x, Math.min(FlxG.mouse.x, bar.x + bar.width));
            value = bar.min + ((mouseX - bar.x) / bar.width) * (bar.max - bar.min);
            value = Math.max(bar.min, Math.min(value, bar.max));
        }
    
        if (FlxG.mouse.justReleased)
            moving = false;
    
        valueIndicator.x = x + (nWidth - valueIndicator.width);
        valueIndicator.y = y;
        valueIndicator.text = '${FlxMath.roundDecimal(value,1)}$suffix';
        valueIndicator.draw();
    }    

    override function get_width():Float {
        super.get_width();
        return nWidth;
    }

    override function get_height():Float {
        return super.get_height() + 10 + bar.height;
    }
}