package;

#if desktop
import Discord.DiscordClient;
#end
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

class MultiplayerLobby extends MusicBeatState {
  var movedBack:Bool = false;

  var menuText:Array<FlxText> = new Array<FlxText>();

  var menuBG:FlxSprite;

  var selection:Int = 0;

  var selected:Bool = false;

  var mpClient: MultiplayerClient;

  override function create() {
    menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
    transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}
		
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In a lobby", null);
		#end

    

    super.create();
  }

  override function update(elapsed:Float) {

    if (controls.ACCEPT && !selected) {
      FlxG.sound.play(Paths.sound('confirmMenu'));
      selected = true;
    }


    if (controls.BACK && !movedBack)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new MultiplayerMenu());
		}

    super.update(elapsed);
  }
}