package system;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.graphics.FlxGraphic;

class Prefs
{
	public static function init()
	{
		if (FlxG.save.data.fps == null)
			FlxG.save.data.fps = true;
	}
}
