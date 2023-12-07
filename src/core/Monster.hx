package core;

@:allow(core.MonsterSystem)
class Monster {
    private var timeLeft = 0.0;
    private var timeSinceLastAttack = 0.0;
    private var attackInterval = 0.0;

    public var def:def.Monster;
    public var weapon:def.Weapon;

    public function new() {
    }
}
