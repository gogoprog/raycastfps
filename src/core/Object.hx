package core;

class Object {
    public var radius:Float = 16;
    public var lastTranslation = new math.Point();
    public var currentSector:world.Sector;
    public var velocityY = 0.0;

    public function new() {
    }
}
