package lt.states;

import flixel.sound.FlxSound;
import flixel.text.FlxInputText;
import flixel.text.FlxInputTextManager;
import lt.objects.ui.InputBox;
import flixel.math.FlxPoint;
import lt.objects.play.Tile;
import lt.objects.play.editor.DummyTile;
import lt.objects.play.GameplayStage;
import lt.objects.play.Player;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;

class LevelEditorState extends State {
    var stage:GameplayStage;
    var dummy:DummyTile;
    var camFollow:FlxObject;

	var gameCamera:FlxCamera;
	var hudCamera:FlxCamera;

    var lastScroll:FlxPoint;

    var zoomLevel(default,set):Float = 1;
    var conduct(get,never):Conductor;
    function get_conduct():Conductor {
        return Conductor.instance;
    }
    function set_zoomLevel(val:Float):Float {
        return FlxG.camera.zoom = zoomLevel = FlxMath.bound(val,0.3,20);
    }
    override function create() {
        super.create();
        gameCamera = new FlxCamera();
		FlxG.cameras.reset(gameCamera);

		hudCamera = new FlxCamera();
		hudCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(hudCamera, false);

        initStage();
        initHUD();

        FlxG.stage.window.onDropFile.add(onDropFile);
    }

    function onDropFile(path:String) {
        FlxG.sound.music = new FlxSound();
        FlxG.sound.music.loadStream(path, false);
    } 

    function initStage() {
        var wawa:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(Player.BOX_SIZE,Player.BOX_SIZE,Player.BOX_SIZE*2,Player.BOX_SIZE*2,true,0xFF1B1B1B,0xFF2B2B2B));
        wawa.alpha = 0.2;
        add(wawa);

        stage = new GameplayStage(null);
        stage.editing = true;
        add(stage);

        dummy = new DummyTile(stage);
        stage.add(dummy);

