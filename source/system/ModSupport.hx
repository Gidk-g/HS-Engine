package system;

import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import hscript.Parser;
import hscript.Interp;

class ModSupport {
    static var modDirectory:String = "mods/";
    static var modConfigs:Array<ModConfig>;

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
    var name:String;
    var version:String;
    var author:String;
    var description:String;
    var icon:String;
    var colors:Array<{r:Int, g:Int, b:Int}>;

    public function new() {
        colors = [];
    }

    public function printInfo():Void {
        trace("Mod Name:", name);
        trace("Version:", version);
        trace("Author:", author);
        trace("Description:", description);
        trace("Icon:", icon);
        for (color in colors) {
            trace("Colors:", color.r, color.g, color.b);
        }
    }

    public static function fromDynamic(data:Dynamic):ModConfig {
        if (!Reflect.hasField(data, "name") || !Reflect.hasField(data, "version") ||
            !Reflect.hasField(data, "author") || !Reflect.hasField(data, "description") ||
            !Reflect.hasField(data, "icon") || !Reflect.hasField(data, "colors")) {
            trace("Invalid mod data format");
            return null;
        }

        var modConfig:ModConfig = new ModConfig();
        modConfig.name = data.name;
        modConfig.version = data.version;
        modConfig.author = data.author;
        modConfig.description = data.description;
        modConfig.icon = data.icon;
        modConfig.colors = [];
        for (i in 0...data.colors.length) {
            var colorData = data.colors[i];
            if (Reflect.hasField(colorData, "r") && Reflect.hasField(colorData, "g") && Reflect.hasField(colorData, "b")) {
                modConfig.colors.push({r: colorData.r, g: colorData.g, b: colorData.b});
            } else {
                trace("Invalid color data format");
            }
        }
        return modConfig;
    }

    public static function parseJson(jsonData:String):ModConfig {
        var data:Dynamic = Json.parse(jsonData);
        return ModConfig.fromDynamic(data);
    }
}

class ModPaths {
    static var modDirectory:String = "mods/";

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
        var fullPath:String = modDirectory + modFolder + "/sounds/" + path + ".ogg";
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
    static var modDirectory:String = "mods/";

	static var script:hscript.Expr;
	static var interp = new Interp();
	static var parser = new Parser();

    static function executeModScript(path:String):Void {
        var modFolder:String = ModPaths.getModFolder();
        var scriptFullPath:String = modDirectory + modFolder + "/" + path + ".hx";

        if (FileSystem.exists(scriptFullPath)) {
            var scriptContent:String = File.getContent(scriptFullPath);
            executeScript(scriptContent);
        } else {
            trace("Script not found:", scriptFullPath);
        }
    }

    static function executeScript(path:String) {
        parser.allowTypes = true;
        parser.allowJSON = true;
        parser.allowMetadata = true;

        interp.variables.set("File", File);
        interp.variables.set("FileSystem", FileSystem);

        script = parser.parseString(path);
		interp.execute(script);
    }

    static function callFunction(funcName:String, args:Array<Dynamic>):Dynamic {
        if (args == null)
            args = [];
        try {
            var func:Dynamic = interp.variables.get(funcName);
            if (func != null && Reflect.isFunction(func))
                return Reflect.callMethod(null, func, args);
        } catch (e:Dynamic) {
            trace(e);
        }
        return null;
    }
}
