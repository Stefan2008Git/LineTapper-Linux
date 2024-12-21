package lt.states;

import lt.objects.play.Tile;
import lt.objects.play.TimingDisplay;
import flixel.ui.FlxBar;
import lt.backend.MapData.MapAsset;
import lt.objects.play.Player;
import lt.objects.play.GameplayStage;

class PlayState extends StateBase {
    /**
     * Current active instance of PlayState.
     */
    public static var instance:PlayState;

    /**
	 * Current song's name.
	 */
	public var songName:String = "Tutorial";
    /**
	 * The world camera, shortcut to `FlxG.camera`.
	 */
	public var gameCamera:FlxCamera;
	
	/**
	 * The HUD Camera.
	 */
	public var hudCamera:FlxCamera;

    public var stage:GameplayStage;
    public var camFollow:FlxObject;
    public var player:Player;

    public var timeBar:FlxBar;
    public var timeTextLeft:FlxText;
    public var songText:FlxText;
    public var timeTextRight:FlxText;

    public var timing:TimingDisplay;
    public var playerText:FlxText;

    public var score:Int = 0;
    public var combo:Int = 0;

    public var playbackRate:Float = 0.9;

    public var paused:Bool = false;
	public var pauseBG:FlxSprite;
	public var pauseTextBG:FlxSprite;
	public var pauseText:FlxText;

    public function new(?song:String) {
        super();
        songName = song ?? "Tutorial";
    }
    override function create() {
        instance = this;
        Conductor.instance.time = 0;

        gameCamera = new FlxCamera();
		FlxG.cameras.reset(gameCamera);

		hudCamera = new FlxCamera();
		hudCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(hudCamera, false);

        stage = new GameplayStage(this);
        stage.generateTiles(loadSong(songName));
        stage.onTileHit.add(onTileHit);
        stage.onTileMiss.add(onTileMiss);
        player = stage.player;
        add(stage);
        
        initHUD();

        camFollow = new FlxObject(player.x, player.y - 100, 1, 1);
		add(camFollow);
		FlxG.camera.follow(camFollow, LOCKON);
        super.create();
    }

    inline function initHUD() {
        inline function makeText(nX:Float,nY:Float,label:String, size:Int, ?bold:Bool = false, ?align:FlxTextAlign):FlxText {
			var obj:FlxText = new FlxText(nX, nY, -1, label);
			obj.setFormat(Assets.font("extenro"+(bold?"-bold":"")), size, FlxColor.WHITE, align, OUTLINE, FlxColor.BLACK);
			obj.cameras = [hudCamera];
			obj.active = false;
			return obj;
		}

		// Time Bar lt.objects. //
		timeBar = new FlxBar(0,0,LEFT_TO_RIGHT, FlxG.width,5,null,"",0,1,false);
		timeBar.numDivisions = 2000; // uhhh
		timeBar.createFilledBar(0x00000000, 0xFFFFFFFF);
		timeBar.cameras = [hudCamera];
		add(timeBar);
		
		var startY:Float = timeBar.y + timeBar.height + 5;

		timeTextLeft = makeText(10, startY, "", 12, false, LEFT);
		add(timeTextLeft);

        songText = makeText(FlxG.width*0.5, startY, songName.toUpperCase(), 12, false, LEFT);
        songText.x -= songText.width*0.5;
        add(songText);

		timeTextRight = makeText(FlxG.width, startY, "", 12, false, LEFT);
		timeTextRight.x -= timeTextRight.width;
		add(timeTextRight);

        playerText = makeText(10, 0, "", 12, false, LEFT);
		add(playerText);

        timing = new TimingDisplay();
        timing.y = FlxG.height - 25;
        timing.cameras = [hudCamera];
        add(timing);

		pauseBG = new FlxSprite(0,0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        pauseBG.alpha = 0.0;
		pauseBG.cameras = [hudCamera];
        add(pauseBG);

		pauseText = makeText(0,0,"Paused", 32, true, CENTER);
		pauseText.screenCenter();
		pauseText.alpha = 0.0;
		pauseText.cameras = [hudCamera];
        
		pauseTextBG = new FlxSprite(0, 0).makeGraphic(Std.int(pauseText.width + 16), Std.int(pauseText.height + 16), FlxColor.BLACK);
		pauseTextBG.alpha = 0.0;
		pauseTextBG.cameras = [hudCamera];
		pauseTextBG.screenCenter();

        add(pauseTextBG);
        add(pauseText);

    }

    function loadSong(_song:String) {
        var mapAsset:MapAsset = Assets.map(_song);
        FlxG.sound.playMusic(mapAsset.audio, 1, false);
		FlxG.sound.music.time = 0;
        FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.pause();
        Conductor.instance.updateBPM(mapAsset.map.bpm);
        return mapAsset.map;
    }

    public var started:Bool = false;

    override function update(elapsed:Float) {
		if (FlxG.keys.justPressed.SPACE && !started) {
            stage.start();
            FlxG.sound.music.play();
			started = true;
        }

		if (FlxG.keys.justPressed.ENTER && started)
        {
            paused = !paused;
			stage.paused = paused;

			var targABG:Float = 0.0;
			var targATXT:Float = 0.0;
			if (paused)
				targABG = 0.5;
			if (paused)
				targATXT = 1.0;
			if (paused)
                FlxG.sound.music.pause();
            else
                FlxG.sound.music.play();

			FlxTween.tween(pauseBG, {alpha: targABG}, 1.0);
			FlxTween.tween(pauseText, {alpha: targATXT}, 1.0);
			FlxTween.tween(pauseTextBG, {alpha: targATXT}, 1.0);
        }

		if (!paused) {
			camFollow.x = FlxMath.lerp(player.getMidpoint().x, camFollow.x, 1 - (elapsed * 12));
			camFollow.y = FlxMath.lerp(player.getMidpoint().y, camFollow.y, 1 - (elapsed * 12));

			timeBar.percent = (Conductor.instance.time / FlxG.sound.music.length) * 100;
			timeTextLeft.text = Utils.formatMS(Conductor.instance.time);
			timeTextRight.text = Utils.formatMS(FlxG.sound.music.length);
			timeTextRight.x = FlxG.width - (timeTextRight.width + 10);

			playerText.updateHitbox();
			playerText.setPosition(10, FlxG.height - (playerText.height + 10));
		} else {
            if (FlxG.keys.justReleased.ESCAPE)
            {
				Utils.switchState(new MenuState(), "Leaving Gameplay");
            }
        }

        super.update(elapsed);
    }

    public function onTileHit(tile:Tile) {
        timing.addBar(tile.time - Conductor.instance.time);
        combo++;
        updatePlayerText();
    }
    public function onTileMiss(tile:Tile) {
        combo = 0;
        updatePlayerText("Missed!");
    }

    var _tween:FlxTween;
    public function updatePlayerText(rating:String = "Perfect!") {
        playerText.text = '$rating\n${combo}x';

        playerText.scale.set(1.2,1.2);
        playerText.updateHitbox();
        playerText.setPosition(10, FlxG.height - (playerText.height + 10));
        if (_tween!=null) _tween.cancel();

        _tween = FlxTween.tween(playerText.scale, {x:1,y:1}, 0.2, {onUpdate: (_)->{
            playerText.updateHitbox();
        },onComplete: (_)->{
            _tween = null;
        }});
    }
}