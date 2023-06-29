package world;

import math.Point;

class Wall {
    public var a:Point;
    public var b:Point;
    public var bottomTextureName:String;
    public var textureName:String;
    public var texture:display.Framebuffer;
    public var bottomTexture:display.Framebuffer;
    public var length:Float;
    public var height:Float;
    public var offset:Float = 0;
    public var textureScale:Point = [1, 1];
    public var center:Point;

    public function new(a, b, textureName, bottomTextureName) {
        this.a = a;
        this.b = b;
        this.textureName = textureName;
        this.bottomTextureName = bottomTextureName;
        length = (a - b).getLength();
        height = 1;
        center = (a + b) * 0.5;
    }
}
