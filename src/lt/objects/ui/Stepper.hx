package lt.objects.ui;

class Stepper extends Button {
    public var stepLabel:Text;

    public var value(default,set):Float = 0;
    function set_value(val:Float):Float {
        val = FlxMath.bound(val, min, max);
        skipCheck = true;
        input.text = '$val';
        skipCheck = false;
        return value = val;
    }

    public var min:Float = 0;
    public var max:Float = 1;
    public var step:Float = 0.1;
    public var onChange:Float -> Void;
    public var input:InputBox;
    public var rightButton:Button;
    public function new(nX:Float, nY:Float, nWidth:Float, text:String, value:Float, min:Float, max:Float, step:Float, ?onChange:Float->Void) {
        super(nX,nY,20, '<', (_)->{
            changeNumber(-step);
        });
        this.min = min;
        this.max = max;
        this.step = step;
        if (onChange != null)
            this.onChange = onChange;

        input = new InputBox(0,0,nWidth-40,'$value');
        input.onTextChange.add(updateText);
        input.filterMode = CHARS('0123456789.');
        rightButton = new Button(0,0,20,">",(_)->{
            changeNumber(step);
        });
        stepLabel = new Text(0,0,text,13, CENTER);
        stepLabel.applyUIFont();
        this.value = value;
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        input.update(elapsed);
    }

    var skipCheck:Bool = false;
    function updateText(text:String, _) {
        if (skipCheck) return;
        value = Std.parseFloat(text);
        if (Math.isNaN(value))
            value = min;
    }
    
    function changeNumber(add:Float = 0) {
        value += add;
    }

    override function draw() {
        super.draw();
        for (i in [stepLabel, input, rightButton]) 
            if (i != null) i.cameras = cameras;
        stepLabel.setPosition(
            x,
            y - 20
        );
        stepLabel.draw();
        input.setPosition(
            x + width,
            y + (height - input.height) * 0.5
        );
        input.draw();

        rightButton.setPosition(
            input.x + input.width,
            y + (height - rightButton.height) * 0.5
        );
        rightButton.draw();
    }
}