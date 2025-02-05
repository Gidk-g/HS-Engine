package system;

#if sys
import haxe.Json;
import flixel.FlxG;
import haxe.io.Path;
import flixel.FlxObject;
import flixel.math.FlxAngle;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.graphics.FlxGraphic;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import flixel.math.FlxMath;
import lime.utils.Assets;
import haxe.zip.Reader;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import hscript.Parser;
import hscript.Interp;
import sys.FileSystem;
import sys.io.File;

#if VIDEOS
import hxvlc.flixel.FlxVideo;
import hxvlc.flixel.FlxVideoSprite;
#end

using StringTools;

class ModSupport {}

class ModPaths {
    public static var modDirectory:String = "mods/";
    private static var modInfo:Array<{ folder:String, enabled:Bool }> = [];

    inline static public function image(path:String):String {
        return findFileInModFolders("images", path + ".png");
    }

    inline static public function sound(path:String):String {
        return findFileInModFolders("", path + ".ogg");
    }

    inline static public function data(path:String):String {
        return findFileInModFolders("data", path + ".json");
    }

    inline static public function script(path:String):String {
        return findFileInModFolders("", path + ".hx");
    }

    inline static public function modFolder(path:String):String {
        return findFileInModFolders("", path);
    }

    static private function findFileInModFolders(subfolder:String, path:String):String {
        var fullPath:String = null;
        for (modFolder in getModFolders()) {
            if (modFolder.enabled) {
                var folderPath:String = haxe.io.Path.join([modDirectory, modFolder.folder, subfolder, path]);
                if (FileSystem.exists(folderPath)) {
                    fullPath = folderPath;
                    break;
                }
            }
        }
        return fullPath;
    }

    static public function getModFolders():Array<{ folder:String, enabled:Bool }> {
        if (modInfo.length == 0) {
            loadModSettings();
        }

        var modsFolder:String = modDirectory;
        var newMods:Array<String> = [];

        if (FileSystem.exists(modsFolder)) {
            for (item in FileSystem.readDirectory(modsFolder)) {
                var itemPath = haxe.io.Path.join([modsFolder, item]);
                if (FileSystem.isDirectory(itemPath)) {
                    processModFolder(item, itemPath, newMods);
                } else if (haxe.io.Path.extension(item).toLowerCase() == "zip") {
                    var modName = haxe.io.Path.withoutExtension(item);
                    var extractedFolder = haxe.io.Path.join([modsFolder, modName]);
                    if (!FileSystem.exists(extractedFolder)) {
                        extractZipMod(itemPath, extractedFolder);
                    }
                    if (FileSystem.isDirectory(extractedFolder)) {
                        processModFolder(modName, extractedFolder, newMods);
                    }
                }
            }

            var removedMods = modInfo.filter(info -> !FileSystem.exists(haxe.io.Path.join([modsFolder, info.folder])));
            if (removedMods.length > 0 || newMods.length > 0) {
                modInfo = modInfo.filter(info -> FileSystem.exists(haxe.io.Path.join([modsFolder, info.folder])));
                saveModSettings();
            }
        }

        return modInfo;
    }

    static private function processModFolder(folderName:String, folderPath:String, newMods:Array<String>):Void {
        var modExists:Bool = false;
        for (info in modInfo) {
            if (info.folder == folderName) {
                modExists = true;
                break;
            }
        }
        if (!modExists) {
            newMods.push(folderName);
            modInfo.push({ folder: folderName, enabled: true });
        }
    }

