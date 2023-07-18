package system;

#if sys
import haxe.Json;
import flixel.FlxG;
import haxe.io.Path;
import Type.ValueType;
import flixel.FlxBasic;
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

#if windows
import llua.Convert;
import llua.Lua;
import llua.State;
import llua.LuaL;
#end

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

// gay lua psych-hs script
#if windows
class ModLuaScripts {
	public static var Function_Stop = 1;
	public static var Function_Continue = 0;

	private  var lua:State = null;

	var lePlayState:PlayState = null;

	#if (haxe >= "4.0.0")
	public var tweens:Map<String, FlxTween> = new Map();
	public var sprites:Map<String, LuaSprite> = new Map();
	public var timers:Map<String, FlxTimer> = new Map();
	public var sounds:Map<String, FlxSound> = new Map();
	public var texts:Map<String, LuaText> = new Map();
	#else
	public var tweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var sprites:Map<String, LuaSprite> = new Map<String, LuaSprite>();
	public var timers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var sounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var texts:Map<String, LuaText> = new Map<String, LuaText>();
	#end

	public var accessedProps:Map<String, Dynamic> = null;

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

		#if (haxe >= "4.0.0")
		accessedProps = new Map();
		#else
		accessedProps = new Map<String, Dynamic>();
		#end

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
		setVar('startedCountdown', false);

		setVar('isStoryMode', PlayState.isStoryMode);
		setVar('difficulty', PlayState.storyDifficulty);
		setVar('weekRaw', PlayState.storyWeek);
		setVar('seenCutscene', PlayState.seenCutscene);

		setVar('cameraX', 0);
		setVar('cameraY', 0);

		setVar('screenWidth', FlxG.width);
		setVar('screenHeight', FlxG.height);

		setVar('curBeat', 0);
		setVar('curStep', 0);

		setVar('score', 0);
		setVar('misses', 0);
		setVar('hits', 0);

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

		Lua_helper.add_callback(lua, "triggerEvent", function(event:String, arg1:Dynamic, arg2:Dynamic) {
			var value1:String = arg1;
			var value2:String = arg2;
			ModchartAPI.triggerEvent(event, value1, value2);
		});

		Lua_helper.add_callback(lua, "getRandomInt", function(min:Int, max:Int = FlxMath.MAX_VALUE_INT, exclude:String = '') {
			var excludeArray:Array<String> = exclude.split(',');
			var toExclude:Array<Int> = [];
			for (i in 0...excludeArray.length)
			{
				toExclude.push(Std.parseInt(excludeArray[i].trim()));
			}
			return FlxG.random.int(min, max, toExclude);
		});

		Lua_helper.add_callback(lua, "getRandomFloat", function(min:Float, max:Float = 1, exclude:String = '') {
			var excludeArray:Array<String> = exclude.split(',');
			var toExclude:Array<Float> = [];
			for (i in 0...excludeArray.length)
			{
				toExclude.push(Std.parseFloat(excludeArray[i].trim()));
			}
			return FlxG.random.float(min, max, toExclude);
		});

		Lua_helper.add_callback(lua, "getRandomBool", function(chance:Float = 50) {
			return FlxG.random.bool(chance);
		});

		Lua_helper.add_callback(lua, "getProperty", function(variable:String) {
			var killMe:Array<String> = variable.split('.');
			if(killMe.length > 1) {
				return Reflect.getProperty(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			}
			return Reflect.getProperty(lePlayState, variable);
		});

		Lua_helper.add_callback(lua, "setProperty", function(variable:String, value:Dynamic) {
			var killMe:Array<String> = variable.split('.');
			if(killMe.length > 1) {
				return Reflect.setProperty(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1], value);
			}
			return Reflect.setProperty(lePlayState, variable, value);
		});

		Lua_helper.add_callback(lua, "getPropertyFromGroup", function(obj:String, index:Int, variable:Dynamic) {
			if(Std.isOfType(Reflect.getProperty(lePlayState, obj), FlxTypedGroup)) {
				return getGroupStuff(Reflect.getProperty(lePlayState, obj).members[index], variable);
			}
			var leArray:Dynamic = Reflect.getProperty(lePlayState, obj)[index];
			if(leArray != null) {
				if(Type.typeof(variable) == ValueType.TInt) {
					return leArray[variable];
				}
				return getGroupStuff(leArray, variable);
			}
			return null;
		});

