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

    private var scrollOffset:Float = 0;
    private var targetScrollOffset:Float = 0;
    private var scrollSpeed:Float = 5;
    private var maxScrollOffset:Float = 0;

    private var restartNeeded:Bool = ModPaths.checkRestartStatus();

    override function create():Void {
		#if desktop
		DiscordClient.changePresence("In the Mod Menu", null);
		#end

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
        maxScrollOffset = Math.max(0, (modGroup.members.length * 50) - FlxG.height + 150);
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
        updateScroll();
        handleInput();
    }

    private function handleInput():Void {
        if (controls.UP_P) {
            if (selectedIndex == 0) {
                selectedIndex = modGroup.members.length - 1;
                targetScrollOffset = maxScrollOffset;
            } else {
                selectedIndex--;
                if (scrollOffset > 0) {
                    targetScrollOffset = Math.max(0, targetScrollOffset - 50);
                }
            }
            FlxG.sound.play(Paths.sound('scrollMenu'));
            updateScroll();
            updateSelection();
        } else if (controls.DOWN_P) {
            if (selectedIndex == modGroup.members.length - 1) {
                selectedIndex = 0;
                targetScrollOffset = 0;
            } else {
                selectedIndex++;
                if (scrollOffset < maxScrollOffset) {
                    targetScrollOffset = Math.min(maxScrollOffset, targetScrollOffset + 50);
                }
            }
            FlxG.sound.play(Paths.sound('scrollMenu'));
            updateScroll();
            updateSelection();
        } else if (FlxG.keys.justPressed.SEVEN) {
            FlxG.switchState(new states.editors.EditorMenuState());
        } else if (controls.BACK) {
            if (restartNeeded) {
                TitleState.initialized = false;
                TitleState.closedState = false;

                FlxG.sound.music.fadeOut(0.3);
                FlxG.camera.fade(FlxColor.BLACK, 0.5, false, FlxG.resetGame, false);
            } else {
                scriptState.callFunction("goToMenu", []);
                FlxG.switchState(new MainMenuState());
            }
        } else if (controls.ACCEPT) {
            var modFolders:Array<{ folder:String, enabled:Bool }> = ModPaths.getModFolders();
            if (selectedIndex >= 0 && selectedIndex < modFolders.length) {
                toggleMod(modFolders[selectedIndex].folder);
            }
        }
        targetScrollOffset = Math.max(0, Math.min(targetScrollOffset, maxScrollOffset));
    }

    private function updateScroll():Void {
        if (scrollOffset != targetScrollOffset) {
            var delta:Float = (targetScrollOffset - scrollOffset) * 0.1;
            scrollOffset += delta;
            modList.y = 50 - scrollOffset;
            for (i in 0...modGroup.members.length) {
                var modText:FlxText = cast(modGroup.members[i], FlxText);
                modText.y = 100 + (50 * i) - scrollOffset;
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