        camFollow = new FlxObject(0, -100, 1, 1);
		add(camFollow);
    }

    function initHUD() {
        var bpm:InputBox = new InputBox(10,FlxG.height - 50,200,"120");
        bpm.label.text = "Beats Per Minute";
        bpm.filterMode = CHARS("0123456789.");
        bpm.cameras = [hudCamera];
        bpm.onTextChange.add((t, c)->{
            Conductor.instance.updateBPM(Std.parseFloat(t));
        });
        bpm.scrollFactor.set();
        add(bpm);
    }

    var playing = false;
    override function update(elapsed:Float) {
        if (playing) {
            camFollow.x = FlxMath.lerp(stage.player.getMidpoint().x, camFollow.x, 1 - (elapsed * 12));
            camFollow.y = FlxMath.lerp(stage.player.getMidpoint().y, camFollow.y, 1 - (elapsed * 12));
        }
        super.update(elapsed);

        _keyboardControls(elapsed);
        _mouseControls(elapsed);
    }

    var camTween:FlxTween;
    function _keyboardControls(elapsed: Float) {
        if (FlxG.keys.justPressed.ESCAPE) {
            if (FlxInputText.globalManager.isTyping)
                FlxInputText.globalManager.focus.endFocus();
            else if (playing)
                stopPlaytest();
            else 
                Utils.switchState(new MenuState(), "Main Menu");
            return;
        }
    
        // Don't run any input checking if the user is typing, it'll be annoying if we didn't do this.
        if (FlxInputText.globalManager.isTyping)
            return;

        if (FlxG.keys.justPressed.SPACE) {
            if (!playing) {
                if (camTween != null) camTween.cancel();
                camTween = FlxTween.tween(FlxG.camera.scroll, {
                    x: stage.player.getMidpoint().x - FlxG.camera.width * 0.5,
                    y: stage.player.getMidpoint().y - FlxG.camera.height * 0.5}, 1, {
                        ease: FlxEase.expoInOut, 
                        onComplete: (_)->{
                            lastScroll = FlxG.camera.scroll;
                            camTween = null;
                            startPlaytest();
                        }
                    });
            } else {
                stopPlaytest();
            }

        }

        // Zoom & Scrolling //
        var moveSpeed:Float = elapsed * 500;
        var zoomChange:Float = 3 * elapsed;
    
        var scrollX:Float = (FlxG.keys.pressed.D ? moveSpeed : 0) - (FlxG.keys.pressed.A ? moveSpeed : 0);
        var scrollY:Float = (FlxG.keys.pressed.S ? moveSpeed : 0) - (FlxG.keys.pressed.W ? moveSpeed : 0);
        FlxG.camera.scroll.x += scrollX;
        FlxG.camera.scroll.y += scrollY;

        zoomLevel += (FlxG.keys.pressed.Q ? zoomChange : 0) - (FlxG.keys.pressed.E ? zoomChange : 0);
    }    

    var _lastClickPoint:FlxPoint = null;
    var _lastCameraScroll:FlxPoint = null;
    
    function _mouseControls(elapsed:Float) {
        var mouseScreen:FlxPoint = FlxG.mouse.getViewPosition();
    
        // CAMERA //
        if (FlxG.mouse.justPressedMiddle) {
            _lastClickPoint = FlxPoint.get(mouseScreen.x, mouseScreen.y);
            _lastCameraScroll = FlxPoint.get(FlxG.camera.scroll.x, FlxG.camera.scroll.y);
        }
        if (FlxG.mouse.pressedMiddle) {
            FlxG.camera.scroll.x = _lastCameraScroll.x - (mouseScreen.x - _lastClickPoint.x);
            FlxG.camera.scroll.y = _lastCameraScroll.y - (mouseScreen.y - _lastClickPoint.y);
        }
    
        if (FlxG.mouse.wheel != 0) 
            zoomLevel += (0.1 * zoomLevel) * FlxG.mouse.wheel;
    
        // EDITING //
        if (!FlxInputText.globalManager.isTyping) {
            if (FlxG.mouse.justPressed) 
                placeTile();
            if (FlxG.mouse.justPressedRight) 
                removeTile();
        }
    }

    function removeTile() {
        var tile:Tile = stage.tiles.getLastTile();
        if (tile == null) return;
        stage.removeTile(tile);
        stage.updateTileDirections();
    }

    function placeTile() {
        var tile:Tile = stage.tiles.getLastTile() ?? new Tile(0, 0, UNKNOWN, 0);
        if (tile == null) return;
    
        var newTile:Tile = new Tile(0, 0, UNKNOWN, 0);
        newTile.active = false;
        var diff:Float = 0;
    
        switch (dummy.direction) {
            case LEFT:
                diff = Math.floor((dummy.x - tile.x) / Player.BOX_SIZE);
                newTile.x = tile.x + (Player.BOX_SIZE * diff);
                newTile.y = tile.y;
            case RIGHT:
                diff = Math.ceil((dummy.x - tile.x) / Player.BOX_SIZE);
                newTile.x = tile.x + (Player.BOX_SIZE * diff);
                newTile.y = tile.y;
            case UP:
                diff = Math.floor((dummy.y - tile.y) / Player.BOX_SIZE);
                newTile.x = tile.x;
                newTile.y = tile.y + (Player.BOX_SIZE * diff);
            case DOWN:
                diff = Math.ceil((dummy.y - tile.y) / Player.BOX_SIZE);
                newTile.x = tile.x;
                newTile.y = tile.y + (Player.BOX_SIZE * diff);
            default:
                trace('Invalid direction');
                return;
        }
    
        newTile.direction = dummy.direction;
        newTile.time = tile.time + (conduct.step_ms * Math.abs(diff));
    
        trace('${dummy.direction} >> $diff // ${newTile.x} // ${newTile.y} // ${newTile.direction} // ${newTile.time} // ${(conduct.step_ms * Math.abs(diff))}');
        stage.addTile(newTile);
        stage.updateTileDirections();
    }
    
    
    function startPlaytest() {
        playing = true;
        Conductor.instance.time = 0;
        FlxG.camera.follow(camFollow, LOCKON);
        FlxG.sound.music?.play();
        stage.start();
    }

    function stopPlaytest() {
        playing = false;
        FlxG.camera.target = null;
        FlxG.camera.scroll = lastScroll;
        Conductor.instance.time = 0;
        FlxG.sound.music?.stop();
        stage.stop();
        stage.player.setPosition();
    }
}