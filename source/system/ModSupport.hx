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
import hscript.Parser;
import hscript.Interp;
import sys.FileSystem;
import sys.io.File;

#if VIDEOS
#if (hxCodec >= "2.6.1") import hxcodec.VideoHandler as MP4Handler;
#elseif (hxCodec == "2.6.0") import VideoHandler as MP4Handler;
#else import vlc.MP4Handler; #end
#end

using StringTools;

class ModSupport {
    // lol
}

class ModPaths {
    public static var modDirectory:String = "mods/";

    inline static public function image(path:String):String {
        var fullPath:String = null;
        for (modFolder in getModFolders()) {
            fullPath = Sys.getCwd() + modDirectory + modFolder + "/images/" + path + ".png";
            if (FileSystem.exists(fullPath)) {
                break;
            }
        }
        return fullPath;
    }

    inline static public function sound(path:String):String {
        var fullPath:String = null;
        for (modFolder in getModFolders()) {
            fullPath = Sys.getCwd() + modDirectory + modFolder + "/" + path + ".ogg";
            if (FileSystem.exists(fullPath)) {
                break;
            }
        }
        return fullPath;
    }

    inline static public function data(path:String):String {
        var fullPath:String = null;
        for (modFolder in getModFolders()) {
            fullPath = Sys.getCwd() + modDirectory + modFolder + "/data/" + path + ".json";
            if (FileSystem.exists(fullPath)) {
                break;
            }
        }
        return fullPath;
    }

    inline static public function script(path:String):String {
        var fullPath:String = null;
        for (modFolder in getModFolders()) {
            fullPath = Sys.getCwd() + modDirectory + modFolder + "/" + path + ".hx";
            if (FileSystem.exists(fullPath)) {
                break;
            }
        }
        return fullPath;
    }

    inline static public function modFolder(path:String):String {
        var fullPath:String = null;
        for (modFolder in getModFolders()) {
            fullPath = Sys.getCwd() + modDirectory + modFolder + "/" + path;
            if (FileSystem.exists(fullPath)) {
                break;
            }
        }
        return fullPath;
    }

	static public function getModFolders():Array<String> {
		var list:Array<String> = [];
		var modsFolder:String = modDirectory;
		if(FileSystem.exists(modsFolder)) {
			for (folder in FileSystem.readDirectory(modsFolder)) {
				var path = haxe.io.Path.join([modsFolder, folder]);
				if (FileSystem.isDirectory(path) && !list.contains(folder)) {
					list.push(folder);
				}
			}
		}
		return list;
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
		interp.variables.set('MP4Handler', MP4Handler);
		#end
		interp.variables.set('BGSprite', BGSprite);
		interp.variables.set('Modchart', ModchartAPI);
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
        var scriptContent:String = File.getContent(ModPaths.script(path));
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
            trace(error);
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
		interp.variables.set('MP4Handler', MP4Handler);
		#end
		interp.variables.set('BGSprite', BGSprite);
		interp.variables.set('Modchart', ModchartAPI);
        interp.variables.set("FlxColor", system.classes.FlxColorHelper);
        interp.variables.set("FlxKey", system.classes.FlxKeyHelper);
        interp.variables.set("BlendMode", system.classes.BlendModeHelper);
        interp.variables.set("FlxCameraFollowStyle", system.classes.FlxCameraFollowStyleHelper);
        interp.variables.set("FlxTextAlign", system.classes.FlxTextAlignHelper);
        interp.variables.set("FlxTextBorderStyle", system.classes.FlxTextBorderStyleHelper);
        interp.variables.set("StringHelper", system.classes.StringHelper);

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
            trace(error);
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
		interp.variables.set('MP4Handler', MP4Handler);
		#end
		interp.variables.set('BGSprite', BGSprite);
		interp.variables.set('Modchart', ModchartAPI);
        interp.variables.set("FlxColor", system.classes.FlxColorHelper);
        interp.variables.set("FlxKey", system.classes.FlxKeyHelper);
        interp.variables.set("BlendMode", system.classes.BlendModeHelper);
        interp.variables.set("FlxCameraFollowStyle", system.classes.FlxCameraFollowStyleHelper);
        interp.variables.set("FlxTextAlign", system.classes.FlxTextAlignHelper);
        interp.variables.set("FlxTextBorderStyle", system.classes.FlxTextBorderStyleHelper);
        interp.variables.set("StringHelper", system.classes.StringHelper);

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
            trace(error);
		}
		return true;
	}
}

class ModchartAPI {
	static public function tweenCameraPos(toX:Int, toY:Int, time:Float, camera:Any) {
		FlxTween.tween(camera, {x: toX, y: toY}, time, {ease: FlxEase.linear} );
	}

	static public function tweenCameraAngle(toAngle:Float, time:Float, camera:Any) {
		FlxTween.tween(camera, {angle:toAngle}, time, {ease: FlxEase.linear});
	};

	static public function tweenCameraZoom(toZoom:Float, time:Float, camera:Any) {
		FlxTween.tween(camera, {zoom:toZoom}, time, {ease: FlxEase.linear });
	};

	static public function tweenHudPos(toX:Int, toY:Int, time:Float) {
		FlxTween.tween(PlayState.instance.camHUD, {x: toX, y: toY}, time, {ease: FlxEase.linear});
	};

	static public function tweenHudAngle(toAngle:Float, time:Float) {
		FlxTween.tween(PlayState.instance.camHUD, {angle:toAngle}, time, {ease: FlxEase.linear });
	};

	static public function tweenHudZoom(toZoom:Float, time:Float) {
		FlxTween.tween(PlayState.instance.camHUD, {zoom:toZoom}, time, {ease: FlxEase.linear});
	};

