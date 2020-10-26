package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.text.FlxText;

class FreeplayState extends MusicBeatState
{
	var songs:Array<String> = ["Bopeebo", "Dadbattle", "Fresh", "Tutorial\nlol"];

	var selector:FlxText;
	var curSelected:Int = 0;

	override function create()
	{
		// LOAD MUSIC

		// LOAD CHARACTERS

		var bg:FlxSprite = FlxGridOverlay.create(20, 20);
		add(bg);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(40, (70 * i) + 30, songs[i]);
			add(songText);
		}

		selector = new FlxText();
		selector.size = 40;
		selector.text = ">";
		add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.UP)
		{
			curSelected -= 1;
		}
		if (FlxG.keys.justPressed.DOWN)
		{
			curSelected += 1;
		}

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		selector.y = (70 * curSelected) + 30;

		if (FlxG.keys.justPressed.ENTER)
		{
			PlayState.SONG = Song.loadFromJson(songs[curSelected].toLowerCase());
			FlxG.switchState(new PlayState());
		}

		super.update(elapsed);
	}
}
