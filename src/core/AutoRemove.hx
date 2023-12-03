package core;

@:allow(core.AutoRemoveSystem)
class AutoRemove {
    public var duration:Float;

    public function new(duration) {
        this.duration = duration;
    }

    private var time = 0.0;
}
