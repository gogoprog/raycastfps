package input;

class Keyboard {
    public var previousKeys:Dynamic = {};
    public var keys:Dynamic = {};

    public function new() {
    }

    inline public function isJustPressed(k:String) {
        return untyped !previousKeys[k] && untyped keys[k];
    }

    inline public function isPressed(k:String) {
        return untyped keys[k];
    }
}
