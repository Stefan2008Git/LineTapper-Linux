package lt.objects.play;

import lt.objects.play.Player.Direction;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import openfl.utils.ByteArray;
import flixel.math.FlxRect;

class Tile extends Sprite {
    /**
     * Time offset for a tile's entrance animation, measured in steps.
     * This determines how early the animation starts relative to the current audio time.
     * Example: If the offset is 2.5, the entrance animation begins when 
     *          `Conductor.time + _TILE_ENTER_OFFSET` exceeds the tile's time.
     */
    public static var _TILE_ENTER_OFFSET:Float = 6.4;

    /**
     * Time offset for a tile's exit animation, measured in steps.
     * This determines how late the animation plays relative to the tile's time.
     * Example: If the offset is 0.5, the exit animation triggers when 
     *          `Conductor.time` surpasses the tile's time plus `_TILE_EXIT_OFFSET`.
     * 
     * Note: This timer will start when the player missed the tile.
     */
    public static var _TILE_EXIT_OFFSET:Float = 1;
    
    public var hitable(get, never):Bool;
    inline function get_hitable():Bool {
        return time > Conductor.instance.time - (Conductor.instance.safe_zone_offset * 1.5)
            && time < Conductor.instance.time + (Conductor.instance.safe_zone_offset * 0.5);
    }

    public var canUpdate(get,never):Bool;
    inline function get_canUpdate():Bool {
        return Conductor.instance.time + (conduct.step_ms * _TILE_ENTER_OFFSET) > time
            && Conductor.instance.time < time + (conduct.beat_ms * (_TILE_EXIT_OFFSET+4));
    }

    public var invalid(get,never):Bool;
    function get_invalid() {
        return !beenHit && time < (Conductor.instance.time - 166);
    }

    public var beenHit:Bool = false;
    public var missed:Bool = false;

    public var holdFinish:Bool = false;
    public var time(default, set):Float = 0;
    function set_time(val:Float):Float {
        time = val;
        color = Utils.getTileColor(time, editing);
        return time = val;
    }
    public var length:Float = 0;
    public var direction(default,set):Direction = LEFT;
    function set_direction(val:Direction):Direction {
        direction = val;
        var updateGraphic:Bool = true;
        switch (val) {
            case LEFT:
                angle = 90;
            case RIGHT:
                angle = -90;
            case UP:
                angle = 180;
            case DOWN:
                angle = 0;
            default:
                updateGraphic = false;
                setGraphic("play/stop_tile");
                angle = 0;
        }
        if (updateGraphic)
            setGraphic("play/tile");
        return val;
    }

    public var hitOutline:TileEffect;

    // Used by hold tiles.
    public var holdSprite:Sprite;
    public var releaseSprite:Sprite;

    private var conduct:Conductor = null;

    public var editing:Bool = false;
    public function new(nX:Float, nY:Float, direction:Direction, time:Float, length:Float = 0.0) {
        super(nX, nY);

        setGraphic("play/tile");

        this.time = time;
		this.direction = direction;
        this.length = length;
        conduct = Conductor.instance;

        // That one hit effect thing //
        var _graphicSize:Float = Player.BOX_SIZE + (200);
        hitOutline = new TileEffect(nX,nY).makeGraphic(300,300,0xFFFFFFFF);
        hitOutline.outline = 0.95;
		hitOutline.alpha = 0;
		hitOutline.setGraphicSize(_graphicSize,_graphicSize);
		hitOutline.updateHitbox();

        if (length > 0) {
            holdSprite = new Sprite().loadGraphic(Assets.image("play/hold"));
            holdSprite.scale.x = (length/conduct.step_ms) * Player.BOX_SIZE;
            holdSprite.scale.y = (Player.BOX_SIZE*0.65) / holdSprite.frameHeight;
            holdSprite.updateHitbox();
            holdSprite.active = false;
            
            releaseSprite = new Sprite().loadGraphic(Assets.image("play/stop_tile"));
            releaseSprite.active = false;
            releaseSprite.setGraphicSize(Player.BOX_SIZE, Player.BOX_SIZE);
            releaseSprite.updateHitbox();
        }
    }

    public function resetProp() {
        beenHit = false;
        missed = false;
        angle = 0;
        alpha = 1;
        time = time;
        setGraphicSize(Player.BOX_SIZE, Player.BOX_SIZE);
		updateHitbox();
    }

    var _lastGraphic:String = "";
    public function setGraphic(path:String) {
        if (_lastGraphic == path) return;
        _lastGraphic = path;
        loadGraphic(Assets.image(path));
		setGraphicSize(Player.BOX_SIZE, Player.BOX_SIZE);
		updateHitbox();
    }

    override function draw() {
        super.draw();
    
        if (length > 0) {
            switch (direction) {
                case LEFT: 
                    holdSprite.angle = 0;
                    holdSprite.x = x - holdSprite.width;
                    holdSprite.y = y + (height - holdSprite.height) * 0.5;
    
                    releaseSprite.x = holdSprite.x - releaseSprite.width;
                    releaseSprite.y = y + (height - releaseSprite.height) * 0.5;
    
                case DOWN: 
                    holdSprite.angle = 90;
                    releaseSprite.x = x + (width - releaseSprite.width) * 0.5;
                    releaseSprite.y = y + height + holdSprite.width;

                    holdSprite.x = x + (width - holdSprite.width) * 0.5;
                    holdSprite.y = y + height + (holdSprite.width-holdSprite.height)*0.5;
                case UP: 
                    holdSprite.angle = 90;
                    releaseSprite.x = x + (width - releaseSprite.width) * 0.5;
                    releaseSprite.y = y - (holdSprite.width+releaseSprite.height);

                    holdSprite.x = x + (width - holdSprite.width) * 0.5;
                    holdSprite.y = y - (holdSprite.width+holdSprite.height)*0.5;
                case RIGHT: 
                    holdSprite.angle = 0;
                    holdSprite.x = x + width;
                    holdSprite.y = y + (height - holdSprite.height) * 0.5;
    
                    releaseSprite.x = holdSprite.x + holdSprite.width;
                    releaseSprite.y = y + (height - releaseSprite.height) * 0.5;
                default:
                    // do none
            }
    
            propDraw(holdSprite);
            propDraw(releaseSprite);
        }
    
        if (!editing) {
            hitOutline.x = x - (hitOutline.width - width) / 2;
            hitOutline.y = y - (hitOutline.height - height) / 2;
            hitOutline.draw();
        }

    }    
    

