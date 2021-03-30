package;

import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

class MultiplayerFinishScreen extends MusicBeatState
{
	var movedBack:Bool = false;
	var menuBG:FlxSprite;
	var players:Array<Player> = new Array();
	var firstBF:Boyfriend;
	var secondBF:Boyfriend;
	var thirdBF:Boyfriend;
	var firstScore:FlxText;
	var secondScore:FlxText;
	var thirdScore:FlxText;

	public override function create()
	{
		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		menuBG = new FlxSprite().loadGraphic(Paths.image('podiums'));
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		firstBF = new Boyfriend(445, 25, 'bf');
		firstBF.setGraphicSize(Std.int(firstBF.width * 0.45));
		firstScore = new FlxText(465, 35, 0, "", 32);
		secondBF = new Boyfriend(25, 150, 'bf');
		secondBF.setGraphicSize(Std.int(secondBF.width * 0.45));
		secondScore = new FlxText(45, 140, 0, "", 32);
		thirdBF = new Boyfriend(850, 230, 'bf');
		thirdBF.setGraphicSize(Std.int(thirdBF.width * 0.45));
		thirdScore = new FlxText(870, 220, 0, "", 32);

		menuBG.setGraphicSize(Std.int(menuBG.width * 1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		add(firstBF);
		add(secondBF);
		add(thirdBF);

		add(firstScore);
		add(secondScore);
		add(thirdScore);

		firstBF.playAnim('hey');
		secondBF.playAnim('scared');
		secondBF.animation.pause();
		secondBF.animation.curAnim.curFrame = secondBF.animation.curAnim.numFrames - 1;
		thirdBF.playAnim('singUPmiss');
		thirdBF.animation.pause();
		thirdBF.animation.curAnim.curFrame = thirdBF.animation.curAnim.numFrames - 1;

		for (key => value in MPClientStore.client.users)
		{
			players.push(value);
		}

		players.sort(function(a, b)
		{
			return a.score - b.score;
		});

		players.reverse();

		firstScore.text = '${players[0].name}\nScore: ${players[0].score}';
		secondScore.text = '${players[1].name}\nScore: ${players[1].score}';
		thirdScore.text = players.length > 2 ? '${players[2].name}\nScore: ${players[2].score}' : 'Your Dog\nScore: -21';
	}

	public override function update(elapsed)
	{
		if ((controls.BACK || controls.ACCEPT) && !movedBack)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			MPClientStore.client.close();
			MPClientStore.client = null;
			FlxG.switchState(new MultiplayerMenu());
		}

		super.update(elapsed);
	}
}
