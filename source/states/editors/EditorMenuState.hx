package states.editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class EditorMenuState extends MusicBeatState {
    var options:Array<String> = ['Character Editor', 'Stage Editor', 'Week Editor', 'Exit'];

    private static var curSelected:Int = 0;
    private var grpOptions:FlxTypedGroup<Alphabet>;

    override function create() {
        #if desktop
        DiscordClient.changePresence("In the Editor Menu", null);
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
        super.create();
    }

    override function update(elapsed:Float) {
        if (controls.UP_P)
            changeSelection(-1);
        if (controls.DOWN_P)
            changeSelection(1);
        if (controls.ACCEPT)
            openSelectedOption(options[curSelected]);
        if (controls.BACK)
            FlxG.switchState(new ModState());
        super.update(elapsed);
    }

    function openSelectedOption(label:String) {
        switch(label) {
            case 'Character Editor':
                FlxG.switchState(new states.editors.character.CharacterEditorState());
			case 'Stage Editor':
				FlxG.switchState(new states.editors.stage.StageEditorState());
            case 'Week Editor':
                FlxG.switchState(new states.editors.week.WeekEditorState());
            case 'Exit':
                FlxG.switchState(new ModState());
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
