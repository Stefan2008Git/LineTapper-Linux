package lt.objects.ui;

import flixel.group.FlxSpriteGroup;

enum abstract CategoryType(String) from String to String {
    var CHECKBOX = "checkbox";
    var SCROLLBAR = "scrollbar";
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

        bg = new FlxSprite().makeGraphic(1,1,0xFF000000);
        add(bg);

        indicator = new FlxSprite().makeGraphic(10, 20, 0xFFFFFFFF);
        add(indicator);

        displayText = new FlxText(indicator.x + indicator.width + 20, indicator.y + indicator.height * 0.5, -1, name.toUpperCase(), 14);
        displayText.font = Assets.font("extenro-bold");
        displayText.y -= displayText.height * 0.5;
        add(displayText);

        childIndicator = new FlxSprite(indicator.x + indicator.width*0.5, indicator.y + indicator.height + 10).makeGraphic(1,1,0xFFFFFFFF);
        add(childIndicator);
        
        child = new FlxSpriteGroup(displayText.x, displayText.y + displayText.height + 10);
        add(child);
    }

    override function update(elapsed:Float) {
        childIndicator.scale.y = child.height;
        childIndicator.offset.y = -(child.height*0.5);
        super.update(elapsed);
    }
    
    public function addCheckBox(name:String, ?checked:Bool = false, ?callback:Bool -> Void) {
        var n:Checkbox = new Checkbox(0,0,name, 300, checked);
        if (callback != null)
            n.onChanged = callback;
        child.add(n);
    }
}