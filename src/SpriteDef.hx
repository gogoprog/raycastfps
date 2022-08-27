package;

typedef Texture = {
    var name:String;
    @:optional var flip:Bool;
}

class SpriteDef {
    public var textures: Array<Texture> = [];
    public var heightOffset = 0;

    public function new() {
    }
}
