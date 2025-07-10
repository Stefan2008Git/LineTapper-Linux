package lt.objects.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.util.FlxColor;

class DropDown extends FlxSpriteGroup {
    /** Currently opened dropdown instance. **/
    public static var ACTIVE_ELEMENT:DropDown = null;

    /** Drop down name text object. **/
    public var dropLabel:Text;

    /** Drop down button object. **/
    public var dropButton:Button;

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

    /** Current selected data index in data array. **/
    public var selectedIndex:Int = 0;

    /** Array containing this Drop Down's child. **/
    var childrens:Array<DropDownChild> = [];
	var scrollAmount:Float = 0;
	var scrollLerp:Float = 0;
	var labelOnLeft:Bool = false;
    var nWidth:Float = 0;
    var lastSelected:String = '';
	public function new(nX:Float, nY:Float, nWidth:Float = 200, txt:String, data:Array<String>, onChange:(current:String, last:String)->Void, labelOnLeft:Bool = false) {
		super(nX, nY);
        this.nWidth = nWidth;
		this.data = data;
		this.onChange = onChange;
		this.labelOnLeft = labelOnLeft;

		dropButton = new Button(0, 20, nWidth, '', (_)->{
			opened = !opened;
            if (opened)
			    DropDown.ACTIVE_ELEMENT = this;
		});
		dropButton.align = LEFT;
		add(dropButton);

		dropLabel = new Text(0, 0, txt, 13, CENTER);
		dropLabel.applyUIFont();
		add(dropLabel);

		dropPanel = new Panel(0, 0, nWidth, 0);
		dropPanel.sliceRect = new FlxRect(5, 0, 20, 20);
		dropPanel.sourceRect = new FlxRect(0, 5, 30, 30);
		add(dropPanel);

		icon = new Sprite().loadGraphic(Assets.image("ui/icons/drop"));
		icon.setGraphicSize(-1, dropButton.height);
		icon.updateHitbox();
		add(icon);

		refreshChildren(labelOnLeft ? Math.max(40, nWidth - dropLabel.width - 5) : nWidth);
		updateLayout();
	}

    /**
     * Change the currently selected data
     * @param toData 
     */
    public function changeSelected(toData:String) {
        if (!data.contains(toData)) return;
        selectedIndex = data.indexOf(toData);
        dropButton.label.text = selected = toData;

        if (onChange != null)
            onChange(selected, lastSelected);

        lastSelected = toData;
    }

	function refreshChildren(w:Float):Void {
		for (c in childrens) remove(c, true);
		childrens = [];

		for (ind => item in data) {
			var child = new DropDownChild(item, w - 2, (ind + 1) % 2 == 0);
			childrens.push(child);
			add(child);
		}
		selected = data[0];
		selectedIndex = 0;
		dropButton.label.text = selected;
	}

    function updateLayout():Void {
        dropLabel.setPosition(x, labelOnLeft ? y : y - 20);
    
        if (labelOnLeft) {
            dropLabel.setPosition(x, y);
    
            var finalButtonWidth = Math.max(40, nWidth - dropLabel.width - 5);
    
            dropButton.setPosition(x + dropLabel.width + 5, y);
            dropButton.width = dropPanel.width = finalButtonWidth;
    
            icon.setPosition(
                dropButton.x + dropButton.width - icon.width - 2,
                dropButton.y + (dropButton.height - icon.height) * 0.5
            );
        } else {
            dropButton.setPosition(x, y);
            dropPanel.width = dropButton.width;
    
            dropLabel.setPosition(x, y - 20);
    
            icon.setPosition(
                dropButton.x + dropButton.width - icon.width - 2,
                dropButton.y + (dropButton.height - icon.height) * 0.5
            );
        }
    }

	override function update(elapsed:Float) {
		super.update(elapsed);
		updateLayout();

		dropPanel.setPosition(dropButton.x, dropButton.y + dropButton.height);
		var targetHeight = opened ? FlxMath.bound(childrens.length, 0, 6) * 30 : 0;
		dropPanel.height = FlxMath.lerp(dropPanel.height, targetHeight, elapsed * 32);

		if (FlxG.mouse.overlaps(dropPanel, cameras[0])) {
			if (FlxG.mouse.wheel != 0) {
				scrollAmount += 30 * FlxG.mouse.wheel;
			}
		}
		scrollLerp = FlxMath.lerp(scrollLerp, scrollAmount, elapsed * 32);

		var lastPos:Float = dropPanel.y + scrollLerp;
        if (dropPanel.height > 2) {
            for (i in 0...childrens.length) {
                var child = childrens[i];
                child.active = true;
                child.setPosition(dropPanel.x + 1, lastPos);
                if (child.clipRect == null)
                    child.clipRect = new FlxRect(0, 0, child.width, child.height);
            
                var vTop:Float = dropPanel.y;
                var vBtm:Float = dropPanel.y + dropPanel.height;
                var iTop:Float = child.y;
                var iBtm:Float = child.y + child.height;
    
                child.clipRect.x = 0;
                child.clipRect.y = Math.max(vTop - iTop, 0);
                child.clipRect.width = child.width;
                child.clipRect.height = Math.max(0, Math.min(iBtm, vBtm) - (iTop + child.clipRect.y));
    
                child.visible = (lastPos + child.height >= dropPanel.y) && (lastPos <= dropPanel.y + dropPanel.height);
                lastPos += child.height;
    
                if (child.visible && FlxG.mouse.overlaps(child, child.cameras[0])) {
                    if (FlxG.mouse.justReleased) {
                        var last = selected;
                        changeSelected(child.label.text);
                        DropDown.ACTIVE_ELEMENT = null;
                        opened = false;
                    }
                }
            }
        } else {
            for (i in 0...childrens.length) {
                childrens[i].visible = childrens[i].active = false;
            }
        }
		
		if (!FlxG.mouse.overlaps(dropPanel, cameras[0]) && !FlxG.mouse.overlaps(dropButton, cameras[0])) {
			if (FlxG.mouse.justReleased) {
				DropDown.ACTIVE_ELEMENT = null;
				opened = false;
			}
		}

		icon.flipY = opened;
	}

	override function destroy() {
		for (c in childrens) c.destroy();
		childrens = [];
		super.destroy();
	}

    override function get_height():Float {
        if (labelOnLeft) {
            return (dropButton.height + dropPanel.height);
        } else {
            return (dropLabel.height + dropButton.height + dropPanel.height);
        }
    }
}

class DropDownChild extends FlxSpriteGroup {
    public var bg:Sprite;
	public var label:Text;
	var isSecond:Bool;

	public function new(text:String, nWidth:Float, isSecond:Bool) {
		super();
		this.isSecond = isSecond;
        bg = new Sprite().makeGraphic(Std.int(nWidth), 30, FlxColor.WHITE);
        add(bg);

		label = new Text(0, 0, text, 13, CENTER);
		label.applyUIFont();
		label.active = false;
		label.setPosition(bg.x + 4, bg.y + (bg.height - label.height) * 0.5);
        add(label);
	}

	override function update(e:Float) {
        super.update(e);
		var alphaBase = isSecond ? 0 : 0.05;
		bg.alpha = alphaBase;
		if (FlxG.mouse.overlaps(this, cameras[0])) {
			bg.alpha = FlxG.mouse.pressed ? alphaBase : 0.1 + alphaBase;
		}
        bg.cameras = cameras;
		bg.clipRect = clipRect;
		label.cameras = cameras;
		label.clipRect = clipRect;
	}
}
