package system;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.graphics.FlxGraphic;

class Prefs
{
	public static function init()
	{
		if (FlxG.save.data.mods == null)
			FlxG.save.data.mods = true;

		PlayerSettings.init();
		Highscore.load();
	}
}
