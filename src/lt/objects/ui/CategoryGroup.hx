package lt.objects.ui;

enum abstract CategoryType(String) from String to String {
    var CHECKBOX = "checkbox";
    var SCROLLBAR = "scrollbar";
}

class CategoryGroup extends SpriteGroup {
    var bg:Sprite;
    var indicator:Sprite;
    var displayText:Text;

    public var name:String = "";
    public function new(nX:Float, nY:Float, name:String) {
        super(nX, nY);
        this.name = name;

        bg = new Sprite().makeGraphic(1,1,0xFF000000);
        add(bg);

        indicator = new Sprite().makeGraphic(10, 30, 0xFFFFFFFF);
        add(indicator);

        displayText = new Text(indicator.x + indicator.width + 20, indicator.y + indicator.height * 0.5, name, 20, LEFT, true);
        add(cast displayText);
    }
}