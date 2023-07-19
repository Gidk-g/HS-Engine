package game;

import flixel.FlxSprite;
import lime.utils.Assets;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public var isPlayer:Bool = false;

	public function new(char:String = 'face', isPlayer:Bool = false)
	{
		super();
		this.isPlayer = isPlayer;
		changeIcon(char);
		animation.play(char);
		antialiasing = true;
		scrollFactor.set();
	}

	public function changeIcon(char:String)
	{
		if (animation.getByName(char) == null)
		{
			if (!Paths.fileExists(Paths.image('icons/icon-$char')))
				loadGraphic(Paths.image('icons/icon-$char'), true, 150, 150);
			else
				loadGraphic(Paths.image("icons/icon-face"), true, 150, 150);
			animation.add(char, [0, 1], 0, false, isPlayer);
		}
		animation.play(char);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
