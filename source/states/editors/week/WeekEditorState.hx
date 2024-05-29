package states.editors.week;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUITabMenu;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import flash.net.FileFilter;
import states.StoryMenuState.WeekData;

using StringTools;

class WeekEditorState extends MusicBeatState {
    var weekFile:WeekData;
    var txtWeekTitle:FlxText;
    var txtTracklist:FlxText;
    var uiBox:FlxUITabMenu;
    var grpWeekText:FlxTypedGroup<MenuItem>;
    var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

    override function create() {
        FlxG.mouse.visible = true;

        if (FlxG.sound.music != null)
            FlxG.sound.music.stop();

        loadWeekFile();

        txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
        txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
        txtWeekTitle.alpha = 0.7;

        grpWeekText = new FlxTypedGroup<MenuItem>();
        add(grpWeekText);

        var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);

        grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

        var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, weekFile.texture);
        weekThing.y += ((weekThing.height + 20) * 0);
        weekThing.targetY = 0;
        grpWeekText.add(weekThing);

        weekThing.screenCenter(X);
        weekThing.antialiasing = true;

        var charArray:Array<String> = weekFile.characters;
        for (char in 0...3) {
            var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, charArray[char]);
            weekCharacterThing.y += 70;
            grpWeekCharacters.add(weekCharacterThing);
        }

        add(yellowBG);
        add(grpWeekCharacters);

        txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
        txtTracklist.alignment = CENTER;
        txtTracklist.setFormat(Paths.font("vcr.ttf"), 32);
        txtTracklist.color = 0xFFe55777;
        add(txtTracklist);

        add(txtWeekTitle);

        addUIBox();
        addWeekUI();
        updateInformations();
        changeCharacters();
        updateText();

        super.create();
    }

    override function update(elapsed:Float) {
        txtWeekTitle.text = weekFile.name.toUpperCase();
        txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

        if (FlxG.keys.justPressed.ESCAPE) {
            FlxG.mouse.visible = false;
            FlxG.switchState(new states.editors.EditorMenuState());
            FlxG.sound.playMusic(Paths.music('freakyMenu'));
        }

        super.update(elapsed);
    }

    function updateText() {
        txtTracklist.text = "Tracks\n";

        var stringThing:Array<String> = input_weekSongs.text.trim().split(',');

        for (i in stringThing)
            txtTracklist.text += "\n" + i;

        txtTracklist.text = txtTracklist.text.toUpperCase();

        txtTracklist.screenCenter(X);
        txtTracklist.x -= FlxG.width * 0.35;

        txtTracklist.text += "\n";
    }

    function changeCharacters() {
        for (i in 0...grpWeekCharacters.length) {
            grpWeekCharacters.members[i].changeCharacter(weekFile.characters[i]);
        }
    }

    function loadWeekFile(?data:WeekData = null) {
        if (data == null) {
            weekFile = {
                name: "Daddy Dearest",
                texture: "week1",
                songs: ["Bopeebo", "Fresh", "Dadbattle"],
                characters: ["dad", "bf", "gf"]
            }
        } else {
            weekFile = data;
        }
    }

    function addUIBox() {
        var tabs = [{ name: "Week", label: 'Week'}];
        uiBox = new FlxUITabMenu(null, tabs, true);
        uiBox.resize(400, 200);
        uiBox.x = FlxG.width - uiBox.width - 20;
        uiBox.y = FlxG.height - uiBox.height - 20;
        uiBox.scrollFactor.set();
        add(uiBox);
    }

    var input_texturePath:FlxUIInputText;
    var input_weekName:FlxUIInputText;
    var input_weekSongs:FlxUIInputText;
    var input_weekCharacters:FlxUIInputText;

    function addWeekUI() {
        var tab_group_week = new FlxUI(null, uiBox);
        tab_group_week.name = "Week";

        input_texturePath = new FlxUIInputText(10, 20, 200, '', 8);
        tab_group_week.add(input_texturePath);

        var opText:FlxText = new FlxText(input_texturePath.x, input_texturePath.y - 15, FlxG.width, "Week texture path", 8);
        tab_group_week.add(opText);

        input_weekName = new FlxUIInputText(10, 50, 200, '', 8);
        tab_group_week.add(input_weekName);

        var opText:FlxText = new FlxText(input_weekName.x, input_weekName.y - 15, FlxG.width, "Week Name", 8);
        tab_group_week.add(opText);

        input_weekSongs = new FlxUIInputText(10, 80, 200, '', 8);
        tab_group_week.add(input_weekSongs);

        var opText:FlxText = new FlxText(input_weekSongs.x, input_weekSongs.y - 15, FlxG.width, "Week Songs", 8);
        tab_group_week.add(opText);

        input_weekCharacters = new FlxUIInputText(10, 110, 200, '', 8);
        tab_group_week.add(input_weekCharacters);

        var opText:FlxText = new FlxText(input_weekCharacters.x, input_weekCharacters.y - 15, FlxG.width, "Week Characters", 8);
        tab_group_week.add(opText);

        var button:FlxButton = new FlxButton(275, 20, 'Save Week', function() {
            saveWeek(weekFile);
        });
        tab_group_week.add(button);

        var button2:FlxButton = new FlxButton(275, button.y + button.height + 10, 'Load Week', function() {
            loadWeek();
        });
        tab_group_week.add(button2);

        uiBox.addGroup(tab_group_week);
        uiBox.scrollFactor.set();
    }

    function updateInformations() {
        input_texturePath.text = weekFile.texture;
        input_weekName.text = weekFile.name;
        var str:String = weekFile.songs.toString();
        input_weekSongs.text = str.substr(1, str.length - 2);
        var strr:String = weekFile.characters.toString();
        input_weekCharacters.text = strr.substr(1, strr.length - 2);
    }

    override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>) {
        if (id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText)) {
            if (sender == input_texturePath) {
                grpWeekText.members[0].changeGraphic(input_texturePath.text);
                weekFile.texture = input_texturePath.text;
            } else if (sender == input_weekName) {
                weekFile.name = input_weekName.text;
            } else if (sender == input_weekSongs) {
                weekFile.songs = input_weekSongs.text.trim().split(',');
                updateText();
            } else if (sender == input_weekCharacters) {
                var sex:Array<String> = input_weekCharacters.text.trim().split(',');
                weekFile.characters = [sex[0], sex[1], sex[2]];
                changeCharacters();
            }
        }
    }

    var _file:FileReference;

    function loadWeek() {
        var jsonFilter:FileFilter = new FileFilter('JSON', 'json');
        _file = new FileReference();
        _file.addEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onLoadComplete);
        _file.addEventListener(Event.CANCEL, onLoadCancel);
        _file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
        _file.browse([jsonFilter]);
    }

    var loadedWeek:WeekData = null;
    var loadError:Bool = false;

    function onLoadComplete(_):Void {
        _file.removeEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onLoadComplete);
        _file.removeEventListener(Event.CANCEL, onLoadCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);

        #if sys
        var fullPath:String = null;
        var jsonLoaded = cast haxe.Json.parse(haxe.Json.stringify(_file));
        if (jsonLoaded.__path != null)
            fullPath = jsonLoaded.__path;

        if(fullPath != null) {
            var rawJson:String = sys.io.File.getContent(fullPath);
            if(rawJson != null) {
                loadedWeek = cast haxe.Json.parse(rawJson);
                if(loadedWeek.characters != null && loadedWeek.name != null) {
                    var cutName:String = _file.name.substr(0, _file.name.length - 5);
                    Logger.log("Successfully loaded file: " + cutName);
                    loadError = false;
                    _file = null;

                    checkJson();
                    updateInformations();
                    changeCharacters();
                    updateText();
                    grpWeekText.members[0].changeGraphic(input_texturePath.text);

                    return;
                }
            }
        }
        loadError = true;
        loadedWeek = null;
        _file = null;
        #else
        Logger.log("Error: File couldn't be loaded! You aren't on Desktop, are you?");
        #end
    }

    function checkJson() {
        weekFile = {
            name: loadedWeek.name,
            texture: loadedWeek.texture,
            songs: loadedWeek.songs,
            characters: loadedWeek.characters
        }
    }

    /**
    * Called when the save file dialog is cancelled.
    */
    function onLoadCancel(_):Void {
        _file.removeEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onLoadComplete);
        _file.removeEventListener(Event.CANCEL, onLoadCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
        _file = null;
        Logger.log("Cancelled file loading.");
    }

    /**
    * Called if there is an error while saving the gameplay recording.
    */
    function onLoadError(_):Void {
        _file.removeEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onLoadComplete);
        _file.removeEventListener(Event.CANCEL, onLoadCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
        _file = null;
        Logger.log("Error: Problem loading file");
    }

    function saveWeek(weekFile:WeekData) {
        var data:String = haxe.Json.stringify(weekFile, "\t");
        if (data.length > 0) {
            _file = new FileReference();
            _file.addEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onSaveComplete);
            _file.addEventListener(Event.CANCEL, onSaveCancel);
            _file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
            _file.save(data, "week.json");
        }
    }
    
    function onSaveComplete(_):Void {
        _file.removeEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
        Logger.log("Successfully saved file.");
    }

    function onSaveCancel(_):Void {
        _file.removeEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
    }

    function onSaveError(_):Void {
        _file.removeEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
        Logger.log("Error: Problem saving file");
    }
}
