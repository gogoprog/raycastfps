package def;

typedef Wall = {
    var a:Int;
    var b:Int;
    var bottomTextureName:String;
    var textureName:String;
    var textureScale:math.Point;
}

typedef Room = {
    var walls:Array<Int>;
    var floorTextureName:String;
    var bottom:Float;
    var top:Float;
    @:optional var door:Bool;
}

typedef Object = {
    var type:String;
    var name:String;
    var position:math.Point;
}

typedef Level = {
    @:optional var name:String;
    @:optional var type:String;
    @:optional var endMenu:Int;
    var vertices:Array<math.Point>;
    var walls:Array<Wall>;
    var rooms:Array<Room>;
    var objects:Array<Object>;
    var skyTextureName:String;
    @:optional var effect:String;
    @:optional var music:String;
}