		Lua_helper.add_callback(lua, "setPropertyFromGroup", function(obj:String, index:Int, variable:Dynamic, value:Dynamic) {
			if(Std.isOfType(Reflect.getProperty(lePlayState, obj), FlxTypedGroup)) {
				setGroupStuff(Reflect.getProperty(lePlayState, obj).members[index], variable, value);
				return;
			}
			var leArray:Dynamic = Reflect.getProperty(lePlayState, obj)[index];
			if(leArray != null) {
				if(Type.typeof(variable) == ValueType.TInt) {
					leArray[variable] = value;
					return;
				}
				setGroupStuff(leArray, variable, value);
			}
		});

		Lua_helper.add_callback(lua, "removeFromGroup", function(obj:String, index:Int, dontDestroy:Bool = false) {
			if(Std.isOfType(Reflect.getProperty(lePlayState, obj), FlxTypedGroup)) {
				var sex = Reflect.getProperty(lePlayState, obj).members[index];
				if(!dontDestroy)
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

		Lua_helper.add_callback(lua, "getObjectOrder", function(obj:String) {
			if(sprites.exists(obj))
			{
				return lePlayState.members.indexOf(sprites.get(obj));
			}
			else if(texts.exists(obj))
			{
				return lePlayState.members.indexOf(texts.get(obj));
			}
			var leObj:FlxBasic = Reflect.getProperty(lePlayState, obj);
			if(leObj != null)
			{
				return lePlayState.members.indexOf(leObj);
			}
			return -1;
		});

		Lua_helper.add_callback(lua, "setObjectOrder", function(obj:String, position:Int) {
			if(sprites.exists(obj)) {
				var spr:LuaSprite = sprites.get(obj);
				if(spr.wasAdded) {
					lePlayState.remove(spr, true);
				}
				lePlayState.insert(position, spr);
				return;
			}
			if(texts.exists(obj)) {
				var spr:LuaText = texts.get(obj);
				if(spr.wasAdded) {
					lePlayState.remove(spr, true);
				}
				lePlayState.insert(position, spr);
				return;
			}
			var leObj:FlxBasic = Reflect.getProperty(lePlayState, obj);
			if(leObj != null) {
				lePlayState.remove(leObj, true);
				lePlayState.insert(position, leObj);
				return;
			}
		});

		Lua_helper.add_callback(lua, "makeLuaSprite", function(tag:String, image:String, x:Float, y:Float) {
			tag = tag.replace('.', '');
			resetSpriteTag(tag);
			var leSprite:LuaSprite = new LuaSprite(x, y);
			if(image != null && image.length > 0)
			{
				leSprite.loadGraphic(Paths.image(image));
			}
			leSprite.antialiasing = true;
			sprites.set(tag, leSprite);
			leSprite.active = true;
		});

		Lua_helper.add_callback(lua, "makeAnimatedLuaSprite", function(tag:String, image:String, x:Float, y:Float) {
			tag = tag.replace('.', '');
			resetSpriteTag(tag);
			var leSprite:LuaSprite = new LuaSprite(x, y);
			leSprite.frames = Paths.getSparrowAtlas(image);
			leSprite.antialiasing = true;
			sprites.set(tag, leSprite);
		});

		Lua_helper.add_callback(lua, "makeGraphic", function(tag:String, width:Int, height:Int, color:String) {
			var colorNum:Int = Std.parseInt(color);
			if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);
			if(sprites.exists(tag)) {
				sprites.get(tag).makeGraphic(width, height, colorNum);
				return;
			}
			var object:FlxSprite = Reflect.getProperty(lePlayState, tag);
			if(object != null) {
				object.makeGraphic(width, height, colorNum);
			}
		});

		Lua_helper.add_callback(lua, "addAnimationByPrefix", function(obj:String, name:String, prefix:String, framerate:Int = 24, loop:Bool = true) {
			if(sprites.exists(obj)) {
				var cock:LuaSprite = sprites.get(obj);
				cock.animation.addByPrefix(name, prefix, framerate, loop);
				if(cock.animation.curAnim == null) {
					cock.animation.play(name, true);
				}
				return;
			}
			var cock:FlxSprite = Reflect.getProperty(lePlayState, obj);
			if(cock != null) {
				cock.animation.addByPrefix(name, prefix, framerate, loop);
				if(cock.animation.curAnim == null) {
					cock.animation.play(name, true);
				}
			}
		});

		Lua_helper.add_callback(lua, "addAnimationByIndices", function(obj:String, name:String, prefix:String, indices:String, framerate:Int = 24) {
			var strIndices:Array<String> = indices.trim().split(',');
			var die:Array<Int> = [];
			for (i in 0...strIndices.length) {
				die.push(Std.parseInt(strIndices[i]));
			}
			if(sprites.exists(obj)) {
				var pussy:LuaSprite = sprites.get(obj);
				pussy.animation.addByIndices(name, prefix, die, '', framerate, false);
				if(pussy.animation.curAnim == null) {
					pussy.animation.play(name, true);
				}
				return;
			}
			var pussy:FlxSprite = Reflect.getProperty(lePlayState, obj);
			if(pussy != null) {
				pussy.animation.addByIndices(name, prefix, die, '', framerate, false);
				if(pussy.animation.curAnim == null) {
					pussy.animation.play(name, true);
				}
			}
		});

		Lua_helper.add_callback(lua, "objectPlayAnimation", function(obj:String, name:String, forced:Bool = false, ?startFrame:Int = 0) {
			if(sprites.exists(obj)) {
				sprites.get(obj).animation.play(name, forced, startFrame);
				return;
			}
			var spr:FlxSprite = Reflect.getProperty(lePlayState, obj);
			if(spr != null) {
				spr.animation.play(name, forced);
			}
		});

		Lua_helper.add_callback(lua, "setScrollFactor", function(obj:String, scrollX:Float, scrollY:Float) {
			if(sprites.exists(obj)) {
				sprites.get(obj).scrollFactor.set(scrollX, scrollY);
				return;
			}
			var object:FlxObject = Reflect.getProperty(lePlayState, obj);
			if(object != null) {
				object.scrollFactor.set(scrollX, scrollY);
			}
		});

		Lua_helper.add_callback(lua, "setGraphicSize", function(obj:String, x:Int, y:Int = 0) {
			if(sprites.exists(obj)) {
				var shit:LuaSprite = sprites.get(obj);
				shit.setGraphicSize(x, y);
				shit.updateHitbox();
				return;
			}
			var poop:FlxSprite = Reflect.getProperty(lePlayState, obj);
			if(poop != null) {
				poop.setGraphicSize(x, y);
				poop.updateHitbox();
				return;
			}
		});

		Lua_helper.add_callback(lua, "scaleObject", function(obj:String, x:Float, y:Float) {
			if(sprites.exists(obj)) {
				var shit:LuaSprite = sprites.get(obj);
				shit.scale.set(x, y);
				shit.updateHitbox();
				return;
			}
			var poop:FlxSprite = Reflect.getProperty(lePlayState, obj);
			if(poop != null) {
				poop.scale.set(x, y);
				poop.updateHitbox();
				return;
			}
		});

		Lua_helper.add_callback(lua, "updateHitbox", function(obj:String) {
			if(sprites.exists(obj)) {
				var shit:LuaSprite = sprites.get(obj);
				shit.updateHitbox();
				return;
			}
			var poop:FlxSprite = Reflect.getProperty(lePlayState, obj);
			if(poop != null) {
				poop.updateHitbox();
				return;
			}
		});

		Lua_helper.add_callback(lua, "updateHitboxFromGroup", function(group:String, index:Int) {
			if(Std.isOfType(Reflect.getProperty(lePlayState, group), FlxTypedGroup)) {
				Reflect.getProperty(lePlayState, group).members[index].updateHitbox();
				return;
			}
			Reflect.getProperty(lePlayState, group)[index].updateHitbox();
		});

		Lua_helper.add_callback(lua, "setObjectCamera", function(obj:String, camera:String = '') {
			if(sprites.exists(obj)) {
				sprites.get(obj).cameras = [cameraFromString(camera)];
				return true;
			}
			else if(texts.exists(obj)) {
				texts.get(obj).cameras = [cameraFromString(camera)];
				return true;
			}
			var object:FlxObject = Reflect.getProperty(lePlayState, obj);
			if(object != null) {
				object.cameras = [cameraFromString(camera)];
				return true;
			}
			return false;
		});

		Lua_helper.add_callback(lua, "setBlendMode", function(obj:String, blend:String = '') {
			if(sprites.exists(obj)) {
				sprites.get(obj).blend = blendModeFromString(blend);
				return true;
			}
			var spr:FlxSprite = Reflect.getProperty(lePlayState, obj);
			if(spr != null) {
				spr.blend = blendModeFromString(blend);
				return true;
			}
			return false;
		});

		Lua_helper.add_callback(lua, "screenCenter", function(obj:String, pos:String = 'xy') {
			var spr:FlxSprite;
			if(sprites.exists(obj))
				spr = sprites.get(obj);
	        else if(texts.exists(obj))
			    spr = texts.get(obj);
			else
				spr = Reflect.getProperty(lePlayState, obj);
			if(spr != null) {
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
		});

		Lua_helper.add_callback(lua, "objectsOverlap", function(obj1:String, obj2:String) {
			var namesArray:Array<String> = [obj1, obj2];
			var objectsArray:Array<FlxSprite> = [];
			for (i in 0...namesArray.length)
			{
				if(sprites.exists(namesArray[i])) {
					objectsArray.push(sprites.get(namesArray[i]));
				}
				else if(texts.exists(namesArray[i])) {
					objectsArray.push(texts.get(namesArray[i]));
				}
				else {
					objectsArray.push(Reflect.getProperty(lePlayState, namesArray[i]));
				}
			}
			if(!objectsArray.contains(null) && FlxG.overlap(objectsArray[0], objectsArray[1]))
			{
				return true;
			}
			return false;
		});

		Lua_helper.add_callback(lua, "getPixelColor", function(obj:String, x:Int, y:Int) {
			var spr:FlxSprite = null;
			if(sprites.exists(obj)) {
				spr = sprites.get(obj);
			} else if(texts.exists(obj)) {
				spr = texts.get(obj);
			} else {
				spr = Reflect.getProperty(lePlayState, obj);
			}
			if(spr != null)
			{
				if(spr.framePixels != null) spr.framePixels.getPixel32(x, y);
				return spr.pixels.getPixel32(x, y);
			}
			return 0;
		});

		Lua_helper.add_callback(lua, "addLuaSprite", function(tag:String, front:Bool = false) {
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

		Lua_helper.add_callback(lua, "removeLuaSprite", function(tag:String) {
			resetSpriteTag(tag);
		});

		Lua_helper.add_callback(lua, "playMusic", function(sound:String, volume:Float = 1, loop:Bool = false) {
			FlxG.sound.playMusic(Paths.music(sound), volume, loop);
		});

		Lua_helper.add_callback(lua, "playSound", function(sound:String, volume:Float = 1, ?tag:String = null) {
			if(tag != null && tag.length > 0) {
				tag = tag.replace('.', '');
				if(sounds.exists(tag)) {
					sounds.get(tag).stop();
				}
				sounds.set(tag, FlxG.sound.play(Paths.sound(sound), volume, false, function() {
					sounds.remove(tag);
					call('onSoundFinished', [tag]);
				}));
				return;
			}
			FlxG.sound.play(Paths.sound(sound), volume);
		});

		Lua_helper.add_callback(lua, "stopSound", function(tag:String) {
			if(tag != null && tag.length > 1 && sounds.exists(tag)) {
				sounds.get(tag).stop();
				sounds.remove(tag);
			}
		});

		Lua_helper.add_callback(lua, "pauseSound", function(tag:String) {
			if(tag != null && tag.length > 1 && sounds.exists(tag)) {
				sounds.get(tag).pause();
			}
		});

		Lua_helper.add_callback(lua, "resumeSound", function(tag:String) {
			if(tag != null && tag.length > 1 && sounds.exists(tag)) {
				sounds.get(tag).play();
			}
		});

		Lua_helper.add_callback(lua, "soundFadeIn", function(tag:String, duration:Float, fromValue:Float = 0, toValue:Float = 1) {
			if(tag == null || tag.length < 1) {
				FlxG.sound.music.fadeIn(duration, fromValue, toValue);
			} else if(sounds.exists(tag)) {
				sounds.get(tag).fadeIn(duration, fromValue, toValue);
			}
		});

		Lua_helper.add_callback(lua, "soundFadeOut", function(tag:String, duration:Float, toValue:Float = 0) {
			if(tag == null || tag.length < 1) {
				FlxG.sound.music.fadeOut(duration, toValue);
			} else if(sounds.exists(tag)) {
				sounds.get(tag).fadeOut(duration, toValue);
			}
		});

		Lua_helper.add_callback(lua, "soundFadeCancel", function(tag:String) {
			if(tag == null || tag.length < 1) {
				if(FlxG.sound.music.fadeTween != null) {
					FlxG.sound.music.fadeTween.cancel();
				}
			} else if(sounds.exists(tag)) {
				var theSound:FlxSound = sounds.get(tag);
				if(theSound.fadeTween != null) {
					theSound.fadeTween.cancel();
					sounds.remove(tag);
				}
			}
		});

		Lua_helper.add_callback(lua, "getSoundVolume", function(tag:String) {
			if(tag == null || tag.length < 1) {
				if(FlxG.sound.music != null) {
					return FlxG.sound.music.volume;
				}
			} else if(sounds.exists(tag)) {
				return sounds.get(tag).volume;
			}
			return 0;
		});

		Lua_helper.add_callback(lua, "setSoundVolume", function(tag:String, value:Float) {
			if(tag == null || tag.length < 1) {
				if(FlxG.sound.music != null) {
					FlxG.sound.music.volume = value;
				}
			} else if(sounds.exists(tag)) {
				sounds.get(tag).volume = value;
			}
		});

		Lua_helper.add_callback(lua, "getSoundTime", function(tag:String) {
			if(tag != null && tag.length > 0 && sounds.exists(tag)) {
				return sounds.get(tag).time;
			}
			return 0;
		});

		Lua_helper.add_callback(lua, "setSoundTime", function(tag:String, value:Float) {
			if(tag != null && tag.length > 0 && sounds.exists(tag)) {
				var theSound:FlxSound = sounds.get(tag);
				if(theSound != null) {
					var wasResumed:Bool = theSound.playing;
					theSound.pause();
					theSound.time = value;
					if(wasResumed) theSound.play();
				}
			}
		});

		Lua_helper.add_callback(lua, "musicFadeIn", function(duration:Float, fromValue:Float = 0, toValue:Float = 1) {
			FlxG.sound.music.fadeIn(duration, fromValue, toValue);
		});

		Lua_helper.add_callback(lua, "musicFadeOut", function(duration:Float, toValue:Float = 0) {
			FlxG.sound.music.fadeOut(duration, toValue);
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

		Lua_helper.add_callback(lua, "keyJustPressed", function(name:String) {
			var key:Bool = false;
			switch(name) {
				case 'left': key = FlxG.keys.justPressed.LEFT;
				case 'down': key = FlxG.keys.justPressed.DOWN;
				case 'up': key = FlxG.keys.justPressed.UP;
				case 'right': key = FlxG.keys.justPressed.RIGHT;
				case 'back': key = FlxG.keys.justPressed.BACKSPACE;
				case 'enter': key = FlxG.keys.justPressed.ENTER;
				case 'reset': key = FlxG.keys.justPressed.R;
				case 'space': key = FlxG.keys.justPressed.SPACE;
			}
			return key;
		});

		Lua_helper.add_callback(lua, "keyPressed", function(name:String) {
			var key:Bool = false;
			switch(name) {
				case 'left': key = FlxG.keys.pressed.LEFT;
				case 'down': key = FlxG.keys.pressed.DOWN;
				case 'up': key = FlxG.keys.pressed.UP;
				case 'right': key = FlxG.keys.pressed.RIGHT;
				case 'back': key = FlxG.keys.pressed.BACKSPACE;
				case 'enter': key = FlxG.keys.pressed.ENTER;
				case 'reset': key = FlxG.keys.pressed.R;
				case 'space': key = FlxG.keys.pressed.SPACE;
			}
			return key;
		});

		Lua_helper.add_callback(lua, "keyReleased", function(name:String) {
			var key:Bool = false;
			switch(name) {
				case 'left': key = FlxG.keys.released.LEFT;
				case 'down': key = FlxG.keys.released.DOWN;
				case 'up': key = FlxG.keys.released.UP;
				case 'right': key = FlxG.keys.released.RIGHT;
				case 'back': key = FlxG.keys.released.BACKSPACE;
				case 'enter': key = FlxG.keys.released.ENTER;
				case 'reset': key = FlxG.keys.released.R;
				case 'space': key = FlxG.keys.released.SPACE;
			}
			return key;
		});

		Lua_helper.add_callback(lua, "keyJustReleased", function(name:String) {
			var key:Bool = false;
			switch(name) {
				case 'left': key = FlxG.keys.justReleased.LEFT;
				case 'down': key = FlxG.keys.justReleased.DOWN;
				case 'up': key = FlxG.keys.justReleased.UP;
				case 'right': key = FlxG.keys.justReleased.RIGHT;
				case 'back': key = FlxG.keys.justReleased.BACKSPACE;
				case 'enter': key = FlxG.keys.justReleased.ENTER;
				case 'reset': key = FlxG.keys.justReleased.R;
				case 'space': key = FlxG.keys.justReleased.SPACE;
			}
			return key;
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

		Lua_helper.add_callback(lua, "makeLuaText", function(tag:String, text:String, width:Int, x:Float, y:Float) {
			tag = tag.replace('.', '');
			resetTextTag(tag);
			var leText:LuaText = new LuaText(x, y, text, width);
			texts.set(tag, leText);
		});

		Lua_helper.add_callback(lua, "setTextString", function(tag:String, text:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				obj.text = text;
			}
		});

		Lua_helper.add_callback(lua, "setTextSize", function(tag:String, size:Int) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				obj.size = size;
			}
		});

		Lua_helper.add_callback(lua, "setTextWidth", function(tag:String, width:Float) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				obj.fieldWidth = width;
			}
		});

		Lua_helper.add_callback(lua, "setTextBorder", function(tag:String, size:Int, color:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				var colorNum:Int = Std.parseInt(color);
				if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);

				obj.borderSize = size;
				obj.borderColor = colorNum;
			}
		});

		Lua_helper.add_callback(lua, "setTextColor", function(tag:String, color:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				var colorNum:Int = Std.parseInt(color);
				if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);

				obj.color = colorNum;
			}
		});

