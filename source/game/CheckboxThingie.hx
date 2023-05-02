package game;

import flixel.FlxSprite;

class CheckboxThingie extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public var daValue(default, set):Bool;
	public var copyAlpha:Bool = true;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;

	public function new(x:Float = 0, y:Float = 0, ?checked = false)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('checkboxThingie');
		animation.addByPrefix("unchecked", "Check Box unselected", 24, false);
		animation.addByPrefix("checking", "Check Box selecting animation", 24, false);
		animation.addByPrefix("checked", "Check Box Selected Static", 24, false);

		antialiasing = true;
		setGraphicSize(Std.int(0.9 * width));
		updateHitbox();

		animationFinished(checked ? 'checking' : 'unchecked');
		animation.finishCallback = animationFinished;
		daValue = checked;
	}

	override function update(elapsed:Float)
	{
		if (sprTracker != null)
		{
			setPosition(sprTracker.x - 130 + offsetX, sprTracker.y - 30 + offsetY);
			if (copyAlpha)
				alpha = sprTracker.alpha;
		}
		super.update(elapsed);
	}

	private function set_daValue(check:Bool):Bool
	{
		if (check)
		{
			animation.play('checking', true);
			offset.set(22, 90);
		}
		else
		{
			animation.play('unchecked', true);
			offset.set();
		}
		return check;
	}

	private function animationFinished(name:String)
	{
		if (name == 'checking')
		{
			animation.play('checked', true);
			offset.set(11, 63);
		}
	}
}
