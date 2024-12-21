package lt.states;

import lt.objects.play.Tile;
import flixel.addons.transition.FlxTransitionSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;

class TestTransition extends State {
    var f:Tile;
    override function create() {
        super.create();
        var wawa:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(10,10,FlxG.width,FlxG.height,true,0xFF353535,0xFF505050));
        wawa.scale.set(4,4);
        wawa.scrollFactor.set(0.2,0.2);
        wawa.alpha = 0.5;
        add(wawa);
        var f:Tile = new Tile(0,0,LEFT,0,Conductor.instance.step_ms*4);
        add(f);
        var x:Tile = new Tile(0,100,RIGHT,Conductor.instance.step_ms,Conductor.instance.step_ms*4);
        add(x);
        var a:Tile = new Tile(200,0,UP,Conductor.instance.step_ms*2,Conductor.instance.step_ms*4);
        add(a);
        var c:Tile = new Tile(200,300,DOWN,Conductor.instance.step_ms*3,Conductor.instance.step_ms*4);
        add(c);
    }

    var ue:Bool = false;
    override function update(elapsed:Float) {
        super.update(elapsed);

        var moveSpeed:Float = elapsed*1000;
        if (FlxG.keys.pressed.A || FlxG.keys.pressed.D) 
            FlxG.camera.scroll.x -= FlxG.keys.pressed.A ? moveSpeed : -moveSpeed;
        if (FlxG.keys.pressed.W || FlxG.keys.pressed.S) 
            FlxG.camera.scroll.y -= FlxG.keys.pressed.W ? moveSpeed : -moveSpeed;

        if (FlxG.keys.pressed.Q || FlxG.keys.pressed.E) 
            FlxG.camera.zoom -= FlxG.keys.pressed.Q ? -(3*elapsed) : (3*elapsed);

        if (FlxG.keys.justPressed.SPACE) {
            trace("Wawa");
            Utils.switchState(new TestTransition(true,true), "Transition Test!");
        }
    }
}