package;

import haxe.DynamicAccess;
#if js // jayess
import js.html.DOMError;
import js.Browser;
#elseif sys // hot sissy trap
import sys.io.File;
import Sys;
#end
import haxe.Json;
import haxe.ds.StringMap;

class Storage {
  #if neko // windoes
    static var userVar = "UserProfile";
    static var dataPath = "\\AppData\\Roaming\\FridayNightFunkin";
  #else // unicks
    static var userVar = "HOME";
    static var dataPath = "/.local/share/FridayNightFunkin";
  #end

  static var store:StringMap<String> = new StringMap<String>();
  static var initialized = false;

  static public function init() {
    #if js
      var storage = Browser.getLocalStorage();

      var settings = storage.getItem("gameSettings");
      if (settings == null) {
        storage.setItem("gameSettings", "{\"name\":\"You're Name\"}");
        settings = "{\"name\":\"You're Name\"}";
      }

      var json:DynamicAccess<Dynamic> = Json.parse(settings);
      for (key => value in json) {
        store.set(key, value);
      }

    #elseif sys
      trace("bru");
    #else
      throw "i was not written for thisd paltform";
    #end

    initialized = true;
    return;
  }

  inline static public function set(key: String, value: String) {
    if (initialized == false) throw "dumb";
    store.set(key, value);
  }

  inline static public function get(key: String): String {
    if (initialized == false) throw "dumb";
    return store.get(key);
  }

  inline static public function delete(key: String) {
    if (initialized == false) throw "dumb";
    store.remove(key);
  }

  inline static public function setAndWrite(key: String, value: String) {
    set(key, value);
    write();
  }

  inline static public function deleteAndWrite(key: String) {
    delete(key);
    write();
  }

  // writes cock data to disk or local storgrsa
  inline static public function write() {
    var data = Json.stringify(Json.parse(Json.stringify(store)).h);
    #if js
      var storage = Browser.getLocalStorage();
      storage.setItem("gameSettings", data);
    #elseif sys
      var userProfile = Sys.environment().get(userVar);
      File.write('$userProfile$dataPath')
        .write(data);
    #else
      throw "wow dumby";
    #end
  }
}
