package lt.objects.play;

class TimingDisplay extends Sprite {
    var indicators:Array<{spr:Sprite,diff:Float}> = [];
    var msText:Text;
    public function new() {
        super();
        loadGraphic(Assets.image("play/hit_bar"));
        screenCenter(X);
        //blend = ADD;
        alpha = 1;

        msText = new Text(0,0,"",14, CENTER);
        msText.setFont("musticapro");
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

        if (msText.alpha > 0) {
            msText.alpha -= FlxG.elapsed*2;
            msText.setPosition(
                x + (width - msText.width) * 0.5,
                FlxMath.lerp(msText.y, y - msText.height - 5, FlxG.elapsed * 12)
            );
            msText.cameras = cameras;
            msText.draw();
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

        msText.text = FlxMath.roundDecimal(ms,1)+"ms";
        msText.y += 5;
        msText.alpha = 1;
    }
}