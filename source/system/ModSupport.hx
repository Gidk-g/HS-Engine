package system;

#if sys
import haxe.Json;
import flixel.FlxG;
import haxe.io.Path;
import Type.ValueType;
import flixel.FlxObject;
import flixel.math.FlxAngle;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import openfl.display.BlendMode;
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
import llua.Convert;
import llua.Lua;
import llua.State;
import llua.LuaL;

using StringTools;

class ModSupport {
    // lol
}

class ModPaths {
    public static var modDirectory:String = "mods/";

    inline static public function image(path:String):String {
        var fullPath:String = null;
        for (modFolder in FileSystem.readDirectory("mods")) {
            fullPath = modDirectory + modFolder + "/images/" + path + ".png";
            if (FileSystem.exists(fullPath)) {
                break;
            }
        }
        return fullPath;
    }

    inline static public function sound(path:String):String {
        var fullPath:String = null;
        for (modFolder in FileSystem.readDirectory("mods")) {
            fullPath = modDirectory + modFolder + "/" + path + ".ogg";
            if (FileSystem.exists(fullPath)) {
                break;
            }
        }
        return fullPath;
    }

    inline static public function data(path:String):String {
        var fullPath:String = null;
        for (modFolder in FileSystem.readDirectory("mods")) {
            fullPath = modDirectory + modFolder + "/data/" + path + ".json";
            if (FileSystem.exists(fullPath)) {
                break;
            }
        }
        return fullPath;
    }

