package lt.objects;

import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

typedef SpriteGroup = FlxTypedSpriteGroup<Sprite>;

/**
 * Sprite is just Sprite but with additional helper functions.
 */
class Sprite extends FlxSprite {
    public function new(nX:Float = 0, nY:Float = 0, ?nGraphic:FlxGraphicAsset) {
        super(nX,nY);
        if (nGraphic != null) 
            loadGraphic(nGraphic);

        antialiasing = Preferences.data.antialiasing;
    }

    /**
     * Sets XY scaling properties of this sprite equally.
     * @param value The scaling value.
     * @param noHitbox Whether to not update this sprite's hitbox
     */
    public function setScale(value:Float, noHitbox:Bool = false) {
        scale.set(value,value);
        if (!noHitbox)
            updateHitbox();
    }

    override function makeGraphic(Width:Int, Height:Int, Color:FlxColor = FlxColor.WHITE, Unique:Bool = false, ?Key:String):Sprite {
        return cast super.makeGraphic(Width, Height, Color, Unique, Key);
    }

    override function loadGraphic(graphic:FlxGraphicAsset, animated:Bool = false, frameWidth:Int = 0, frameHeight:Int = 0, unique:Bool = false, ?key:String):Sprite {
        return cast super.loadGraphic(graphic, animated, frameWidth, frameHeight, unique, key);
    }
}