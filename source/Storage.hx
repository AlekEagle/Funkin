package;

import haxe.DynamicAccess;
#if js // jayess
import js.html.DOMError;
import js.Browser;
#elseif sys // hot sissy trap
import sys.FileSystem;
import sys.io.File;
import Sys;
#end
import haxe.Json;
import haxe.ds.StringMap;
import haxe.io.Bytes;

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
    if (initialized) return;
    #if js
      var storage = Browser.getLocalStorage();

      var settings = storage.getItem("gameSettings");
      if (settings == null) {
        storage.setItem("gameSettings", "{}");
        settings = "{}";
      }

      var json:DynamicAccess<Dynamic> = Json.parse(settings);
      for (key => value in json) {
        store.set(key, value);
      }

    #elseif sys
      var userProfile = Sys.environment().get(userVar);
      if (!FileSystem.exists('$userProfile$dataPath')) FileSystem.createDirectory('$userProfile$dataPath');
      if (FileSystem.exists('$userProfile$dataPath') && FileSystem.isDirectory('$userProfile$dataPath') && FileSystem.exists('$userProfile$dataPath/settings.json')) {
        var file = File.read('$userProfile$dataPath/settings.json');
        var data = file.readAll();
        var json:DynamicAccess<Dynamic> = Json.parse(data.getString(0, data.length));
        file.close();
        for (key => value in json) {
          store.set(key, value);
        }
      }else {
        if (FileSystem.exists('$userProfile$dataPath') && !FileSystem.isDirectory('$userProfile$dataPath')) {
          FileSystem.deleteFile('$userProfile$dataPath');
          FileSystem.createDirectory('$userProfile$dataPath');
        }
        File.write('$userProfile$dataPath/settings.json')
          .write(Bytes.ofString("{}"));
        var json:DynamicAccess<Dynamic> = Json.parse("{}");
        for (key => value in json) {
          store.set(key, value);
        }
      }
    #else
      throw "i was not written for thisd paltform";
    #end

    initialized = true;
    return;
  }

  inline static public function set(key: String, value: String): String {
    if (!initialized) throw "dumb";
    store.set(key, value);
    return value;
  }

  inline static public function get(key: String, ?def: String = ""): String {
    if (!initialized) throw "dumb";
    if (store.exists(key)) return store.get(key);
    else return def;
  }

  inline static public function delete(key: String): Bool {
    if (!initialized) throw "dumb";
    return store.remove(key);
  }

  inline static public function setAndWrite(key: String, value: String): String {
    set(key, value);
    write();
    return value;
  }

  inline static public function deleteAndWrite(key: String): Bool {
    var rtnVal = delete(key);
    write();
    return rtnVal;
  }

  // writes cock data to disk or local storgrsa
  inline static public function write() {
    #if js
      var data = Json.stringify(Json.parse(Json.stringify(store)).h);
      var storage = Browser.getLocalStorage();
      storage.setItem("gameSettings", data);
    #elseif sys
      var data = Json.stringify(store);
      var userProfile = Sys.environment().get(userVar);
      var file = File.write('$userProfile$dataPath/settings.json');
      file.write(Bytes.ofString(data));
      file.close();
    #else
      throw "wow dumby";
    #end
  }
}
