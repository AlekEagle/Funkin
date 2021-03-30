package;

import haxe.Json;

class MultiplayerSong {
  public var name: String;
  public var difficulty: Int;
  public var week: Int;

  public function new (song: Any) {
    if (Std.is(song, String)){
      var s = Json.parse(song);
      this.name = s.name;
      this.difficulty = s.difficulty;
      this.week = s.week;
    } else if (song != null) {
      this.name = (song : Dynamic).name;
      this.difficulty = (song : Dynamic).difficulty;
      this.week =  (song : Dynamic).week;
    }
  }

  public function toString(): String {
    return Json.stringify(this);
  }
}