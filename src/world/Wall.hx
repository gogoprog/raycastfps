package world;

import math.Point;

class Wall {
    public var a:Point;
    public var b:Point;
    public var textureName:String;
    public var texture:display.Framebuffer;
    public var length:Float;
    public var height:Float;
    public var textureScale:Point = [0.8, 4];

    public function new(a, b, textureName) {
        this.a = a;
        this.b = b;
        this.textureName = textureName;
        length = (a - b).getLength();
        height = 3;
    }
}