    inline static public function modFolder(path:String):String {
        var fullPath:String = null;
        for (modFolder in FileSystem.readDirectory("mods")) {
            fullPath = modDirectory + modFolder + "/" + path;
            if (FileSystem.exists(fullPath)) {
                break;
            }
        }
        return fullPath;
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

		interp.variables.set('Modchart', ModchartAPI);

        interp.variables.set("FlxColor", system.classes.FlxColorHelper);
        interp.variables.set("FlxKey", system.classes.FlxKeyHelper);
        interp.variables.set("BlendMode", system.classes.BlendModeHelper);
        interp.variables.set("FlxCameraFollowStyle", system.classes.FlxCameraFollowStyleHelper);
        interp.variables.set("FlxTextAlign", system.classes.FlxTextAlignHelper);
        interp.variables.set("FlxTextBorderStyle", system.classes.FlxTextBorderStyleHelper);
        interp.variables.set("StringHelper", system.classes.StringHelper);

        interp.variables.set("switchState", function(state:String):Void {
            var modStatePath = ModPaths.modFolder("data/states/" + state + ".hx");
            if (modStatePath != null) {
                if (FileSystem.exists(modStatePath)) {
                    FlxG.switchState(Type.createInstance(ModScriptState, [modStatePath]));
                }
            }
        });

        interp.variables.set("openSubState", function(substate:String, pauseGame:Bool = false):Void {
            var modSubStatePath = ModPaths.modFolder("data/substates/" + substate + ".hx");
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
        var scriptContent:String = File.getContent(ModPaths.modFolder(path + ".hx"));
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
        callFunction("create");
        super.create();
        callFunction("createPost");
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
            var modStatePath = ModPaths.modFolder("data/states/" + state + ".hx");
            if (modStatePath != null) {
                if (FileSystem.exists(modStatePath)) {
                    FlxG.switchState(Type.createInstance(ModScriptState, [modStatePath]));
                }
            }
        });

        interp.variables.set("openSubState", function(substate:String, pauseGame:Bool = false):Void {
            var modSubStatePath = ModPaths.modFolder("data/substates/" + substate + ".hx");
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
        callFunction("create");
        super.create();
        callFunction("createPost");
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
            var modStatePath = ModPaths.modFolder("data/states/" + state + ".hx");
            if (modStatePath != null) {
                if (FileSystem.exists(modStatePath)) {
                    FlxG.switchState(Type.createInstance(ModScriptState, [modStatePath]));
                }
            }
        });

        interp.variables.set("openSubState", function(substate:String, pauseGame:Bool = false):Void {
            var modSubStatePath = ModPaths.modFolder("data/substates/" + substate + ".hx");
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

class ModLuaScripts {
	public static var Function_Stop = 1;
	public static var Function_Continue = 0;

	private  var lua:State = null;

	var lePlayState:PlayState = null;

	#if (haxe >= "4.0.0")
	public var tweens:Map<String, FlxTween> = new Map();
	public var sprites:Map<String, LuaSprite> = new Map();
	public var timers:Map<String, FlxTimer> = new Map();
	#else
	public var tweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var sprites:Map<String, LuaSprite> = new Map<String, Dynamic>();
	public var timers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	#end

	public function new(script:String) {
		lua = LuaL.newstate();
		LuaL.openlibs(lua);
		Lua.init_callbacks(lua);

		var result:Dynamic = LuaL.dofile(lua, script);
		var resultStr:String = Lua.tostring(lua, result);

		if(resultStr != null && result != 0) {
			lime.app.Application.current.window.alert(resultStr, 'Error on .LUA script!');
			trace('Error on .LUA script! ' + resultStr);
			lua = null;
			return;
		}

		var curState:Dynamic = FlxG.state;
		lePlayState = curState;

		setVar('Function_Stop', Function_Stop);
		setVar('Function_Continue', Function_Continue);

		setVar('curBpm', Conductor.bpm);
		setVar('bpm', PlayState.SONG.bpm);
		setVar('scrollSpeed', PlayState.SONG.speed);
		setVar('crochet', Conductor.crochet);
		setVar('stepCrochet', Conductor.stepCrochet);
		setVar('songLength', FlxG.sound.music.length);
		setVar('songName', PlayState.SONG.song);

		setVar('cameraX', 0);
		setVar('cameraY', 0);

		setVar('screenWidth', FlxG.width);
		setVar('screenHeight', FlxG.height);

		setVar('curBeat', 0);
		setVar('curStep', 0);

		Lua_helper.add_callback(lua, "playSound", function(sound:String, volume:Float = 1) {
			FlxG.sound.play(Paths.sound(sound), volume);
		});	

		Lua_helper.add_callback(lua, "startCountdown", function(variable:String) {
			lePlayState.startCountdown();
		});

		Lua_helper.add_callback(lua, "getSongPosition", function() {
			return Conductor.songPosition;
		});

		Lua_helper.add_callback(lua, "getColorFromHex", function(color:String) {
			if(!color.startsWith('0x')) color = '0xff' + color;
			return Std.parseInt(color);
		});

		Lua_helper.add_callback(lua, "cameraShake", function(camera:String, intensity:Float, duration:Float) {
			cameraFromString(camera).shake(intensity, duration);
		});

		Lua_helper.add_callback(lua, "cameraFlash", function(camera:String, color:String, duration:Float,forced:Bool) {
			var colorNum:Int = Std.parseInt(color);
			if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);
			cameraFromString(camera).flash(colorNum, duration,null,forced);
		});

		Lua_helper.add_callback(lua, "cameraFade", function(camera:String, color:String, duration:Float,forced:Bool) {
			var colorNum:Int = Std.parseInt(color);
			if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);
			cameraFromString(camera).fade(colorNum, duration,false,null,forced);
		});

		Lua_helper.add_callback(lua, "getProperty", function(variable:String) {
			var killMe:Array<String> = variable.split('.');
			if(killMe.length > 1) {
				var coverMeInPiss:Dynamic = Reflect.getProperty(lePlayState, killMe[0]);
				for (i in 1...killMe.length-1) {
					coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
				}
				return Reflect.getProperty(coverMeInPiss, killMe[killMe.length-1]);
			}
			return Reflect.getProperty(lePlayState, variable);
		});

		Lua_helper.add_callback(lua, "setProperty", function(variable:String, value:Dynamic) {
			var killMe:Array<String> = variable.split('.');
			if(killMe.length > 1) {
				var coverMeInPiss:Dynamic = Reflect.getProperty(lePlayState, killMe[0]);
				for (i in 1...killMe.length-1) {
					coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
				}
				return Reflect.setProperty(coverMeInPiss, killMe[killMe.length-1], value);
			}
			return Reflect.setProperty(lePlayState, variable, value);
		});

		Lua_helper.add_callback(lua, "getPropertyFromGroup", function(obj:String, index:Int, variable:Dynamic) {
			if(Std.isOfType(Reflect.getProperty(lePlayState, obj), FlxTypedGroup)) {
				return Reflect.getProperty(Reflect.getProperty(lePlayState, obj).members[index], variable);
			}

			var leArray:Dynamic = Reflect.getProperty(lePlayState, obj)[index];
			if(leArray != null) {
				if(Type.typeof(variable) == ValueType.TInt) {
					return leArray[variable];
				}
				return Reflect.getProperty(leArray, variable);
			}
			return null;
		});

		Lua_helper.add_callback(lua, "setPropertyFromGroup", function(obj:String, index:Int, variable:Dynamic, value:Dynamic) {
			if(Std.isOfType(Reflect.getProperty(lePlayState, obj), FlxTypedGroup)) {
				return Reflect.setProperty(Reflect.getProperty(lePlayState, obj).members[index], variable, value);
			}

			var leArray:Dynamic = Reflect.getProperty(lePlayState, obj)[index];
			if(leArray != null) {
				if(Type.typeof(variable) == ValueType.TInt) {
					return leArray[variable] = value;
				}
				return Reflect.setProperty(leArray, variable, value);
			}
		});

		Lua_helper.add_callback(lua, "removeFromGroup", function(obj:String, index:Int, dontKill:Bool = false, dontDestroy:Bool = false) {
			if(Std.isOfType(Reflect.getProperty(lePlayState, obj), FlxTypedGroup)) {
				var sex = Reflect.getProperty(lePlayState, obj).members[index];
				if(!dontKill)
					sex.kill();
				Reflect.getProperty(lePlayState, obj).remove(sex, true);
				if(!dontDestroy)
					sex.destroy();
				return;
			}
			Reflect.getProperty(lePlayState, obj).remove(Reflect.getProperty(lePlayState, obj)[index]);
		});

		Lua_helper.add_callback(lua, "getPropertyFromClass", function(classVar:String, variable:String) {
			var killMe:Array<String> = variable.split('.');
			if(killMe.length > 1) {
				var coverMeInPiss:Dynamic = Reflect.getProperty(Type.resolveClass(classVar), killMe[0]);
				for (i in 1...killMe.length-1) {
					coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
				}
				return Reflect.getProperty(coverMeInPiss, killMe[killMe.length-1]);
			}
			return Reflect.getProperty(Type.resolveClass(classVar), variable);
		});

		Lua_helper.add_callback(lua, "setPropertyFromClass", function(classVar:String, variable:String, value:Dynamic) {
			var killMe:Array<String> = variable.split('.');
			if(killMe.length > 1) {
				var coverMeInPiss:Dynamic = Reflect.getProperty(Type.resolveClass(classVar), killMe[0]);
				for (i in 1...killMe.length-1) {
					coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
				}
				return Reflect.setProperty(coverMeInPiss, killMe[killMe.length-1], value);
			}
			return Reflect.setProperty(Type.resolveClass(classVar), variable, value);
		});

		Lua_helper.add_callback(lua, "makeSprite", function(tag:String, image:String, x:Float, y:Float) {
			resetSpriteTag(tag);
			var leSprite:LuaSprite = new LuaSprite(x, y);
			leSprite.loadGraphic(Paths.image(image));
			leSprite.antialiasing = true;
			sprites.set(tag, leSprite);
			leSprite.active = false;
		});

		Lua_helper.add_callback(lua, "makeAnimatedSprite", function(tag:String, image:String, x:Float, y:Float) {
			resetSpriteTag(tag);
			var leSprite:LuaSprite = new LuaSprite(x, y);
			leSprite.frames = Paths.getSparrowAtlas(image);
			leSprite.antialiasing = true;
			sprites.set(tag, leSprite);
		});

		Lua_helper.add_callback(lua, "makeGraphicSprite", function(tag:String, width:Int, height:Int, color:String) {
			if(sprites.exists(tag)) {
				var colorNum:Int = Std.parseInt(color);
				if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);
				var cock:LuaSprite = sprites.get(tag);
				cock.makeGraphic(width, height, colorNum);
			}
		});

		Lua_helper.add_callback(lua, "addAnimationByPrefixSprite", function(tag:String, name:String, prefix:String, framerate:Int = 24, loop:Bool = true) {
			if(sprites.exists(tag)) {
				var cock:LuaSprite = sprites.get(tag);
				cock.animation.addByPrefix(name, prefix, framerate, loop);
				if(cock.animation.curAnim == null) {
					cock.animation.play(name, true);
				}
			}
		});

		Lua_helper.add_callback(lua, "addAnimationByIndicesSprite", function(tag:String, name:String, prefix:String, indices:String, framerate:Int = 24) {
			if(sprites.exists(tag)) {
				var strIndices:Array<String> = indices.trim().split(',');
				var die:Array<Int> = [];
				for (i in 0...strIndices.length) {
					die.push(Std.parseInt(strIndices[i]));
				}
				var pussy:LuaSprite = sprites.get(tag);
				pussy.animation.addByIndices(name, prefix, die, '', framerate, false);
				if(pussy.animation.curAnim == null) {
					pussy.animation.play(name, true);
				}
			}
		});

		Lua_helper.add_callback(lua, "playAnimationSprite", function(tag:String, name:String, forced:Bool = false) {
			if(sprites.exists(tag)) {
				sprites.get(tag).animation.play(name, forced);
			}
		});

		Lua_helper.add_callback(lua, "setScrollFactorSprite", function(tag:String, scrollX:Float, scrollY:Float) {
			if(sprites.exists(tag)) {
				sprites.get(tag).scrollFactor.set(scrollX, scrollY);
			}
		});

		Lua_helper.add_callback(lua, "setGraphicSizeSprite", function(tag:String, x:Int, y:Int = 0, updateHitbox:Bool = true) {
			if(sprites.exists(tag)) {
				var cock:LuaSprite = sprites.get(tag);
				cock.setGraphicSize(x, y);
				if(updateHitbox) cock.updateHitbox();
				return;
			}
		});

		Lua_helper.add_callback(lua, "scaleObjectSprite", function(tag:String, x:Int, y:Int = 0, updateHitbox:Bool = true) {
			if(sprites.exists(tag)) {
				var cock:LuaSprite = sprites.get(tag);
				cock.scale.set(x, y);
				if(updateHitbox) cock.updateHitbox();
				return;
			}
		});

		Lua_helper.add_callback(lua, "updateHitboxSprite", function(tag:String) {
			if(sprites.exists(tag)) {
				var cock:LuaSprite = sprites.get(tag);
                cock.updateHitbox();
				return;
			}
		});

		Lua_helper.add_callback(lua, "setObjectCameraSprite", function(tag:String, camera:String = '') {
			if(sprites.exists(tag)) {
				var cock:LuaSprite = sprites.get(tag);
                cock.cameras = [cameraFromString(camera)];
				return;
			}
		});

		Lua_helper.add_callback(lua, "setBlendModeSprite", function(tag:String, blend:String = '') {
			if(sprites.exists(tag)) {
				var cock:LuaSprite = sprites.get(tag);
                cock.blend = blendModeFromString(blend);
				return;
			}
		});

		Lua_helper.add_callback(lua, "screenCenterSprite", function(tag:String, pos:String = 'xy') {
			if(sprites.exists(tag)) {
			    var spr:LuaSprite = sprites.get(tag);
			    if(spr != null)
				{
					switch(pos.trim().toLowerCase())
					{
						case 'x':
							spr.screenCenter(X);
							return;
						case 'y':
							spr.screenCenter(Y);
							return;
						default:
							spr.screenCenter(XY);
							return;
					}
				}
		    }
		});

		Lua_helper.add_callback(lua, "addSprite", function(tag:String, front:Bool = false) {
			if(sprites.exists(tag)) {
				var shit:LuaSprite = sprites.get(tag);
				if(!shit.wasAdded) {
					if(front) {
						lePlayState.foregroundGroup.add(shit);
					} else {
						lePlayState.backgroundGroup.add(shit);
					}
					shit.isInFront = front;
					shit.wasAdded = true;
				}
			}
		});

		Lua_helper.add_callback(lua, "removeSprite", function(tag:String) {
			resetSpriteTag(tag);
		});

		Lua_helper.add_callback(lua, "getPropertySprite", function(tag:String, variable:String) {
			if(sprites.exists(tag)) {
				var killMe:Array<String> = variable.split('.');
				if(killMe.length > 1) {
					var coverMeInPiss:Dynamic = Reflect.getProperty(sprites.get(tag), killMe[0]);
					for (i in 1...killMe.length-1) {
						coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
					}
					return Reflect.getProperty(coverMeInPiss, killMe[killMe.length-1]);
				}
				return Reflect.getProperty(sprites.get(tag), variable);
			}
			return null;
		});

		Lua_helper.add_callback(lua, "setPropertySprite", function(tag:String, variable:String, value:Dynamic) {
			if(sprites.exists(tag)) {
				var killMe:Array<String> = variable.split('.');
				if(killMe.length > 1) {
					var coverMeInPiss:Dynamic = Reflect.getProperty(sprites.get(tag), killMe[0]);
					for (i in 1...killMe.length-1) {
						coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
					}
					return Reflect.setProperty(coverMeInPiss, killMe[killMe.length-1], value);
				}
				return Reflect.setProperty(sprites.get(tag), variable, value);
			}
		});

		Lua_helper.add_callback(lua, "characterPlayAnim", function(character:String, anim:String, ?forced:Bool = false) {
			switch(character.toLowerCase()) {
				case 'dad':
					if(lePlayState.dad.animOffsets.exists(anim))
						lePlayState.dad.playAnim(anim, forced);
				case 'gf' | 'girlfriend':
					if(lePlayState.gf.animOffsets.exists(anim))
						lePlayState.gf.playAnim(anim, forced);
				default: 
					if(lePlayState.boyfriend.animOffsets.exists(anim))
						lePlayState.boyfriend.playAnim(anim, forced);
			}
		});

		Lua_helper.add_callback(lua, "characterDance", function(character:String) {
			switch(character.toLowerCase()) {
				case 'dad': lePlayState.dad.dance();
				case 'gf' | 'girlfriend': lePlayState.gf.dance();
				default: lePlayState.boyfriend.dance();
			}
		});

		Lua_helper.add_callback(lua, "mouseClicked", function(button:String) {
			var boobs = FlxG.mouse.justPressed;
			switch(button) {
				case 'middle':
					boobs = FlxG.mouse.justPressedMiddle;
				case 'right':
					boobs = FlxG.mouse.justPressedRight;
			}
			return boobs;
		});

		Lua_helper.add_callback(lua, "mousePressed", function(button:String) {
			var boobs = FlxG.mouse.pressed;
			switch(button) {
				case 'middle':
					boobs = FlxG.mouse.pressedMiddle;
				case 'right':
					boobs = FlxG.mouse.pressedRight;
			}
			return boobs;
		});

		Lua_helper.add_callback(lua, "mouseReleased", function(button:String) {
			var boobs = FlxG.mouse.justReleased;
			switch(button) {
				case 'middle':
					boobs = FlxG.mouse.justReleasedMiddle;
				case 'right':
					boobs = FlxG.mouse.justReleasedRight;
			}
			return boobs;
		});

		Lua_helper.add_callback(lua, "setHealthBarColors", function(leftHex:String, rightHex:String) {
			var left:FlxColor = Std.parseInt(leftHex);
			if(!leftHex.startsWith('0x')) left = Std.parseInt('0xff' + leftHex);
			var right:FlxColor = Std.parseInt(rightHex);
			if(!rightHex.startsWith('0x')) right = Std.parseInt('0xff' + rightHex);
			PlayState.instance.healthBar.createFilledBar(left, right);
			PlayState.instance.healthBar.updateBar();
		});

		Lua_helper.add_callback(lua, "getMouseX", function(camera:String) {
			var cam:FlxCamera = cameraFromString(camera);
			return FlxG.mouse.getScreenPosition(cam).x;
		});

		Lua_helper.add_callback(lua, "getMouseY", function(camera:String) {
			var cam:FlxCamera = cameraFromString(camera);
			return FlxG.mouse.getScreenPosition(cam).y;
		});

		Lua_helper.add_callback(lua, "doTweenX", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String, delay:Float = 0) {
			var penisExam:Dynamic = tweenShit(tag, vars);
			if(penisExam != null) {
				tweens.set(tag, FlxTween.tween(penisExam, {x: value}, duration, {ease: getFlxEaseByString(ease), startDelay: delay,
					onComplete: function(twn:FlxTween) {
						call('onTweenCompleted', [tag]);
						tweens.remove(tag);
					}
				}));
			}
		});

		Lua_helper.add_callback(lua, "doTweenY", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String, delay:Float = 0) {
			var penisExam:Dynamic = tweenShit(tag, vars);
			if(penisExam != null) {
				tweens.set(tag, FlxTween.tween(penisExam, {y: value}, duration, {ease: getFlxEaseByString(ease), startDelay: delay,
					onComplete: function(twn:FlxTween) {
						call('onTweenCompleted', [tag]);
						tweens.remove(tag);
					}
				}));
			}
		});

