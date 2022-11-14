package core;

import math.Transform;

class BulletSystem extends ecs.System {

    var hittables:Array<ecs.Entity>;

    public function new() {
        super();
        addComponentClass(Bullet);
        addComponentClass(Transform);
    }

    override public function update(dt:Float) {
        hittables = engine.getMatchingEntities(Hittable);
        super.update(dt);
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var bullet = e.get(core.Bullet);
        var transform = e.get(Transform);

        for(h in hittables) {
            var htransform = h.get(Transform);
            var hobject = h.get(Object);
        }
    }
}
