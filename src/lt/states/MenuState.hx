package lt.states;

import lt.backend.Game;
import lt.macros.Github;
import lime.app.Application;
import lt.substates.SettingsSubstate;
import flixel.util.FlxTimer;
import flixel.graphics.FlxGraphic;
import lt.objects.menu.Profile;
import flixel.math.FlxMath;
import haxe.Constraints.Function;
import flixel.group.FlxGroup.FlxTypedGroup;

import flixel.group.FlxSpriteGroup;
import flixel.util.FlxGradient;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

/**
 * Main Menu of LineTapper.
 */
class MenuState extends State {
	var bg:FlxSprite;
	var boxBelow:Sprite;
	var logo:Sprite;

	var ind_top:Sprite;
	var ind_bot:Sprite;

	var user_profile:Profile;

	var particles:SpriteGroup;
	var menuGroup:FlxTypedGroup<FlxText>;
	var tri_top:Sprite; // Triangle Top
	var tri_bot:Sprite; // Triangle Bottom

	var curSelected:Int = 0;
	var options(get, never):Array<Dynamic>;
	var MENUGROUP_MEMBER_DISTANCE(default, null):Float = 150;
	function get_options():Array<Dynamic>{
		return [
			[PhraseManager.getPhrase("settings"), () -> openSubState(new SettingsSubstate())],
			[PhraseManager.getPhrase("play"), () -> Utils.switchState(new MenuDebugState(), PhraseManager.getPhrase("Song Select"))],
			[PhraseManager.getPhrase("edit"), () -> Utils.switchState(new LevelEditorState(), PhraseManager.getPhrase("Level Editor"))],
			[PhraseManager.getPhrase("credits"), () -> Utils.switchState(new CreditsState(), PhraseManager.getPhrase("Credits"))],
		];	
	} 
	var canInteract:Bool = false;
	var _scaleDiff:Float = 0;

	override function create() {
		_scaleDiff = 1 - IntroState._scaleDec;

		persistentUpdate = true;
		// Objects
		bg = cast FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [FlxColor.BLACK, FlxColor.WHITE], 1, 90, true);
		bg.alpha = 0;
		add(bg);

		particles = new SpriteGroup();
		add(particles);

		boxBelow = new Sprite().makeGraphic(Std.int(IntroState._boxSize * _scaleDiff), Std.int(IntroState._boxSize * _scaleDiff));
		boxBelow.screenCenter();
		add(boxBelow);

		menuGroup = new FlxTypedGroup<FlxText>();
		add(menuGroup);

		generateOptions();

		logo = new Sprite().loadGraphic(Assets.image("menu/logo"));
		logo.screenCenter(X);
		logo.y = 30;
		logo.scale.set(0.6, 0.6);
		logo.visible = false;
		add(logo);
		
		//user_profile = new Profile(0,FlxG.height-(Profile.size.height+20));
		//user_profile.x -= user_profile.nWidth + 10;
		//add(user_profile);

		var scaleXTarget:Float = (FlxG.width * 1) / boxBelow.width;
		var scaleYTarget:Float = (boxBelow.height - 30) / boxBelow.height;

		FlxTween.tween(boxBelow, {alpha: 0.3}, 1, {ease: FlxEase.expoInOut});
		FlxTween.tween(boxBelow.scale, {x: scaleXTarget, y: scaleYTarget}, 1, {
			ease: FlxEase.expoInOut,
			onComplete: (_) -> {
				trace("everything should work by now");
				startMenu();
			}
		});
		
		var localChanges:Bool = Github.getGitHasLocalChanges();
		var debugTXT:String = ' (DEBUG)\n${Github.getGitBranch()}/${Github.getGitCommitHash()}${localChanges ? ' (Modified)' : ''}';
		var versionText:Text = new Text(0,0,'v${Game.VERSION #if debug + debugTXT #end}', 14);
		versionText.setFont("musticapro");

		versionText.setPosition(10, FlxG.height - versionText.height - 10);
		versionText.alpha = 0.0;
		add(versionText);

		FlxTween.tween(versionText, {alpha: 1.0}, 1.0);