    function propDraw(spr:Sprite) {
        spr.alpha = alpha;
        spr.color = color;
        spr.draw();
    }

    var _rotationAdd:Float = 0;
    var _scaleAdd:Float = 0;
    override function update(elapsed:Float) {
        super.update(elapsed);
        _updateAnimation(elapsed);
    }

    function _updateAnimation(elapsed:Float) {
        if (editing) return;
        var enterOffset:Float = conduct.step_ms * _TILE_ENTER_OFFSET;
        var exitOffset:Float = conduct.step_ms * _TILE_EXIT_OFFSET;

        var hitOffset:Float = conduct.step_ms * (_TILE_ENTER_OFFSET * 0.7);
        if (!beenHit) {
            if (conduct.time + hitOffset > time && conduct.time < time) {
                var timeDiff:Float = Math.abs(((conduct.time - time) % enterOffset) / enterOffset);	
                var _animTime:Float = FlxEase.backOut(Math.abs(timeDiff));
                var _graphicSize:Float = Player.BOX_SIZE + (100 * _animTime);
                
                hitOutline.scale.set(_graphicSize / hitOutline.frameWidth, _graphicSize / hitOutline.frameHeight);
                hitOutline.alpha += 6 * elapsed;
            } else {
                hitOutline.alpha -= 6 * elapsed;
            }
    
            if (conduct.time + enterOffset > time && !(conduct.time > time + exitOffset + length)) {
                alpha += 4 * elapsed;
            } else {
                alpha -= 4 * elapsed;
            }    

            
            if (invalid && conduct.time > time + exitOffset) {
                color = 0xFFFF0000;
            }
        } else {
            if (conduct.time > time + length) {
                if (_rotationAdd == 0){
                    _rotationAdd = FlxG.random.float(-90, 90);
                    alpha = 1;
                    // Snap the scaling.
                    var toThis:Float = Player.BOX_SIZE/hitOutline.frameWidth;
                    hitOutline.scale.set(toThis, toThis);
                    hitOutline.alpha = 1;
                    hitOutline.outline = 0.98;
                }
    
                scale.x += 0.05 * (elapsed*12);
                scale.y = scale.x;
    
                angle += _rotationAdd * elapsed;
                alpha -= 2 * elapsed;
    
                var _graphicSize:Float = Player.BOX_SIZE + (100);
                var lerpThing:Float = FlxMath.lerp(hitOutline.scale.x, _graphicSize/hitOutline.frameWidth, 12 * elapsed);
                hitOutline.scale.set(lerpThing, lerpThing);
                hitOutline.alpha -= 3 * elapsed;
            }
        }
    }

    override function destroy() {
        hitOutline?.destroy();
        holdSprite?.destroy();
        releaseSprite?.destroy();
        super.destroy();
    }
}

/**
 * The hit approach outline of a Tile object.
 */
class TileEffect extends Sprite {
    public var outline(default, set):Float = 0;
    var _ogPixels:BitmapData;

    override public function loadGraphic(Graphic:Dynamic, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false, Key:String = ""):TileEffect {
        super.loadGraphic(Graphic, Animated, Width, Height, Unique, Key);
        _ogPixels = this.pixels.clone();
        return this;
    }
    override public function makeGraphic(Width:Int, Height:Int, Color:FlxColor = 0xFFFFFFFF, Unique:Bool = false, Key:String = ""):TileEffect {
        super.makeGraphic(Width, Height, Color, Unique, Key);
        _ogPixels = this.pixels.clone();
        return this;
    }
    
    function set_outline(val:Float):Float {
        if (val < 0) val = 0;
        if (val > 1) val = 1;

        if (clipRect == null)
            clipRect = new FlxRect(0, 0, frameWidth, frameHeight);
    
        var actualVal:Float = 1-val;
        var _progress = {
            width: frameWidth * actualVal,
            height: frameHeight * actualVal,
        };
    
        clipRect.width = frameWidth - _progress.width;
        clipRect.height = frameHeight - _progress.height;
        clipRect.x = _progress.width * 0.5;
        clipRect.y = _progress.height * 0.5;
    
        this.pixels.copyPixels(_ogPixels, new Rectangle(0, 0, _ogPixels.width, _ogPixels.height), new openfl.geom.Point());

        var bitmapData:BitmapData = this.pixels;
        bitmapData.fillRect(new Rectangle(clipRect.x, clipRect.y, clipRect.width, clipRect.height), 0x00000000);
        
        var byteArray:ByteArray = bitmapData.getPixels(new Rectangle(0, 0, bitmapData.width, bitmapData.height));
        pixels.setPixels(new Rectangle(0, 0, bitmapData.width, bitmapData.height), byteArray);
    
        return outline = val;
    }
}
