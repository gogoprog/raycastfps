package core;

import def.Monster;

@:allow(core.CharacterSystem)
class Character {
    public var requestFire = false;
    public var requestOpen = false;
    public var didFire = false;
    public var weapon:def.Weapon;
    public var animations:def.Animations;
    public var effects:def.Effects;
    public var sounds:def.Sounds;

    public function new() {
    }

    private var timeSinceLastFire = 0.0;
    private var lastSeconds = 0;
    private var time = 0.0;
}
