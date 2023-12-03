package core;

class Control {

    public function new() {
    }

    public var mouseMovement = 0.0;
    public var mouseButtons:Array<Bool> = [];
    public var previousMouseButtons:Array<Bool> = [];
    public var keys:Dynamic;
    public var speed:Float = 0;
    public var lateralSpeed:Float = 0;
    public var maxSpeed:Float = 300;
    public var acceleration:Float = 1000;
    public var deceleration:Float = 500;
    public var direction:math.Point = [0, 0];
}
