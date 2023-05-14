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
			if (Assets.exists(Paths.image('icons/icon-$char')))
				loadGraphic(Paths.image('icons/icon-$char'), true, 150, 150);
			#if sys
			else if (sys.FileSystem.exists(ModPaths.modImage('images/icons/icon-$char')))
				loadGraphic(ModPaths.modImage('images/icons/icon-$char'), true, 150, 150);
			#end
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
