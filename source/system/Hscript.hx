package system;

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
import polymod.backends.PolymodAssets;
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

using StringTools;

class Hscript
{
	public var script:hscript.Expr;

	public var interp = new Interp();
	public var parser = new Parser();

	public function new()
	{
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
		interp.variables.set("File", File);
		interp.variables.set("Assets", Assets);
		interp.variables.set("FileSystem", FileSystem);
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("FlxGroup", FlxGroup);
		interp.variables.set("FlxTypedGroup", FlxTypedGroup);
		interp.variables.set("CoolUtil", CoolUtil);
		interp.variables.set("Paths", Paths);
		interp.variables.set("Path", Path);
		interp.variables.set("Json", Json);
        interp.variables.set("PolymodAssets", PolymodAssets);

		interp.variables.set("FlxAngle", FlxAngle);

		interp.variables.set("FlxAtlasFrames", FlxAtlasFrames);
		interp.variables.set("FlxAtlas", FlxAtlas);

		interp.variables.set("Character", Character);
		interp.variables.set("Boyfriend", Boyfriend);

		interp.variables.set("Song", Song);
		interp.variables.set("Conductor", Conductor);
		interp.variables.set("Note", Note);
	}

	public function call(funcName:String, ?args:Array<Dynamic>):Dynamic
	{
		if (args == null)
			args = [];

		try
		{
			var func:Dynamic = interp.variables.get(funcName);
			if (func != null && Reflect.isFunction(func))
				return Reflect.callMethod(null, func, args);
		}
		catch (e)
		{
			FlxG.log.add(e.details());
		}

		return true;
	}

	public function loadScript(key:String)
	{
		script = parser.parseString(Assets.getText(Paths.hx(key)));
		interp.execute(script);
	}
}