		Lua_helper.add_callback(lua, "doTweenAlpha", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String, delay:Float = 0) {
			var penisExam:Dynamic = tweenShit(tag, vars);
			if(penisExam != null) {
				tweens.set(tag, FlxTween.tween(penisExam, {alpha: value}, duration, {ease: getFlxEaseByString(ease), startDelay: delay,
					onComplete: function(twn:FlxTween) {
						call('onTweenCompleted', [tag]);
						tweens.remove(tag);
					}
				}));
			}
		});

		Lua_helper.add_callback(lua, "doTweenZoom", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String, delay:Float = 0) {
			var penisExam:Dynamic = tweenShit(tag, vars);
			if(penisExam != null) {
				tweens.set(tag, FlxTween.tween(penisExam, {zoom: value}, duration, {ease: getFlxEaseByString(ease), startDelay: delay,
					onComplete: function(twn:FlxTween) {
						call('onTweenCompleted', [tag]);
						tweens.remove(tag);
					}
				}));
			}
		});

		Lua_helper.add_callback(lua, "doTweenColor", function(tag:String, vars:String, targetColor:String, duration:Float, ease:String, delay:Float = 0) {
			var penisExam:Dynamic = tweenShit(tag, vars);
			if(penisExam != null) {
				var color:Int = Std.parseInt(targetColor);
				if(!targetColor.startsWith('0x')) color = Std.parseInt('0xff' + targetColor);
				tweens.set(tag, FlxTween.color(penisExam, duration, penisExam.color, color, {ease: getFlxEaseByString(ease), startDelay: delay,
					onComplete: function(twn:FlxTween) {
						tweens.remove(tag);
						call('onTweenCompleted', [tag]);
					}
				}));
			}
		});

		Lua_helper.add_callback(lua, "cancelTween", function(tag:String) {
			cancelTween(tag);
		});

		Lua_helper.add_callback(lua, "runTimer", function(tag:String, time:Float = 1, loops:Int = 1) {
			cancelTimer(tag);
			timers.set(tag, new FlxTimer().start(time, function(tmr:FlxTimer) {
				if(tmr.finished) {
					timers.remove(tag);
				}
				call('onTimerCompleted', [tag, tmr.loops, tmr.loopsLeft]);
			}, loops));
		});

		Lua_helper.add_callback(lua, "cancelTimer", function(tag:String) {
			cancelTimer(tag);
		});
    }

	function resetSpriteTag(tag:String) {
		if(!sprites.exists(tag)) {
			return;
		}
		var pee:LuaSprite = sprites.get(tag);
		pee.kill();
		if(pee.wasAdded) {
			if(pee.isInFront) {
				lePlayState.foregroundGroup.remove(pee, true);
			} else {
				lePlayState.backgroundGroup.remove(pee, true);
			}
		}
		pee.destroy();
		sprites.remove(tag);
	}

	function cancelTween(tag:String) {
		if(tweens.exists(tag)) {
			tweens.get(tag).cancel();
			tweens.get(tag).destroy();
			tweens.remove(tag);
		}
	}

	function tweenShit(tag:String, vars:String) {
		cancelTween(tag);
		var variables:Array<String> = vars.replace(' ', '').split('.');
		var sexyProp:Dynamic = Reflect.getProperty(lePlayState, variables[0]);
		if(sexyProp == null && sprites.exists(variables[0])) {
			sexyProp = sprites.get(variables[0]);
		}
		for (i in 1...variables.length) {
			sexyProp = Reflect.getProperty(sexyProp, variables[i]);
		}
		return sexyProp;
	}

	function cancelTimer(tag:String) {
		if(timers.exists(tag)) {
			timers.get(tag).cancel();
			timers.get(tag).destroy();
			timers.remove(tag);
		}
	}

	function blendModeFromString(blend:String):BlendMode {
		switch(blend.toLowerCase().trim()) {
			case 'add': return ADD;
			case 'alpha': return ALPHA;
			case 'darken': return DARKEN;
			case 'difference': return DIFFERENCE;
			case 'erase': return ERASE;
			case 'hardlight': return HARDLIGHT;
			case 'invert': return INVERT;
			case 'layer': return LAYER;
			case 'lighten': return LIGHTEN;
			case 'multiply': return MULTIPLY;
			case 'overlay': return OVERLAY;
			case 'screen': return SCREEN;
			case 'shader': return SHADER;
			case 'subtract': return SUBTRACT;
		}
		return NORMAL;
	}

	function getFlxEaseByString(?ease:String = '') {
		switch(ease.toLowerCase()) {
			case 'backin': return FlxEase.backIn;
			case 'backinout': return FlxEase.backInOut;
			case 'backout': return FlxEase.backOut;
			case 'bouncein': return FlxEase.bounceIn;
			case 'bounceinout': return FlxEase.bounceInOut;
			case 'bounceout': return FlxEase.bounceOut;
			case 'circin': return FlxEase.circIn;
			case 'circinout': return FlxEase.circInOut;
			case 'circout': return FlxEase.circOut;
			case 'cubein': return FlxEase.cubeIn;
			case 'cubeinout': return FlxEase.cubeInOut;
			case 'cubeout': return FlxEase.cubeOut;
			case 'elasticin': return FlxEase.elasticIn;
			case 'elasticinout': return FlxEase.elasticInOut;
			case 'elasticout': return FlxEase.elasticOut;
			case 'expoin': return FlxEase.expoIn;
			case 'expoinout': return FlxEase.expoInOut;
			case 'expoout': return FlxEase.expoOut;
			case 'quadin': return FlxEase.quadIn;
			case 'quadinout': return FlxEase.quadInOut;
			case 'quadout': return FlxEase.quadOut;
			case 'quartin': return FlxEase.quartIn;
			case 'quartinout': return FlxEase.quartInOut;
			case 'quartout': return FlxEase.quartOut;
			case 'quintin': return FlxEase.quintIn;
			case 'quintinout': return FlxEase.quintInOut;
			case 'quintout': return FlxEase.quintOut;
			case 'sinein': return FlxEase.sineIn;
			case 'sineinout': return FlxEase.sineInOut;
			case 'sineout': return FlxEase.sineOut;
			case 'smoothstepin': return FlxEase.smoothStepIn;
			case 'smoothstepinout': return FlxEase.smoothStepInOut;
			case 'smoothstepout': return FlxEase.smoothStepInOut;
			case 'smootherstepin': return FlxEase.smootherStepIn;
			case 'smootherstepinout': return FlxEase.smootherStepInOut;
			case 'smootherstepout': return FlxEase.smootherStepOut;
		}
		return FlxEase.linear;
	}

	function cameraFromString(cam:String):FlxCamera {
		switch(cam.toLowerCase()) {
			case 'camhud' | 'hud': return PlayState.instance.camHUD;
		}
		return PlayState.instance.camGame;
	}

	public function call(event:String, args:Array<Dynamic>):Dynamic {
		if(lua == null) {
			return Function_Continue;
		}

		Lua.getglobal(lua, event);

		for (arg in args) {
			Convert.toLua(lua, arg);
		}

		var result:Null<Int> = Lua.pcall(lua, args.length, 1, 0);
		if(result != null && resultIsAllowed(lua, result)) {
			if(Lua.type(lua, -1) == Lua.LUA_TSTRING) {
				var error:String = Lua.tostring(lua, -1);
				if(error == 'attempt to call a nil value') {
					return Function_Continue;
				}
			}
			var conv:Dynamic = Convert.fromLua(lua, result);
			return conv;
		}

		return Function_Continue;
	}

	function resultIsAllowed(leLua:State, leResult:Null<Int>) {
		switch(Lua.type(leLua, leResult)) {
			case Lua.LUA_TNIL | Lua.LUA_TBOOLEAN | Lua.LUA_TNUMBER | Lua.LUA_TSTRING | Lua.LUA_TTABLE:
				return true;
		}
		return false;
	}

	public function setVar(varName:String, value:Dynamic):Void {
		if(lua == null) {
			return;
		}

		Convert.toLua(lua, value);
		Lua.setglobal(lua, varName);
	}

	public function setTweensActive(value:Bool) {
		if(lua == null) {
			return;
		}

		for (tween in tweens) {
			tween.active = value;
		}
	}

	public function stop() {
		sprites.clear();
		tweens.clear();

		if(lua == null) {
			return;
		}

		Lua.close(lua);
		lua = null;
	}
}