    static private function extractZipMod(zipPath:String, outputFolder:String):Void {
        Logger.log("Extracting mod zip: " + zipPath + " to " + outputFolder);
        try {
            var bytes:Bytes = File.getBytes(zipPath);
            var input:haxe.io.Input = new BytesInput(bytes);
            var zipReader = new Reader(input);
            var entries = zipReader.read();
            if (!sys.FileSystem.exists(outputFolder)) {
                sys.FileSystem.createDirectory(outputFolder);
            }
            for (entry in entries) {
                var outPath:String = haxe.io.Path.join([outputFolder, entry.fileName]);
                if (entry.fileName.endsWith("/")) {
                    if (!sys.FileSystem.exists(outPath)) {
                        sys.FileSystem.createDirectory(outPath);
                    }
                } else {
                    var dir:String = haxe.io.Path.directory(outPath);
                    if (!sys.FileSystem.exists(dir)) {
                        sys.FileSystem.createDirectory(dir);
                    }
                    var fileData:Bytes;
                    if (entry.compressed) {
                        fileData = Reader.unzip(entry);
                    } else {
                        fileData = entry.data;
                    }
                    var out:sys.io.FileOutput = File.write(outPath, false);
                    out.writeBytes(fileData, 0, fileData.length);
                    out.close();
                }
            }
        } catch (e:Dynamic) {
            Logger.log("Error: extracting ZIP file: " + e);
        }
    }

    static public function isModEnabled(folder:String):Bool {
        for (info in modInfo) {
            if (info.folder == folder) {
                return info.enabled;
            }
        }
        return false;
    }

    static public function toggleMod(folder:String, enable:Bool):Void {
        for (mod in modInfo) {
            if (mod.folder == folder) {
                mod.enabled = enable;
                saveModSettings();
                break;
            }
        }
    }

    static public function checkRestartStatus():Bool {
        for (modFolder in getModFolders()) {
            if (modFolder.enabled) {
                var filePath:String = haxe.io.Path.join([modDirectory, modFolder.folder, "data", "waitingToRestart.txt"]);
                if (FileSystem.exists(filePath)) {
                    var fileContent:String = sys.io.File.getContent(filePath).trim().toLowerCase();
                    return (fileContent == "true");
                }
            }
        }
        return false;
    }

    static public function saveModSettings():Void {
        var savePath:String = "mod_settings.txt";
        var file:sys.io.FileOutput = sys.io.File.write(savePath, false);
        for (info in modInfo) {
            file.writeString(info.folder + ":" + (info.enabled ? "1" : "0") + "\n");
        }
        getModFolders();
        file.close();
    }

    static private function loadModSettings():Void {
        var savePath:String = "mod_settings.txt";
        if (sys.FileSystem.exists(savePath)) {
            var fileContent:String = sys.io.File.getContent(savePath);
            var lines:Array<String> = fileContent.split("\n");
            for (line in lines) {
                var parts:Array<String> = line.split(":");
                if (parts.length == 2) {
                    var folder:String = parts[0].trim();
                    var enabled:Bool = (parts[1].trim() == "1");
                    modInfo.push({ folder: folder, enabled: enabled });
                }
            }
        }
    }
}

class ModScripts {
	public var script:hscript.Expr;
	public var interp = new Interp();
	public var parser = new Parser();

	public function new() {
        executeScript();
    }

