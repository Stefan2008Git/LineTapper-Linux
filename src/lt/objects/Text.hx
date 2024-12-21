package lt.objects;

class Text extends FlxText {
    public function new(nX:Float, nY:Float, nText:String, nSize:Int = 12, ?align:FlxTextAlign = LEFT, ?bold:Bool = false) {
        super(nX, nY, 0, nText, nSize);
        setFormat(Assets.font("extenro"+(bold?"-bold":"")), size, FlxColor.WHITE, align, OUTLINE, FlxColor.BLACK);
    }

    public function setFont(name:String, bold:Bool = false):Void {
        font = Assets.font(name+(bold?"-bold":""));
    }
}