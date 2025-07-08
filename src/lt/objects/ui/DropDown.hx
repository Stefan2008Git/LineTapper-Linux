package lt.objects.ui;

class DropDown extends Button {
    /** Currently opened dropdown instance. **/
    public static var ACTIVE_ELEMENT:DropDown = null;

    /** Drop down name text object. **/
    public var dropLabel:Text;

    /** List of data used by this Drop Down object. **/
    public var data:Array<String> = [];
    
    /** Icon sprite, defaults it's graphic to "ui/icons/drop.png". **/
    public var icon:Sprite;
    
    /** Whether this Drop Down has opened or not. **/
    public var opened:Bool = false;

    /** Drop Down child panel object. **/
    public var dropPanel:Panel;
    
    /** Callback when the selected data has changed. **/
    public var onChange:(current:String, last:String)->Void;

    /** Current selected data. **/
    public var selected:String = '';

    /** Current selected data index in `data` array. **/
    public var selectedIndex:Int = 0;

    /** Whether the name label should be placed beside this dropdown instead of top. **/
    public var labelOnLeft:Bool = false;

    /** Array containing this Drop Down's child. **/
    var childrens:Array<DropDownChild> = [];
    public function new(nX:Float, nY:Float, nWidth:Float = 200, txt:String, data:Array<String>, onChange:(current:String, last:String)->Void) {
        super(nX, nY, nWidth, '', (_)->{
            DropDown.ACTIVE_ELEMENT = this;
            opened = !opened;
        });
        this.data = data;
        if (this.data != null) {
            label.text = data[0];
            for (ind=>i in this.data) {
                var child:DropDownChild = new DropDownChild(i, nWidth-2, (ind+1)%2==0);
                childrens.push(child);
            }
        }
        this.onChange = onChange;
        align = LEFT;
        dropPanel = new Panel(0,0,nWidth,20);
        dropPanel.sliceRect = new FlxRect(5, 0, 20, 20);
        dropPanel.sourceRect = new FlxRect(0, 5, 30, 30);

        icon = new Sprite().loadGraphic(Assets.image("ui/icons/drop"));
        icon.setGraphicSize(-1,height);
        icon.updateHitbox();

        dropLabel = new Text(0,0,txt,13, CENTER);
        dropLabel.applyUIFont();
    }

    var scrollAmount:Float = 0;
    var scrollLerp:Float = 0;
    override function draw() {
        for (i in [dropPanel, dropLabel, icon]) 
            if (i != null) i.cameras = cameras;
        dropPanel.setPosition(
            x,
            y+height
        );
        dropPanel.height = FlxMath.lerp(
            dropPanel.height, 
            opened ? FlxMath.bound(childrens.length, 0, 6)*30 : 0, 
            FlxG.elapsed * 32
        );

        if (FlxG.mouse.overlaps(dropPanel, cameras[0])) {
            if (FlxG.mouse.wheel != 0) {
                scrollAmount += 30 * FlxG.mouse.wheel;
            }
        }
        scrollLerp = FlxMath.lerp(scrollLerp, scrollAmount, FlxG.elapsed * 32);

        var hovered:Bool = false;
        if (dropPanel.height > 2) {
            dropPanel.draw();

            var lastPos:Float = dropPanel.y + scrollLerp;
            for (id => i in childrens) {
                if (i.clipRect == null)
                    i.clipRect = new FlxRect(0, 0, i.width, i.height);
            
                var vTop:Float = dropPanel.y;
                var vBtm:Float = dropPanel.y + dropPanel.height;
                var iTop:Float = i.y;
                var iBtm:Float = i.y + i.height;
    
                i.clipRect.x = 0;
                i.clipRect.y = Math.max(vTop - iTop, 0);
                i.clipRect.width = i.width;
                i.clipRect.height = Math.max(0, Math.min(iBtm, vBtm) - (iTop + i.clipRect.y));
            
                i.cameras = cameras;
                i.setPosition(x+1, lastPos);
                i.draw();
                lastPos += i.height;
    
                if (FlxG.mouse.overlaps(i, i.cameras[0])) {
                    hovered = true;
                    if (FlxG.mouse.justReleased) {
                        var last:String = selected;
                        label.text = selected = i.label.text;
                        selectedIndex = id;
                        if (onChange!=null)
                            onChange(selected, last);
                        DropDown.ACTIVE_ELEMENT = null;
                        opened = false;
                    }
                }
            }
        }
        if (!hovered && FlxG.mouse.justReleased) {
            DropDown.ACTIVE_ELEMENT = null;
            opened = false;

        }
        super.draw();
        
        dropLabel.setPosition(
            x,
            y - 20
        );
        dropLabel.draw();

        icon.setPosition(
            x + (width - icon.width) -2,
            y + (height - icon.height) * 0.5
        );
        icon.flipY = opened;
        icon.draw();
    }

    override function destroy() {
        for (i in [dropPanel, dropLabel, icon])  {
            i.destroy();
        }
        
        for (i in childrens) {
            childrens.remove(i);
            i.destroy();
        } 

        childrens = [];
        super.destroy();
    }
}

class DropDownChild extends Sprite {
    public var label:Text;
    var isSecond:Bool = false;
    public function new(text:String, nWidth:Float, isSecond:Bool) {
        super();
        this.isSecond = isSecond;
        makeGraphic(Std.int(nWidth), 30);
        label = new Text(0,0,text,13, CENTER);
        label.applyUIFont();
        label.active = false;
    }

    override function draw() {
        super.draw();
        label.setPosition(
            x + 2,
            y + (height - label.height) * 0.5
        );
        label.cameras = cameras;
        label.clipRect = clipRect;
        label.draw();

        var add = isSecond ? 0 : 0.05;
        alpha = add;
        if (FlxG.mouse.overlaps(this, cameras[0])) {
            alpha = FlxG.mouse.pressed ? add : 0.1+add;
        }
        
    }
}