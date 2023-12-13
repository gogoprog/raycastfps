package input;

class Mouse {
    public var buttons:Array<Bool> = [];
    public var wheelDelta:Int = 0;
    public var previousButtons:Array<Bool> = [];
    public var position:math.Point = [];
    public var internalPosition:math.Point = [0, 0];
    public var moveX = 0.0;

    public function new() {
    }

    inline public function isJustPressed(i:Int) {
        return !previousButtons[i] && buttons[i];
    }

    inline public function isJustReleased(i:Int) {
        return previousButtons[i] && !buttons[i];
    }
}
