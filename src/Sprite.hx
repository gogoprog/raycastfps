package;

@:allow(Renderer)
class Sprite {
    public var position:Point;
    public var texture:Framebuffer;
    public var heightOffset = 0;
    public var flip:Bool;
    private var distance:Float;

    public function new() {
    }
}
