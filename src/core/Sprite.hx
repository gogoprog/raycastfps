package core;

typedef Texture = {
    var name:String;
    @:optional var flip:Bool;
}

class Sprite {
    public var textures: Array<Texture> = [];
    public var heightOffset = 0;

    public function new() {
    }
}
