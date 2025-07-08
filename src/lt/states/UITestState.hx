package lt.states;

import lt.objects.ui.Stepper;
import lt.objects.ui.DropDown;
import lt.objects.ui.Scrollbar;
import flixel.group.FlxSpriteGroup;
import lt.objects.ui.TabGroup;
import lt.objects.ui.Checkbox;
import lt.objects.ui.SelectionRect;
import flixel.text.FlxInputText.FlxInputTextChange;
import lt.backend.Game;
import lt.backend.MapData;
import lt.objects.ui.InputBox;
import lt.objects.ui.Button;
import openfl.display.BitmapData;
import lt.objects.ui.Dialog;
import lt.objects.play.Tile;
import flixel.addons.transition.FlxTransitionSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;

class UITestState extends State {
    var gameCamera:FlxCamera;
	var hudCamera:FlxCamera;

    override function create() {
        super.create();
        gameCamera = new FlxCamera();
		FlxG.cameras.reset(gameCamera);

		hudCamera = new FlxCamera();
		hudCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(hudCamera, false);

        var wawa:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(10,10,FlxG.width,FlxG.height,true,0xFF353535,0xFF505050));
        wawa.scale.set(4,4);
        wawa.scrollFactor.set(0.2,0.2);
        wawa.alpha = 0.2;
        add(wawa);

        var sel:SelectionRect = new SelectionRect();
        add(sel);

        var button:Button = new Button(20,100, "This is a cool looking button", (_)->{
            trace("i'm depressed....");
        });
        add(button);
        var buttonTog:Button;
        buttonTog = new Button(20,140, "This one is a toggle: Enabled!", (status)->{
            if (status)
                buttonTog.label.text = "This one is a toggle: Enabled!";
            else 
                buttonTog.label.text = "This one is a toggle: Disabled!";
        });
        buttonTog.isToggle = true;
        add(buttonTog);

        var inputBox:InputBox = new InputBox(20,180, 200);
        inputBox.placeholder.text = "Hello! I'm an Input Box!";
        add(inputBox);

        var check:Checkbox = new Checkbox(20, 210, "This is a checkbox");
        add(check);

        inline function mktxt(nx,ny,t,s) {
            var nt:Text = new Text(nx,ny,t,s);
            nt.applyUIFont();
            return nt;
        }
        var tabGroup:TabGroup = new TabGroup(300, 300, 600, 200);
        tabGroup.add("General", (p:FlxSpriteGroup)->{
            p.add(mktxt(0,0, "General", 20));
            p.add(mktxt(0,24, "Lorem ipsum dolor sit amet.", 14));
        });
        tabGroup.add("View", (p:FlxSpriteGroup)->{
            p.add(mktxt(0,0, "View", 20));
            p.add(mktxt(0,24, "super.view()", 14));
        });
        tabGroup.add("Options", (p:FlxSpriteGroup)->{
            p.add(mktxt(0,0, "Options", 20));
            p.add(mktxt(0,24, "hmm....", 14));
        });
        tabGroup.add("Help", (p:FlxSpriteGroup)->{
            p.add(mktxt(0,0, "Help", 20));
            p.add(mktxt(0,24, "Press F1 for help.", 14));
        });
        add(tabGroup);

        var scrollbar:Scrollbar = new Scrollbar(20, 230, 'Scroll Bar','%', 300, 0.4, 0, 1, 0.2);
        add(scrollbar);

        var dropDown:DropDown = new DropDown(600, 50, 200, 'Drop down example', [
            'hi guys',
            'cats',
            'woah!!',
            'this is 4th',
            'wawa',
            'ouch',
            'el wawa',
            'ok',
            'meow',
            'lmao',
            'gato :]',
            'ooo',
            'car',
            'what',
            'e',
            'cat!!',
            'zzz',
            'o7',
            ':3'
        ], (nData:String, lData:String) -> {
            trace('Selected: $nData (was $lData)');
        });

        var stepper:Stepper = new Stepper(900, 50, 150, "Stepper example, min 0, max 100, step 10", 50,0,100,10);
        add(stepper);
        
        add(dropDown);
        initHUD();
    }

    function initHUD() {
        var lastY:Float = 10;
        inline function makeInputBox(text:String, defaultTxt:String = '', onChange:(String, FlxInputTextChange)->Void):InputBox {
            var obj:InputBox = new InputBox(20,lastY+30,200,defaultTxt);
            obj.label.text = text;
            obj.cameras = [hudCamera];
            obj.onTextChange.add(onChange);
            obj.scrollFactor.set();
            add(obj);
            
            lastY = obj.y + obj.height;
            return obj;
        }
        inline function makeText(nx:Float, ny:Float, text:String):Text {
            var txt:Text = new Text(nx,ny,text, 14, RIGHT);
            txt.cameras = [hudCamera];
            txt.applyUIFont();
            add(txt);
            return txt;
        }
        inline function makeButton(text:String,onClick:Bool->Void,isToggle:Bool) {
            var btn:Button = new Button(20, lastY,200,text, onClick);
            btn.isToggle = isToggle;
            btn.cameras = [hudCamera];
            add(btn);
            lastY = btn.y + btn.height + 10;
            return btn;
        }
        var inputBox:InputBox = makeInputBox("Input Box", 'Text box', (t,c)->{
        });

        var button:Button = makeButton("Button", (_)->{
        }, false);

        var version:Text = makeText(20,0,'${Game.VERSION_LABEL} // Development in progress, features may change.');
        version.y = FlxG.height - version.height - 20;
        version.alpha = 0.5;
    }

    var ue:Bool = false;
    override function update(elapsed:Float) {
        super.update(elapsed);
        // var moveSpeed:Float = elapsed*500;
        // if (FlxG.keys.pressed.A || FlxG.keys.pressed.D) 
        //     FlxG.camera.scroll.x -= FlxG.keys.pressed.A ? moveSpeed : -moveSpeed;
        // if (FlxG.keys.pressed.W || FlxG.keys.pressed.S) 
        //     FlxG.camera.scroll.y -= FlxG.keys.pressed.W ? moveSpeed : -moveSpeed;

        // if (FlxG.keys.pressed.Q || FlxG.keys.pressed.E) 
        //     FlxG.camera.zoom -= FlxG.keys.pressed.E ? -(3*elapsed) : (3*elapsed);

        // if (FlxG.keys.justPressed.SPACE) {
        //     trace("Wawa");
        //     Utils.switchState(new UITestState(true,true), "Transition Test!");
        // }
        if (FlxG.keys.justPressed.TAB) {
            trace("Wawa");
            Utils.switchState(new MenuState(), "menu woooo");
        }
    }
}