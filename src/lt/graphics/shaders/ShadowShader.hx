package lt.graphics.shaders;

import flixel.addons.display.FlxRuntimeShader;

class ShadowShader extends FlxRuntimeShader {
    
    public function new() {
        super(Assets.frag('dropShadow'));
        setFloat('alpha', 0.7);
        setFloat('offsetX', 50);
        setFloat('offsetY', 50);
    }

    //function set_borderWidth(value:Float):Float {
    //    setFloat('borderWidth', borderWidth = value);
    //    return borderWidth;
    //}
}
