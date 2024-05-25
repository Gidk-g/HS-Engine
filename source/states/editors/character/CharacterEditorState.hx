package states.editors.character;

import flixel.FlxG;
import flixel.FlxCamera;

class CharacterEditorState extends MusicBeatState {
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

	override public function create() {
        if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

        super.create();
    }

    override function update(elapsed:Float) {
        if (FlxG.keys.justPressed.ESCAPE) {
            FlxG.switchState(new states.editors.EditorMenuState());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
        }
        super.update(elapsed);
    }
}
