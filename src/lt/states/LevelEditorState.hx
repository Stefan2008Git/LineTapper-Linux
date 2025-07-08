package lt.states;

import lt.objects.ui.Button;
import haxe.Json;
import lt.backend.Game;
import sys.io.File;
import sys.FileSystem;
import lt.objects.ui.Dialog;
import lt.backend.MapData;
import flixel.sound.FlxSound;
import flixel.text.FlxInputText;
import flixel.text.FlxInputTextManager;
import lt.objects.ui.InputBox;

import lt.objects.play.Tile;
import lt.objects.play.editor.DummyTile;
import lt.objects.play.GameplayStage;
import lt.objects.play.Player;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;

class LevelEditorState extends State {
    var mapData:LineMap;
    var stage:GameplayStage;
    var dummy:DummyTile;
    var camFollow:FlxObject;

	var gameCamera:FlxCamera;
	var hudCamera:FlxCamera;

    var lastScroll:FlxPoint;
    
    var streamPath:String = '';

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
        mapData = {
            name: "LTSONG",
            lyrics: true,
            tiles: [],
            meta: [
                {
                    name: "Artist",
                    value: "Unknown"
                }
            ],
            bpm: conduct.bpm,
            data: {
                version: Game.VERSION,
                apiLevel: Game.API_LEVEL
            }
        }
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
        streamPath = path;
        FlxG.sound.music = new FlxSound();
        FlxG.sound.music.loadStream(streamPath, false);
    } 

    function initStage() {
        var wawa:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(Player.BOX_SIZE,Player.BOX_SIZE,Player.BOX_SIZE*2,Player.BOX_SIZE*2,true,0xFF1B1B1B,0xFF2B2B2B));
        wawa.alpha = 0.2;
        add(wawa);

        stage = new GameplayStage(null);
        stage.editing = true;
        add(stage);
        stage.autoplay = true;

        dummy = new DummyTile(stage);
        stage.add(dummy);

        camFollow = new FlxObject(0, -100, 1, 1);
		add(camFollow);
    }

    var audioPath:Text;
    function initHUD() {
        var lastY:Float = 10;
        inline function makeInputBox(text:String, defaultTxt:String = '', onChange:(String, FlxInputTextChange)->Void):InputBox {
            var obj:InputBox = new InputBox(20,lastY+30,200,defaultTxt);
            obj.label.text = PhraseManager.getPhrase(text);
            obj.cameras = [hudCamera];
            obj.onTextChange.add(onChange);
            obj.scrollFactor.set();
            add(obj);
            
            lastY = obj.y + obj.height;
            return obj;
        }
        inline function makeText(nx:Float, ny:Float, text:String):Text {
            var txt:Text = new Text(nx,ny,text, 14, RIGHT);
            txt.cameras = [hudCamera];
            txt.applyUIFont();
            add(txt);
            return txt;
        }
        inline function makeButton(text:String,onClick:Bool->Void,isToggle:Bool) {
            var btn:Button = new Button(20, lastY,200, text, onClick);
            btn.isToggle = isToggle;
            btn.cameras = [hudCamera];
            add(btn);
            lastY = btn.y + btn.height + 10;
            return btn;
        }
        var songName:InputBox = makeInputBox("Song Name", '${mapData.name}', (t,c)->{
            mapData.name = t;
        });

        var load:Button = makeButton("Load", (_)->{
            loadMap(songName.text);
            trace("haha");
        }, false);

        var bpm:InputBox = makeInputBox("Beats Per Minute", '${conduct.bpm}', (t,c)->{
            mapData.bpm = Std.parseFloat(t);
            Conductor.instance.updateBPM(mapData.bpm);
        });
        bpm.filterMode = CHARS("0123456789.");
        
        // TEXTS
        audioPath = makeText(0,0,'');

        var version:Text = makeText(20,0,'LT v${Game.VERSION} API-${Game.API_LEVEL} // Development in progress, features may change.');
        version.y = FlxG.height - version.height - 20;
        version.alpha = 0.5;
    }

    var playing = false;
    override function update(elapsed:Float) {
        if (playing) {
            camFollow.x = FlxMath.lerp(stage.player.getMidpoint().x, camFollow.x, 1 - (elapsed * 12));
            camFollow.y = FlxMath.lerp(stage.player.getMidpoint().y, camFollow.y, 1 - (elapsed * 12));
        }
        super.update(elapsed);

        // UI UPDATE //
        audioPath.setPosition(FlxG.width - audioPath.width - 20, 20);
        audioPath.text = streamPath == "" ? 'Drop .ogg file to this window to set the song.' : streamPath;

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
                            camFollow.setPosition(
                                stage.player.getMidpoint().x, 
                                stage.player.getMidpoint().y
                            );
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
    
        // Operations //
        if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S) {
            saveMap();
        }
    }    

    var _lastClickPoint:FlxPoint = null;
    var _lastCameraScroll:FlxPoint = null;
    var _lastPlacedTile:Tile = null;
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
            if (FlxG.mouse.pressed && _lastPlacedTile != null) {
                _lastPlacedTile.length = Math.round(((dummy.time - conduct.step_ms) - _lastPlacedTile.time) / conduct.step_ms) * conduct.step_ms;
                _lastPlacedTile.direction = dummy.direction;
            }
            
            if (FlxG.mouse.justReleased && _lastPlacedTile != null){
                //_lastPlacedTile.isRelease = true;
                _lastPlacedTile = null;
            }
            if (FlxG.mouse.justReleasedRight) 
                removeTile();
        }
    }

    function removeTile() {
        var tile:Tile = stage.tiles.getLastTile();
        if (tile == null) return;
        stage.removeTile(tile);
        if (tile == _lastPlacedTile) 
            _lastPlacedTile = null;
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
        _lastPlacedTile = newTile;
        stage.updateTileDirections();
    }
    
    
    function startPlaytest() {
        playing = true;
        Conductor.instance.time = 0;
        FlxG.camera.follow(camFollow, LOCKON);
        FlxG.sound.music?.fadeTween?.cancel();
        FlxG.sound.music?.play();
        if (FlxG.sound.music != null)
            FlxG.sound.music.volume = 1;
        stage.start();
    }

    function stopPlaytest() {
        playing = false;
        FlxG.camera.target = null;
        FlxG.camera.scroll = lastScroll;
        Conductor.instance.time = 0;
        FlxG.sound.music?.fadeOut(0.5, 0, (t)->{
            FlxG.sound.music?.stop();
        });
        stage.stop();
        stage.player.setPosition();
    }

    function saveMap():Void {
        mapData.tiles = stage.tiles.members.map(t->t.getData());
        var info:Array<String> = [];

        var exportFolder:String = "./assets/data/maps/" + mapData.name;
        if (!FileSystem.exists(exportFolder)) {
            FileSystem.createDirectory(exportFolder);
        }
        var curdate:String = DateTools.format(Date.now(), "%Y-%m-%d_%H-%M-%S").toString();
        var exportFile:String = exportFolder+"/"+'map.json';
        var json:String = Json.stringify(mapData, "\t");
        File.saveContent(exportFile, json);
        info.push('Exported to ' + exportFile);

        if (streamPath.endsWith("ogg")) {
            File.copy(streamPath, exportFolder+'/audio.ogg');
            info.push('Audio copied to ' + exportFolder+'/audio.ogg');
        } else {
            info.push('Copy failed, audio should be in OGG format.');
        }

        Dialog.show("Editor", info.join('\n'));
    }

    function loadMap(mapName:String):Void {
        var folder = './assets/data/maps/' + mapName;
        var path = folder + '/map.json';
    
        if (!FileSystem.exists(path)) {
            Dialog.show("Error", 'Map file not found:\n$path');
            return;
        }
    
        var json:String = File.getContent(path);
        var data:Dynamic = Json.parse(json);
        
        mapData = cast data;
        conduct.updateBPM(mapData.bpm);
    
        stage.clearTiles();
        stage.generateTiles(mapData);
        var audioFile = folder + '/audio.ogg';
        if (FileSystem.exists(audioFile)) {
            streamPath = audioFile;
            FlxG.sound.music = new FlxSound();
            FlxG.sound.music.loadStream(streamPath, false);
        } else {
            Dialog.show("Warning", 'Audio file not found:\n$audioFile');
        }
    }
    
}