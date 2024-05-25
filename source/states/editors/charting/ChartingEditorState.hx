package states.editors.charting;

import flixel.FlxG;

class ChartingEditorState extends MusicBeatState {
    override public function create() {
        if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

        super.create();
    }

    override function update(elapsed:Float) {
        if (FlxG.keys.justPressed.ENTER) {
            // jaja
        }
        super.update(elapsed);
    }
}
