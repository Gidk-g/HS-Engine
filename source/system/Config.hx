package system;

import flixel.FlxG;

class Config {
	public static var framerate:Int = 60;
	public static var noteSplashes:Bool = true;
	public static var ghostTapping:Bool = true;
    public static var showFPS:Bool = true;
    public static var keyBinds:Array<String> = ['A','S','W','D','R'];

	public static function save() {
		FlxG.save.data.framerate = framerate;
		FlxG.save.data.noteSplashes = noteSplashes;
		FlxG.save.data.ghostTapping = ghostTapping;
		FlxG.save.data.showFPS = showFPS;
		FlxG.save.flush();
    }

	public static function load() {
		if(FlxG.save.data.framerate != null) {
			framerate = FlxG.save.data.framerate;
			if(framerate > FlxG.drawFramerate) {
				FlxG.updateFramerate = framerate;
				FlxG.drawFramerate = framerate;
			} else {
				FlxG.drawFramerate = framerate;
				FlxG.updateFramerate = framerate;
			}
		}
		if(FlxG.save.data.noteSplashes != null)
			noteSplashes = FlxG.save.data.noteSplashes;
		if(FlxG.save.data.ghostTapping != null)
			ghostTapping = FlxG.save.data.ghostTapping;
		if(FlxG.save.data.showFPS != null) {
			showFPS = FlxG.save.data.showFPS;
			if(Main.fpsVar != null) {
				Main.fpsVar.visible = showFPS;
			}
		}
    }
}
