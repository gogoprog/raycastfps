package core;

@:allow(core.CharacterSystem)
class Character {
    public var requestFire = false;
    public var fireRate = 1.4;
    public var didFire = false;

    public function new() {
    }

    private var timeSinceLastFire = 0.0;
}
