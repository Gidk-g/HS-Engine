package system;

import flixel.FlxG;

class Config {
	public static var ghostTapping:Bool = true;

	public static function save() {
		FlxG.save.data.ghostTapping = ghostTapping;
		FlxG.save.flush();
    }

	public static function load() {
		if(FlxG.save.data.ghostTapping != null)
			ghostTapping = FlxG.save.data.ghostTapping;
    }
}
