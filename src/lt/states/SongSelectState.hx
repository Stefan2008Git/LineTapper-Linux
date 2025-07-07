package lt.states;

import sys.FileSystem;

class SongSelectState extends State {
	var topText:FlxText;
	var topText_phrase:String = 'SELECT A SONG';

	var centerText:FlxText;

	var bottomText:FlxText;
	var bottomText_phrase:String = 'INVALID SONG';

	var song:String = 'Tutorial';
	var songList:Array<String> = ['Tutorial'];
	var songIndex:Int = 0;

	override function create() {
		super.create();

		topText = new FlxText(20, 180, -1, PhraseManager.getPhrase(topText_phrase, topText_phrase), 20);
		topText.setFormat(Assets.font('extenro-extrabold'), 22, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		topText.screenCenter(X);
		add(topText);

		centerText = new FlxText(20, 180, -1, song, 20);
		centerText.setFormat(Assets.font('extenro-extrabold'), 22, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(centerText);

		bottomText = new FlxText(20, FlxG.height - 180, -1, PhraseManager.getPhrase(bottomText_phrase, bottomText_phrase), 20);
		bottomText.setFormat(Assets.font('extenro-extrabold'), 22, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		bottomText.color = FlxColor.RED;
		bottomText.screenCenter(X);
		bottomText.visible = false;
		add(bottomText);

		songList = FileSystem.readDirectory('assets/data/maps');

		if (songList.length < 1) {
			songList = ['Tutorial'];
		}
		trace(songList);

		songIndex = songList.indexOf('Tutorial');
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		song = songList[songIndex];
		centerText.text = song.toLowerCase();
		centerText.screenCenter();

		if (FlxG.keys.justReleased.LEFT)
			incrementSongIndex(-1);
		if (FlxG.keys.justReleased.RIGHT)
			incrementSongIndex(1);

		if (FlxG.keys.justPressed.ENTER) {
			if (song.length > 0 && FileSystem.exists('${Assets._MAP_PATH}/$song')) {
				Utils.switchState(() -> new PlayState(song.trim()), PhraseManager.getPhrase("Gameplay"));
				FlxG.sound.play(Assets.sound("menu/press"));
			} else {
				FlxFlicker.flicker(bottomText, 1, 0.02, false);
				FlxG.sound.play(Assets.sound("menu/key_cancel"));
				new FlxTimer().start(1, function(tmr:FlxTimer) {
					bottomText.color = FlxColor.WHITE;
					bottomText.visible = false;
				});
			}
		}
	}

	function incrementSongIndex(increment:Int = 0) {
		songIndex += increment;

		if (songIndex < 0)
			songIndex = 0;

		if (songIndex >= songList.length - 1)
			songIndex = songList.length - 1;
	}
}
