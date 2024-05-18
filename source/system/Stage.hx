package system;

import haxe.Json;

typedef ObjectData = {
    var name:String;
    var position:Array<Float>;
    var image:String;
    var scrollFactor:Array<Float>;
    var antialiasing:Bool;
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

// TODO: create the stage JSON but not now because i'm lazy lol
class Stage {
    public function new(jsonData:String) {
        var stageJson = Json.parse(jsonData);
        if (stageJson == null) {
            Logger.log("Error: Failed to parse JSON data");
            return;
        }
    }
}
