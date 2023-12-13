package core;


@:allow(core.PlayerSystem)
class Player {
    public function new() {
    }

    private var time = 0.0;
    private var timeSinceLastEffect = 0.0;
    public var cameraOffsetY = 32.0;
}
