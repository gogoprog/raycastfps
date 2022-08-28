package core;

@:allow(core.SpriteAnimationSystem)
class SpriteAnimation {
    public function new() {}

    public var name:String;

    private var time:Float = 0;
    private var currentName:String;
    private var def:def.Animation;
    private var duration:Float;
}
