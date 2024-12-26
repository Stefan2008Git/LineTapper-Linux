package lt.objects.ui;

import flixel.FlxBasic;
import flixel.addons.display.FlxTiledSprite;
import flixel.addons.effects.chainable.FlxOutlineEffect;

typedef DialogButton = {text:String, action:Void->Void}

// substate...
class Dialog extends FlxSubState {
    public static final ENTER_DURATION:Float = 0.5;
    public static final MIN_SIZE:{x:Float, y:Float} = {x:200, y:100};
    public static final MAX_SIZE:{x:Float, y:Float} = {x:500, y:-1}; // Use -1 to indicate no limit for height.
    public static final MARGIN:Float = 20;

    /**
     * Shows new dialog box.
     */
    public static function show(_title:String, body:String, ?buttons:Array<DialogButton>) {
        if (FlxG.state == null) {
            trace("Could not open new dialog, FlxG.state is null.");
            return;
        }
        try {
            FlxG.state.openSubState(new Dialog(_title, body, buttons));
        } catch(e) {
            trace("Caught error while opening dialog: " + e.message);
        }
    }

    var bg:Sprite;
    var bgDialog:Sprite;
    var dialog:Sprite;
    var text:Text;
    var title:Text;
    var topEffect:FlxTiledSprite;
    var btmEffect:FlxTiledSprite;
    var hasButtons:Bool = false;
    
    var initialSpeedUp:Float = 100;
    public function new(_title:String, body:String, ?buttons:Array<DialogButton>) {
        super();
        hasButtons = (buttons != null && buttons.length > 0);

        bg = new Sprite().makeGraphic(1, 1, 0xFF000000);
        bg.setScale(FlxG.width);
        bg.screenCenter();
        bg.alpha = 0;
        addObject(bg);
        FlxTween.tween(bg, {alpha: 0.5}, ENTER_DURATION, {ease: FlxEase.expoOut});

        dialog = new Sprite().makeGraphic(1, 1, 0xFF000000);
        addObject(dialog);

        text = new Text(0, 0, body, 14);
        text.setFont("musticapro");
        if (text.width > MAX_SIZE.x) 
            text.fieldWidth = MAX_SIZE.x;
        addObject(text);

        title = new Text(0, 0, _title.toUpperCase(), 16, CENTER, true);
        addObject(title);

        var dialogWidth:Float = Math.max(MIN_SIZE.x, Math.min(MAX_SIZE.x, text.width + (MARGIN * 2)));
        var contentHeight:Float = title.height + 10 + text.height;
        var dialogHeight:Float = (MAX_SIZE.y != -1) 
            ? Math.max(MIN_SIZE.y, Math.min(MAX_SIZE.y, contentHeight + (MARGIN * 2))) 
            : Math.max(MIN_SIZE.y, contentHeight + (MARGIN * 2));

        dialog.scale.set(dialogWidth, dialogHeight);
        dialog.updateHitbox();
        dialog.screenCenter();

        title.setPosition(dialog.x + (dialog.width - title.width) * 0.5, dialog.y + MARGIN);
        text.setPosition(dialog.x + MARGIN, title.y + title.height + 10);

        topEffect = new FlxTiledSprite(Assets.image("ui/skew"), dialog.width,20,true,false);
        addObject(topEffect);

        btmEffect = new FlxTiledSprite(Assets.image("ui/skew"), dialog.width,20,true,false);
        addObject(btmEffect);

        topEffect.setPosition(dialog.x, dialog.y - 20);
        btmEffect.setPosition(dialog.x, dialog.y + dialog.height);

        cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
    }

    function addObject(basic:Dynamic) {
        basic.scrollFactor.set();
        return super.add(basic);
    }

    override function update(elapsed:Float) {
        initialSpeedUp = FlxMath.lerp(initialSpeedUp, 0, elapsed*2);
        var scrollVelocity:Float = (20+initialSpeedUp)*elapsed;
        topEffect.scrollX += scrollVelocity;
        btmEffect.scrollX -= scrollVelocity;
        if (!hasButtons) {
            if (FlxG.keys.justPressed.ANY || FlxG.mouse.justPressed) {
                close();
            } 
        } else {
            // tba
        }
        super.update(elapsed);
    }
}
