package lt.backend.objects;

import lt.backend.native.NativeUtil;
import flixel.FlxG;
import haxe.Timer;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * FPS and Memory Usage counter that's shown on top corner left of the game.
 */
class InfoOverlay extends TextField
{
	/** Active instance of the Stats Display. **/
	public static var current:InfoOverlay = null;

	/** Current FPS value. **/
	public var curFps:Float = 0;

	/** Current used GC Memory in Bytes. **/
	public var curMemory:Float = 0;
	
	/** Memory Peak / Highest Memory. **/
	public var highestMemory:Float = 0;

	/** Tracked frames in a second. **/
	public var frames:Array<Float> = [];

	public var lowFps(get,never):Bool;
	function get_lowFps():Bool {
		return (frames.length < FlxG.updateFramerate/2);
	}

	/**
	 * Creates a new Stats Display object.
	 * @param nX X Position of the object.
	 * @param nY Y Position of the object.
	 * @param nColor Text color.
	 */
	public function new(nX:Float = 10.0, nY:Float = 10.0, nColor:Int = 0x000000)
	{
		super();
		x = nX;
		y = nY;
		current = this;

		selectable = false;
		defaultTextFormat = new TextFormat(Assets.font("musticapro"), 12, nColor, null, null, null, null, null, RIGHT);
		autoSize = LEFT;
        alpha = 0.7;
	}

    var lastTime:Float = 0;
	private override function __enterFrame(elapsed:Float) {
		var now:Float = Timer.stamp();
		frames.push(now);
	
		while (frames[0] < now - 1) frames.shift();

		curMemory = NativeUtil.getUsedMemory();
        if (now - lastTime > 1){
            lastTime = now;
            curFps = frames.length;
        }
		
		if (curMemory > highestMemory) highestMemory = curMemory;
		updateText();
	}

	/**
	 * A function that updates the text of the Info Overlay.
	 * You could also override this in a script and modify it to your liking.
	 */
	public dynamic function updateText():Void {
		if (!visible) return;
	
		var ramStr:String = Utils.formatBytes(curMemory);
		var rndFPS:String = '$curFps';
		var labels = {
			fps: rndFPS+" FPS",
			mem: ramStr
		};
		
		var wholeText:String = '${labels.fps}\n${labels.mem}';
		text = wholeText;
	}
}