		Lua_helper.add_callback(lua, "setTextFont", function(tag:String, newFont:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				obj.font = Paths.font(newFont);
			}
		});

		Lua_helper.add_callback(lua, "setTextItalic", function(tag:String, italic:Bool) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				obj.italic = italic;
			}
		});

		Lua_helper.add_callback(lua, "setTextAlignment", function(tag:String, alignment:String = 'left') {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				obj.alignment = LEFT;
				switch(alignment.trim().toLowerCase())
				{
					case 'right':
						obj.alignment = RIGHT;
					case 'center':
						obj.alignment = CENTER;
				}
			}
		});

		Lua_helper.add_callback(lua, "getTextString", function(tag:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				return obj.text;
			}
			return null;
		});

		Lua_helper.add_callback(lua, "getTextSize", function(tag:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				return obj.size;
			}
			return -1;
		});

		Lua_helper.add_callback(lua, "getTextFont", function(tag:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				return obj.font;
			}
			return null;
		});

		Lua_helper.add_callback(lua, "getTextWidth", function(tag:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				return obj.fieldWidth;
			}
			return 0;
		});

		Lua_helper.add_callback(lua, "addLuaText", function(tag:String) {
			if(texts.exists(tag)) {
				var shit:LuaText = texts.get(tag);
				if(!shit.wasAdded) {
					lePlayState.add(shit);
					shit.wasAdded = true;
				}
			}
		});

		Lua_helper.add_callback(lua, "removeLuaText", function(tag:String, destroy:Bool = true) {
			if(!texts.exists(tag)) {
				return;
			}
			var pee:LuaText = texts.get(tag);
			if(destroy) {
				pee.kill();
			}
			if(pee.wasAdded) {
				lePlayState.remove(pee, true);
				pee.wasAdded = false;
			}
			if(destroy) {
				pee.destroy();
				texts.remove(tag);
			}
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

		call('create', []);
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

	function resetTextTag(tag:String) {
		if(!texts.exists(tag)) {
			return;
		}
		var pee:LuaText = texts.get(tag);
		pee.kill();
		if(pee.wasAdded) {
			PlayState.instance.remove(pee, true);
		}
		pee.destroy();
		texts.remove(tag);
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
		if(sprites.exists(variables[0])) {
			sexyProp = sprites.get(variables[0]);
		}
		if(texts.exists(variables[0])) {
			sexyProp = texts.get(variables[0]);
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

	function getPropertyLoopThingWhatever(killMe:Array<String>, ?checkForTextsToo:Bool = true):Dynamic
	{
		var coverMeInPiss:Dynamic = getObjectDirectly(killMe[0], checkForTextsToo);
		for (i in 1...killMe.length-1) {
			coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
		}
		return coverMeInPiss;
	}

	function getObjectDirectly(objectName:String, ?checkForTextsToo:Bool = true):Dynamic
	{
		var coverMeInPiss:Dynamic = null;
		if(sprites.exists(objectName)) {
			coverMeInPiss = sprites.get(objectName);
		} else if(checkForTextsToo && texts.exists(objectName)) {
			coverMeInPiss = texts.get(objectName);
		} else {
			coverMeInPiss = Reflect.getProperty(lePlayState, objectName);
		}
		return coverMeInPiss;
	}

	function setGroupStuff(leArray:Dynamic, variable:String, value:Dynamic) {
		var killMe:Array<String> = variable.split('.');
		if(killMe.length > 1) {
			var coverMeInPiss:Dynamic = Reflect.getProperty(leArray, killMe[0]);
			for (i in 1...killMe.length-1) {
				coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
			}
			Reflect.setProperty(coverMeInPiss, killMe[killMe.length-1], value);
			return;
		}
		Reflect.setProperty(leArray, variable, value);
	}

	function getGroupStuff(leArray:Dynamic, variable:String) {
		var killMe:Array<String> = variable.split('.');
		if(killMe.length > 1) {
			var coverMeInPiss:Dynamic = Reflect.getProperty(leArray, killMe[0]);
			for (i in 1...killMe.length-1) {
				coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
			}
			return Reflect.getProperty(coverMeInPiss, killMe[killMe.length-1]);
		}
		return Reflect.getProperty(leArray, variable);
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

	function getTextObject(name:String):FlxText
	{
		return texts.exists(name) ? texts.get(name) : Reflect.getProperty(lePlayState, name);
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
		if(lua == null) {
			return;
		}

		if(accessedProps != null) {
			accessedProps.clear();
		}

		Lua.close(lua);
		lua = null;
	}
}

class LuaSprite extends FlxSprite
{
	public var wasAdded:Bool = false;
	public var isInFront:Bool = false;

	public function new(?x:Float = 0, ?y:Float = 0)
	{
		super(x, y);
		antialiasing = true;
	}
}

class LuaText extends FlxText
{
	public var wasAdded:Bool = false;

	public function new(x:Float, y:Float, text:String, width:Float)
	{
		super(x, y, width, text, 16);
		setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		cameras = [PlayState.instance.camHUD];
		scrollFactor.set();
		borderSize = 2;
	}
}
#end

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

		#if sys
		#if windows
		PlayState.instance.callLua('event', [event, value1, value2]);
		#end
		#end

		#if sys
		PlayState.instance.script.callFunction('event', [event, value1, value2]);
		#end
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
