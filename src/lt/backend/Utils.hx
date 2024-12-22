package lt.backend;

import flixel.util.typeLimit.NextState;
import lt.objects.menu.Profile.User;

using StringTools;

typedef RGB = {
	var red:Int;
	var green:Int;
	var blue:Int;
}

class Utils {
	public static var SCENE_TRANSITIONING:Bool = false;

	/**
	 * Every supported Haxe file extensions (Used for Scripting).
	 */
	public static var HAXE_EXT:Array<String> = ["hx", "hxs", "hscript"];

	public static function checkHXS(filename:String) {
		for (i in HAXE_EXT)
			if (filename.endsWith(i))
				return true;
		return false;
	}

	/**
	 * Player's data.
	 */
	public static var PLAYER:User = null;

	public static final TRANSITION_TIME:Float = 1;

	public static function initialize():Void {
		loadUser();
	}

	public static function loadUser():Void {
		if (PLAYER != null) {
			trace("User are already logged in!");
			return;
		}

		// For testing purposes
		PLAYER = {
			id: 1,
			username: "corecathx",
			display: "CoreCat",
			profile_url: "https://cdn.discordapp.com/avatars/694791036094119996/08795150028fbab041c2cc9359bc5e43.png?size=1024"
		}
	}

	/**
	 * Get HH:MM:SS formatted time from miliseconds.
	 * @param time The miliseconds to convert.
	 * @return String
	 */
	public static function formatMS(time:Float):String {
		var seconds:Int = Math.floor(time / 1000);
		var secs:String = '' + seconds % 60;
		var mins:String = "" + Math.floor(seconds / 60) % 60;
		var hour:String = '' + Math.floor((seconds / 3600)) % 24;
		if (seconds < 0)
			seconds = 0;
		if (time < 0)
			time = 0;

		if (secs.length < 2)
			secs = '0' + secs;

		var shit:String = mins + ":" + secs;
		if (hour != "0") {
			if (mins.length < 2)
				mins = "0" + mins;
			shit = hour + ":" + mins + ":" + secs;
		}
		return shit;
	}

	public static inline function switchState(nextState:NextState, ?transText:String = ""):Void {
		if (!SCENE_TRANSITIONING) {
			SCENE_TRANSITIONING = true;
			final stateOnCall = FlxG.state;
			@:privateAccess {
				if (!nextState.isInstance() || FlxG.canSwitchTo(cast nextState)) {
					try {
						cast(FlxG.state, State)._transText = transText;
					} catch (e) {
						trace("Transition fail: Could not set transition text, maybe it's not extending State?");
					}
					FlxG.state.startOutro(function() {
						try {
							cast(nextState, State)._transText = transText;
						} catch (e) {
							trace("Transition fail: Could not set transition text, maybe it's not extending State?");
						}

						if (FlxG.state == stateOnCall)
							FlxG.game._nextState = nextState;
						else
							FlxG.log.warn("`onOutroComplete` was called after the state was switched. This will be ignored");
					});
				}
			}
		}
	}

	public static inline function getTileColor(time:Float, subtractOffset:Bool = false) {
		var _quant:Int = Std.int((((time - (subtractOffset ? 0 : Conductor.instance?.offset)) / Conductor.instance.step_ms) + 1) % 4);
		var _colorList:Array<FlxColor> = [0xFFFF8800, 0xFFFBFF00, 0xFF00EEFF, 0xFFFF00FF];

		return (_quant < _colorList.length) ? _colorList[_quant] : 0xFFFFFFFF;
	}
}
