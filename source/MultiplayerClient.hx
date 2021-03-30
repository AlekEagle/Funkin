package;

import haxe.net.WebSocket;
import haxe.Json;
import haxe.ds.StringMap;

interface Message
{
	public var users:Null<Array<String>>;
	public var user:Null<String>;
	public var health:Null<Float>;
	public var score:Null<Int>;
	public var opcode:String;
	public var song:Null<String>;
}

class MultiplayerClient
{
	public var users(default, null):StringMap<Player> = new StringMap<Player>();
	public var me(default, null):String;
	public var song(default, null):Null<MultiplayerSong>;
	public var owner(default, null):Bool = false;

	var socket:WebSocket;

	public function new(ip:String, name:String)
	{
		this.socket = WebSocket.create('ws://$ip:6969/gateway');
		this.socket.onopen = this.onSocketConnect;
		this.socket.onmessageString = this.onSocketMessage;
		this.me = name;
		this.users.set(this.me, new Player(this.me));
		// this.socket.onmessageBytes = this.onSocketMessage;
		this.socket.onerror = this.onSocketError;
	}

	public dynamic function onConnect(users:StringMap<Player>)
	{
	}

	public dynamic function onUserUpdate(users:StringMap<Player>, song:Null<MultiplayerSong>)
	{
	}

	public dynamic function onUserStatusUpdate(user:Player)
	{
	}

	public dynamic function onGameStart()
	{
	}

	public dynamic function onAllPlayersLoaded()
	{
	}

	public function setReady()
	{
		if (!this.users.get(this.me).state.match(Lobby(true)) && !this.users.get(this.me).state.match(Lobby(false)))
			throw "wow you're dumbo";

		this.sendShit({"opcode": "0"});
	}

	public function setScore(score:Int, health:Float)
	{
		if (!this.users.get(this.me).state.match(InGame(true)))
			throw "wow you're dumbo";

		this.sendShit({"opcode": "0", "score": score, "health": health});
	}

	public function setSong(song:MultiplayerSong)
	{
		var songStr = song.toString();
		this.sendShit({"opcode": "5", "song": songStr});
	}

	public function setLoaded()
	{
		if (!this.users.get(this.me).state.match(InGame(false)))
			throw "wow you're dumbo";
		this.users.get(this.me).setState(InGame(true));
		this.sendShit({"opcode": "3"});
	}

	function sendShit(shit:Dynamic)
	{
		this.socket.sendString(Json.stringify(shit));
	}

	function onSocketConnect()
	{
		this.sendShit({"opcode": "0", "username": this.users.get(this.me).name});
	}

	function onSocketMessage(message:String)
	{
		var message:Message = Json.parse(message);
		switch (this.users.get(this.me).state)
		{
			case Login:
				switch (message.opcode)
				{
					case "1":
						for (user in message.users)
							this.users.set(user, new Player(user, Lobby(false)));
						this.users.get(this.me).setState(Lobby(false));
						this.onConnect(this.users);
						if (message.users.length < 1) this.owner = true;

					default:
						trace(message);
						trace('bad opcode ${message.opcode} for state ${null}');
				}
			case Lobby(ready):
				switch (message.opcode)
				{
					case "1":
						for (key => player in this.users)
						{
							this.users.get(key).setState(Lobby(false));
						}
						for (user in message.users)
						{
							if (this.users.get(user).state.match(Lobby(false)))
							{
								this.users.get(user).setState(Lobby(true));
							}
						}
						this.song = new MultiplayerSong(message.song);
						this.onUserUpdate(this.users, this.song);
					case "2":
						for (user in this.users.keys())
							this.users.get(user).setState(InGame(false));
						this.onGameStart();
					case "3":
						this.users.set(message.user, new Player(message.user, Lobby(false)));
						this.onUserUpdate(this.users, this.song);
					case "4":
						this.users.remove(message.user);
						this.onUserUpdate(this.users, this.song);
					default:
						trace(message);
						throw('how!?!');
				}
			case InGame(loaded):
				switch (message.opcode)
				{
					case "1":
						var user = this.users.get(message.user);
						user.setHealth(message.health);
						user.setScore(message.score);
						this.onUserStatusUpdate(user);
					case "2":
						this.users.remove(message.user);
						this.onUserUpdate(this.users, this.song);
					case "4":
						this.onAllPlayersLoaded();
					default:
						trace(message);
						throw('how!?!');
				}
		}
	}

	function onSocketError(message:String)
	{
		trace('uh oh i had a stinky poo poo at $message');
	}

	public function process()
	{
		this.socket.process();
	}

	public function close()
	{
		this.socket.close();
	}
}
