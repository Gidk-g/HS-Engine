package system;

import lime.app.Application;
import lime.system.DisplayMode;
import flixel.util.FlxColor;
import flixel.FlxG;
import openfl.display.FPS;
import openfl.Lib;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;

class OptionCategory
{
	private var _options:Array<Option> = [];

	public function new(catName:String, ?options:Array<Option>)
	{
		_name = catName;
		_options = options;
	}

	public final function getOptions():Array<Option>
	{
		return _options;
	}

	public final function addOption(opt:Option)
	{
		_options.push(opt);
	}

	public final function removeOption(opt:Option)
	{
		_options.remove(opt);
	}

	private var _name:String = "New Category";

	public final function getName()
	{
		return _name;
	}
}

class Option
{
	private var display:String;
	private var acceptValues:Bool = false;

	public var isBool:Bool = true;
	public var daValue:Bool = false;

	public function new()
	{
		display = updateDisplay();
	}

	public final function getDisplay():String
	{
		return display;
	}

	public final function getAccept():Bool
	{
		return acceptValues;
	}

	// Returns whether the label is to be updated.
	public function press():Bool
	{
		return true;
	}

	private function updateDisplay():String
	{
		return "";
	}

	public function left():Bool
	{
		return false;
	}

	public function right():Bool
	{
		return false;
	}
}

class ModOption extends Option
{
	public function new()
	{
		super();
	}

	public override function press():Bool
	{
		FlxG.save.data.mods = !FlxG.save.data.mods;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Mod Support";
	}
}
