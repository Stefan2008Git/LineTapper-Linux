package lt.objects.play;

class TimingDisplay extends Sprite {
    var indicators:Array<{spr:Sprite,diff:Float}> = [];
    public function new() {
        super();
        loadGraphic(Assets.image("play/hit_bar"));
        screenCenter(X);
        blend = ADD;
        alpha = 0.7;
    }

    override function draw() {
        super.draw();
        for (i in indicators) {
            var sprite:Sprite = i.spr;
            var mappedPosition:Float = (i.diff + 250) / 500 * width;
            sprite.cameras = cameras;
            sprite.x = x + mappedPosition - (sprite.width * 0.5);
            sprite.y = y + (height - sprite.height) * 0.5;
            sprite.scale.y -= 100 * FlxG.elapsed;

            if (sprite.scale.y < 0) {
                i.spr.kill();
                indicators.remove(i);
                i.spr.destroy();
                i.spr = null;
            }
            i.spr?.draw();
        }
    }
    

    public function addBar(ms:Float) {
        var spr:Sprite = new Sprite().makeGraphic(1,1);
        spr.scale.x = 2;
        spr.scale.y = height + 20;
        spr.active = false;
        indicators.push({
            spr: spr,
            diff: ms
        });
    }
}