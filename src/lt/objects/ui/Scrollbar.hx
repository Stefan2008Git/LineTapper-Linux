package lt.objects.ui;

import flixel.ui.FlxBar;

class Scrollbar extends Text {
    var bar:FlxBar;
    var barHandle:Sprite;
    var valueIndicator:Text;
    var nWidth:Int = 0;

    public var stepSize:Float = 0.1;
    public var onChanged:Float -> Void = (wa:Float)->{};
    public var value(default,set):Float = 0;
    
    var __lastValue(default,set):Float = 0;
    var __skipCall:Bool = false;

    var lerpValue:Float = 0;

    function set_value(val:Float):Float {
        value = val;
        if (!__skipCall) {
            __lastValue = val;
            onChanged(value);
        }
        return val;
    }

    function set___lastValue(val:Float):Float {
        if (__lastValue != val) {
            Sound.playSfx(Assets.sound("menu/click"), 0.6);
        }
        return __lastValue = val;
    }

    public var suffix:String = "";

    public function new(nX:Float, nY:Float, nText:String, suffix:String = "", nWidth:Float = 200, ?value:Float = 0.5, ?min:Float = 0, ?max:Float = 100, ?step:Float = 1) {
        super(nX,nY,nText,13);
        this.suffix = suffix;
        __skipCall = true;
        this.value = value;
        this.stepSize = step;
        __skipCall = false;
        this.nWidth = Std.int(nWidth);
        applyUIFont();

        bar = new FlxBar(0,0,LEFT_TO_RIGHT, Std.int(nWidth), 5, this, "lerpValue", min, max);
        bar.createFilledBar(0xFF303030, 0xFFFFFFFF);

        barHandle = new Sprite().makeGraphic(10,10,0xFFFFFFFF);

        valueIndicator = new Text(0,0,"",13, RIGHT);
        valueIndicator.applyUIFont();
    }

    override function update(elapsed:Float) {
        bar.update(elapsed);
        super.update(elapsed);
    }

    var moving:Bool = false;
    override function draw() {
        super.draw();
    
        bar.x = x;
        bar.y = y + 25;
        bar.draw();
    
        barHandle.x = bar.x + (Utils.normalize(lerpValue, bar.min, bar.max) * bar.width) - (barHandle.width * 0.5);
        barHandle.y = bar.y + (bar.height - barHandle.height) * 0.5;
        barHandle.draw();
    
        if ((FlxG.mouse.overlaps(bar) || FlxG.mouse.overlaps(barHandle)) && FlxG.mouse.justPressed)
            moving = true;
    
        if (moving) {
            var mouseX:Float = Math.max(bar.x, Math.min(FlxG.mouse.x, bar.x + bar.width));
            var rawValue:Float = bar.min + ((mouseX - bar.x) / bar.width) * (bar.max - bar.min);
            
            value = Math.round(rawValue / stepSize) * stepSize;
            value = Math.max(bar.min, Math.min(value, bar.max));
        }

        lerpValue = FlxMath.lerp(lerpValue, value, FlxG.elapsed * 12);
    
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

    override function destroy() {
        bar?.destroy();
        barHandle?.destroy();
        valueIndicator?.destroy();
        super.destroy();
    }
}