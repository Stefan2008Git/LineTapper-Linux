package lt.substates;

import lt.backend.Game;
import lt.objects.ui.CategoryGroup;
import lt.objects.ui.CategoryGroup.CategoryType;
import lt.objects.ui.InputBox;

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

    var exiting:Bool = false;
    override function update(elapsed:Float) {
        if (!exiting && (FlxG.keys.justPressed.ESCAPE || (!FlxG.mouse.overlaps(panel) && FlxG.mouse.justPressed) && !panel.searchBar.hasFocus)) {
            exit();
            Preferences.save();
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
    ?desc:String,
    ?type:CategoryType,
    ?min:Float,
    ?max:Float,
    ?suffix:String,
    ?onChange:Dynamic -> Void,
    ?step:Float,
    ?data:Array<String>
}

typedef SettingsCategory = {
    name:String,
    langname:String,
    children:Array<SettingsChild>
}

class SettingsPanel extends Sprite {
    var bgCover:Sprite;
    var titleText:Text;
    var subtitleText:Text;
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
        ]);

        bgCover = new Sprite().makeGraphic(Std.int(width - 80), 150, 0xFF000000);
        objects.push(bgCover);

        titleText = new Text(0, 0, PhraseManager.getPhrase('settings', "Settings").toUpperCase(), 20, CENTER, true);
        objects.push(titleText);

        subtitleText = new Text(0, 0, FlxG.random.getObject(messages), 13, CENTER);
        subtitleText.applyUIFont();
        subtitleText.alpha = 0.5;
        objects.push(subtitleText);

        searchBar = new InputBox(0, 0, width - 80);
        searchBar.placeholder.text = PhraseManager.getPhrase('search_settings', 'Search settings...');
        objects.push(searchBar);

        divider = new Sprite().makeGraphic(Std.int(width - 80), 1, 0xFF303030);
        objects.push(divider);

        generateSettings();
    }

    function generateSettings() {
        // Define categories & children
        addCategory("Display", 'settings_graphics', [
            createCheckbox("Antialiasing", 'settings_antialiasing', 'Whether to use antialiasing (smoother visuals)', 'antialiasing', (val:Bool) -> {
                FlxSprite.defaultAntialiasing = val;
            }),
            createDropdown('Language', "settings_language", "Language used in the game.", 'language', Game.SUPPORTED_LANGUAGES, (val:String)->{
                PhraseManager.init(); //Reinit phrases.
            })
        ]);

        addCategory("Gameplay", 'settings_gameplay', [
            createScrollbar("Tile Offset", "settings_tile_offset", "Defines offset value used in-game (Tile time offset)", 'offset', -300, 300, 10, 'ms')
        ]);

        addCategory("Audio", 'settings_audio', [
            createScrollbar("Master Volume", "settings_master_volume", "Adjust how loud the game's audio.", 'masterVolume', 0, 1, 0.1, '%', (val:Float)->{
                FlxG.sound.volume = val;
            }),
            createScrollbar("Music Volume", "settings_music_volume", "Adjust how loud music should be.", 'musicVolume', 0, 1, 0.1, '%'),
            createScrollbar("SFX Volume", "settings_sfx_volume", "Adjust how loud sound effects should be.", 'sfxVolume', 0, 1, 0.1, '%'),
        ]);

        // create elements
        for (category in categories) {
            var group = new CategoryGroup(0, 0, category.langname);
            for (child in category.children) {
                var prefValue:Dynamic = Reflect.getProperty(Preferences.data, child.field);

                switch (child.type) {
                    case CHECKBOX:
                        group.addCheckBox(child.langname, prefValue, (v:Bool) -> {
                            Reflect.setProperty(Preferences.data, child.field, v);
                            child.onChange(v);
                        });
                    case SCROLLBAR:
                        group.addScrollBar(child.langname, child.suffix, prefValue, child.min, child.max, child.step, (v:Float) -> {
                            Reflect.setProperty(Preferences.data, child.field, v);
                            child.onChange(v);
                        });
                    case DROPDOWN:
                        group.addDropDown(child.langname, child.data, (v:String, _)->{
                            Reflect.setProperty(Preferences.data, child.field, v);
                            child.onChange(v);
                        });
                }
            }
            settings.push(group);
        }
    }

    function addCategory(name:String, langname:String, children:Array<SettingsChild>) {
        categories.push({
            name: name,
            langname: PhraseManager.getPhrase(langname, name),
            children: children
        });
    }

    /**
     * Creates checkbox option.
     */
    function createCheckbox(
        name:String, langname:String, desc:String, field:String, onChange:Bool->Void
    ):SettingsChild {
        return {
            type: CHECKBOX,
            name: name,
            langname: PhraseManager.getPhrase(langname, name),
            desc: desc,
            field: field,
            onChange: onChange
        }
    }


    /**
     * Creates scrollbar option.
     */
    function createScrollbar(
        name:String, langname:String, desc:String, field:String, min:Float, max:Float, step:Float, suffix:String, ?onChange:Float -> Void
    ):SettingsChild {
        return {
            type: SCROLLBAR,
            name: name,
            langname: PhraseManager.getPhrase(langname, name),
            desc: desc,
            field: field,
            min: min,
            max: max,
            step: step,
            suffix: suffix,
            onChange: onChange != null ? onChange : (_) -> {}
        }
    }

    function createDropdown(
        name:String, langname:String, desc:String, field:String, data:Array<String>, onChange:String -> Void
    ):SettingsChild {
        return {
            type: DROPDOWN,
            name: name,
            langname: PhraseManager.getPhrase(langname, name),
            desc: desc,
            field: field,
            data: data,
            onChange: onChange != null ? onChange : (_) -> {}
        }
    }

    function createChild(
        name:String, langname:String, desc:String, field:String,
        type:CategoryType, ?min:Float = 0, ?max:Float = 1,
        ?suffix:String = "", ?onChange:Dynamic -> Void, ?step:Float = 1,
    ):SettingsChild {
        return {
            name: name,
            langname: PhraseManager.getPhrase(langname, name),
            desc: desc,
            field: field,
            type: type,
            min: min,
            max: max,
            suffix: suffix,
            onChange: onChange != null ? onChange : (_) -> {},
            step: step,
        };
    }

    override function update(elapsed:Float) {
        searchBar.update(elapsed);
        if (FlxG.mouse.wheel != 0) {
            scrollY += 20 * FlxG.mouse.wheel;
        }
        _scrollY = FlxMath.lerp(_scrollY, scrollY, 12 * elapsed);
        for (obj in settings) obj.update(elapsed);
        super.update(elapsed);
    }

    override function draw() {
        super.draw();
    
        objectCenterX(bgCover); bgCover.y = y;
        objectCenterX(titleText); titleText.y = y + 60;
        objectCenterX(subtitleText); subtitleText.y = titleText.y + titleText.height + 3;
        objectCenterX(searchBar); searchBar.y = subtitleText.y + 30;
        objectCenterX(divider); divider.y = bgCover.y + bgCover.height;
    
        var offsetY:Float = divider.y + 40 + _scrollY;
        for (group in settings) {
            group.exists = true;
            group.setPosition(x + 40, offsetY);
            offsetY += group.height + 10;
        }
        
        var a:Array<CategoryGroup> = settings.copy();
        a.reverse();
        for (group in a)
            group.draw();
    
        for (obj in objects) obj.draw();
    }
    

    inline function objectCenterX(obj:FlxObject) {
        obj.x = x + (width - obj.width) * 0.5;
    }
}
