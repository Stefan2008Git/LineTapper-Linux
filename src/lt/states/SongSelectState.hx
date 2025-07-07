package lt.states;

class SongSelectState extends State {
	var topText:FlxText;
        var topText_phrase:String = 'SELECT A SONG';

	override function create() {
		super.create();

		topText = new FlxText(20, 180, -1, PhraseManager.getPhrase(topText_phrase, topText_phrase), 20);
		topText.setFormat(Assets.font("extenro-extrabold"), 22, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		topText.screenCenter(X);
		add(topText);
	}
}
