package lt.backend;

import haxe.Unserializer;
import haxe.Serializer;
import haxe.io.Bytes;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;

@:structInit
class PrefData {
    /** Whether to use antialiasing for sprites (smoother visuals) **/
    public var antialiasing:Bool = true;
    /** Defines offset value used in-game (Tile time offset) **/
    public var offset:Float = 120;

    public var masterVolume:Float = 100;
    public var musicVolume:Float = 100;
    public var sfxVolume:Float = 100;

    public var language:String = "english";
}

class Preferences {
    public static final FILE_NAME:String = 'lt.save';
    public static final PATH:String = './${FILE_NAME}';
    public static var data:PrefData = {};

    /**
     * Loads your preferences, if it doesn't exists, it'll create a new one.
     */
    public static function init():Void {
        trace(FileSystem.exists(PATH) ? "Found preferences file." : "No preferences file found.");
        if (FileSystem.exists(PATH)) {
            load();
        } else {
            save();
            load();
        }

        trace('Preferences loaded!');
    }

    /**
     * Saves your current preferences data.
     */
    public static function save():Void {
        var jsonData:String = Json.stringify(data, "\t");
        File.saveContent(PATH, Serializer.run(jsonData));
    }

    /**
     * Loads your preferences data.
     */
    public static function load():Void {
        if (!FileSystem.exists(PATH)) {
            trace("Could not find any save files.");
            return;
        }
        var w:Any = Json.parse(Unserializer.run(File.getContent(PATH)));
        data = {};

        for (field in Reflect.fields(w)) {
            Reflect.setProperty(data, field, Reflect.getProperty(w, field));
        }
        trace(data);
    }

    static function convert(data:String):PrefData {
        return cast Json.parse(data);
    }
}