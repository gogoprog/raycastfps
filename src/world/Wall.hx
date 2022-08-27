package world;

import math.Point;

class Wall {
    public var a:Point;
    public var b:Point;
    public var texture:display.Framebuffer;
    public var length:Float;

    public function new(a, b, texture) {
        this.a = a;
        this.b = b;
        this.texture = texture;
        length = (a - b).getLength();
    }
}
