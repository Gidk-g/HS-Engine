package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;

class OptionsState extends MusicBeatState {
	var options:Array<String> = ['Preferences', 'Controls', 'Exit'];

	private static var curSelected:Int = 0;
	private var grpOptions:FlxTypedGroup<Alphabet>;

    override function create() {
		#if desktop
		DiscordClient.changePresence("In the Options Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length) {
            var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
            optionText.screenCenter();
            optionText.y += (100 * (i - (options.length / 2))) + 50;
            grpOptions.add(optionText);
        }

		changeSelection();
		Config.save();
		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		Config.save();
	}

	override function update(elapsed:Float) {
        if (controls.UP_P)
			changeSelection(-1);
		if (controls.DOWN_P)
			changeSelection(1);
		if (controls.ACCEPT)
			openSelectedOption(options[curSelected]);
		if (controls.BACK) {
			#if sys
			scriptState.callFunction("goToMenu", []);
			#end
            MusicBeatState.switchState(new MainMenuState());
		}
		super.update(elapsed);
    }

	function openSelectedOption(label:String) {
		switch(label) {
			case 'Preferences':
                openSubState(new PreferencesSubstate());
			case 'Controls':
				openSubState(new substates.KeyBindMenu());
			case 'Exit':
				#if sys
				scriptState.callFunction("goToMenu", []);
				#end
                MusicBeatState.switchState(new MainMenuState());
		}
	}

	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;
		var bullShit:Int = 0;
		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;
			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}

class PreferencesSubstate extends MusicBeatSubstate
{
	private static var curSelected:Int = 0;

	static var unselectableOptions:Array<String> = [
		'GAMEPLAY',
		'VISUALS'
	];

	static var options:Array<String> = [
		'GAMEPLAY',
		'BotPlay',
		'DownScroll',
		'MiddleScroll',
		'Ghost Tapping',
		'VISUALS',
		'Note Splashes',
		'Flashing Menu',
		'Camera Zooms',
		#if !mobile
		'FPS Counter'
		#end
	];

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var checkboxArray:Array<CheckboxThingie> = [];
	private var checkboxNumber:Array<Int> = [];
	private var descText:FlxText;
	private var bg:FlxSprite;

