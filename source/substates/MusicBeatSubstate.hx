package substates;

import system.Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSubState;

class MusicBeatSubstate extends FlxSubState
{
	public function new()
	{
		super();
	}

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	#if sys
	public var scriptSubstate:ModScripts = new ModScripts();
	#end

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
        #if sys
		if (sys.FileSystem.exists(ModPaths.script("data/substates/" + Type.getClassName(Type.getClass(FlxG.state.subState))))) {
			scriptSubstate.loadScript("data/substates/" + Type.getClassName(Type.getClass(FlxG.state.subState)));
		}
		scriptSubstate.interp.scriptObject = this;

		scriptSubstate.interp.variables.set("close", function() {
			close();
		});

		scriptSubstate.interp.variables.set("add", function(value:flixel.FlxObject) {
			add(value);
		});

		scriptSubstate.interp.variables.set("remove", function(value:flixel.FlxObject) {
			remove(value);
		});

		scriptSubstate.interp.variables.set("curBeat", curBeat);
		scriptSubstate.interp.variables.set("curStep", curStep);

		scriptSubstate.interp.variables.set("this", this);
		scriptSubstate.callFunction("create", [this]);
		#end

		super.create();

        #if sys
		scriptSubstate.callFunction("createPost", [this]);
		#end
	}

	override function update(elapsed:Float)
	{
        #if sys
		scriptSubstate.callFunction("update", [elapsed, this]);
		#end

		var oldStep:Int = curStep;

		updateCurStep();
		curBeat = Math.floor(curStep / 4);

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);

        #if sys
		scriptSubstate.callFunction("updatePost", [elapsed, this]);
		#end
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
        #if sys
		scriptSubstate.callFunction("stepHit", [curStep, this]);
		#end
	}

	public function beatHit():Void
	{
        #if sys
		scriptSubstate.callFunction("beatHit", [curBeat, this]);
		#end
	}
}
