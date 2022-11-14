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

    public function replace1(name:String) {
        while(names.length > 1) {
            names.pop();
        }

        currentName = null;
        names.push(name);
    }

    public function getAnimationsCount() {
        return names.length;
    }

    private var names:Array<String> = [];
    private var time:Float = 0;
    private var currentName:String;
    private var def:def.Animation;
    private var duration:Float;
}