    public function executeScript() {
        parser.allowTypes = true;
        parser.allowJSON = true;
        parser.allowMetadata = true;

		interp.allowStaticVariables = true;
        interp.allowPublicVariables = true;

		interp.variables.set("Int", Int);
		interp.variables.set("String", String);
		interp.variables.set("Float", Float);
		interp.variables.set("Array", Array);
		interp.variables.set("Bool", Bool);
		interp.variables.set("Dynamic", Dynamic);
		interp.variables.set("Math", Math);
        interp.variables.set("Sys", Sys);
		interp.variables.set("FlxMath", FlxMath);
		interp.variables.set("Std", Std);
		interp.variables.set("StringTools", StringTools);
		interp.variables.set("FlxG", FlxG);
		interp.variables.set("FlxSound", FlxSound);
		interp.variables.set("FlxSprite", FlxSprite);
		interp.variables.set("FlxText", FlxText);
		interp.variables.set("FlxGraphic", FlxGraphic);
		interp.variables.set("FlxTween", FlxTween);
		interp.variables.set("FlxEase", FlxEase);
		interp.variables.set("FlxCamera", FlxCamera);
		interp.variables.set("Assets", Assets);
		interp.variables.set("File", File);
		interp.variables.set("Window", Window);
		interp.variables.set("FileSystem", FileSystem);
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("FlxGroup", FlxGroup);
		interp.variables.set("FlxTimer", FlxTimer);
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
        interp.variables.set("Controls", Controls);
		interp.variables.set("Conductor", Conductor);
		interp.variables.set("Note", Note);
		interp.variables.set("Config", Config);
        interp.variables.set("ModPaths", ModPaths);
        interp.variables.set("MusicBeatState", MusicBeatState);
        interp.variables.set("MusicBeatSubstate", MusicBeatSubstate);
		#if VIDEOS
		interp.variables.set('VideoHandler', FlxVideo);
		interp.variables.set('FlxVideo', FlxVideo);
		interp.variables.set('FlxVideoSprite', FlxVideoSprite);
		#end
		interp.variables.set('BGSprite', BGSprite);
		interp.variables.set("FunkinShader", FunkinShader);
		interp.variables.set("CustomShader", CustomShader);
        interp.variables.set("window", lime.app.Application.current.window);
        interp.variables.set("FlxColor", system.classes.FlxColorHelper);
        interp.variables.set("FlxKey", system.classes.FlxKeyHelper);
        interp.variables.set("BlendMode", system.classes.BlendModeHelper);
        interp.variables.set("FlxCameraFollowStyle", system.classes.FlxCameraFollowStyleHelper);
        interp.variables.set("FlxTextAlign", system.classes.FlxTextAlignHelper);
        interp.variables.set("FlxTextBorderStyle", system.classes.FlxTextBorderStyleHelper);
        interp.variables.set("StringHelper", system.classes.StringHelper);

        interp.variables.set("switchState", function(state:String):Void {
            var modStatePath = ModPaths.script("data/states/" + state);
            if (modStatePath != null) {
                if (FileSystem.exists(modStatePath)) {
                    FlxG.switchState(Type.createInstance(ModScriptState, [modStatePath]));
                }
            }
        });

        interp.variables.set("openSubState", function(substate:String, pauseGame:Bool = false):Void {
            var modSubStatePath = ModPaths.script("data/substates/" + substate);
            if (modSubStatePath != null) {
                if (FileSystem.exists(modSubStatePath)) {
                    PlayState.instance.openSubState(Type.createInstance(ModScriptSubstate, [modSubStatePath]));
                }
            }
            if(pauseGame) {
                PlayState.instance.persistentUpdate = false;
                PlayState.instance.persistentDraw = true;
                PlayState.instance.paused = true;
                if(FlxG.sound.music != null) {
                    FlxG.sound.music.pause();
                    PlayState.instance.vocals.pause();
                }
            }
        });

        interp.variables.set("closeSubState", function() {
			if(ModScriptSubstate.instance != null) {
                PlayState.instance.closeSubState();
                ModScriptSubstate.instance = null;
                return true;
            }
            return false;
        });
    }

    public function loadScript(path:String):Void {
        var scriptContent:String = File.getContent(path);
        script = parser.parseString(scriptContent);
        interp.execute(script);
    }

	public function callFunction(funcName:String, ?args:Array<Dynamic>):Dynamic {
		if (args == null)
			args = [];
		try {
			var func:Dynamic = interp.variables.get(funcName);
			if (func != null && Reflect.isFunction(func))
				return Reflect.callMethod(null, func, args);
		} catch (error:Dynamic) {
			FlxG.log.add(error.details());
            Logger.log("Error:" + error);
		}
		return true;
	}
}

class ModScriptState extends MusicBeatState {
    public var scriptPath:String;
	public var interp = new Interp();
	public var parser = new Parser();

    override public function new(scriptPath:String) {
        this.scriptPath = scriptPath;
        executeScript();
        loadScript();
        super();
    }

