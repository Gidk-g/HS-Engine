package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class ModState extends MusicBeatState {
    private var bg:FlxSprite;
    private var modList:FlxText;

    override function create():Void {
        bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
        add(bg);

        modList = new FlxText(50, 300, 1180, "", 32);
        modList.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        modList.borderSize = 1.25;
        modList.scrollFactor.set();
        add(modList);

        try {
            var modFolders:Array<String> = ModPaths.getModFolders();
            if (modFolders.length > 0) {
                var modText:String = "All Mods:\n";
                for (modFolder in modFolders) {
                    modText += "- " + modFolder + "\n";
                }
                modList.text = modText;
            } else {
                modList.text = "No mods found.";
            }
        } catch (error:Dynamic) {
            modList.text = "Error loading mods:\n" + Std.string(error);
        }

        super.create();
    }

    override function update(elapsed:Float) {
        if (controls.BACK) {
			FlxG.switchState(new MainMenuState());
		}
        super.update(elapsed);
    }

    override function stepHit():Void {
        super.stepHit();
    }

    override function beatHit():Void {
        super.beatHit();
    }
}
