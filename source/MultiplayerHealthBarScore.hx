package;

import Song;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;

class MultiplayerHealthBarScore
{
	private var health:Float;
	private var index:Int;
	private var SONG:SwagSong;
	private var barBG:FlxSprite;
	private var bar:FlxBar;
	private var player:Player;
	private var iconP1:FlxSprite;
	private var iconP2:FlxSprite;
	private var scoreTxt:FlxText;

	public function new(i:Int, player:Player, ctx:MusicBeatState, song:SwagSong, cams:Array<FlxCamera>)
	{
		this.player = player;
		this.barBG = new FlxSprite(5, FlxG.height * (0.2 + (i / 10))).loadGraphic(Paths.image('healthBar'));
		this.bar = new FlxBar(this.barBG.x + 4, this.barBG.y + 4, RIGHT_TO_LEFT, Std.int(this.barBG.width - 8), Std.int(this.barBG.height - 8), this,
			'health', 0, 2);
		this.health = this.player.health;
		this.SONG = song;
		this.barBG.scrollFactor.set();
		this.bar.scrollFactor.set();
		this.bar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		this.scoreTxt = new FlxText(this.barBG.x + this.barBG.width - 190, this.barBG.y + 30, 0, "", 20);
		this.scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
		this.scoreTxt.scrollFactor.set();
		this.iconP1 = new HealthIcon('face', true);
		this.iconP1.y = this.bar.y - (this.iconP1.height / 2);
		this.iconP2 = new HealthIcon(this.SONG.player2, false);
		this.iconP2.y = this.bar.y - (this.iconP2.height / 2);
		ctx.add(this.barBG);
		ctx.add(this.bar);
		ctx.add(this.scoreTxt);
		ctx.add(this.iconP1);
		ctx.add(this.iconP2);
		this.barBG.cameras = cams;
		this.bar.cameras = cams;
		this.scoreTxt.cameras = cams;
		this.iconP1.cameras = cams;
		this.iconP2.cameras = cams;
	}

	public function update(player:Player)
	{
		this.player = player;
		this.health = this.player.health;
		this.scoreTxt.text = '${this.player.name}\'s Score:${this.player.score}';

		this.iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, this.iconP1.width, 0.50)));
		this.iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, this.iconP2.width, 0.50)));

		this.iconP1.updateHitbox();
		this.iconP2.updateHitbox();

		var iconOffset:Int = 26;

		this.iconP1.x = this.bar.x + (this.bar.width * (FlxMath.remapToRange(this.bar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		this.iconP2.x = this.bar.x + (this.bar.width * (FlxMath.remapToRange(this.bar.percent, 0, 100, 100, 0) * 0.01)) - (this.iconP2.width - iconOffset);

		if (this.bar.percent < 20)
			this.iconP1.animation.curAnim.curFrame = 1;
		else
			this.iconP1.animation.curAnim.curFrame = 0;

		if (this.bar.percent > 80)
			this.iconP2.animation.curAnim.curFrame = 1;
		else
			this.iconP2.animation.curAnim.curFrame = 0;
	}

	public function beatHit()
	{
		this.iconP1.setGraphicSize(Std.int(this.iconP1.width + 30));
		this.iconP2.setGraphicSize(Std.int(this.iconP2.width + 30));

		this.iconP1.updateHitbox();
		this.iconP2.updateHitbox();
	}
}
