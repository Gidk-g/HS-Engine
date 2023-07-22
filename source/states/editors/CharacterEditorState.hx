package states.editors;

import haxe.Json;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.ui.FlxButton;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import lime.system.Clipboard;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;

class CharacterEditorState extends MusicBeatState
{
	var char:Character;
	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var charLayer:FlxTypedGroup<Character>;
	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var isDad:Bool = true;
	var daAnim:String = 'spooky';
	var camFollow:FlxObject;

	var characterList:Array<String> = [];
	var leHealthIcon:HealthIcon;

	var UI_characterbox:FlxUITabMenu;
	var UI_charactergbox:FlxUITabMenu;
	var UI_box:FlxUITabMenu;

	private var camEditor:FlxCamera;
	private var camHUD:FlxCamera;
	private var camMenu:FlxCamera;

	public function new(daAnim:String = 'spooky')
	{
		super();
		this.daAnim = daAnim;
	}

	override function create()
	{
		FlxG.sound.music.stop();

		camEditor = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camMenu = new FlxCamera();
		camMenu.bgColor.alpha = 0;

		FlxG.cameras.reset(camEditor);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camMenu);
		FlxCamera.defaultCameras = [camEditor];

		var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
		bg.antialiasing = true;
		bg.scrollFactor.set(0.9, 0.9);
		bg.active = false;
		add(bg);

		var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		stageFront.antialiasing = true;
		stageFront.scrollFactor.set(0.9, 0.9);
		stageFront.active = false;
		add(stageFront);

		var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
		stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		stageCurtains.updateHitbox();
		stageCurtains.antialiasing = true;
		stageCurtains.scrollFactor.set(1.3, 1.3);
		stageCurtains.active = false;
		add(stageCurtains);

		charLayer = new FlxTypedGroup<Character>();
		add(charLayer);

		loadChar(!daAnim.startsWith('bf'), false);

