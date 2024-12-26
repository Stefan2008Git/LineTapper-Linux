package lt.substates;

import lt.states.PlayState;
import lt.states.MenuState;

class PauseSubstate extends FlxSubState {
    public static inline var FADE_DURATION:Float = 0.2;

    var pauseBG:Sprite;
    var pauseText:Text;
    var pauseTextBG:Sprite;
    var parent:PlayState;
    public function new(parent:PlayState) {
        super();
        this.parent = parent;

        pauseBG = new Sprite(0,0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        pauseBG.alpha = 0.0;
        add(pauseBG);

		pauseText = new Text(0,0, PhraseManager.getPhrase("PAUSED"), 24, CENTER, true);
		pauseText.screenCenter();
		pauseText.alpha = 0.0;

        pauseTextBG = new Sprite(0, 0).makeGraphic(Std.int(pauseText.width + 16), Std.int(pauseText.height + 16), FlxColor.BLACK);
		pauseTextBG.alpha = 0.0;
		pauseTextBG.screenCenter();
        add(pauseTextBG);

        add(pauseText);

        FlxTween.tween(pauseBG, {alpha: 0.5}, FADE_DURATION, {ease: FlxEase.expoOut});
        FlxTween.tween(pauseText, {alpha: 1}, FADE_DURATION, {ease: FlxEase.expoOut});
        FlxTween.tween(pauseTextBG, {alpha: 1}, FADE_DURATION, {ease: FlxEase.expoOut});

        cameras = [parent.hudCamera];
    }

    override function update(elapsed:Float) {
        if (FlxG.keys.justReleased.ESCAPE) {
            Utils.switchState(new MenuState(), PhraseManager.getPhrase("Leaving Gameplay"));
        } else if (FlxG.keys.justPressed.ANY) {
            FlxTween.tween(pauseBG, {alpha: 0}, FADE_DURATION, {ease: FlxEase.expoOut});
            FlxTween.tween(pauseText, {alpha: 0}, FADE_DURATION, {ease: FlxEase.expoOut});
            FlxTween.tween(pauseTextBG, {alpha: 0}, FADE_DURATION, {ease: FlxEase.expoOut, onComplete: (_)->{
                close();
            }});
        }
        super.update(elapsed);
    }
}