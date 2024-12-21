package lt.substates;

import lt.objects.ui.InputBox;
import flixel.FlxSubState;

class SettingsSubstate extends FlxSubState {
    var bg:Sprite;
    var panel:SettingsPanel;

    public function new():Void {
        super();
        bg = new Sprite().makeGraphic(1,1,0xFF000000);
        bg.setScale(FlxG.width);
        bg.screenCenter();
        add(bg);

        panel = new SettingsPanel();
        add(panel);

        bg.alpha = 0;
        FlxTween.tween(bg, {alpha:0.5}, 0.5, {ease: FlxEase.expoOut});
        tweenX(panel, -panel.width, 0);
    }

    override function update(elapsed:Float) {
        if (panel.searchBar.hasFocus && (!FlxG.mouse.overlaps(panel) && FlxG.mouse.justPressed)) {
            panel.searchBar.hasFocus = false;
        }
        if (FlxG.keys.justPressed.ESCAPE || (!FlxG.mouse.overlaps(panel) && FlxG.mouse.justPressed) && !panel.searchBar.hasFocus) {
            exit();
        }
        super.update(elapsed);
    }
    
    function exit() {
        bg.alpha = 0.5;
        FlxTween.tween(bg, {alpha:0}, 0.5, {ease: FlxEase.expoOut, onComplete: (_)->{close();}});
        tweenX(panel, 0, -(panel.width+2));
    }

    override function destroy() {
        bg?.destroy();
        panel?.destroy();
        super.destroy();
    }

    var tweenMap:Map<Sprite, FlxTween> = [];
    function tweenX(obj:Sprite, from:Float, to:Float, duration:Float = 0.5) {
        if (tweenMap.exists(obj)){
            tweenMap.get(obj)?.cancel();
            tweenMap.remove(obj);
        }
        obj.x = from;
        tweenMap.set(obj, FlxTween.tween(obj, {x: to}, duration, {ease:FlxEase.expoOut, onComplete: (_)->{
            tweenMap.remove(obj);
        }}));
    }
}

class SettingsPanel extends Sprite {
    var bgCover:Sprite;
    var title:Text;
    var randomText:Text;
    public var searchBar:InputBox;
    var divider:Sprite;


    var messages:Array<String> = [
        "Adjust these to your preferences.",
        "Let me guess, offset?"
    ];

    public var objects:Array<Dynamic> = [];
    public var scrollY:Float = 0;
    public function new():Void {
        super();
        loadGraphic(Assets.image("ui/settings/panel"));

        bgCover = new Sprite().makeGraphic(Std.int(width-80), 150, 0xFF000000);
        objects.push(bgCover);

        title = new Text(0,0, "SETTINGS", 20, CENTER, true);
        objects.push(title);

        randomText = new Text(0,0, FlxG.random.getObject(messages), 13, CENTER);
        randomText.setFont("musticapro");
        randomText.alpha = 0.5;
        objects.push(randomText);

        searchBar = new InputBox(0,0, width-80);
        searchBar.placeholder.text = "Search settings...";
        objects.push(searchBar);

        divider = new Sprite().makeGraphic(Std.int(width-80), 1, 0xFF303030);
        objects.push(divider);
    }

    override function update(elapsed:Float) {
        searchBar.update(elapsed);
        super.update(elapsed);
    }

    override function draw() {
        super.draw();
        objectCenterX(bgCover);
        bgCover.y = y;

        objectCenterX(title);
        title.y = y + 60;
        
        objectCenterX(randomText);
        randomText.y = title.y + title.height + 3;

        objectCenterX(searchBar);
        searchBar.y = randomText.y + 30;

        objectCenterX(divider);
        divider.y = bgCover.y + bgCover.height;

        for (obj in objects) {
            obj.draw();
        }
    }

    inline function objectCenterX(obj:FlxObject) {
        obj.x = x + (width - obj.width) * 0.5;
    }
}