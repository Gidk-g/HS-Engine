package system;

#if sys
import haxe.Json;
import flixel.FlxG;
import haxe.io.Path;
import sys.thread.Thread;
import flixel.math.FlxAngle;
import flixel.group.FlxGroup;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.graphics.FlxGraphic;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import flixel.math.FlxMath;
import lime.utils.Assets;
import hscript.Parser;
import hscript.Interp;
import sys.FileSystem;
import sys.io.File;

class ModSupport {
    // lol
}

class ModPaths {
    public static var modDirectory:String = "mods/";

    inline static public function image(path:String):String {
        var modFolder = FileSystem.readDirectory('mods');
        var fullPath:String = modDirectory + modFolder + "/images/" + path + ".png";
        return fullPath;
    }

    inline static public function sound(path:String):String {
        var modFolder = FileSystem.readDirectory('mods');
        var fullPath:String = modDirectory + modFolder + "/" + path + ".ogg";
        return fullPath;
    }

    inline static public function data(path:String):String {
        var modFolder = FileSystem.readDirectory('mods');
        var fullPath:String = modDirectory + modFolder + "/data/" + path + ".json";
        return fullPath;
    }

    inline static public function getSparrowAtlas(path:String):FlxAtlasFrames {
        var modFolder = FileSystem.readDirectory('mods');
        var pngPath:String = modDirectory + modFolder + "/images/" + path + ".png";
        var xmlPath:String = modDirectory + modFolder + "/images/" + path + ".xml";
        var atlasFrames:FlxAtlasFrames = FlxAtlasFrames.fromSparrow(pngPath, xmlPath);
        return atlasFrames;
    }

    inline static public function modFolder(path:String):String {
        var modFolder = FileSystem.readDirectory('mods');
        var fullPath:String = modDirectory + modFolder + "/" + path;
        return fullPath;
    }
}

class ModScripts {
	public static var script:hscript.Expr;
	public static var interp = new Interp();
	public static var parser = new Parser();

    inline static public function executeModScript(path:String):Void {
        var modFolder = FileSystem.readDirectory('mods');
        var scriptFullPath:String = ModPaths.modDirectory + modFolder + "/" + path + ".hx";

        if (FileSystem.exists(scriptFullPath)) {
            var scriptContent:String = File.getContent(scriptFullPath);
            executeScript(scriptContent);
        } else {
            trace("Script not found:", scriptFullPath);
        }
    }

    inline static public function executeScript(path:String) {
        parser.allowTypes = true;
        parser.allowJSON = true;
        parser.allowMetadata = true;

		interp.variables.set("Int", Int);
		interp.variables.set("String", String);
		interp.variables.set("Float", Float);
		interp.variables.set("Array", Array);
		interp.variables.set("Bool", Bool);
		interp.variables.set("Dynamic", Dynamic);
		interp.variables.set("Math", Math);
		interp.variables.set("FlxMath", FlxMath);
		interp.variables.set("Std", Std);
		interp.variables.set("StringTools", StringTools);
		interp.variables.set("FlxG", FlxG);
		interp.variables.set("FlxSound", FlxSound);
		interp.variables.set("FlxSprite", FlxSprite);
		interp.variables.set("FlxText", FlxText);
		interp.variables.set("FlxGraphic", FlxGraphic);
		interp.variables.set("FlxTween", FlxTween);
		interp.variables.set("FlxCamera", FlxCamera);
		interp.variables.set("Assets", Assets);
		interp.variables.set("File", File);
		interp.variables.set("Windows", Windows);
		interp.variables.set("FileSystem", FileSystem);
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("FlxGroup", FlxGroup);
		interp.variables.set("FlxTypedGroup", FlxTypedGroup);
		interp.variables.set("CoolUtil", CoolUtil);
		interp.variables.set("Paths", Paths);
		interp.variables.set("Path", Path);
		interp.variables.set("Json", Json);
		interp.variables.set("FlxAngle", FlxAngle);
		interp.variables.set("FlxAtlasFrames", FlxAtlasFrames);
		interp.variables.set("FlxAtlas", FlxAtlas);
		interp.variables.set("Character", Character);
		interp.variables.set("Boyfriend", Boyfriend);
		interp.variables.set("Song", Song);
		interp.variables.set("Conductor", Conductor);
		interp.variables.set("Note", Note);
        interp.variables.set("ModPaths", ModPaths);

        script = parser.parseString(path);
		interp.execute(script);
    }

    inline static public function callFunction(funcName:String, args:Array<Dynamic>):Dynamic {
        if (args == null)
            args = [];
        try {
            var func:Dynamic = interp.variables.get(funcName);
            if (func != null && Reflect.isFunction(func))
                return Reflect.callMethod(null, func, args);
        } catch (error:Dynamic) {
            FlxG.log.add(error.details());
            trace(error);
        }
        return null;
    }
}
#end
