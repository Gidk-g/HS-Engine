package system;

import haxe.Json;
import flixel.FlxBasic;
import flixel.FlxSprite;
import openfl.utils.Assets;
import openfl.display.BlendMode;
import flixel.group.FlxGroup.FlxTypedGroup;

typedef StageJSON =
{
	var defaultZoom:Float;
	var spawnGirlfriend:Bool;
	var boyfriend:Array<Dynamic>;
	var girlfriend:Array<Dynamic>;
	var dad:Array<Dynamic>;
    var objects:Array<StageObject>;
}

typedef StageObject =
{
	var name:Null<String>;
	var spritePath:Null<String>;
	var position:Null<Array<Float>>;
	var scrollFactor:Null<Array<Float>>;
	var scale:Null<Array<Float>>;
	var animations:Null<Array<Dynamic>>;
	var defaultAnimation:Null<String>;
	var flipX:Null<Bool>;
	var size:Null<Float>;
	var layer:String;
	var blend:String;
	var antialiasing:Bool;
}

class StageJson extends FlxTypedGroup<FlxBasic>
{
	public var foreground:FlxTypedGroup<FlxBasic>;
	public var layers:FlxTypedGroup<FlxBasic>;

    public static var objectMap:Map<String, FlxSprite> = new Map<String, FlxSprite>();

    public function new()
    {
		super();

		foreground = new FlxTypedGroup<FlxBasic>();
		layers = new FlxTypedGroup<FlxBasic>();

		var stageJson:StageJSON = getStageFile();

		if (stageJson != null)
        {
            if (stageJson.objects != null)
            {
                for (object in stageJson.objects)
                {
                    var createdSprite:FlxSprite = new FlxSprite(object.position[0], object.position[1]);

                    if (object.animations != null)
                    {
                        createdSprite.frames = Paths.getSparrowAtlas(object.spritePath);
                        for (anim in object.animations)
                            createdSprite.animation.addByPrefix(anim[0], anim[1], anim[2], anim[3]);
                        if (object.defaultAnimation != null)
                            createdSprite.animation.play(object.defaultAnimation);
                    }
                    else
                        createdSprite.loadGraphic(Paths.image(object.spritePath));

                    if (object.scrollFactor != null)
                        createdSprite.scrollFactor.set(object.scrollFactor[0], object.scrollFactor[1]);

                    if (object.size != null)
                        createdSprite.setGraphicSize(Std.int(createdSprite.width * object.size));

                    if (object.scale != null)
                    {
                        createdSprite.scale.x = object.scale[0];
                        createdSprite.scale.y = object.scale[1];
                    }

                    createdSprite.flipX = object.flipX;
                    createdSprite.antialiasing = object.antialiasing;

                    if (object.blend != null)
                        createdSprite.blend = returnBlendMode(object.blend);

                    if (object.name != null && createdSprite != null)
                        objectMap.set(object.name, createdSprite);

                    switch (object.layer)
                    {
                        case 'layers':
                            layers.add(createdSprite);
                        case 'foreground':
                            foreground.add(createdSprite);
                        default:
                            add(createdSprite);
                    }
                }
            }
        }
    }

	public static function returnBlendMode(str:String):BlendMode
    {
        return switch (str)
        {
            case "normal": BlendMode.NORMAL;
            case "darken": BlendMode.DARKEN;
            case "multiply": BlendMode.MULTIPLY;
            case "lighten": BlendMode.LIGHTEN;
            case "screen": BlendMode.SCREEN;
            case "overlay": BlendMode.OVERLAY;
            case "hardlight": BlendMode.HARDLIGHT;
            case "difference": BlendMode.DIFFERENCE;
            case "add": BlendMode.ADD;
            case "subtract": BlendMode.SUBTRACT;
            case "invert": BlendMode.INVERT;
            case _: BlendMode.NORMAL;
        }
    }

	public static function getStageFile():StageJSON
    {
        var rawJson:String = null;
        var path:String = Paths.json('stages/' + PlayState.curStage);

        if(Assets.exists(path))
            rawJson = Assets.getText(path);
        else
            return null;

        return cast Json.parse(rawJson);
    }
}
