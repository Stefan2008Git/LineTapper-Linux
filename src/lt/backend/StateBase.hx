package lt.backend;

import flixel.util.typeLimit.NextState;

/**
 * Hi future CoreCat pls tidy this up holy heck
 */
class StateBase extends FlxState {
    var _defaultCamera:FlxCamera;
    var _transIn:Bool = false;
    var _transOut:Bool = false;
    var _transText:String = "";
    public function new(?transInEnabled:Bool = true, ?transOutEnabled:Bool = true) {
        super();
        _transIn = transInEnabled;
        _transOut = transOutEnabled;
    }

    override function create() {
        super.create();

        //_defaultCamera = new FlxCamera();
        //FlxG.cameras.reset(_defaultCamera);
        initTransIn();
    }

    function initTransIn():Void {
        if (!_transIn) return; 
        var _transCam:FlxCamera = new FlxCamera();
        _transCam.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(_transCam, false);
        
        var _tr_bg:FlxSprite = new FlxSprite(FlxG.width).loadGraphic(Assets.image("ui/transition"));
        _tr_bg.cameras = [_transCam];
        _tr_bg.screenCenter();
        add(_tr_bg);
        
        var _tr_text:FlxText = new FlxText(0,0,-1,_transText,30);
        _tr_text.setFormat(Assets.font("extenro-bold"), 18, 0xFFFFFFFF);
        _tr_text.screenCenter();
        _tr_text.cameras = [_transCam];
        add(_tr_text);

        FlxTween.tween(_tr_bg, {x: -(_tr_bg.width)}, 1, {ease:FlxEase.expoInOut});
        FlxTween.tween(_tr_text, {x: -(FlxG.width+((FlxG.width-_tr_text.width)*0.5))}, 1, {ease:FlxEase.expoInOut});
    }

    /**
     * Called when switching lt.states.
     * @param onOutroComplete
     */
    override function startOutro(onOutroComplete:() -> Void) {
        if (!_transOut) {
            onOutroComplete();
            return; 
        }
        var _transCam:FlxCamera = new FlxCamera();
        _transCam.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(_transCam, false);
        
        var _tr_bg:FlxSprite = new FlxSprite(FlxG.width).loadGraphic(Assets.image("ui/transition"));
        _tr_bg.cameras = [_transCam];
        add(_tr_bg);
        
        var _tr_text:FlxText = new FlxText(0,0,-1,_transText,30);
        _tr_text.setFormat(Assets.font("extenro-bold"), 18, 0xFFFFFFFF);
        _tr_text.x = (FlxG.width) + ((FlxG.width-_tr_text.width)*0.5);
        _tr_text.screenCenter(Y);
        _tr_text.cameras = [_transCam];
        add(_tr_text);

        FlxTween.tween(_tr_bg, {x: (FlxG.width-_tr_bg.width)*0.5}, 1, {ease:FlxEase.expoOut});
        FlxTween.tween(_tr_text, {x: (FlxG.width-_tr_text.width)*0.5}, 1, {ease:FlxEase.expoOut});
        FlxTimer.wait(1, ()->{
            onOutroComplete();
        });
    }
}