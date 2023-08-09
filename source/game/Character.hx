package game;

import haxe.Json;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSort;
import openfl.utils.Assets;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class Character extends FlxSprite
{
	public var stunned:Bool = false;

	public var animationNotes:Array<Dynamic> = [];
	public var animationsArray:Array<AnimStuff> = [];
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;
	public var singDuration:Float = 4;

	public var danceIdle:Bool = false;
	public var healthIcon:String = 'face';

	public var cameraOffset:Array<Float> = [0,0];
	public var characterOffset:Array<Float> = [0,0];

	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var goofyAntialiasing:Bool = false;
	public var originalFlipX:Bool = false;
	public var skipDance:Bool = false;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		loadCharacterJson();
		recalculateDanceIdle();
		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}

		switch(curCharacter)
		{
			case 'pico-speaker':
				skipDance = true;
				loadMappedAnims();
				playAnim("shoot1");
		}
	}

    public function loadCharacterJson()
	{
		var rawJson = null;

		#if sys
		var moddyFile:String = ModPaths.data("characters/" + curCharacter);
		if(sys.FileSystem.exists(moddyFile)) {
			rawJson = sys.io.File.getContent(moddyFile);
		}
		#end

		if(rawJson == null) {
			#if sys
			rawJson = sys.io.File.getContent(Paths.json("characters/" + curCharacter));
			#else
			rawJson = Assets.getText(Paths.json("characters/" + curCharacter));
			#end
		}

		var json:CharJson = cast Json.parse(rawJson);

		if (Assets.exists(Paths.file("images/" + json.spritePath + ".txt", TEXT)))
			frames = Paths.getPackerAtlas(json.spritePath);
        else
			frames = Paths.getSparrowAtlas(json.spritePath);

		imageFile = json.spritePath;

		cameraOffset = json.cameraOffset;
		characterOffset = json.characterOffset;

		goofyAntialiasing = json.antialiasing;
		antialiasing = json.antialiasing;
		singDuration = json.singDuration;

		healthIcon = json.healthIcon;
		originalFlipX = flipX;
		flipX = json.flipX;

		animationsArray = json.animations;
		if(animationsArray != null && animationsArray.length > 0) {
			for (anim in animationsArray) {
				var animIndices:Array<Int> = anim.indices;
				if (animIndices != null && animIndices.length > 0)
					animation.addByIndices(anim.anim, anim.name, animIndices, "", anim.fps, anim.loop);
				else
					animation.addByPrefix(anim.anim, anim.name, anim.fps, anim.loop);
				if (anim.offsets != null && anim.offsets.length > 1)
					addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
			}
		}

		if (json.scale != 1) {
			jsonScale = json.scale;
			setGraphicSize(Std.int(width * jsonScale));
			updateHitbox();
		}
	}

	override function update(elapsed:Float)
	{
		if (!curCharacter.startsWith('bf'))
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			if (holdTimer >= Conductor.stepCrochet * 0.001 * singDuration)
			{
				dance();
				holdTimer = 0;
			}
		}

		switch(curCharacter)
		{
			case 'pico-speaker':
				if(animationNotes.length > 0 && Conductor.songPosition > animationNotes[0][0])
				{
					var noteData:Int = 1;
					if(animationNotes[0][1] > 2) noteData = 3;

					noteData += FlxG.random.int(0, 1);
					playAnim('shoot' + noteData, true);
					animationNotes.shift();
				}
				if(animation.curAnim.finished) playAnim(animation.curAnim.name, false, false, animation.curAnim.frames.length - 3);
		}

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
		}

		if (animation.curAnim.finished && animation.getByName(animation.curAnim.name + '-loop') != null)
		{
			playAnim(animation.curAnim.name + '-loop');
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode && !skipDance)
		{
			if (danceIdle)
			{
				danced = !danced;

				if (danced)
					playAnim('danceRight');
				else
					playAnim('danceLeft');
			}
			else if (animation.getByName('idle') != null)
			{
				if (curCharacter == 'tankman' && PlayState.SONG.song.toLowerCase() == 'stress' && PlayState.tankmangood == 1)
					playAnim('singDOWN-alt');
				else
				    playAnim('idle');
			}
		}
	}

	function loadMappedAnims():Void
	{
		var noteData:Array<SwagSection> = Song.loadFromJson('picospeaker', Paths.formatToSongPath(PlayState.SONG.song)).notes;
		for (section in noteData) {
			for (songNotes in section.sectionNotes) {
				animationNotes.push(songNotes);
			}
		}
		TankmenBG.animationNotes = animationNotes;
		animationNotes.sort(sortAnims);
	}

	function sortAnims(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	public var danceEveryNumBeats:Int = 2;
	private var settingCharacterUp:Bool = true;

	public function recalculateDanceIdle()
	{
		var lastDanceIdle:Bool = danceIdle;

		danceIdle = (animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null);

		if(settingCharacterUp)
		{
			danceEveryNumBeats = (danceIdle ? 1 : 2);
		}
		else if(lastDanceIdle != danceIdle)
		{
			var calc:Float = danceEveryNumBeats;
			if(danceIdle)
				calc /= 2;
			else
				calc *= 2;

			danceEveryNumBeats = Math.round(Math.max(calc, 1));
		}

		settingCharacterUp = false;
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}

typedef CharJson = {
	var animations:Array<AnimStuff>;
	var spritePath:String;
	var healthIcon:String;
	var scale:Float;
	var flipX:Bool;
	var antialiasing:Bool;
	var singDuration:Float;
	var cameraOffset:Array<Float>;
	var characterOffset:Array<Float>;
}

typedef AnimStuff = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}
