package;

import haxe.net.WebSocket;
import haxe.Json;
import haxe.ds.StringMap;

enum User {
	Login;
	Lobby(ready: Bool);
	Play;
}

interface Message {
	public var users: Null<Array<String>>;
	public var user: Null<String>;
  public var opcode: String;
}

class MultiplayerClient {
	public var users(default, null): Null<StringMap<User>>;
	public var name(default, null): String;
	public var state(get, null): Null<User>;

	var socket: WebSocket;

	function get_state(): Null<User> {
		if (this.users == null) return null;
		else return this.users.get(this.name);
	}

	public function new(ip: String, name: String) {
		this.name = name;
		this.socket = WebSocket.create('ws://$ip/');
		this.socket.onopen = this.onSocketConnect;
		this.socket.onmessageString = this.onSocketMessage;
		//this.socket.onmessageBytes = this.onSocketMessage;
		this.socket.onerror = this.onSocketError;
	}

	public dynamic function onConnect() {}
	public dynamic function onUserUpdate(users: Array<String>) {}
	public dynamic function onGameStart() {}

	public function setReady() {
		if (this.state != User.Lobby(false))
			throw "wow you're dumbo";

		this.sendShit({"opcode": "0"});
	}

	public function setScore(score: Int) {
		if (this.state != User.Play)
			throw "wow you're dumbo";

		this.sendShit({"opcode": "0", "score": score});
	}

	function sendShit(shit: Dynamic) {
		this.socket.sendString(Json.stringify(shit));
	}

	function onSocketConnect() {
		this.sendShit({"opcode": "0", "username": this.name});
	}

	function onSocketMessage(message: String) {
		var message: Message = Json.parse(message);
		switch (this.state) {
			case null:
				switch (message.opcode) {
					case "1":
						this.users = new StringMap();
						for (user in message.users)
							this.users.set(user, User.Lobby(false));
						this.users.set(this.name, User.Lobby(false));
						this.onConnect();

					default:
						trace('bad opcode ${message.opcode} for state ${null}');
				}
			case User.Lobby(ready):
				switch (message.opcode) {
					case "1":
						var changed = [];
						for (user in message.users) {
							if (this.users.get(user) == User.Lobby(false))
								changed.push(user);
							this.users.set(user, User.Lobby(true));
						}
						this.onUserUpdate(changed);

					case "2":
						for (user in this.users.keys())
							this.users.set(user, User.Play);
						this.onGameStart();

					case "3":
						this.users.set(message.user, User.Lobby(false));
						this.onUserUpdate([message.user]);

					case "4":
						this.users.remove(message.user);
						this.onUserUpdate([message.user]);
				}
			
			default:
				trace("poo");
		}
	}

	function onSocketError(message: String) {
		trace('uh oh i had a stinky poo poo at $message');
	}
}
