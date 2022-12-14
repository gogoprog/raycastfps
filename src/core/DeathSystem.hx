package core;

import math.Point;
import math.Transform;

class DeathSystem extends ecs.System {

    public function new() {
        super();
        addComponentClass(Hittable);
        addComponentClass(Character);
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var character = e.get(core.Character);
        var hittable = e.get(core.Hittable);

        if(hittable.life <= 0) {
            var animator = e.get(core.SpriteAnimator);
            animator.clear();
            animator.push("explosion");
            e.remove(Hittable);

            Factory.createGibs(engine, e.get(Transform).position);
        }
    }
}
