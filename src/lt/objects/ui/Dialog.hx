package lt.objects.ui;

import flixel.group.FlxSpriteGroup;
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
    public static function show(_title:String = "", body:String = "", ?buttons:Array<DialogButton>) {
        if (FlxG.state == null) {
            trace("Could not open new dialog, FlxG.state is null.");
            return;
        }
        try {
            FlxG.state.openSubState(new Dialog(_title, body, buttons));
        } catch(e) {
            trace("Caught error while opening dialog: " + e.message + "//" +e.stack);
        }
    }

    var bg:Sprite;
    var dialog:FlxSprite;
    var text:Text;
    var title:Text;

    var dialogGroup:FlxSpriteGroup;
    var topEffect:FlxTiledSprite;
    var btmEffect:FlxTiledSprite;
    var hasButtons:Bool = false;
    
    var initialSpeedUp:Float = 200;
    public function new(_title:String, body:String, ?buttons:Array<DialogButton>) {
        super();
        hasButtons = (buttons != null && buttons.length > 0);

        bg = new Sprite().makeGraphic(1, 1, 0xFF000000);
        bg.setScale(FlxG.width);
        bg.screenCenter();
        bg.alpha = 0;
        bg.scrollFactor.set();
        add(bg);
        FlxTween.tween(bg, {alpha: 0.5}, ENTER_DURATION, {ease: FlxEase.expoOut});

        dialogGroup = new FlxSpriteGroup();
        add(dialogGroup);

        generateDialog(_title, body, buttons);

        dialogGroup.screenCenter();
        dialogGroup.alpha = 0;
        dialogGroup.scale.set(0.7,0.7);
        dialogGroup.antialiasing = Preferences.data.antialiasing;

        FlxTween.tween(dialogGroup, {alpha: 1}, ENTER_DURATION, {ease: FlxEase.expoOut});
        FlxTween.tween(dialogGroup.scale, {x: 1, y: 1}, ENTER_DURATION, {ease: FlxEase.expoOut});

        cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
    }

    function generateDialog(_title:String, body:String, ?buttons:Array<DialogButton>) {
        text = new Text(0, 0, body, 14);
        text.setFont("musticapro");
        if (text.width > MAX_SIZE.x) 
            text.fieldWidth = MAX_SIZE.x;
        text.scrollFactor.set();
        
        title = new Text(0, 0, _title.toUpperCase(), 16, CENTER, true);
        title.scrollFactor.set();

        var dialogWidth:Float = Math.max(MIN_SIZE.x, Math.min(MAX_SIZE.x, text.width + (MARGIN * 2)));
        var contentHeight:Float = title.height + 10 + text.height;
        var dialogHeight:Float = (MAX_SIZE.y != -1) 
            ? Math.max(MIN_SIZE.y, Math.min(MAX_SIZE.y, contentHeight + (MARGIN * 2))) 
            : Math.max(MIN_SIZE.y, contentHeight + (MARGIN * 2));

        dialog = new FlxSprite().makeGraphic(Std.int(dialogWidth), Std.int(dialogHeight), 0xFF000000);
        dialog.scrollFactor.set();
        dialogGroup.add(dialog);
        dialogGroup.add(text);
        dialogGroup.add(title);

        title.setPosition(dialog.x + (dialog.width - title.width) * 0.5, dialog.y + MARGIN);
        text.setPosition(dialog.x + MARGIN, title.y + title.height + 10);

        topEffect = new FlxTiledSprite(Assets.image("ui/skew"), dialog.width,20,true,false);
        topEffect.scrollFactor.set();
        dialogGroup.add(topEffect);

        btmEffect = new FlxTiledSprite(Assets.image("ui/skew"), dialog.width,20,true,false);
        btmEffect.scrollFactor.set();
        dialogGroup.add(btmEffect);

        topEffect.setPosition(dialog.x, dialog.y - 15);
        btmEffect.setPosition(dialog.x, dialog.y + dialog.height);
    }
    
    var exiting:Bool = false;
    override function update(elapsed:Float) {
        initialSpeedUp = FlxMath.lerp(initialSpeedUp, 0, elapsed*2);
        var scrollVelocity:Float = (20+initialSpeedUp)*elapsed;
        topEffect.scrollX += scrollVelocity;
        btmEffect.scrollX -= scrollVelocity;
        if (!hasButtons) {
            if (!exiting && (FlxG.keys.justPressed.ANY || FlxG.mouse.justPressed))
                exit();
        } else {
            // tba
        }
        super.update(elapsed);
    }

    function exit() {
        FlxTween.tween(bg, {alpha: 0}, ENTER_DURATION, {ease: FlxEase.expoOut});
        FlxTween.tween(dialogGroup, {alpha: 0}, ENTER_DURATION, {ease: FlxEase.expoOut});
        FlxTween.tween(dialogGroup.scale, {x: 0.7, y: 0.7}, ENTER_DURATION, {ease: FlxEase.expoOut, onComplete: (_)->{
            close();
        }});
    }
}
