package lt.states;

import sys.FileSystem;

class SongSelectState extends State {
	var topText:FlxText;
	var topText_phrase:String = 'SELECT A SONG';

	var centerDoubleLeftText:FlxText;
	var centerLeftText:FlxText;
	var centerText:FlxText;
	var centerRightText:FlxText;
	var centerDoubleRightText:FlxText;

	var bottomText:FlxText;
	var bottomText_phrase:String = 'INVALID SONG';

	var songDoubleLeft:String = '';
	var songLeft:String = '';
	var song:String = 'Tutorial';
	var songRight:String = '';
	var songDoubleRight:String = '';
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

		centerDoubleLeftText = new FlxText(20, 180, -1, songDoubleLeft, 20);
		centerDoubleLeftText.setFormat(Assets.font('extenro-extrabold'), 22, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(centerDoubleLeftText);
		centerDoubleLeftText.alpha = 0.25;

		centerDoubleRightText = new FlxText(20, 180, -1, songDoubleRight, 20);
		centerDoubleRightText.setFormat(Assets.font('extenro-extrabold'), 22, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(centerDoubleRightText);
		centerDoubleRightText.alpha = 0.25;

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
				FlxG.sound.play(Assets.sound("menu/select"));
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

		var songlistlen = songList.length - 1;
		if (songIndex < 0) {
			songIndex = 0;
			FlxG.sound.play(Assets.sound("menu/key_cancel"));
		} else if (songIndex >= songlistlen) {
			songIndex = songlistlen;
			FlxG.sound.play(Assets.sound("menu/key_cancel"));
		} else {
			FlxG.sound.play(Assets.sound("menu/press"));
		}

		song = songList[songIndex];
		songLeft = '';
		songRight = '';
		songDoubleLeft = '';
		songDoubleRight = '';
		if (songIndex - 1 >= 0)
			songLeft = songList[songIndex - 1];
		if (songIndex + 1 <= songlistlen)
			songRight = songList[songIndex + 1];
		if (songIndex - 2 >= 0)
			songDoubleLeft = songList[songIndex - 2];
		if (songIndex + 2 <= songlistlen)
			songDoubleRight = songList[songIndex + 2];

		songSelectionTransition(0);
	}

	function songSelectionTransition(increment:Int = 0) {
		if (increment == 0) {
			songSelectionTransitionFinished();
			return;
		}

		var positions = {
			centerText: centerText.getPosition(),
			centerLeftText: centerLeftText.getPosition(),
			centerDoubleLeftText: centerDoubleLeftText.getPosition(),
			centerRightText: centerRightText.getPosition(),
			centerDoubleRightText: centerDoubleRightText.getPosition(),
		}
		var opacities = {
			centerText: centerText.alpha,
			centerLeftText: centerLeftText.alpha,
			centerDoubleLeftText: centerDoubleLeftText.alpha,
			centerRightText: centerRightText.alpha,
			centerDoubleRightText: centerDoubleRightText.alpha,
		}

		// ! SEVERE WORK IN PROGRESS ! \\
		if (increment < 0) {
			FlxTween.tween(centerDoubleLeftText, {x: positions.centerLeftText.x, alpha: opacities.centerLeftText}, 1);
			FlxTween.tween(centerLeftText, {x: positions.centerText.x, alpha: opacities.centerText}, 1);
			FlxTween.tween(centerText, {x: positions.centerRightText.x, alpha: opacities.centerRightText}, 1);
			FlxTween.tween(centerRightText, {x: positions.centerDoubleRightText.x, alpha: opacities.centerDoubleRightText}, 1);
			centerDoubleRightText.alpha = 0;
			centerDoubleRightText.x = positions.centerDoubleLeftText.x - centerDoubleLeftText.width - centerDoubleRightText.width;
			centerDoubleRightText.text = songDoubleLeft;
			FlxTween.tween(centerDoubleRightText, {x: positions.centerDoubleLeftText.x, alpha: opacities.centerDoubleLeftText}, 1, {
				onComplete: tween -> {
					songSelectionTransitionFinished();
				}
			});
		} else {
			centerDoubleLeftText.alpha = 0;
			centerDoubleLeftText.x = positions.centerDoubleRightText.x - centerDoubleRightText.width - centerDoubleLeftText.width;
			centerDoubleLeftText.text = songDoubleLeft;
			FlxTween.tween(centerDoubleLeftText, {x: positions.centerDoubleRightText.x, alpha: opacities.centerDoubleRightText}, 1, {
				onComplete: tween -> {
					songSelectionTransitionFinished();
				}
			});
			FlxTween.tween(centerLeftText, {x: positions.centerDoubleLeftText.x, alpha: opacities.centerDoubleLeftText}, 1);
			FlxTween.tween(centerText, {x: positions.centerLeftText.x, alpha: opacities.centerLeftText}, 1);
			FlxTween.tween(centerRightText, {x: positions.centerText.x, alpha: opacities.centerText}, 1);

			FlxTween.tween(centerDoubleRightText, {x: positions.centerRightText.x, alpha: opacities.centerRightText}, 1);
		}
	}

	function songSelectionTransitionFinished() {
		centerText.text = song.toLowerCase();
		centerText.screenCenter();

		centerLeftText.text = songLeft.toLowerCase();
		centerLeftText.screenCenter();
		centerLeftText.x -= centerText.width + centerLeftText.width;

		centerRightText.text = songRight.toLowerCase();
		centerRightText.screenCenter();
		centerRightText.x += centerText.width + centerRightText.width;

		centerDoubleLeftText.text = songDoubleLeft.toLowerCase();
		centerDoubleLeftText.screenCenter();
		centerDoubleLeftText.x = centerLeftText.x - centerLeftText.width - centerDoubleLeftText.width;

		centerDoubleRightText.text = songDoubleRight.toLowerCase();
		centerDoubleRightText.screenCenter();
		centerDoubleRightText.x = centerRightText.x + centerRightText.width + centerDoubleRightText.width;

		centerText.alpha = 1.0;
		centerLeftText.alpha = 0.5;
		centerRightText.alpha = 0.5;
		centerDoubleLeftText.alpha = 0.25;
		centerDoubleRightText.alpha = 0.25;
	}
}
