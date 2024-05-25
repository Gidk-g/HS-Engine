package states.editors.week;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import states.StoryMenuState.WeekData;

using StringTools;

class WeekEditorState extends MusicBeatState {
    var weekFile:WeekData;
    var txtWeekTitle:FlxText;
	var txtTracklist:FlxText;

    override function create() {
        if (FlxG.sound.music != null)
            FlxG.sound.music.stop();

        txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
        txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
        txtWeekTitle.alpha = 0.7;

        var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);

        add(yellowBG);

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.setFormat(Paths.font("vcr.ttf"), 32);
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);

        add(txtWeekTitle);

        addWeekUI();

        super.create();
    }

    override function update(elapsed:Float) {
		txtTracklist.text = "Tracks\n";

        txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

        if (FlxG.keys.justPressed.ESCAPE) {
            FlxG.switchState(new states.editors.EditorMenuState());
            FlxG.sound.playMusic(Paths.music('freakyMenu'));
        }

        super.update(elapsed);
    }

    function addWeekUI() {}
}
