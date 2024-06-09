package system;

import haxe.Json;
import flixel.FlxSprite;

typedef ObjectData = {
    var name:String;
    var position:Array<Float>;
    var image:String;
    var scrollFactor:Array<Float>;
    var antialiasing:Bool;
    var alpha:Float;
    var layer:Int;
    var scale:Float;
}

typedef StageJson = {
    var objects:Array<ObjectData>;
    var defaultCamZoom:Float;
    var bfPosition:Array<Float>;
    var gfPosition:Array<Float>;
    var dadPosition:Array<Float>;
}

class Stage {
    var stageFile:StageJson;

    public static var stageZoom:Float = 1.05;

    public static var bfPos:Array<Float> = [770, 100];
    public static var gfPos:Array<Float> = [400, 130];
    public static var dadPos:Array<Float> = [100, 100];

    public static var objectMap:Map<String, FlxSprite> = new Map<String, FlxSprite>();

    public function new(jsonData:String) {
        stageZoom = 0.9;

        bfPos = [770, 100];
        gfPos = [400, 130];
        dadPos = [100, 100];

        try {
            var parsedData:Dynamic = Json.parse(jsonData);
            if (parsedData == null) {
                Logger.log("Warn: Parsed data is null");
            }
            stageFile = parsedData;
            createObjects();
            updatePosition();
            Logger.log("Successfully parsed stage data");
        } catch (error:Dynamic) {
            Logger.log("Error: Failed to parse JSON data - " + error);
            return;
        }
    }

    function createObjects() {
        for (i in 0...stageFile.objects.length) {
            var sprite:FlxSprite = new FlxSprite();
            sprite.loadGraphic(Paths.image(stageFile.objects[i].image));
            sprite.scale.set(stageFile.objects[i].scale, stageFile.objects[i].scale);
            sprite.antialiasing = stageFile.objects[i].antialiasing;
            sprite.setPosition(stageFile.objects[i].position[0], stageFile.objects[i].position[1]);
            sprite.scrollFactor.set(stageFile.objects[i].scrollFactor[0], stageFile.objects[i].scrollFactor[1]);
            sprite.alpha = stageFile.objects[i].alpha;
            switch (stageFile.objects[i].layer) {
                case 0:
                    PlayState.instance.add(sprite);
                case 1:
                    PlayState.instance.foreground.add(sprite);
                default:
                    PlayState.instance.add(sprite);
            }
            objectMap.set(stageFile.objects[i].name, sprite);
            sprite.ID = i;
        }
    }

    function updatePosition() {
        bfPos = stageFile.bfPosition;
        gfPos = stageFile.gfPosition;
        dadPos = stageFile.dadPosition;
        stageZoom = stageFile.defaultCamZoom;
    }
}
