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
import flixel.addons.ui.FlxInputText;
import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

class MultiplayerMenu extends MusicBeatState
{
  var movedBack:Bool = false;

  var menuText:Array<FlxText> = new Array<FlxText>();

  var menuBG:FlxSprite;

  var selection:Int = 0;

  var selected:Bool = false;

  var name:FlxInputText;

  override function create() {
    Storage.init();
    Storage.write();
    FlxG.mouse.visible = true;
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
		DiscordClient.changePresence("Thinking about playing with friends", null);
		#end

    menuText.push(new FlxText(menuBG.width / 2, menuBG.height / 2, 0, "Join Game", 64));
    menuText.push(new FlxText(menuBG.width / 2, menuBG.height / 2, 0, "Create Game", 64));

    for (i in 0...menuText.length) {
      add(menuText[i]);
    }
    
    name = new FlxInputText(menuBG.width / 2 - 500/1.75, 25, 500, "You're name", 64);
    name.text = Storage.get("name");
    name.callback = function (s1, s2) {
      Storage.set('name', s1);
    }
    add(name);

    super.create();
  }

  override function update(elapsed:Float) {

    if (controls.UP_P && !selected && !name.hasFocus) {
      if (++selection > menuText.length - 1) selection = 0;
    }

    if (controls.DOWN_P && !selected && !name.hasFocus) {
      if (--selection < 0) selection = menuText.length - 1;
    }

    if (controls.ACCEPT && !selected) {
      FlxG.mouse.visible = false;
      FlxG.sound.play(Paths.sound('confirmMenu'));
      selected = true;
      switch(selection) {
        case 0:
          Storage.write();
          FlxG.switchState(new MultiplayerLobby());
      }
    }
    
    for (i in 0...menuText.length) {
      menuText[i].x = menuBG.width / 2 - menuText[i].width + 10;
      menuText[i].y = menuBG.height / 2 - menuText[i].height - 200 + (menuText[i].height * (i+1)) + 5;
      if (i != selection) {
        menuText[i].color = new FlxColor(0xff8888);
      }else {
        if (!selected) menuText[i].color = FlxColor.WHITE;
        else menuText[i].color = FlxColor.RED;
      }
    }


    if (controls.BACK && !movedBack)
		{
      Storage.write();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}

    super.update(elapsed);
  }
}