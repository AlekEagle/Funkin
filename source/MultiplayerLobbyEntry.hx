package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;

class MultiplayerLobbyEntry {
  private var i: Int;

  public var player: Null<Player>;
  private var nameText: FlxText = new FlxText();
  private var readyText: FlxText = new FlxText();
  private var icon: FlxSprite = new FlxSprite();

  public function new(i: Int, plyr: Null<Player>, ctx: MusicBeatState) {
    this.readyText.size = 36;
    this.nameText.size = 36;
    this.player = plyr;
    this.i = i;
    this.icon.loadGraphic(Paths.image('iconGrid'), true, 150, 150);
    this.icon.animation.add('face', [10, 11], 0, false, false);
    this.icon.animation.play('face');
    if (this.player == null) this.icon.animation.curAnim.curFrame = 1;
    this.icon.x = (this.i*300) + 100;
    this.icon.y = FlxG.height/2 - 200;
    this.nameText.x = (this.i*300) + 100;
    this.nameText.y = FlxG.height/2 - 100;
    this.nameText.text = this.player != null ? this.player.name : "No one";
    this.readyText.x = (this.i*300) + 100;
    this.readyText.y = FlxG.height/2 - 50;
    if (this.player != null) {
      this.readyText.text = this.player.state.getParameters()[0] ? "Ready" : "Not Ready";
    }
    ctx.add(this.nameText);
    ctx.add(this.readyText);
    ctx.add(this.icon);
  }

  public function setPlayer(plyr: Player) {
    this.player = plyr;
    this.icon.loadGraphic(Paths.image('iconGrid'), true, 150, 150);
    this.icon.animation.add('face', [10, 11], 0, false, false);
    this.icon.animation.play('face');
    if (this.player == null) this.icon.animation.curAnim.curFrame = 1;
    this.icon.x = (this.i*300) + 100;
    this.icon.y = FlxG.height/2 - 200;
    this.nameText.x = (this.i*300) + 100;
    this.nameText.y = FlxG.height/2 - 100;
    this.nameText.text = this.player != null ? this.player.name : "No one";
    this.readyText.x = (this.i*300) + 100;
    this.readyText.y = FlxG.height/2 - 50;
    if (this.player != null) {
      this.readyText.text = this.player.state.getParameters()[0] ? "Ready" : "Not Ready";
    }else this.readyText.text = "";
  }
}