	public function new()
	{
		super();

	    bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var isCentered:Bool = unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, options[i], false, false);
			optionText.isMenuItem = true;
			if(isCentered) {
				optionText.screenCenter(X);
				optionText.forceX = optionText.x;
			} else {
				optionText.x += 300;
				optionText.forceX = 300;
			}
			optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if(!isCentered) {
				var useCheckbox:Bool = true;
				if(useCheckbox) {
					var checkbox:CheckboxThingie = new CheckboxThingie(optionText.x - 105, optionText.y, false);
					checkbox.sprTracker = optionText;
					checkboxArray.push(checkbox);
					checkboxNumber.push(i);
					add(checkbox);
				}
			}
		}

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		for (i in 0...options.length) {
			if(!unselectableCheck(i)) {
				curSelected = i;
				break;
			}
		}
		changeSelection();
		reloadValues();
	}

	var nextAccept:Int = 5;

	override function update(elapsed:Float)
	{
		if (controls.UP_P)
		{
			changeSelection(-1);
		}

		if (controls.DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.BACK) {
			grpOptions.forEachAlive(function(spr:Alphabet) {
				spr.alpha = 0;
			});
			for (i in 0...checkboxArray.length) {
				var spr:CheckboxThingie = checkboxArray[i];
				if(spr != null) {
					spr.alpha = 0;
				}
			}
			bg.alpha = 0;
			descText.alpha = 0;
			close();
		}

		var usesCheckbox = true;
		if(usesCheckbox) {
			if(controls.ACCEPT && nextAccept <= 0) {
				switch(options[curSelected]) {
					case 'FPS Counter':
						Config.showFPS = !Config.showFPS;
						if(Main.fpsVar != null)
							Main.fpsVar.visible = Config.showFPS;
					case 'BotPlay':
						Config.botplay = !Config.botplay;
					case 'DownScroll':
						Config.downScroll = !Config.downScroll;
					case 'MiddleScroll':
						Config.middleScroll = !Config.middleScroll;
					case 'Note Splashes':
						Config.noteSplashes = !Config.noteSplashes;
					case 'Flashing Menu':
						Config.flashingMenu = !Config.flashingMenu;
					case 'Ghost Tapping':
						Config.ghostTapping = !Config.ghostTapping;
					case 'Camera Zooms':
						Config.camZooms = !Config.camZooms;
				}
				FlxG.sound.play(Paths.sound('scrollMenu'));
				reloadValues();
			}
		}

		if(nextAccept > 0) {
			nextAccept -= 1;
		}
		super.update(elapsed);
	}
	
	function changeSelection(change:Int = 0)
	{
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = options.length - 1;
			if (curSelected >= options.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var daText:String = '';
		switch(options[curSelected]) {
			case 'FPS Counter':
				daText = "";
			case 'BotPlay':
				daText = "";
			case 'DownScroll':
				daText = "";
			case 'MiddleScroll':
				daText = "";
			case 'Ghost Tapping':
				daText = "";
			case 'Flashing Menu':
				daText = "";
			case 'Note Splashes':
				daText = "";
			case 'Camera Zooms':
				daText = "";
		}
		descText.text = daText;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;
			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
				for (j in 0...checkboxArray.length) {
					var tracker:FlxSprite = checkboxArray[j].sprTracker;
					if(tracker == item) {
						checkboxArray[j].alpha = item.alpha;
						break;
					}
				}
			}
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function reloadValues() {
		for (i in 0...checkboxArray.length) {
			var checkbox:CheckboxThingie = checkboxArray[i];
			if(checkbox != null) {
				var daValue:Bool = false;
				switch(options[checkboxNumber[i]]) {
					case 'FPS Counter':
						daValue = Config.showFPS;
					case 'BotPlay':
						daValue = Config.botplay;
					case 'DownScroll':
						daValue = Config.downScroll;
					case 'MiddleScroll':
						daValue = Config.middleScroll;
					case 'Note Splashes':
						daValue = Config.noteSplashes;
					case 'Ghost Tapping':
						daValue = Config.ghostTapping;
					case 'Flashing Menu':
						daValue = Config.flashingMenu;
					case 'Camera Zooms':
						daValue = Config.camZooms;
				}
				checkbox.daValue = daValue;
			}
		}
	}

	private function unselectableCheck(num:Int):Bool {
		for (i in 0...unselectableOptions.length) {
			if(options[num] == unselectableOptions[i]) {
				return true;
			}
		}
		return options[num] == '';
	}
}

class CheckboxThingie extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public var daValue(default, set):Bool;
	public var offsetX:Float = 0;
	public var offsetY:Float = 50;

	public function new(x:Float = 0, y:Float = 0, ?checked = false) {
		super(x, y);

		frames = Paths.getSparrowAtlas('checkboxThingie');
		animation.addByPrefix("unchecked", "Check Box unselected", 24, false);
		animation.addByPrefix("checked", "Check Box selecting animation", 24, false);

		antialiasing = true;
		setGraphicSize(Std.int(0.9 * width));
		updateHitbox();

		set_daValue(checked);
	}

	override function update(elapsed:Float) {
		if (sprTracker != null)
			setPosition(sprTracker.x - 130 + offsetX, sprTracker.y - 30 + offsetY);
		super.update(elapsed);
	}

	private function set_daValue(check:Bool):Bool {
		if (check) {
			if(animation.curAnim.name != 'checked') {
			    animation.play('checked', true);
			    offset.set(22, 90);
			}
		} else {
			animation.play('unchecked', true);
			offset.set();
		}
		return check;
	}
}
