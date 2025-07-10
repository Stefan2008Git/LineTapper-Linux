package lt.objects.play;

enum abstract Direction(Int) {
	var UNKNOWN = -1;
	var LEFT = 0;
	var DOWN = 1;
	var UP = 2;
	var RIGHT = 3;
}

class Player extends Sprite {
	/** Size of the player sprite (also used by Tile objects). **/
	public static var BOX_SIZE:Int = 40;

	/** Current facing direction of the player. **/
	public var direction:Direction = DOWN;

	/** Whether to show trails while the player moves. **/
	public var showTrails:Bool = true;

	/** List of trail sprites. **/
	public var trails:Array<Sprite> = [];

	/** Delay between each trail spawn. **/
	public var trails_delay:Float = 0.05;

	/** Strength of the glow effect. **/
	public var glowLevel:Float = 0;

	/** Glow sprite used for held tiles. **/
	public var glowObject:Sprite;

	/** Whether this player is being used in the editor. **/
	public var editing:Bool = false;

    public function new(nX:Float, nY:Float) {
        super(nX, nY);
        makeGraphic(BOX_SIZE, BOX_SIZE);

		glowObject = new Sprite().loadGraphic(Assets.image("play/glow"));
		glowObject.scale.x = glowObject.scale.y = (BOX_SIZE + 120) / glowObject.frameWidth;
		glowObject.updateHitbox();
		glowObject.active = false;
		glowObject.blend = ADD;
    }

	/**
	 * Starts the glow effect.
	 * @param c Glow color.
	 */
	public function startGlow(c:FlxColor) {
		glowLevel = 1;
		glowObject.color = c;
	}

	var missTimer:Float = 0;
	/**
	 * Starts the miss effect.
	 */
	public function startMiss() {
		missTimer = 0;
	}

    override function draw() {
		if (!editing) {
			if (missTimer < 0.3) {
				missTimer += FlxG.elapsed;
				var progress:Float = (missTimer / 0.3);
				angle = (3 - (3 * progress));
				color = FlxColor.interpolate(FlxColor.RED, FlxColor.WHITE, progress);
			} else {
				angle = 0;
			}
			if (glowLevel > 0) {
				glowObject.x = x + (width - glowObject.width) * 0.5;
				glowObject.y = y + (height - glowObject.height) * 0.5;
				glowLevel -= 30 * FlxG.elapsed;
				glowObject.alpha = glowLevel;
				glowObject.draw();
			}
	
			_drawTrails(); // Draw the trails BEFORE drawing the Player.
		}

        super.draw();
    }

    var _trailTime:Float = 0;
    function _drawTrails() {
        _trailTime += FlxG.elapsed;

		if (_trailTime > trails_delay) {
			var n:Sprite = new Sprite(x, y).makeGraphic(BOX_SIZE, BOX_SIZE, 0xFFFFFFFF);
			n.alpha = 0.8;
			n.active = false;
			n.blend = ADD;
			trails.push(n);
			_trailTime = 0;
		}

		for (i in trails) {
			if (i.alpha > 0) {
				i.alpha -= 0.8 * FlxG.elapsed;
				i.color = FlxColor.interpolate(FlxColor.BLUE, FlxColor.CYAN, i.alpha - 0.2);
				i.scale.set(i.alpha, i.alpha);
			} else {
				i.kill();
				i.destroy();
				trails.remove(i);
			}
		}

        for (i in trails) {
			if (i.visible && i.alpha > 0)
				i.draw();
		}
    }
}