    override function create():Void {
        callFunction("create", []);
        super.create();
        callFunction("createPost", []);
    }

	override function update(elapsed:Float) {
        callFunction("update", [elapsed]);
        super.update(elapsed);
        callFunction("updatePost", [elapsed]);
    }

	override function stepHit():Void {
        callFunction("stepHit", [curStep]);
        super.stepHit();
    }

    override function beatHit():Void {
        callFunction("beatHit", [curBeat]);
        super.beatHit();
    }

    public function executeScript() {
        parser.allowTypes = true;
        parser.allowJSON = true;
        parser.allowMetadata = true;

        interp.scriptObject = this;

		interp.allowStaticVariables = true;
        interp.allowPublicVariables = true;

		interp.variables.set("Int", Int);
		interp.variables.set("String", String);
		interp.variables.set("Float", Float);
		interp.variables.set("Array", Array);
		interp.variables.set("Bool", Bool);
		interp.variables.set("Dynamic", Dynamic);
		interp.variables.set("Math", Math);
        interp.variables.set("Sys", Sys);
		interp.variables.set("FlxMath", FlxMath);
		interp.variables.set("Std", Std);
		interp.variables.set("StringTools", StringTools);
		interp.variables.set("FlxG", FlxG);
		interp.variables.set("FlxSound", FlxSound);
		interp.variables.set("FlxSprite", FlxSprite);
		interp.variables.set("FlxText", FlxText);
		interp.variables.set("FlxGraphic", FlxGraphic);
		interp.variables.set("FlxTween", FlxTween);
		interp.variables.set("FlxEase", FlxEase);
		interp.variables.set("FlxCamera", FlxCamera);
		interp.variables.set("Assets", Assets);
		interp.variables.set("File", File);
		interp.variables.set("Window", Window);
		interp.variables.set("FileSystem", FileSystem);
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("FlxGroup", FlxGroup);
		interp.variables.set("FlxTimer", FlxTimer);
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
        interp.variables.set("Controls", Controls);
		interp.variables.set("Conductor", Conductor);
        interp.variables.set("controls", controls);
		interp.variables.set("Note", Note);
		interp.variables.set("Config", Config);
        interp.variables.set("ModPaths", ModPaths);
        interp.variables.set("MusicBeatState", MusicBeatState);
        interp.variables.set("MusicBeatSubstate", MusicBeatSubstate);
		#if VIDEOS
		interp.variables.set('VideoHandler', FlxVideo);
		interp.variables.set('FlxVideo', FlxVideo);
		interp.variables.set('FlxVideoSprite', FlxVideoSprite);
		#end
		interp.variables.set('BGSprite', BGSprite);
		interp.variables.set("FunkinShader", FunkinShader);
		interp.variables.set("CustomShader", CustomShader);
        interp.variables.set("window", lime.app.Application.current.window);
        interp.variables.set("FlxColor", system.classes.FlxColorHelper);
        interp.variables.set("FlxKey", system.classes.FlxKeyHelper);
        interp.variables.set("BlendMode", system.classes.BlendModeHelper);
        interp.variables.set("FlxCameraFollowStyle", system.classes.FlxCameraFollowStyleHelper);
        interp.variables.set("FlxTextAlign", system.classes.FlxTextAlignHelper);
        interp.variables.set("FlxTextBorderStyle", system.classes.FlxTextBorderStyleHelper);
        interp.variables.set("StringHelper", system.classes.StringHelper);

		interp.variables.set("members", members);
	    interp.variables.set("controls", controls);
	    interp.variables.set("curBeat", curBeat);
		interp.variables.set("curStep", curStep);

        interp.variables.set("switchState", function(state:String):Void {
            var modStatePath = ModPaths.script("data/states/" + state);
            if (modStatePath != null) {
                if (FileSystem.exists(modStatePath)) {
                    FlxG.switchState(Type.createInstance(ModScriptState, [modStatePath]));
                }
            }
        });

        interp.variables.set("openSubState", function(substate:String, pauseGame:Bool = false):Void {
            var modSubStatePath = ModPaths.script("data/substates/" + substate);
            if (modSubStatePath != null) {
                if (FileSystem.exists(modSubStatePath)) {
                    PlayState.instance.openSubState(Type.createInstance(ModScriptSubstate, [modSubStatePath]));
                }
            }
            if(pauseGame) {
                PlayState.instance.persistentUpdate = false;
                PlayState.instance.persistentDraw = true;
                PlayState.instance.paused = true;
                if(FlxG.sound.music != null) {
                    FlxG.sound.music.pause();
                    PlayState.instance.vocals.pause();
                }
            }
        });

        interp.variables.set("closeSubState", function() {
			if(ModScriptSubstate.instance != null) {
                PlayState.instance.closeSubState();
                ModScriptSubstate.instance = null;
                return true;
            }
            return false;
        });

		interp.variables.set("add", function(value:FlxObject) {
			add(value);
		});

		interp.variables.set("remove", function(value:FlxObject) {
			remove(value);
		});

		interp.variables.set("insert", function(position:Int, value:FlxObject) {
			insert(position, value);
		});
    }

