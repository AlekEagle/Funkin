package;

enum State
{
	Login;
	Lobby(ready:Bool);
	InGame(loaded:Bool);
}

class Player
{
	public var name:String;
	public var score:Int = 0;
	public var health:Float = 1;
	public var state:State = State.Login;

	public function new(name:String, ?state:Null<State>)
	{
		this.name = name;
		if (state != null)
		{
			this.state = state;
		}
	}

	public function setState(state:State):State
	{
		this.state = state;
		return this.state;
	}

	public function setScore(score:Int):Int
	{
		this.score = score;
		return this.score;
	}

	public function setHealth(health:Float):Float
	{
		this.health = health;
		return this.health;
	}
}