		super.create();
	}

	function generateOptions() {
		curSelected = 1;
		for (index => data in options) {
			var txt:FlxText = new FlxText(0, 0, -1, data[0].toUpperCase(), 8);
			txt.setFormat(Assets.font("extenro-bold"), 18, FlxColor.WHITE, CENTER);
			txt.x = ((FlxG.width - txt.width) * 0.5) + ((MENUGROUP_MEMBER_DISTANCE) * (curSelected - index));
			txt.alpha = 0;
			txt.active = false;
			txt.ID = index;
			menuGroup.add(txt);
		}

		tri_top = new Sprite().loadGraphic(Assets.image("ui/triangle"));
		tri_top.screenCenter(X);
		tri_top.y = boxBelow.y - (tri_top.height + 5);
		tri_top.flipY = true;
		add(tri_top);

		tri_bot = new Sprite().loadGraphic(Assets.image("ui/triangle"));
		tri_bot.screenCenter(X);
		tri_bot.y = boxBelow.y + boxBelow.height + 5;
		add(tri_bot);

		tri_bot.alpha = tri_top.alpha = 0;
	}

	function startMenu() {
		var logo_yDec:Float = 50;

		logo.y -= logo_yDec;
		FlxFlicker.flicker(logo, 0.5, 0.02, true);
		FlxTween.tween(logo, {y: logo.y + logo_yDec}, 0.5, {
			ease: FlxEase.expoInOut,
			onComplete: (_) -> {
				canInteract = true;
				for (obj in [tri_bot, tri_top]) {
					FlxTween.tween(obj, {alpha: 1}, 1, {ease: FlxEase.expoOut});
				}
				//FlxTimer.wait(0.5, ()->{
				///	FlxTween.tween(user_profile,{x: 20},1, {ease: FlxEase.expoOut});
				//});

			}
		});
	}

	var confirmed:Bool = false;

	override function update(elapsed:Float) {
		if (FlxG.keys.justPressed.SPACE && subState == null) {
			FlxG.resetState();
		}

		if (!confirmed && subState == null) {
			if (FlxG.keys.justPressed.ENTER) {
				if (options[curSelected][0] != "settings") {
					confirmed = true;
					FlxG.sound.play(Assets.sound("menu/select"));
					for (obj in menuGroup.members) {
						if (curSelected == obj.ID) {
							FlxTween.tween(boxBelow.scale,{x: (obj.width+20*2) / (Std.int(IntroState._boxSize * _scaleDiff))},1,{ease:FlxEase.expoOut});
							FlxFlicker.flicker(obj,1, 0.04,false,true,(_)->{
								options[curSelected][1]();   
							});
						} else {
							FlxTween.tween(obj, {alpha:0}, 1);
						}
					}
				} else {
					options[curSelected][1](); 
				}
			}

			if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT) {
				FlxG.sound.play(Assets.sound("menu/press"));
				tri_top.y -= 10; // stupid
				tri_bot.y += 10;
				curSelected = FlxMath.wrap(curSelected + (FlxG.keys.justPressed.LEFT ? 1 : -1), 0, options.length - 1);
			}
		}

		menuUpdate(elapsed);
		super.update(elapsed);
	}

	var _timePassed:Float = 0;
	var _timeTracked:Float = 0;

	var _cachedGraphic:FlxGraphic = null;
	function menuUpdate(elapsed:Float) {
		if (!canInteract)
			return;

		_timePassed += elapsed;
		bg.alpha = (Math.sin(_timePassed) * 0.1);

		if (_timePassed - _timeTracked > FlxG.random.float(0.4, 1.3)) {
			_timeTracked = _timePassed;
			var s:Sprite = new Sprite(FlxG.random.float(0, FlxG.width), FlxG.height + FlxG.random.float(30, 50));
			if (_cachedGraphic == null) {
				s.makeGraphic(10, 10);
				_cachedGraphic = s.graphic;
			} else {
				s.loadGraphic(_cachedGraphic);
			}
			var scaling:Float = FlxG.random.float(0.1, 1.2);
			s.active = false;
			s.scale.set(scaling, scaling);
			particles.add(s);
		}

		particles.forEachAlive((spr:Sprite) -> {
			spr.y -= (100 * spr.scale.x) * elapsed;
			spr.angle += (150 * spr.scale.x) * elapsed;
			if (spr.y < -20) {
				spr.destroy();
				remove(spr);
			}
		});

		// Menu Texts
		var lerpFactor:Float = 1 - (elapsed * 12);
		for (obj in menuGroup.members) {
			var diff:Int = curSelected - obj.ID;
			obj.screenCenter(Y);

			obj.x = FlxMath.lerp(((FlxG.width - obj.width) * 0.5) + ((MENUGROUP_MEMBER_DISTANCE) * diff), obj.x, lerpFactor);
			if (!confirmed) obj.alpha = FlxMath.lerp(curSelected == obj.ID ? 1 : 0.4, obj.alpha, lerpFactor);
			obj.scale.x = obj.scale.y = FlxMath.lerp(curSelected == obj.ID ? 1 : 0.7, obj.scale.x, lerpFactor);
		}

		// Menu Triangles
		tri_top.y = FlxMath.lerp(boxBelow.y - (tri_top.height + 5), tri_top.y, lerpFactor);
		tri_bot.y = FlxMath.lerp(boxBelow.y + boxBelow.height + 5, tri_bot.y, lerpFactor);
	}
}
