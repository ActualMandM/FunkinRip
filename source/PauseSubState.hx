package;

import flixel.text.FlxText;
import flixel.addons.text.FlxTypeText;
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	// for displaying autoplay params
	var showParam:Bool = false;
	var textParam:FlxText;
	var edit:Int = -1;

	public function new(x:Float, y:Float)
	{
		super();

		pauseMusic = new FlxSound().loadEmbedded('assets/music/breakfast' + TitleState.soundExt, true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		textParam = new FlxText(500, 20, 700, "", 20);
		add(textParam);

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					close();
				case "Restart Song":
					if (PlayState.isStoryMode)
					{
						PlayState.hasRestarted = true;
					}

					FlxG.resetState();
				case "Exit to menu":
					// FlxG.switchState(new MainMenuState());

					if (PlayState.isStoryMode)
					{
						PlayState.hasRestarted = false;
						FlxG.switchState(new StoryMenuState());
					}
					else
						FlxG.switchState(new FreeplayState());
			}
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
			// hi just gonna borrow this place
			showParam = !showParam;
		}

		if (FlxG.keys.justPressed.C)
		{
			PlayState.autoplay = !PlayState.autoplay;
			trace("Autoplay " + (PlayState.autoplay ? "enabled" : "disabled"));
		}

		if (FlxG.keys.justPressed.P)
		{
			PlayState.perfectAuto = !PlayState.perfectAuto;
			trace("Perfect autoplay " + (PlayState.perfectAuto ? "enabled" : "disabled"));
		}

		if (showParam)
		{
			if (PlayState.autoplay)
			{
				var PARAM_NUM = 6;
				if (edit == -1)
					edit = 0;

				if (PlayState.perfectAuto)
					textParam.text = "PERFECT ENABLED\n";
				else
					textParam.text = "AUTO ENABLED\n";

				// param modifier
				if (FlxG.keys.justPressed.T)
					edit = (edit + (PARAM_NUM - 1)) % PARAM_NUM; // -1 fails lol
				if (FlxG.keys.justPressed.G)
					edit = (edit + 1) % PARAM_NUM;

				var left = FlxG.keys.justPressed.F;
				var right = FlxG.keys.justPressed.H;
				if (left || right)
				{
					switch (edit)
					{
						case 0:
							if (left && Note.delayMin > 0)
								Note.delayMin -= 1;
							else if (right && Note.delayMin < Note.delayMax)
								Note.delayMin += 1;
						case 1:
							if (left && Note.delayMax > Note.delayMin)
								Note.delayMax -= 1;
							else if (right)
								Note.delayMax += 1;
						case 2:
							if (left && Note.delayStd > 1e-5) // float comparison epic
								Note.delayStd -= 0.1;
							else if (right)
								Note.delayStd += 0.1;
						case 3:
							if (left && PlayState.antiInfiHoldThres > 1)
								PlayState.antiInfiHoldThres -= 1;
							else if (right)
								PlayState.antiInfiHoldThres += 1;
						case 4:
							if (!PlayState.perfectAuto)
							{
								if (left && PlayState.holdDelayMin > 2)
									PlayState.holdDelayMin -= 1;
								else if (right)
									PlayState.holdDelayMin += 1;
							}
							else
							{
								if (left && PlayState.holdPerfDelayMin > 2)
									PlayState.holdPerfDelayMin -= 1;
								else if (right)
									PlayState.holdPerfDelayMin += 1;
							}
						case 5:
							if (!PlayState.perfectAuto)
							{
								if (left && PlayState.holdDelayMax > 2)
									PlayState.holdDelayMax -= 1;
								else if (right)
									PlayState.holdDelayMax += 1;
							}
							else
							{
								if (left && PlayState.holdPerfDelayMax > 2)
									PlayState.holdPerfDelayMax -= 1;
								else if (right)
									PlayState.holdPerfDelayMax += 1;
							}
					}
				}
			}
			else
			{
				edit = -1;
				textParam.text = "AUTO DISABLED\n";
			}
			textParam.text += "Min delay: " + (edit == 0 ? "< " : "  ") + Note.delayMin + (edit == 0 ? " >" : "  ") + "\n";
			textParam.text += "Max delay: " + (edit == 1 ? "< " : "  ") + Note.delayMax + (edit == 1 ? " >" : "  ") + "\n";
			textParam.text += "Std delay: " + (edit == 2 ? "< " : "  ") + Note.delayStd + (edit == 2 ? " >" : "  ") + "\n";
			textParam.text += "Inf thres: " + (edit == 3 ? "< " : "  ") + PlayState.antiInfiHoldThres + (edit == 3 ? " >" : "  ") + "\n";
			textParam.text += "Hold min : " + (edit == 4 ? "< " : "  ") + (PlayState.perfectAuto ? PlayState.holdPerfDelayMin : PlayState.holdDelayMin) + (edit == 4 ? " >" : "  ") + "\n";
			textParam.text += "Hold max : " + (edit == 5 ? "< " : "  ") + (PlayState.perfectAuto ? PlayState.holdPerfDelayMax : PlayState.holdDelayMax) + (edit == 5 ? " >" : "  ") + "\n";
		}
		else
			textParam.text = "";
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
