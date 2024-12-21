package lt.states;

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
        var wawa:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(Player.BOX_SIZE,Player.BOX_SIZE,Player.BOX_SIZE*2,Player.BOX_SIZE*2,true,0xFF1B1B1B,0xFF2B2B2B));
        wawa.alpha = 0.2;
        add(wawa);

        stage = new GameplayStage(null);
        stage.editing = true;
        add(stage);

        dummy = new DummyTile(stage);
        stage.add(dummy);
    }

    var ue:Bool = false;
    override function update(elapsed:Float) {
        super.update(elapsed);

        _keyboardControls(elapsed);
        _mouseControls(elapsed);
    }

    function _keyboardControls(elapsed:Float) {
        var moveSpeed:Float = elapsed*500;
        if (FlxG.keys.pressed.A || FlxG.keys.pressed.D) 
            FlxG.camera.scroll.x -= FlxG.keys.pressed.A ? moveSpeed : -moveSpeed;
        if (FlxG.keys.pressed.W || FlxG.keys.pressed.S) 
            FlxG.camera.scroll.y -= FlxG.keys.pressed.W ? moveSpeed : -moveSpeed;

        if (FlxG.keys.pressed.Q || FlxG.keys.pressed.E) 
            zoomLevel -= FlxG.keys.pressed.Q ? -(3*elapsed) : (3*elapsed);

        if (FlxG.keys.justPressed.ESCAPE) {
            Utils.switchState(new MenuState(), "Main Menu");
        }
    }

    var _lastClickPoint:FlxPoint = null;
    var _lastCameraScroll:FlxPoint = null;
    function _mouseControls(elapsed:Float) {
        var mouseScreen:FlxPoint = FlxG.mouse.getScreenPosition();

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
			zoomLevel += (0.1*zoomLevel) * FlxG.mouse.wheel;

        // EDITING //
        if (FlxG.mouse.justPressed)
            placeTile();
        if (FlxG.mouse.justPressedRight) 
            removeTile();
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
            case LEFT, RIGHT:
                diff = (dummy.x - tile.x) / Player.BOX_SIZE;
                newTile.x = tile.x + (Player.BOX_SIZE * diff);
                newTile.y = tile.y;
            case UP, DOWN:
                diff = (dummy.y - tile.y) / Player.BOX_SIZE;
                newTile.x = tile.x;
                newTile.y = tile.y + (Player.BOX_SIZE * diff);
            default:
                trace('what the hell');
                return;
        }
    
        newTile.direction = UNKNOWN;
        newTile.time = tile.time + (conduct.step_ms * (Math.abs(diff)-1));
    
        trace('${dummy.direction} >> $diff // ${newTile.x} // ${newTile.y} // ${newTile.direction} // ${newTile.time} // ${(conduct.step_ms * Math.abs(diff))}');
        stage.addTile(newTile);
        stage.updateTileDirections();
    }
    
}