    public function loadScript():Void {
        var scriptContent:String = File.getContent(scriptPath);
        var classDef = parser.parseString(scriptContent);
        interp.execute(classDef);
    }

	public function callFunction(funcName:String, ?args:Array<Dynamic>):Dynamic {
		if (args == null)
			args = [];
		try {
			var func:Dynamic = interp.variables.get(funcName);
			if (func != null && Reflect.isFunction(func))
				return Reflect.callMethod(null, func, args);
		} catch (error:Dynamic) {
			FlxG.log.add(error.details());
            Logger.log("Error:" + error);
		}
		return true;
	}
}

class ModScriptSubstate extends MusicBeatSubstate {
	public static var instance:ModScriptSubstate;

    public var scriptPath:String;
	public var interp = new Interp();
	public var parser = new Parser();

    override public function new(scriptPath:String) {
		instance = this;
        this.scriptPath = scriptPath;
        executeScript();
        loadScript();
        super();
        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
    }

    override function create():Void {
        callFunction("create", []);
        super.create();
        callFunction("createPost", []);
    }

	override function update(elapsed:Float) {
        callFunction("update", [elapsed]);
        super.update(elapsed);
        callFunction("updatePost", [elapsed]);
    }

	override function stepHit():Void {
        callFunction("stepHit", [curStep]);
        super.stepHit();
    }

    override function beatHit():Void {
        callFunction("beatHit", [curBeat]);
        super.beatHit();
    }

