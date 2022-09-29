package core;

@:allow(core.SpriteAnimationSystem)
class SpriteAnimator {
    public function new() {}

    public function getName():String {
        return names[names.length - 1];
    }

    public function push(name:String) {
        names.push(name);
    }

    private var names:Array<String> = [];
    private var time:Float = 0;
    private var currentName:String;
    private var def:def.Animation;
    private var duration:Float;
}
