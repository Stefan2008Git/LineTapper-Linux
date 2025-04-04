package lt.objects.play;

import flixel.util.FlxGradient;
#if ALLOW_VIDEOS
import hxcodec.flixel.FlxVideoSprite;
#end

class Background extends FlxSprite {
    var background:FlxSprite;
    var usingVideo:Bool = false;
    #if ALLOW_VIDEOS
    var video:FlxVideoSprite;
    #end
    public function new(mapName:String) {
        super();
        background = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [FlxColor.BLACK, FlxColor.BLUE], 1, 90, true);
		background.scrollFactor.set();
		background.alpha = 0.1;
        background.active = false;

        #if ALLOW_VIDEOS
        if (Assets.video(mapName) != "") {
            trace("Found video file, loading.");
            video = new FlxVideoSprite();
            video.scrollFactor.set();
            video.bitmap.onEndReached.add(video.bitmap.dispose);
            video.play(Assets.video(mapName));
            video.pause();
            video.bitmap.time = 0;
            video.bitmap.mute = true;
            usingVideo = true;
            video.alpha = 0;
            trace("Video loaded.");
        }
        #end
    }

    override function draw() {
        if (usingVideo) {
            #if ALLOW_VIDEOS            
            var screenAspect:Float = FlxG.width / FlxG.height;
            var videoAspect:Float = video.width / video.height;
            
            video.setGraphicSize(
                videoAspect > screenAspect ? FlxG.width : Std.int(FlxG.height * videoAspect),
                videoAspect > screenAspect ? Std.int(FlxG.width / videoAspect) : FlxG.height
            );
            
            video.updateHitbox();
            video.cameras = cameras;
            video.draw();
            video.screenCenter();
            #end
        } else {
            background.setPosition(x, y);
            background.cameras = cameras;
            background.draw();
        }
    }
    

    public function play() {
        #if ALLOW_VIDEOS
        if (usingVideo) {
            video.resume();
            trace("Playback started.");
            FlxTween.tween(video, {alpha: 0.5}, Conductor.instance.beat_ms / 1000);
        }
        #else
        trace("Video playback is disabled on this build.");
        #end
    }
}