    public function executeScript() {
        parser.allowTypes = true;
        parser.allowJSON = true;
        parser.allowMetadata = true;

        interp.scriptObject = this;

		interp.allowStaticVariables = true;
        interp.allowPublicVariables = true;

		interp.variables.set("Int", Int);
		interp.variables.set("String", String);
		interp.variables.set("Float", Float);
		interp.variables.set("Array", Array);
		interp.variables.set("Bool", Bool);
		interp.variables.set("Dynamic", Dynamic);
		interp.variables.set("Math", Math);
        interp.variables.set("Sys", Sys);
		interp.variables.set("FlxMath", FlxMath);
		interp.variables.set("Std", Std);
		interp.variables.set("StringTools", StringTools);
		interp.variables.set("FlxG", FlxG);
		interp.variables.set("FlxSound", FlxSound);
		interp.variables.set("FlxSprite", FlxSprite);
		interp.variables.set("FlxText", FlxText);
		interp.variables.set("FlxGraphic", FlxGraphic);
		interp.variables.set("FlxTween", FlxTween);
		interp.variables.set("FlxEase", FlxEase);
		interp.variables.set("FlxCamera", FlxCamera);
		interp.variables.set("Assets", Assets);
		interp.variables.set("File", File);
		interp.variables.set("Window", Window);
		interp.variables.set("FileSystem", FileSystem);
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("FlxGroup", FlxGroup);
		interp.variables.set("FlxTimer", FlxTimer);
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
        interp.variables.set("Controls", Controls);
		interp.variables.set("Conductor", Conductor);
		interp.variables.set("Note", Note);
		interp.variables.set("Config", Config);
        interp.variables.set("ModPaths", ModPaths);
        interp.variables.set("MusicBeatState", MusicBeatState);
        interp.variables.set("MusicBeatSubstate", MusicBeatSubstate);
		#if VIDEOS
		interp.variables.set('VideoHandler', FlxVideo);
		interp.variables.set('FlxVideo', FlxVideo);
		interp.variables.set('FlxVideoSprite', FlxVideoSprite);
		#end
		interp.variables.set('BGSprite', BGSprite);
		interp.variables.set("FunkinShader", FunkinShader);
		interp.variables.set("CustomShader", CustomShader);
        interp.variables.set("window", lime.app.Application.current.window);
        interp.variables.set("FlxColor", system.classes.FlxColorHelper);
        interp.variables.set("FlxKey", system.classes.FlxKeyHelper);
        interp.variables.set("BlendMode", system.classes.BlendModeHelper);
        interp.variables.set("FlxCameraFollowStyle", system.classes.FlxCameraFollowStyleHelper);
        interp.variables.set("FlxTextAlign", system.classes.FlxTextAlignHelper);
        interp.variables.set("FlxTextBorderStyle", system.classes.FlxTextBorderStyleHelper);
        interp.variables.set("StringHelper", system.classes.StringHelper);

		interp.variables.set("members", members);
	    interp.variables.set("controls", controls);
	    interp.variables.set("curBeat", curBeat);
		interp.variables.set("curStep", curStep);

        interp.variables.set("switchState", function(state:String):Void {
            var modStatePath = ModPaths.script("data/states/" + state);
            if (modStatePath != null) {
                if (FileSystem.exists(modStatePath)) {
                    FlxG.switchState(Type.createInstance(ModScriptState, [modStatePath]));
                }
            }
        });

        interp.variables.set("openSubState", function(substate:String, pauseGame:Bool = false):Void {
            var modSubStatePath = ModPaths.script("data/substates/" + substate);
            if (modSubStatePath != null) {
                if (FileSystem.exists(modSubStatePath)) {
                    PlayState.instance.openSubState(Type.createInstance(ModScriptSubstate, [modSubStatePath]));
                }
            }
            if(pauseGame) {
                PlayState.instance.persistentUpdate = false;
                PlayState.instance.persistentDraw = true;
                PlayState.instance.paused = true;
                if(FlxG.sound.music != null) {
                    FlxG.sound.music.pause();
                    PlayState.instance.vocals.pause();
                }
            }
        });

        interp.variables.set("closeSubState", function() {
			if(ModScriptSubstate.instance != null) {
                PlayState.instance.closeSubState();
                ModScriptSubstate.instance = null;
                return true;
            }
            return false;
        });

		interp.variables.set("close", function() {
			close();
		});

		interp.variables.set("add", function(value:FlxObject) {
			add(value);
		});

		interp.variables.set("remove", function(value:FlxObject) {
			remove(value);
		});

		interp.variables.set("insert", function(position:Int, value:FlxObject) {
			insert(position, value);
		});
    }

    public function loadScript():Void {
        var scriptContent:String = File.getContent(scriptPath);
        var classDef = parser.parseString(scriptContent);
        interp.execute(classDef);
    }

	public function callFunction(funcName:String, ?args:Array<Dynamic>):Dynamic {
		if (args == null)
			args = [];
		try {
			var func:Dynamic = interp.variables.get(funcName);
			if (func != null && Reflect.isFunction(func))
				return Reflect.callMethod(null, func, args);
		} catch (error:Dynamic) {
			FlxG.log.add(error.details());
            Logger.log("Error:" + error);
		}
		return true;
	}
}
#end
