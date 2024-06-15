package game;

import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

using StringTools;

class StoryDiffSprite extends FlxSpriteGroup
{
	public var curText:String = '';
	var prevText:String = '';
	public var targetY:Float = 0;
	public var diff:FlxSprite;

	var _defX:Float = 0;
	var _defY:Float = 0;

	var a:Float = 0;

	public function new(x:Float, y:Float, diffic:String)
	{
		super(x, y);
		_defX = x;
		_defY = y;

		diff = new FlxSprite().loadGraphic(Paths.image('difficulties/' + diffic));
		add(diff);
	}

	public function changeDiff(diffName:String)
	{
		var fileName:String = diffName.trim();

		if (fileName != null && fileName.length > 0)
		{
			if (#if sys sys.FileSystem.exists(Paths.image('difficulties/' + fileName))
				|| #end Assets.exists(Paths.image('difficulties/' + fileName), IMAGE))
			{
				diff.loadGraphic(Paths.image('difficulties/' + fileName));
			}
		}

		curText = fileName;
		prevText = curText;
	}
	
	var tweenDifficulty:FlxTween;

	public function doTween()
	{
		diff.y = _defY - 15;
		diff.alpha = 0;

		if (tweenDifficulty != null)
			tweenDifficulty.cancel();
		tweenDifficulty = FlxTween.tween(diff, {y: _defY, alpha: 1}, 0.07, {
			onComplete: function(twn:FlxTween)
			{
				tweenDifficulty = null;
			}
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
