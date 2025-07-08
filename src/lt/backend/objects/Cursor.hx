package lt.backend.objects;

import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.Lib;
import flixel.FlxG;
import openfl.events.Event;
import openfl.geom.Point;

class Cursor extends Sprite {
    private var bmp:Bitmap;
    private var target:Point = new Point();
    private var velocity:Point = new Point();
    private var isMouseDown:Bool = false;

    public function new() {
        super();

        bmp = new Bitmap(Assets.image('ui/cursors/pointer').bitmap);
        bmp.smoothing = true;
        bmp.scaleX = bmp.scaleY = 0.25;
        bmp.x = 0;
        bmp.y = 0;

        addChild(bmp);

        Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        Lib.current.stage.addEventListener(MouseEvent.MOUSE_OUT, onMouseLeave);
        Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        Lib.current.addEventListener(Event.ENTER_FRAME, onEnterFrame);

        FlxG.mouse.visible = false;
    }

    private function onMouseMove(e:MouseEvent):Void {
        target.setTo(e.stageX, e.stageY);
        this.visible = true;
    }

    private function onMouseLeave(e:MouseEvent):Void {
        //this.visible = false;
    }

    private function onMouseDown(e:MouseEvent):Void {
        if (!isMouseDown) {
            Sound.playSfx(Assets.sound('mouse/pressed'), 0.4);
            isMouseDown = true;
        }
    }

    private function onMouseUp(e:MouseEvent):Void {
        if (isMouseDown) {
            Sound.playSfx(Assets.sound('mouse/release'), 0.4);
            isMouseDown = false;
        }
    }

    private function onEnterFrame(e:Event):Void {
        var lerp:Float = 0.25;
        //this.x += (target.x - this.x) * lerp;
        //this.y += (target.y - this.y) * lerp;
        x = target.x;
        y = target.y;

        var dx = target.x - this.x;
        velocity.x += (dx - velocity.x) * 0.1;
        this.rotation = velocity.x * 0.2;

        // Zoom on hold (scale up smoothly)
        var targetScale = isMouseDown ? 0.3 : 0.25;
        bmp.scaleX += (targetScale - bmp.scaleX) * 0.3;
        bmp.scaleY += (targetScale - bmp.scaleY) * 0.3;
    }

    public function destroy():Void {
        Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        Lib.current.stage.removeEventListener(MouseEvent.MOUSE_OUT, onMouseLeave);
        Lib.current.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        Lib.current.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        if (this.parent != null) this.parent.removeChild(this);
        FlxG.mouse.visible = true;
    }
}
