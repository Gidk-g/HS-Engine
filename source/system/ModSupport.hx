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
    public static var modDirectory:String = "mods/";
    public static var modConfigs:Array<ModConfig>;

    inline static public function loadMods():Void {
        modConfigs = [];

        for (modFolder in FileSystem.readDirectory('mods')) {
            var modDataPath:String = modDirectory + modFolder + "/mod.json";
            if (FileSystem.exists(modDataPath)) {
                try {
                    var modData:String = File.getContent(modDataPath);
                    var modConfig:ModConfig = parseMod(modData);
                    if (modConfig != null) {
                        modConfigs.push(modConfig);
                    }
                } catch (error:Dynamic) {
                    trace("Error loading mod:", modFolder);
                    trace(error);
                }
            }
        }
    }

    inline static public function parseMod(modData:String):ModConfig {
        try {
            return ModConfig.parseJson(modData);
        } catch (error:Dynamic) {
            trace("Error parsing mod data");
            trace(error);
            return null;
        }
    }
}

class ModConfig {
    public var name:String;
    public var version:String;
    public var author:String;
    public var description:String;

    public function new() {
        // ModConfig
    }

    public function printInfo():Void {
        trace("Mod Name:", name);
        trace("Version:", version);
        trace("Author:", author);
        trace("Description:", description);
    }

    public static function fromDynamic(data:Dynamic):ModConfig {
        if (!Reflect.hasField(data, "name") || !Reflect.hasField(data, "version") ||
            !Reflect.hasField(data, "author") || !Reflect.hasField(data, "description")) {
            trace("Invalid mod data format");
            return null;
        }
        var modConfig:ModConfig = new ModConfig();
        modConfig.name = data.name;
        modConfig.version = data.version;
        modConfig.author = data.author;
        modConfig.description = data.description;
        return modConfig;
    }

    public static function parseJson(json:String):ModConfig {
        var jsonData:Dynamic = Json.parse(json);
        if (jsonData == null) {
            trace("Invalid JSON format");
            return null;
        }
        return ModConfig.fromDynamic(jsonData);
    }
}

class ModPaths {
    public static var modDirectory:String = "mods/";

    inline static public function image(path:String):String {
        var modFolder:String = getModFolder();
        var fullPath:String = modDirectory + modFolder + "/images/" + path + ".png";
        if (FileSystem.exists(fullPath)) {
            return fullPath;
        }
        trace("Image not found:", fullPath);
        return "";
    }

    inline static public function sound(path:String):String {
        var modFolder:String = getModFolder();
        var fullPath:String = modDirectory + modFolder + "/" + path + ".ogg";
        if (FileSystem.exists(fullPath)) {
            return fullPath;
        }
        trace("Sound not found:", fullPath);
        return "";
    }

    inline static public function data(path:String):String {
        var modFolder:String = getModFolder();
        var fullPath:String = modDirectory + modFolder + "/data/" + path + ".json";
        if (FileSystem.exists(fullPath)) {
            return fullPath;
        }
        trace("Data file not found:", fullPath);
        return "";
    }

    inline static public function getSparrowAtlas(path:String):FlxAtlasFrames {
        var modFolder:String = getModFolder();
        var pngPath:String = modDirectory + modFolder + "/images/" + path + ".png";
        var xmlPath:String = modDirectory + modFolder + "/images/" + path + ".xml";
        var atlasFrames:FlxAtlasFrames = FlxAtlasFrames.fromSparrow(pngPath, xmlPath);
        if (atlasFrames != null) {
            return atlasFrames;
        }
        trace("Sprite file not found:", atlasFrames);
        return null;
    }

    inline static public function modFolder(path:String):String {
        var modFolder:String = getModFolder();
        var fullPath:String = modDirectory + modFolder + "/" + path;
        if (FileSystem.exists(fullPath)) {
            return fullPath;
        }
        trace("Mod file not found:", fullPath);
        return "";
    }

    inline static public function getModFolder():String {
        var modFolders = FileSystem.readDirectory('mods');
        if (modFolders.length > 0) {
            return modFolders[0];
        }
        trace("No mod folders found in", modDirectory);
        return "";
    }
}

class ModScripts {
    public static var modDirectory:String = "mods/";

	public static var script:hscript.Expr;
	public static var interp = new Interp();
	public static var parser = new Parser();

    inline static public function executeModScript(path:String):Void {
        var modFolder:String = ModPaths.getModFolder();
        var scriptFullPath:String = modDirectory + modFolder + "/" + path + ".hx";

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
            trace(error);
        }
        return null;
    }
}
#end
