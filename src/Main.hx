package;

import lime.app.Application;
import lt.backend.native.NativeUtil;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var _conductor:Conductor;
	public var STARTING_STATE = lt.states.IntroState;
	public function new()
	{
		super();
		_conductor = new Conductor();

		NativeUtil.setDPIAware();

		lime.app.Application.current.window.title = "LineTapper - CoreCat's Build";

		addChild(new FlxGame(0, 0, STARTING_STATE, 120,120,true,false));
		FlxG.fixedTimestep = FlxG.autoPause = false;

		NativeUtil.setWindowDarkMode(Application.current.window.title, true);
	}
}
