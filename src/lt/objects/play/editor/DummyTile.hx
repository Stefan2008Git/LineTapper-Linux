package lt.objects.play.editor;

import lt.objects.play.Player;

class DummyTile extends Sprite {
    public var direction:Direction = UNKNOWN;
    public var followMouse:Bool = true;
    public var currentObject(get,never):Tile;
    public var time:Float = 0;
    private function get_currentObject():Tile {
        if (parent == null) return null;
        return parent.tiles.getLastTile();
    }
    public var parent:GameplayStage;
    public function new(parent:GameplayStage) {
        super();
        this.parent = parent;
        
        loadGraphic(Assets.image("play/edit/dummy"));
        setGraphicSize(Player.BOX_SIZE, Player.BOX_SIZE);
        updateHitbox();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (followMouse) {
            // angle stuff oh my god
            var object:{x:Float,y:Float} = {
                x: currentObject?.x ?? 0,
                y: currentObject?.y ?? 0
            }
            var deltaX:Float = FlxG.mouse.x - object.x;
            var deltaY:Float = FlxG.mouse.y - object.y;
            var rotation:Float = Math.atan2(deltaY, deltaX);
    
            if (rotation >= -Math.PI / 4 && rotation < Math.PI / 4) { 
                // Right
                direction = RIGHT;
                x = Math.max(object.x, FlxG.mouse.x); 
                y = Std.int(object.y / Player.BOX_SIZE) * Player.BOX_SIZE; 
                time = (Math.abs(object.x - x) / Player.BOX_SIZE) * Conductor.instance.step_ms;
            } else if (rotation >= Math.PI / 4 && rotation < 3 * Math.PI / 4) { 
                // Down 
                direction = DOWN;
                x = Std.int(object.x / Player.BOX_SIZE) * Player.BOX_SIZE; 
                y = Math.max(object.y, FlxG.mouse.y); 
                time = (Math.abs(object.y - y) / Player.BOX_SIZE) * Conductor.instance.step_ms;
            } else if (rotation >= -3 * Math.PI / 4 && rotation < -Math.PI / 4) { 
                // Up
                direction = UP;
                x = Std.int(object.x / Player.BOX_SIZE) * Player.BOX_SIZE;
                y = Math.min(object.y, FlxG.mouse.y); 
                time = ((Math.abs(object.y - y) / Player.BOX_SIZE)+1) * Conductor.instance.step_ms;
            } else { 
                // Left
                direction = LEFT;
                x = Math.min(object.x, FlxG.mouse.x); 
                y = Std.int(object.y / Player.BOX_SIZE) * Player.BOX_SIZE; 
                time = ((Math.abs(object.x - x) / Player.BOX_SIZE)+1) * Conductor.instance.step_ms;
            }

            x = FlxG.keys.pressed.SHIFT ? x : Math.floor(x / Player.BOX_SIZE) * Player.BOX_SIZE;
            y = FlxG.keys.pressed.SHIFT ? y : Math.floor(y / Player.BOX_SIZE) * Player.BOX_SIZE;

            color = Utils.getTileColor(time, true);
            visible = !FlxG.mouse.pressed;
            FlxG.watch.addQuick('Dummy Direction', direction);
        }
    }
}