package;

import flixel.FlxG;
import flash.media.Sound;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	#if (haxe >= "4.0.0")
	public static var customImagesLoaded:Map<String, FlxGraphic> = new Map();
	public static var customSoundsLoaded:Map<String, Sound> = new Map();
	#else
	public static var customImagesLoaded:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();
	public static var customSoundsLoaded:Map<String, Sound> = new Map<String, Sound>();
	#end

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

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String):Any
	{
		#if sys
		var file:Sound = returnSongFile(ModPaths.sound('songs/' + song.toLowerCase() + '/Voices'));
		if(file != null) {
			return file;
		}
		#end
		return 'songs:assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String):Any
	{
		#if sys
		var file:Sound = returnSongFile(ModPaths.sound('songs/' + song.toLowerCase() + '/Inst'));
		if(file != null) {
			return file;
		}
		#end
		return 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String):Dynamic
	{
		#if sys
		var imageToReturn:FlxGraphic = addCustomGraphic(key);
		if(imageToReturn != null) return imageToReturn;
		#end
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		var imageLoaded:FlxGraphic = addCustomGraphic(key);
		var xmlExists:Bool = false;
		if (sys.FileSystem.exists(ModPaths.modFolder('images/$key.xml')))
		{
			xmlExists = true;
		}
		return FlxAtlasFrames.fromSparrow((imageLoaded != null ? imageLoaded : image(key, library)),
			(xmlExists ? sys.io.File.getContent(ModPaths.modFolder('images/$key.xml')) : file('images/$key.xml', TEXT, library)));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	inline static public function fileExists(key:String, ?type:AssetType, ?library:String)
	{
		if(OpenFlAssets.exists(getPath(key, type, library))) {
			return true;
		}
		#if sys
		if(sys.FileSystem.exists(ModPaths.modFolder(key))) {
			return true;
		}
		#end
		return false;
	}

    #if sys
	static private function addCustomGraphic(key:String):FlxGraphic {
		if(sys.FileSystem.exists(ModPaths.image(key))) {
			if(!customImagesLoaded.exists(key)) {
				var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(ModPaths.image(key)));
				newGraphic.persist = true;
				customImagesLoaded.set(key, newGraphic);
			}
			return customImagesLoaded.get(key);
		}
		return null;
	}

	inline static private function returnSongFile(file:String):Sound {
        if(sys.FileSystem.exists(file)) {
            if(!customSoundsLoaded.exists(file)) {
                customSoundsLoaded.set(file, Sound.fromFile(file));
            }
            return customSoundsLoaded.get(file);
        }
        return null;
    }
	#end
}