	static public function tweenPos(id:FlxObject , toX:Int, toY:Int, time:Float) {
		FlxTween.tween(id, {x: toX, y: toY}, time, {ease: FlxEase.linear});
	};

	static public function tweenPosXAngle(id:FlxObject, toX:Int, toAngle:Float, time:Float) {
		FlxTween.tween(id, {x: toX, angle: toAngle}, time, {ease: FlxEase.linear});
	};

	static public function tweenPosYAngle(id:FlxObject, toY:Int, toAngle:Float, time:Float) {
		FlxTween.tween(id, {y: toY, angle: toAngle}, time, {ease: FlxEase.linear });
	};

	static public function tweenAngle(id:FlxObject, toAngle:Int, time:Float) {
		FlxTween.tween(id, {angle: toAngle}, time, {ease: FlxEase.linear});
	};

	static public function tweenCameraPosOut(toX:Int, toY:Int, time:Float, camera:Any) {
		FlxTween.tween(camera, {x: toX, y: toY}, time, {ease: FlxEase.cubeOut});
	};

	static public function tweenCameraAngleOut(toAngle:Float, time:Float, camera:Any) {
		FlxTween.tween(camera, {angle:toAngle}, time, {ease: FlxEase.cubeOut});
	};

	static public function tweenCameraZoomOut(toZoom:Float, time:Float, camera:Any) {
		FlxTween.tween(camera, {zoom:toZoom}, time, {ease: FlxEase.cubeOut});
	};

	static public function tweenHudPosOut(toX:Int, toY:Int, time:Float) {
		FlxTween.tween(PlayState.instance.camHUD, {x: toX, y: toY}, time, {ease: FlxEase.cubeOut });
	};

	static public function tweenHudAngleOut(toAngle:Float, time:Float) {
		FlxTween.tween(PlayState.instance.camHUD, {angle:toAngle}, time, {ease: FlxEase.cubeOut });
	};

	static public function tweenHudZoomOut(toZoom:Float, time:Float) {
		FlxTween.tween(PlayState.instance.camHUD, {zoom:toZoom}, time, {ease: FlxEase.cubeOut });
	};

	static public function tweenPosOut(id:FlxObject, toX:Int, toY:Int, time:Float) {
		FlxTween.tween(id, {x: toX, y: toY}, time, {ease: FlxEase.cubeOut});
	};

	static public function tweenPosXAngleOut(id:FlxObject, toX:Int, toAngle:Float, time:Float) {
		FlxTween.tween(id, {x: toX, angle: toAngle}, time, {ease: FlxEase.cubeOut});
	};

	static public function tweenPosYAngleOut(id:FlxObject, toY:Int, toAngle:Float, time:Float) {
		FlxTween.tween(id, {y: toY, angle: toAngle}, time, {ease: FlxEase.cubeOut});
	};

	static public function tweenAngleOut(id:FlxObject, toAngle:Int, time:Float) {
		FlxTween.tween(id, {angle: toAngle}, time, {ease: FlxEase.cubeOut });
	};

	static public function tweenCameraPosIn(toX:Int, toY:Int, time:Float, camera:Any) {
		FlxTween.tween(camera, {x: toX, y: toY}, time, {ease: FlxEase.cubeIn });
	};

	static public function tweenCameraAngleIn(toAngle:Float, time:Float, camera:Any) {
		FlxTween.tween(camera, {angle:toAngle}, time, {ease: FlxEase.cubeIn });
	};

	static public function tweenCameraZoomIn(toZoom:Float, time:Float, camera:Any) {
		FlxTween.tween(camera, {zoom:toZoom}, time, {ease: FlxEase.cubeIn });
	};

	static public function tweenHudPosIn(toX:Int, toY:Int, time:Float) {
		FlxTween.tween(PlayState.instance.camHUD, {x: toX, y: toY}, time, {ease: FlxEase.cubeIn });
	};

	static public function tweenHudAngleIn(toAngle:Float, time:Float) {
		FlxTween.tween(PlayState.instance.camHUD, {angle:toAngle}, time, {ease: FlxEase.cubeIn });
	};

	static public function tweenHudZoomIn(toZoom:Float, time:Float) {
		FlxTween.tween(PlayState.instance.camHUD, {zoom:toZoom}, time, {ease: FlxEase.cubeIn });
	};

	static public function tweenPosIn(id:FlxObject, toX:Int, toY:Int, time:Float) {
		FlxTween.tween(id, {x: toX, y: toY}, time, {ease: FlxEase.cubeIn });
	};

	static public function tweenPosXAngleIn(id:FlxObject, toX:Int, toAngle:Float, time:Float) {
		FlxTween.tween(id, {x: toX, angle: toAngle}, time, {ease: FlxEase.cubeIn });
	};

	static public function tweenPosYAngleIn(id:FlxObject, toY:Int, toAngle:Float, time:Float) {
		FlxTween.tween(id, {y: toY, angle: toAngle}, time, {ease: FlxEase.cubeIn });
	};

	static public function tweenAngleIn(id:FlxObject, toAngle:Int, time:Float) {
		FlxTween.tween(id, {angle: toAngle}, time, {ease: FlxEase.cubeIn });
	};

	static public function tweenFadeIn(id:FlxObject, toAlpha:Float, time:Float) {
		FlxTween.tween(id, {alpha: toAlpha}, time, {ease: FlxEase.circIn });
	};

	static public function tweenFadeOut(id:FlxObject, toAlpha:Float, time:Float) {
		FlxTween.tween(id, {alpha: toAlpha}, time, {ease: FlxEase.circOut });
	};
}
#end