		leHealthIcon = new HealthIcon(char.healthIcon, false);
		leHealthIcon.y = FlxG.height - 150;
		add(leHealthIcon);
		leHealthIcon.cameras = [camHUD];

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);
		dumbTexts.cameras = [camHUD];

		textAnim = new FlxText(300, 16);
		textAnim.size = 26;
		textAnim.color = FlxColor.WHITE;
		textAnim.cameras = [camHUD];
		textAnim.scrollFactor.set();
		add(textAnim);

		genBoyOffsets();

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

		var tabs = [
			{name: 'Settings', label: 'Settings'},
		];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.cameras = [camHUD];
		UI_box.resize(350, 120);
		UI_box.x = FlxG.width - 275 - 100;
		UI_box.y = 25;
		UI_box.scrollFactor.set();

		var tabs = [
			{name: 'Animations', label: 'Animations'},
		];

		UI_characterbox = new FlxUITabMenu(null, tabs, true);
		UI_characterbox.cameras = [camHUD];
		UI_characterbox.resize(350, 250);
		UI_characterbox.x = UI_box.x;
		UI_characterbox.y = UI_box.y + UI_box.height;
		UI_characterbox.scrollFactor.set();

		var tabs = [
			{name: 'Character', label: 'Character'},
		];

		UI_charactergbox = new FlxUITabMenu(null, tabs, true);
		UI_charactergbox.cameras = [camHUD];
		UI_charactergbox.resize(350, 300);
		UI_charactergbox.x = UI_box.x;
		UI_charactergbox.y = UI_box.y + UI_box.height + UI_box.height + UI_box.height + 10;
		UI_charactergbox.scrollFactor.set();

		add(UI_characterbox);
		add(UI_charactergbox);
		add(UI_box);

		FlxG.mouse.visible = true;
		UI_characterbox.selected_tab_id = 'Animations';
		UI_charactergbox.selected_tab_id = 'Character';

		addSettingsUI();
		addAnimationsUI();
		addCharacterUI();

		reloadCharacterOptions();

		super.create();
	}

	var charDropDown:FlxUIDropDownMenu;

	function addSettingsUI() {
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Settings";

		var check_player = new FlxUICheckBox(10, 60, null, null, "FlipX Character", 100);
		check_player.checked = daAnim.startsWith('bf');
		check_player.callback = function()
		{
			char.isPlayer = !char.isPlayer;
			char.flipX = !char.flipX;
		};

		charDropDown = new FlxUIDropDownMenu(10, 30, FlxUIDropDownMenu.makeStrIdLabelArray([''], true), function(character:String)
		{
			daAnim = characterList[Std.parseInt(character)];
			loadChar(!check_player.checked);
			reloadCharacterDropDown();
		});
		charDropDown.selectedLabel = daAnim;
		reloadCharacterDropDown();

		var reloadCharacter:FlxButton = new FlxButton(140, 20, "Reload Char", function()
		{
			loadChar(!check_player.checked);
			reloadCharacterDropDown();
		});

		tab_group.add(new FlxText(charDropDown.x, charDropDown.y - 18, 0, 'Character:'));
		tab_group.add(check_player);
		tab_group.add(charDropDown);
		tab_group.add(reloadCharacter);

		UI_box.addGroup(tab_group);
	}

	var animationDropDown:FlxUIDropDownMenu;
	var animationInputText:FlxUIInputText;
	var animationNameInputText:FlxUIInputText;
	var animationIndicesInputText:FlxUIInputText;
	var animationNameFramerate:FlxUINumericStepper;
	var animationLoopCheckBox:FlxUICheckBox;

	function addAnimationsUI() {
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Animations";

		var anims:Array<String> = [];
		for (anim in char.animationsArray) {
			anims.push(anim.anim);
		}

		animationInputText = new FlxUIInputText(15, 85, 80, '', 8);
		animationNameInputText = new FlxUIInputText(animationInputText.x, animationInputText.y + 35, 150, '', 8);
		animationIndicesInputText = new FlxUIInputText(animationNameInputText.x, animationNameInputText.y + 40, 250, '', 8);
		animationNameFramerate = new FlxUINumericStepper(animationInputText.x + 170, animationInputText.y, 1, 24, 0, 240, 0);
		animationLoopCheckBox = new FlxUICheckBox(animationNameInputText.x + 170, animationNameInputText.y - 1, null, null, "Should it Loop?", 100);

		animationDropDown = new FlxUIDropDownMenu(15, animationInputText.y - 55, FlxUIDropDownMenu.makeStrIdLabelArray(anims, true), function(pressed:String) {
			var selectedAnimation:Int = Std.parseInt(pressed);
			for (anim in char.animationsArray) {
				if(char.animationsArray[selectedAnimation].anim == anim.anim) {
					animationInputText.text = anim.anim;
					animationNameInputText.text = anim.name;
					animationLoopCheckBox.checked = anim.loop;
					animationNameFramerate.value = anim.fps;

					var indicesStr:String = anim.indices.toString();
					animationIndicesInputText.text = indicesStr.substr(1, indicesStr.length - 2);
					break;
				}
			}
		});

		var addUpdateButton:FlxButton = new FlxButton(70, animationIndicesInputText.y + 30, "Add/Update", function() {
			var indices:Array<Int> = [];
			var indicesStr:Array<String> = animationIndicesInputText.text.trim().split(',');
			if(indicesStr.length > 1) {
				for (i in 0...indicesStr.length) {
					var index:Int = Std.parseInt(indicesStr[i]);
					if(indicesStr[i] != null && indicesStr[i] != '' && !Math.isNaN(index) && index > -1) {
						indices.push(index);
					}
				}
			}
			var lastAnim:String = '';
			if(char.animation.curAnim != null) {
				lastAnim = char.animation.curAnim.name;
			}
			var lastOffsets:Array<Int> = [0, 0];
			for (anim in char.animationsArray) {
				if(animationInputText.text == anim.anim) {
					lastOffsets = anim.offsets;
					if(char.animation.getByName(animationInputText.text) != null) {
						char.animation.remove(animationInputText.text);
					}
					char.animationsArray.remove(anim);
				}
			}
			var newAnim:AnimStuff = {
				anim: animationInputText.text,
				name: animationNameInputText.text,
				fps: Math.round(animationNameFramerate.value),
				loop: animationLoopCheckBox.checked,
				indices: indices,
				offsets: lastOffsets
			};
			if(indices != null && indices.length > 0) {
				char.animation.addByIndices(newAnim.anim, newAnim.name, newAnim.indices, "", newAnim.fps, newAnim.loop);
			} else {
				char.animation.addByPrefix(newAnim.anim, newAnim.name, newAnim.fps, newAnim.loop);
			}
			if(!char.animOffsets.exists(newAnim.anim)) {
				char.addOffset(newAnim.anim, 0, 0);
			}
			char.animationsArray.push(newAnim);
			if(lastAnim == animationInputText.text) {
				char.playAnim(lastAnim, true);
			}
			reloadAnimationDropDown();
			genBoyOffsets();
			trace('Added/Updated animation: ' + animationInputText.text);
		});

		var removeButton:FlxButton = new FlxButton(180, animationIndicesInputText.y + 30, "Remove", function() {
			for (anim in char.animationsArray) {
				if(animationInputText.text == anim.anim) {
					var resetAnim:Bool = false;
					if(char.animation.curAnim != null && anim.anim == char.animation.curAnim.name) resetAnim = true;
					if(char.animation.getByName(anim.anim) != null) {
						char.animation.remove(anim.anim);
					}
					if(char.animOffsets.exists(anim.anim)) {
						char.animOffsets.remove(anim.anim);
					}
					char.animationsArray.remove(anim);
					if(resetAnim && char.animationsArray.length > 0) {
						char.playAnim(char.animationsArray[0].anim, true);
					}
					reloadAnimationDropDown();
					genBoyOffsets();
					trace('Removed animation: ' + animationInputText.text);
					break;
				}
			}
		});

		tab_group.add(new FlxText(animationDropDown.x, animationDropDown.y - 18, 0, 'Animations:'));
		tab_group.add(new FlxText(animationInputText.x, animationInputText.y - 18, 0, 'Animation name:'));
		tab_group.add(new FlxText(animationNameFramerate.x, animationNameFramerate.y - 18, 0, 'Framerate:'));
		tab_group.add(new FlxText(animationNameInputText.x, animationNameInputText.y - 18, 0, 'Animation on .XML file:'));
		tab_group.add(new FlxText(animationIndicesInputText.x, animationIndicesInputText.y - 18, 0, 'ADVANCED - Animation Indices:'));

		tab_group.add(animationInputText);
		tab_group.add(animationNameInputText);
		tab_group.add(animationIndicesInputText);
		tab_group.add(animationNameFramerate);
		tab_group.add(animationLoopCheckBox);
		tab_group.add(addUpdateButton);
		tab_group.add(removeButton);
		tab_group.add(animationDropDown);

		UI_characterbox.addGroup(tab_group);
	}

	function reloadCharacterDropDown() {
		var charsLoaded:Map<String, Bool> = new Map();
		#if sys
		characterList = [];
		var directories:Array<String> = [ModPaths.modFolder('data/characters/'), Paths.getPreloadPath('data/characters/')];
		for (i in 0...directories.length) {
			var directory:String = directories[i];
			if(sys.FileSystem.exists(directory)) {
				for (file in sys.FileSystem.readDirectory(directory)) {
					var path = haxe.io.Path.join([directory, file]);
					if (!sys.FileSystem.isDirectory(path) && file.endsWith('.json')) {
						var charToCheck:String = file.substr(0, file.length - 5);
						if(!charsLoaded.exists(charToCheck)) {
							characterList.push(charToCheck);
							charsLoaded.set(charToCheck, true);
						}
					}
				}
			}
		}
		#else
		characterList = CoolUtil.coolTextFile(Paths.txt('characterList'));
		#end
		charDropDown.setData(FlxUIDropDownMenu.makeStrIdLabelArray(characterList, true));
		charDropDown.selectedLabel = daAnim;
	}

	function reloadAnimationDropDown() {
		var anims:Array<String> = [];
		for (anim in char.animationsArray) {
			anims.push(anim.anim);
		}
		if(anims.length < 1) anims.push('');
		animationDropDown.setData(FlxUIDropDownMenu.makeStrIdLabelArray(anims, true));
	}

	var imageInputText:FlxUIInputText;
	var healthIconInputText:FlxUIInputText;

	var singDurationStepper:FlxUINumericStepper;
	var scaleStepper:FlxUINumericStepper;
	var positionXStepper:FlxUINumericStepper;
	var positionYStepper:FlxUINumericStepper;
	var positionCameraXStepper:FlxUINumericStepper;
	var positionCameraYStepper:FlxUINumericStepper;

	var flipXCheckBox:FlxUICheckBox;
	var antialiasingCheckBox:FlxUICheckBox;

	function addCharacterUI() {
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Character";

		imageInputText = new FlxUIInputText(15, 30, 200, 'BOYFRIEND', 8);
		var reloadImage:FlxButton = new FlxButton(imageInputText.x + 210, imageInputText.y - 3, "Reload Image", function()
		{
			char.imageFile = imageInputText.text;
			reloadCharacterImage();
			if(char.animation.curAnim != null) {
				char.playAnim(char.animation.curAnim.name, true);
			}
		});

		healthIconInputText = new FlxUIInputText(15, imageInputText.y + 35, 75, leHealthIcon.getCharacter(), 8);
		singDurationStepper = new FlxUINumericStepper(15, healthIconInputText.y + 45, 0.1, 4, 0, 999, 1);
		scaleStepper = new FlxUINumericStepper(15, singDurationStepper.y + 40, 0.1, 1, 0.05, 10, 1);

		flipXCheckBox = new FlxUICheckBox(singDurationStepper.x + 80, singDurationStepper.y, null, null, "Flip X", 50);
		flipXCheckBox.checked = char.flipX;
		if(char.isPlayer) flipXCheckBox.checked = !flipXCheckBox.checked;
		flipXCheckBox.callback = function() {
			char.originalFlipX = !char.originalFlipX;
			char.flipX = char.originalFlipX;
			if(char.isPlayer) char.flipX = !char.flipX;
		};

		antialiasingCheckBox = new FlxUICheckBox(flipXCheckBox.x, flipXCheckBox.y + 40, null, null, "Antialiasing", 80);
		antialiasingCheckBox.checked = char.goofyAntialiasing;
		antialiasingCheckBox.callback = function() {
			char.antialiasing = true;
			if(!antialiasingCheckBox.checked) {
				char.antialiasing = false;
			}
		};

		var saveCharacterButton:FlxButton = new FlxButton(reloadImage.x, antialiasingCheckBox.y + 40, "Save Character", function() {
			saveCharacter();
		});

		tab_group.add(new FlxText(15, imageInputText.y - 18, 0, 'Image file name:'));
		tab_group.add(new FlxText(15, healthIconInputText.y - 18, 0, 'Health icon name:'));
		tab_group.add(new FlxText(15, singDurationStepper.y - 18, 0, 'Sing Animation length:'));
		tab_group.add(new FlxText(15, scaleStepper.y - 18, 0, 'Scale:'));
		tab_group.add(imageInputText);
		tab_group.add(reloadImage);
		tab_group.add(healthIconInputText);
		tab_group.add(singDurationStepper);
		tab_group.add(scaleStepper);
		tab_group.add(flipXCheckBox);
		tab_group.add(antialiasingCheckBox);
		tab_group.add(saveCharacterButton);

		UI_charactergbox.addGroup(tab_group);
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>) {
		if(id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText)) {
			if(sender == healthIconInputText) {
				leHealthIcon.changeIcon(healthIconInputText.text);
				char.healthIcon = healthIconInputText.text;
			}
			else if(sender == imageInputText) {
				char.imageFile = imageInputText.text;
			}
		} else if(id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)) {
			if (sender == scaleStepper)
			{
				reloadCharacterImage();
				char.jsonScale = sender.value;
				char.setGraphicSize(Std.int(char.width * char.jsonScale));
				char.updateHitbox();
				if(char.animation.curAnim != null) {
					char.playAnim(char.animation.curAnim.name, true);
				}
			}
			else if(sender == singDurationStepper)
			{
				char.singDuration = singDurationStepper.value;
			}
		}
	}

	function reloadCharacterImage() {
		var lastAnim:String = '';
		if(char.animation.curAnim != null) {
			lastAnim = char.animation.curAnim.name;
		}
		var anims:Array<game.Character.AnimStuff> = char.animationsArray.copy();
		if (openfl.utils.Assets.exists(Paths.file("images/" + char.imageFile + ".txt", TEXT))) {
			char.frames = Paths.getPackerAtlas(char.imageFile);
		} else {
			char.frames = Paths.getSparrowAtlas(char.imageFile);
		}
		if(char.animationsArray != null && char.animationsArray.length > 0) {
			for (anim in char.animationsArray) {
				var animIndices:Array<Int> = anim.indices;
				if (animIndices != null && animIndices.length > 0)
					char.animation.addByIndices(anim.anim, anim.name, animIndices, "", anim.fps, anim.loop);
				else
					char.animation.addByPrefix(anim.anim, anim.name, anim.fps, anim.loop);
				if (anim.offsets != null && anim.offsets.length > 1)
					char.addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
			}
		}
		if(lastAnim != '') {
			char.playAnim(lastAnim, true);
		} else {
			char.dance();
		}
	}

	function genBoyOffsets():Void
	{
		var daLoop:Int = 0;
		dumbTexts.clear();

		for (anim => offsets in char.animOffsets)
		{
			var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.scrollFactor.set();
			text.color = FlxColor.WHITE;
			dumbTexts.add(text);
			text.cameras = [camHUD];
			daLoop++;
		}

		textAnim.visible = true;
		if(dumbTexts.length < 1) {
			var text:FlxText = new FlxText(10, 38, 0, "ERROR! No animations found.", 15);
			text.scrollFactor.set();
			text.color = FlxColor.RED;
			dumbTexts.add(text);
			textAnim.visible = false;
		}
	}

	function loadChar(isDad:Bool, blahBlahBlah:Bool = true) {
		charLayer.clear();
		char = new Character(0, 0, daAnim, !isDad);
		char.screenCenter();
		char.debugMode = true;
		charLayer.add(char);
		char.setPosition(char.characterOffset[0] + 100, char.characterOffset[1]);
		if(blahBlahBlah) {
			genBoyOffsets();
		}
		reloadCharacterOptions();
	}

	function reloadCharacterOptions() {
		if(UI_characterbox != null) {
			imageInputText.text = char.imageFile;
			healthIconInputText.text = char.healthIcon;
			singDurationStepper.value = char.singDuration;
			scaleStepper.value = char.jsonScale;
			flipXCheckBox.checked = char.originalFlipX;
			antialiasingCheckBox.checked = char.goofyAntialiasing;
			leHealthIcon.changeIcon(healthIconInputText.text);
			reloadAnimationDropDown();
		}
	}

	override function update(elapsed:Float)
	{
		if(char.animation.curAnim != null) {
			textAnim.text = char.animation.curAnim.name;
		} else {
			textAnim.text = '';
		}

		var inputTexts:Array<FlxUIInputText> = [animationInputText, imageInputText, healthIconInputText, animationNameInputText, animationIndicesInputText];
		for (i in 0...inputTexts.length) {
			if(inputTexts[i].hasFocus) {
				super.update(elapsed);
				return;
			}
		}

		if(!charDropDown.dropPanel.visible) {
			if (FlxG.keys.justPressed.ESCAPE) {
				FlxG.switchState(new PlayState());
				FlxG.mouse.visible = false;
				return;
			}

			if (FlxG.keys.pressed.E && FlxG.camera.zoom < 5) {
				FlxG.camera.zoom += elapsed * FlxG.camera.zoom;
				if(FlxG.camera.zoom > 5) FlxG.camera.zoom = 5;
			}
			if (FlxG.keys.pressed.Q && FlxG.camera.zoom > 0.1) {
				FlxG.camera.zoom -= elapsed * FlxG.camera.zoom;
				if(FlxG.camera.zoom < 0.1) FlxG.camera.zoom = 0.1;
			}
	
			if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
			{
				var shiftMult:Int = 1;
				if (FlxG.keys.pressed.SHIFT)
					shiftMult = 4;
	
				if (FlxG.keys.pressed.I)
					camFollow.velocity.y = -90 * shiftMult;
				else if (FlxG.keys.pressed.K)
					camFollow.velocity.y = 90 * shiftMult;
				else
					camFollow.velocity.y = 0;
	
				if (FlxG.keys.pressed.J)
					camFollow.velocity.x = -90 * shiftMult;
				else if (FlxG.keys.pressed.L)
					camFollow.velocity.x = 90 * shiftMult;
				else
					camFollow.velocity.x = 0;
			}
			else
			{
				camFollow.velocity.set();
			}
	
			if(char.animationsArray.length > 0) {
				if (FlxG.keys.justPressed.W)
				{
					curAnim -= 1;
				}
	
				if (FlxG.keys.justPressed.S)
				{
					curAnim += 1;
				}
	
				if (curAnim < 0)
					curAnim = char.animationsArray.length - 1;
	
				if (curAnim >= char.animationsArray.length)
					curAnim = 0;
	
				if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE)
				{
					char.playAnim(char.animationsArray[curAnim].anim, true);
					genBoyOffsets();
				}
	
				var controlArray:Array<Bool> = [FlxG.keys.justPressed.LEFT, FlxG.keys.justPressed.RIGHT, FlxG.keys.justPressed.UP, FlxG.keys.justPressed.DOWN];
				for (i in 0...controlArray.length) {
					if(controlArray[i]) {
						var holdShift = FlxG.keys.pressed.SHIFT;
						var multiplier = 1;
						if (holdShift)
							multiplier = 10;
						var arrayVal = 0;
						if(i > 1) arrayVal = 1;
						var negaMult:Int = 1;
						if(i % 2 == 1) negaMult = -1;
						char.animationsArray[curAnim].offsets[arrayVal] += negaMult * multiplier;
						char.addOffset(char.animationsArray[curAnim].anim, char.animationsArray[curAnim].offsets[0], char.animationsArray[curAnim].offsets[1]);
						char.playAnim(char.animationsArray[curAnim].anim, false);
						genBoyOffsets();
					}
				}
			}
	    }
		camMenu.zoom = FlxG.camera.zoom;
		super.update(elapsed);
	}

	var _file:FileReference;

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved file.");
	}

	/**
		* Called when the save file dialog is cancelled.
		*/
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
		* Called if there is an error while saving the gameplay recording.
		*/
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving file");
	}

	function saveCharacter() {
		var json = {
			"animations": char.animationsArray,
			"spritePath": char.imageFile,
			"scale": char.jsonScale,
			"singDuration": char.singDuration,
			"healthIcon": char.healthIcon,
			"characterOffset":	char.characterOffset,
			"cameraOffset": char.cameraOffset,
			"flipX": char.originalFlipX,
			"antialiasing": char.antialiasing
		};

		var data:String = Json.stringify(json, "\t");

		if (data.length > 0)
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, daAnim + ".json");
		}
	}

	function ClipboardAdd(prefix:String = ''):String {
		if(prefix.toLowerCase().endsWith('v')) //probably copy paste attempt
		{
			prefix = prefix.substring(0, prefix.length-1);
		}
		var text:String = prefix + Clipboard.text.replace('\n', '');
		return text;
	}
}
