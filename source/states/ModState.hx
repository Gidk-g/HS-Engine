package states;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;

class ModState extends MusicBeatState {
    private var bg:FlxBackdrop;
    private var overlay:FlxSprite;
    private var modGroup:FlxGroup;
    private var modList:FlxText;
    private var selectedIndex:Int;
    private var editorHint:FlxText;

    override function create():Void {
        bg = new FlxBackdrop(Paths.image('menuDesat'));
        bg.color = 0xFFea71fd;
        bg.velocity.set(-50, 0);
        bg.y = 0;
        add(bg);

        overlay = new FlxSprite(0, 0);
        overlay.makeGraphic(Std.int(FlxG.width / 2), FlxG.height, 0xFF000000);
        overlay.alpha = 0.5;
        add(overlay);

        var modItem:FlxSprite = new FlxSprite(800, 300);
        modItem.frames = Paths.getSparrowAtlas('mainMenu/mods');
        modItem.animation.addByPrefix('idle', "mods basic", 24, true);
        modItem.animation.play('idle');
        modItem.antialiasing = true;
        modItem.scale.set(1.2, 1.2);
        modItem.scrollFactor.set();
        add(modItem);

        modGroup = new FlxGroup();
        add(modGroup);

        modList = new FlxText(50, 50, 1180, "Available mods:");
        modList.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        modList.borderSize = 1.25;
        modList.scrollFactor.set();
        add(modList);

        loadMods();
        selectedIndex = 0;

        editorHint = new FlxText(FlxG.width - 320, FlxG.height - 30, 300, "Press 7 to go to the editor menu");
        editorHint.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        editorHint.borderSize = 1.0;
        editorHint.scrollFactor.set();
        add(editorHint);

        super.create();
    }

    private function loadMods():Void {
        var modFolders:Array<{ folder:String, enabled:Bool }> = ModPaths.getModFolders();
        if (modFolders.length > 0) {
            for (modFolder in modFolders) {
                var modText:FlxText = new FlxText(50, 100 + 50 * modGroup.members.length, 1180, "- " + modFolder.folder);
                modText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.NONE);
                modText.alpha = ModPaths.isModEnabled(modFolder.folder) ? 1.0 : 0.5;
                modText.scrollFactor.set();
                modGroup.add(modText);
            }
        } else {
            modList.text = "No mods found.";
        }
    }

    private function toggleMod(folder:String):Void {
        ModPaths.toggleMod(folder, !ModPaths.isModEnabled(folder));
        reloadMods();
    }
    
    private function reloadMods():Void {
        modGroup.clear();
        loadMods();
    }

    override function update(elapsed:Float):Void {
        super.update(elapsed);
        updateSelection();
        handleInput();
    }

    private function handleInput():Void {
        if (controls.UP_P) {
            selectedIndex = Std.int(Math.max(0, selectedIndex - 1));
            FlxG.sound.play(Paths.sound('scrollMenu'));
            updateSelection();
        } else if (controls.DOWN_P) {
            selectedIndex = Std.int(Math.min(modGroup.members.length - 1, selectedIndex + 1));
            FlxG.sound.play(Paths.sound('scrollMenu'));
            updateSelection();
        } else if (FlxG.keys.justPressed.SEVEN) {
            FlxG.switchState(new states.editors.EditorMenuState());
        } else if (controls.BACK) {
			scriptState.callFunction("goToMenu", []);
            FlxG.switchState(new MainMenuState());
        } else if (controls.ACCEPT) {
            var modFolders:Array<{ folder:String, enabled:Bool }> = ModPaths.getModFolders();
            if (selectedIndex >= 0 && selectedIndex < modFolders.length) {
                toggleMod(modFolders[selectedIndex].folder);
            }
        }
    }

    private function updateSelection():Void {
        for (i in 0...modGroup.members.length) {
            var modText:FlxText = cast(modGroup.members[i], FlxText);
            modText.color = (i == selectedIndex) ? FlxColor.YELLOW : FlxColor.WHITE;
        }
    }
}
