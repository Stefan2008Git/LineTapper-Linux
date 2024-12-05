package lt.backend;

import haxe.Json;
import openfl.media.Sound;
import lt.backend.Lyrics;
typedef MapAsset =
{
	var audio:Sound;
	var map:LineMap;
    var lyrics:Lyrics;
}

typedef TileData =
{
	var time:Float;
	var direction:Int;
	var type:String;
	var length:Float;
	var event:Array<{name:String, values:Array<String>}>;
}

typedef LineMap =
{
	var name:String;
	var tiles:Array<TileData>;
	var bpm:Float;
	var data:{version:String, apiLevel:Int};
	var meta:Array<{name:String, value:String}>;
	var lyrics:Bool;
}

class MapData {
    public static function loadMap(rawJson:String):LineMap {
        return cast Json.parse(rawJson);
    }
}