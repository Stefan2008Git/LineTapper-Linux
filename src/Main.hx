package;

import openfl.events.Event;
import lt.backend.objects.InfoOverlay;
import lt.backend.Preferences;
import lime.app.Application;
import lt.backend.native.NativeUtil;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var _conductor:Conductor;
	public var STARTING_STATE = lt.states.IntroState;
	var overlay:InfoOverlay;
	public function new()
	{
		super();
		_conductor = new Conductor();
		Preferences.init();
		NativeUtil.setDPIAware();

		addChild(new FlxGame(0, 0, STARTING_STATE, 120,120,true,false));
		FlxG.fixedTimestep = FlxG.autoPause = false;

		overlay = new InfoOverlay(20,20,0xFFFFFF);
		addChild(overlay);

		FlxG.stage.addEventListener(Event.ENTER_FRAME, update);
		NativeUtil.setWindowDarkMode(Application.current.window.title, true);
	}

	function update(_) {
		overlay.x = FlxG.stage.window.width - overlay.width - 10;
		overlay.y = FlxG.stage.window.height - overlay.height - 10;
	}
}
