package def;

typedef Texture = {
    var name:String;
    @:optional var flip:Bool;
}

typedef Textures = Array<Texture>;

typedef Frames = Array<Textures>;

typedef Animation = {
    var frames:Frames;
    var rate:Float;
}
