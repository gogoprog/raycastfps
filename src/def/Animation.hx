package def;

typedef Texture = {
    var name:String;
    @:optional var flip:Bool;
    @:optional var offset:Int;
}

typedef Textures = Array<Texture>;

typedef Frames = Array<Textures>;

typedef Animation = {
    var name:String;
    var frames:Frames;
    var rate:Float;
    var loop:Bool;
}
