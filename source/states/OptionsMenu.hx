package states;

import lime.app.Application;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Lib;
import system.Options;
import system.Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import openfl.display.FPS;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.effects.FlxFlicker;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import lime.system.DisplayMode;

class OptionsMenu extends MusicBeatState
{
	public static var instance:OptionsMenu;

	var selector:FlxText;

	static var curSelected:Int = 0;

	var opt:Option;

	var options:Array<OptionCategory> = [
		new OptionCategory("Preferences",
		[
			#if polymod
			new ModOption(),
			#end
		]),
	];

	private var grpCheckboxes:FlxTypedGroup<CheckboxThingie>;

	var fpsthing:FlxText;

	public var acceptInput:Bool = true;

	public var grpControls:FlxTypedGroup<Alphabet>;

	var currentSelectedCat:OptionCategory;

	var confirming:Bool = false;

	override function create()
	{
		instance = this;

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		grpCheckboxes = new FlxTypedGroup<CheckboxThingie>();
		add(grpCheckboxes);

		generateMainMenu();

		changeSelection();

		super.create();
	}

	function generateMainMenu()
	{
		for (i in 0...options.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, FlxG.height / 5 + 70 * i + 25 * i, options[i].getName(), true);
			controlLabel.screenCenter(X);
			grpControls.add(controlLabel);
		}
	}

	public var isCat:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (acceptInput && !confirming)
		{
			if (controls.BACK)
			{
				if (isCat)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					isCat = false;
					grpControls.clear();
					grpCheckboxes.clear();
					generateMainMenu();
					curSelected = 0;
					changeSelection();
				}
				else
					quit();
			}

			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				changeSelection(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				changeSelection(1);
			}

			if (isCat)
			{
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
				{
					if (FlxG.keys.pressed.SHIFT)
					{
						if (FlxG.keys.pressed.RIGHT)
							currentSelectedCat.getOptions()[curSelected].right();
						if (FlxG.keys.pressed.LEFT)
							currentSelectedCat.getOptions()[curSelected].left();
					}
				}
				else if (FlxG.keys.pressed.SHIFT)
				{
					if (FlxG.keys.justPressed.RIGHT)
						currentSelectedCat.getOptions()[curSelected].right();
					if (FlxG.keys.justPressed.LEFT)
						currentSelectedCat.getOptions()[curSelected].left();
				}
			}

			if (controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				confirming = true;
				FlxFlicker.flicker(grpControls.members[curSelected], 0.5, 0.06, true, false, function(flick:FlxFlicker)
				{
					if (isCat && currentSelectedCat.getOptions()[curSelected].press())
					{
						grpCheckboxes.members[curSelected].daValue = currentSelectedCat.getOptions()[curSelected].daValue;
						grpControls.members[curSelected].changeText(currentSelectedCat.getOptions()[curSelected].getDisplay());
					}
					else
					{
						currentSelectedCat = options[curSelected];
						isCat = true;
						grpControls.clear();
						grpCheckboxes.clear();
						for (i in 0...currentSelectedCat.getOptions().length)
						{
							var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, currentSelectedCat.getOptions()[i].getDisplay(), true, false);
			                controlLabel.isMenuItem = true;
							controlLabel.targetY = i;
							grpControls.add(controlLabel);
							controlLabel.forceX = 150;
							if (currentSelectedCat.getOptions()[i].isBool)
							{
								var checkbox:CheckboxThingie = new CheckboxThingie(controlLabel.x - 105, controlLabel.y,
									currentSelectedCat.getOptions()[i].daValue);
								checkbox.sprTracker = controlLabel;
								checkbox.ID = i;
								grpCheckboxes.add(checkbox);
							}
						}
						curSelected = 0;
						changeSelection();
					}
					confirming = false;
				});
			}
		}
	}

	var isSettingControl:Bool = false;

	function quit()
	{
		FlxG.save.flush();
		FlxG.switchState(new MainMenuState());
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}
}
