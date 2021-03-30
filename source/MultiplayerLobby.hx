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

class MultiplayerLobby extends MusicBeatState
{
	var movedBack:Bool = false;

	var plyrs:Array<MultiplayerLobbyEntry> = new Array<MultiplayerLobbyEntry>();

	var menuBG:FlxSprite;

	var selection:Int = 0;

	var selected:Bool = false;

	var songTitle:FlxText;

	override function create()
	{
		Storage.init();
		var alreadyConnected = true;
		if (MPClientStore.client == null)
		{
			alreadyConnected = false;
			MPClientStore.client = new MultiplayerClient(Storage.get("address"), Storage.get("name"));
		}
		menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		songTitle = new FlxText(8, FlxG.height - 48, 0, "Selected Song: None", 36);

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		if (FlxG.sound.music != null)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		for (i in 0...4)
		{
			plyrs.push(new MultiplayerLobbyEntry(i, null, this));
		}

		if (alreadyConnected)
		{
			var a = MPClientStore.client.users.keyValueIterator();
			for (i in 0...4)
			{
				if (a.hasNext())
					plyrs[i].setPlayer(a.next().value);
				else
					plyrs[i].setPlayer(null);
			}
		}

		MPClientStore.client.onGameStart = function()
		{
			var poop:String = Highscore.formatSong(MPClientStore.client.song.name, MPClientStore.client.song.difficulty);

			MultiplayerPlayState.SONG = Song.loadFromJson(poop, MPClientStore.client.song.name);
			MultiplayerPlayState.isStoryMode = false;
			MultiplayerPlayState.storyDifficulty = MPClientStore.client.song.difficulty;

			MultiplayerPlayState.storyWeek = MPClientStore.client.song.week;
			MultiplayerLoadingState.loadAndSwitchState(new MultiplayerPlayState());
		}

		add(songTitle);

		MPClientStore.client.onConnect = function(players)
		{
			var a = players.keyValueIterator();
			for (i in 0...4)
			{
				if (a.hasNext())
					plyrs[i].setPlayer(a.next().value);
				else
					plyrs[i].setPlayer(null);
			}
		}

		MPClientStore.client.onUserUpdate = function(players, song)
		{
			var a = players.keyValueIterator();
			for (i in 0...4)
			{
				if (a.hasNext())
					plyrs[i].setPlayer(a.next().value);
				else
					plyrs[i].setPlayer(null);
			}
			if (song != null)
			{
				if (song.name == null)
					return;
				var diffStr = "";
				switch (song.difficulty)
				{
					case 0:
						diffStr = "EASY";
					case 1:
						diffStr = "NORMAL";
					case 2:
						diffStr = "HARD";
				}
				songTitle.text = 'Selected Song: ${song.name.split("-").join(" ")} $diffStr';
			}
		}
		super.create();
	}

	override function update(elapsed:Float)
	{
		#if sys
		MPClientStore.client.process();
		#end

		if (controls.ACCEPT && !selected)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			if (MPClientStore.client.owner && !MPClientStore.client.users.get(MPClientStore.client.me).state.getParameters()[0])
			{
				MPClientStore.client.onUserUpdate = function(player, songelapsed)
				{
				}
				FlxG.switchState(new MultiplayerMusicMenu());
			}
			else
				MPClientStore.client.setReady();
		}

		if (controls.BACK && !movedBack)
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
