package lt.objects.ui;

import flixel.group.FlxSpriteGroup;

enum abstract CategoryType(String) from String to String {
    var CHECKBOX = "checkbox";
    var SCROLLBAR = "scrollbar";
    var DROPDOWN = "dropdown";
}

class CategoryGroup extends FlxSpriteGroup {
    var bg:FlxSprite;
    var indicator:FlxSprite;
    var displayText:FlxText;
    var childIndicator:FlxSprite;

    var child:FlxSpriteGroup;

    public var name:String = "";

    public function new(nX:Float, nY:Float, name:String) {
        super(nX, nY);
        this.name = name;

        bg = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
        add(bg);

        indicator = new FlxSprite().makeGraphic(10, 20, 0xFFFFFFFF);
        add(indicator);

        displayText = new FlxText(indicator.x + indicator.width + 20, indicator.y + indicator.height * 0.5, -1, name.toUpperCase(), 14);
        displayText.font = Assets.font("extenro-bold");
        displayText.y -= displayText.height * 0.5;
        displayText.antialiasing = Preferences.data.antialiasing;
        add(displayText);

        childIndicator = new FlxSprite(indicator.x + indicator.width * 0.5, indicator.y + indicator.height + 10).makeGraphic(1, 1, 0xFFFFFFFF);
        add(childIndicator);

        child = new CategorySpriteGroup(displayText.x, displayText.y + displayText.height);
        add(child);
    }

    override function update(elapsed:Float) {
        childIndicator.scale.y = child.height;
        childIndicator.offset.y = -(child.height * 0.5);

        super.update(elapsed);
    }

    public function addCheckBox(name:String, ?checked:Bool = false, ?callback:Bool -> Void) {
        var n:Checkbox = new Checkbox(0, 0, 300, name, callback);
        n.checked = checked;
        child.add(n);
    }

    public function addScrollBar(name:String, suffix:String = "", value:Float = 0.5, min:Float = 0, max:Float = 1, ?step:Float = 0.1, ?callback:Float -> Void) {
        var n:Scrollbar = new Scrollbar(0, 0, name, suffix, 300, value, min, max, step);
        if (callback != null)
            n.onChanged = callback;
        child.add(n);
    }

    public function addDropDown(name:String, data:Array<String>, ?callback:(String, String) -> Void, defaultData:String) {
        var n:DropDown = new DropDown(0, 0, 300, name, data, callback, true);
        if (defaultData != "")
            n.changeSelected(defaultData);
        child.add(n);
    }

    override function get_height():Float
        return indicator.height + 10 + child.height;
}

class CategorySpriteGroup extends FlxSpriteGroup {
    public function new(nX:Float, nY:Float) {
        super(nX, nY);
    }

    var totalHeight:Float = 0;
    override function update(elapsed:Float) {
        super.update(elapsed);
        var lastHeight:Float = 0;
        totalHeight = 0;
        var lastPos:Float = y;
        for (c in members) {
            c.y = lastPos + lastHeight + 10;
            lastPos = c.y;
            lastHeight = c.height;
            totalHeight += lastHeight + 10;
        }
    }

    override function get_height():Float
        return totalHeight;
}