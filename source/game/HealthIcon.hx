package game;

import flixel.FlxSprite;
import lime.utils.Assets;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function new(char:String = 'face', isPlayer:Bool = false)
	{
		super();

		if (animation.getByName(char) == null)
		{
			#if sys
			if (sys.FileSystem.exists(Paths.image('icons/icon-$char')))
			#else
			if (Assets.exists(Paths.image('icons/icon-$char')))
			#end
				loadGraphic(Paths.image('icons/icon-$char'), true, 150, 150);
			else
				loadGraphic(Paths.image("icons/icon-face"), true, 150, 150);
			animation.add(char, [0, 1], 0, false, isPlayer);
		}

		animation.play(char);
		antialiasing = true;
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
