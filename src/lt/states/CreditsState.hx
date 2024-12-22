package lt.states;

import flixel.util.FlxGradient;
import flixel.group.FlxGroup.FlxTypedGroup;

class CreditsState extends State
{
	public var creditsFile(get, null):Array<String>;
    
    function get_creditsFile():Array<String> {
		var credits:Array<String> = [];

        try{
			credits = openfl.Assets.getText('${Assets._DATA_PATH.replace('./', '')}/credits.txt').split('\n');
        } catch(e) {
            trace(e.message);

            credits = [
                'LT Team',
                'Core5570R - Programming'
            ];
        }

        return credits;
    }

	public var textGrp:FlxTypedGroup<Text>;

	var bg:FlxSprite;
	override function create() {
		bg = cast FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [FlxColor.BLACK, FlxColor.WHITE], 1, 90, true);
		bg.alpha = 0;
		add(bg);

		textGrp = new FlxTypedGroup<Text>();
		add(textGrp);

        var index:Int = 0;
        for (item in creditsFile)
        {
            var newtext:Text = new Text(10, 10 + (index * 30), item);
			newtext.y -= creditsFile.length * 30;
			newtext.ID = index;
            textGrp.add(newtext);

			index++;
        }
        
		super.create();
	}

    override function update(elapsed:Float) {
        super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE) {
			Utils.switchState(new MenuState(), "Main Menu");
		}

		for (item in textGrp) {
			item.y -= TEXTGRP_ITEM_MOVESPEED;

			if (item.y < (0 - creditsFile.length * 30))
				item.y = FlxG.height + creditsFile.length * 21;
		}
    }

	var TEXTGRP_ITEM_MOVESPEED:Float = 1.0;
}