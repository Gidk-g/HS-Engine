package states.editors.stage;

import flixel.FlxG;

class StageEditorState extends MusicBeatState {
    override function create() {
        if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.mouse.visible = true;

        super.create();
    }

    override function update(elapsed:Float) {
        if (FlxG.keys.justPressed.ESCAPE) {
			FlxG.mouse.visible = false;
            FlxG.switchState(new states.editors.EditorMenuState());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
        }

        super.update(elapsed);
    }
}
