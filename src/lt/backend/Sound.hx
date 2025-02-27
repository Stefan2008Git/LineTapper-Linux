package lt.backend;

/**
 * Helper class for managing sounds.
 */
class Sound {
    public inline static function playMusic(asset:Any, volume:Float = 1, looped:Bool = true) {
        FlxG.sound.playMusic(asset, Preferences.data.musicVolume * volume, looped);
    }
    public inline static function playSfx(asset:Any, volume:Float = 1, looped:Bool = false) {
        FlxG.sound.play(asset, Preferences.data.sfxVolume * volume, looped);
    }
}