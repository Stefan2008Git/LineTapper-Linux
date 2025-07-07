package lt.states;

import sys.FileSystem;

class SongSelectState extends State {
	var topText:FlxText;
	var topText_phrase:String = 'SELECT A SONG';

	var centerLeftText:FlxText;
	var centerText:FlxText;
	var centerRightText:FlxText;

	var bottomText:FlxText;
	var bottomText_phrase:String = 'INVALID SONG';

	var songLeft:String = '';
	var song:String = 'Tutorial';
	var songRight:String = '';
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

		centerLeftText = new FlxText(20, 180, -1, songLeft, 20);
		centerLeftText.setFormat(Assets.font('extenro-extrabold'), 22, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(centerLeftText);
		centerLeftText.alpha = 0.5;

		centerRightText = new FlxText(20, 180, -1, songRight, 20);
		centerRightText.setFormat(Assets.font('extenro-extrabold'), 22, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(centerRightText);
		centerRightText.alpha = 0.5;

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

		incrementSongIndex();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

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

		song = songList[songIndex];
		songLeft = '';
		songRight = '';
		if (songIndex - 1 >= 0)
			songLeft = songList[songIndex - 1];
		if (songIndex + 1 <= songList.length - 1)
			songRight = songList[songIndex + 1];

		songSelectionTransition();
	}

	function songSelectionTransition() {
		centerText.text = song.toLowerCase();
		centerLeftText.text = songLeft.toLowerCase();
		centerRightText.text = songRight.toLowerCase();
		centerText.screenCenter();
		centerLeftText.screenCenter();
		centerRightText.screenCenter();
		centerLeftText.x -= centerText.width + centerLeftText.width;
		centerRightText.x += centerText.width + centerRightText.width;
	}
}
