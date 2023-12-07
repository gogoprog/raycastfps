package core;

@:allow(core.ProjectileSystem)
class Projectile {
    public var weapon:def.Weapon;
    public var source:ecs.Entity;

    public function new() {
    }

    private var velocity:math.Point;
    private var time = 0.0;
}
