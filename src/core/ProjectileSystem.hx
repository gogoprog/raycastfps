package core;

import math.Point;
import math.Transform;

class ProjectileSystem extends ecs.System {
    var hittables:Array<ecs.Entity>;

    public function new() {
        super();
        addComponentClass(Projectile);
        addComponentClass(Transform);
    }

    override public function update(dt:Float) {
        hittables = engine.getMatchingEntities(Hittable);
        super.update(dt);
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var proj = e.get(core.Projectile);
        var transform = e.get(Transform);

        if(proj.velocity == null) {
            var v:Point = [];
            v.setFromAngle(transform.angle);
            v.mul(proj.weapon.projectile.speed);
            proj.velocity = v;
        }

        transform.position.add(proj.velocity * dt);

        proj.time += dt;

        if(proj.time > proj.weapon.projectile.lifetime) {
            engine.removeEntity(e);
        }
    }

    private function hit(target:ecs.Entity) {
        var hittable = target.get(Hittable);
        hittable.life -= 100;
    }
}
