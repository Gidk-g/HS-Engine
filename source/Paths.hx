package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	inline static public function hx(key:String, ?library:String)
	{
		return getPath('$key.hx', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		var file = ModPaths.modSound('sounds/$key.$SOUND_EXT');
		if (file != null)
		{
			return file;
		}
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		var file = ModPaths.modSound('music/$key.$SOUND_EXT');
		if (file != null)
		{
			return file;
		}
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String)
	{
		var file = ModPaths.modSound('songs/${song.toLowerCase()}/Voices.$SOUND_EXT');
		if (file != null)
		{
			return file;
		}
		return 'songs:assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String)
	{
		var file = ModPaths.modSound('songs/${song.toLowerCase()}/Inst.$SOUND_EXT');
		if (file != null)
		{
			return file;
		}
		return 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String)
	{
		var file = ModPaths.modImage('images/$key.png');
		if (file != null)
		{
			return file;
		}
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String)
	{
		var file = ModPaths.modTxt('fonts/$key');
		if (file != null)
		{
			return file;
		}
		return 'assets/fonts/$key';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		var file = FlxAtlasFrames.fromSparrow(image(key), ModPaths.modTxt('images/$key.xml'));
		if (file != null)
		{
			return file;
		}
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		var file = FlxAtlasFrames.fromSparrow(image(key), ModPaths.modTxt('images/$key.txt'));
		if (file != null)
		{
			return file;
		}
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}
}
