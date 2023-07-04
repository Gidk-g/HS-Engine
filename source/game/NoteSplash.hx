package game;

import openfl.display.BlendMode;
import openfl.display.BitmapData;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;

using StringTools;

class NoteSplash extends FlxSprite
{
    public function new(x:Float, y:Float, note:Int)
	{
        super(x, y);

        var noteColor:String = "purple";

        switch(note){
            case 1:
                noteColor = "blue";
            case 2:
                noteColor = "green";
            case 3:
                noteColor = "red";
        }

        frames = Paths.getSparrowAtlas("noteSplashes");
        antialiasing = true;
        animation.addByPrefix("splash", "note impact " + FlxG.random.int(1, 2) + " " + noteColor, 24 + FlxG.random.int(-3, 4), false);
        animation.finishCallback = function(n) { kill(); }
        animation.play("splash");
        alpha = 0.6;
        updateHitbox();
        offset.set(width * 0.3, height * 0.3);
        angle = FlxG.random.int(0, 359);
    }
}
