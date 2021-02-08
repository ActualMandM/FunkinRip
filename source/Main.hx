package;

import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	// Change this bool if you want to enable or disable the FPS counter
	private static var showFPS:Bool = false;

	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, TitleState));

		if (showFPS)
			addChild(new FPS(10, 3, 0xFFFFFF));
	}
}