class LuaSprite extends FlxSprite
{
	public var wasAdded:Bool = false;
	public var isInFront:Bool = false;
}

class ModchartAPI {
	static public function triggerEvent(event:String, ?value1:Dynamic, ?value2:Dynamic) {
		switch(event) {
			case "Camera Zoom":
				if (FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);

					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					PlayState.instance.camHUD.zoom += hudZoom;
				}
			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [PlayState.instance.camGame, PlayState.instance.camHUD];

				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');

					var duration:Float = 0;
					var intensity:Float = 0;

					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());

					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}
			case 'Camera Position':
				if(PlayState.instance.camFollow != null) {
				    var val1:Float = Std.parseFloat(value1);
				    var val2:Float = Std.parseFloat(value2);

			        if(Math.isNaN(val1)) val1 = 0;
				    if(Math.isNaN(val2)) val2 = 0;

			        if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
				        PlayState.instance.camFollow.x = val1;
				        PlayState.instance.camFollow.y = val2;
			        }
		        }
			case 'Play Animation':
				var char:Character = PlayState.instance.dad;

				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = PlayState.instance.boyfriend;
					case 'gf' | 'girlfriend':
						char = PlayState.instance.gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;
						switch(val2) {
							case 1: char = PlayState.instance.boyfriend;
							case 2: char = PlayState.instance.gf;
						}
				}

				if (char != null) {
					char.playAnim(value1, true);
				}
			case 'Change Character':
				// g
		}
		PlayState.instance.script.callFunction('event', [event, value1, value2]);
	}

    // tweens for hscript omg
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
