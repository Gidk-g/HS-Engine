package states.editors;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.ui.FlxButton;
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
	var characterList:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
	var dumbTexts:FlxTypedGroup<FlxText>;
	var charLayer:FlxTypedGroup<Character>;
	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var isDad:Bool = true;
	var daAnim:String = 'spooky';
	var camFollow:FlxObject;

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
		UI_box.resize(250, 120);
		UI_box.x = FlxG.width - 275;
		UI_box.y = 25;
		UI_box.scrollFactor.set();

		var tabs = [
			{name: 'Animations', label: 'Animations'},
		];

		UI_characterbox = new FlxUITabMenu(null, tabs, true);
		UI_characterbox.cameras = [camHUD];
		UI_characterbox.resize(350, 250);
		UI_characterbox.x = UI_box.x - 100;
		UI_characterbox.y = UI_box.y + UI_box.height;
		UI_characterbox.scrollFactor.set();

		var tabs = [
			{name: 'Character', label: 'Character'},
		];

		UI_charactergbox = new FlxUITabMenu(null, tabs, true);
		UI_charactergbox.cameras = [camHUD];
		UI_charactergbox.resize(350, 250);
		UI_charactergbox.x = UI_box.x - 100;
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

		super.create();
	}

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

		tab_group.add(check_player);

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

	function reloadAnimationDropDown() {
		var anims:Array<String> = [];
		for (anim in char.animationsArray) {
			anims.push(anim.anim);
		}
		if(anims.length < 1) anims.push('');
		animationDropDown.setData(FlxUIDropDownMenu.makeStrIdLabelArray(anims, true));
	}

	function addCharacterUI() {
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Character";
		UI_charactergbox.addGroup(tab_group);
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
	}

	override function update(elapsed:Float)
	{
		if(char.animation.curAnim != null) {
			textAnim.text = char.animation.curAnim.name;
		} else {
			textAnim.text = '';
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

			if (FlxG.keys.justPressed.ESCAPE) {
				FlxG.switchState(new PlayState());
				FlxG.mouse.visible = false;
				return;
			}

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
		camMenu.zoom = FlxG.camera.zoom;
		super.update(elapsed);
	}
}
