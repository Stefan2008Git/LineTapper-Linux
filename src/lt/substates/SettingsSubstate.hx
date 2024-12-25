package lt.substates;

import lt.objects.ui.CategoryGroup;
import lt.objects.ui.CategoryGroup.CategoryType;
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

typedef SettingsChild = {
    name:String,
    langname:String,
    field:String,
    desc:String,
    type:CategoryType,
    min:Float, // Used by "Scroll Bar" type.
    max:Float,  // Used by "Scroll Bar" type.
    suffix:String,
    onChange:Dynamic -> Void
}
typedef SettingsCategory = {
    name:String,
    langname:String,
    child:Array<SettingsChild>
}
class SettingsPanel extends Sprite {
    var bgCover:Sprite;
    var title:Text;
    var randomText:Text;
    public var searchBar:InputBox;
    var divider:Sprite;


    var messages:Array<String> = [];

    public var categories:Array<SettingsCategory> = [];
    public var objects:Array<Dynamic> = [];
    public var settings:Array<CategoryGroup> = [];
    public var scrollY:Float = 0;
    private var _scrollY:Float = 0;
    public function new():Void {
        super();
        loadGraphic(Assets.image("ui/settings/panel"));

        messages = PhraseManager.getPhrase('settings_messages', [
            "Adjust these to your preferences.",
            "Let me guess, offset?",
            "Looking for something?",
            ""
        ]);

        bgCover = new Sprite().makeGraphic(Std.int(width-80), 150, 0xFF000000);
        objects.push(bgCover);

        title = new Text(0,0, PhraseManager.getPhrase('settings').toString().toUpperCase(), 20, CENTER, true);
        objects.push(title);

        randomText = new Text(0,0, FlxG.random.getObject(messages), 13, CENTER);
        randomText.setFont("musticapro");
        randomText.alpha = 0.5;
        objects.push(randomText);

        searchBar = new InputBox(0,0, width-80);
        searchBar.placeholder.text = PhraseManager.getPhrase('search_settings', 'Search settings...');
        objects.push(searchBar);

        divider = new Sprite().makeGraphic(Std.int(width-80), 1, 0xFF303030);
        objects.push(divider);

        generateSettings();
    }
    
    function generateSettings() {
        // Add the category and it's child //
        addCategory("Graphics", 'settings_graphics', [
            makeCategoryChild("Antialiasing", 'settings_antialiasing', "Whether to use antialiasing for sprites (smoother visuals)", "antialiasing", CHECKBOX)
        ]);
        addCategory("Gameplay", 'settings_gameplay', [
            makeCategoryChild("Tile Offset", 'settings_tile_offset', "Defines offset value used in-game (Tile time offset)", "offset", SCROLLBAR, -600, 600, "ms")
        ]);
        addCategory("Audio", 'settings_audio', [
            makeCategoryChild("Master Volume", 'settings_master_volume', "Adjust how loud the game's audio.", "masterVolume", SCROLLBAR, 0, 100, "%", (val:Dynamic) -> {
                FlxG.sound.volume = val/100;
            }),
            makeCategoryChild("Music Volume", 'settings_music_volume', "Adjust how loud are musics supposed to be.", "musicVolume", SCROLLBAR, 0, 100, "%"),
            makeCategoryChild("SFX Volume", 'settings_sfx_volume', "Adjust how loud are sound effects supposed to be.", "sfxVolume", SCROLLBAR, 0, 100, "%"),
        ]);

        // Then generate the UI //
        for (category in categories) {
            var wawa:CategoryGroup = new CategoryGroup(0,0, category.langname);
            for (child in category.child) {
                switch (child.type) {
                    case CHECKBOX:
                        wawa.addCheckBox(child.langname, Reflect.getProperty(Preferences.data,child.field),(val:Bool)->{
                            Reflect.setProperty(Preferences.data, child.field, val);
                            child.onChange(val);
                        });
                    case SCROLLBAR:
                        wawa.addScrollBar(child.langname, child.suffix, Reflect.getProperty(Preferences.data,child.field), child.min, child.max,(val:Float)->{
                            Reflect.setProperty(Preferences.data, child.field, val);
                            child.onChange(val);
                        });
                        // do nothing
                }
            }
            
            settings.push(wawa);
        }
    }

    function addCategory(name:String, langname:String, child:Array<SettingsChild>) {
        categories.push({
            name: name,
            langname: PhraseManager.getPhrase(langname, name),
            child: child
        });
    }

    function makeCategoryChild(name:String, langname:String, desc:String, field:String, type:CategoryType, ?min:Float = 0, ?max:Float = 1, ?suffix:String = "", ?onChange:Dynamic -> Void):SettingsChild {
        return {
            name: name,
            langname: PhraseManager.getPhrase(langname, name),
            desc: desc,
            field: field,
            type: type,
            min: min,
            max: max,
            suffix: suffix,
            onChange: (w:Dynamic)->{
                if (onChange != null)
                    onChange(w);
            }
        }
    }

    override function update(elapsed:Float) {
        searchBar.update(elapsed);
        if (FlxG.mouse.wheel != 0) {
            scrollY += 20 * FlxG.mouse.wheel;
        }
        _scrollY = FlxMath.lerp(_scrollY, scrollY, 12*elapsed);
        for (obj in settings) {
            obj.update(elapsed);
        }
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

        var lastPos:Float = 0;
        var lastHeight:Float = 0;
        for (obj in settings) {
            obj.exists = true;
            obj.setPosition(x + 40, divider.y + 40 + _scrollY + lastPos + lastHeight + 10);
            obj.draw();

            lastPos = obj.y - (divider.y + 40 + _scrollY);
            lastHeight = obj.height;
        }

        for (obj in objects) {
            obj.draw();
        }
    }

    inline function objectCenterX(obj:FlxObject) {
        obj.x = x + (width - obj.width) * 0.5;
    }
}