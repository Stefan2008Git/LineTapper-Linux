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
        Unserializer.run(File.getContent(PATH));
    }

    static function convert(data:String):PrefData {
        return cast Json.parse(data);
    }
}