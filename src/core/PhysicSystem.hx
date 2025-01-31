package core;

import math.Point;
import math.Transform;

class PhysicSystem extends ecs.System {

    public function new() {
        super();
        addComponentClass(Sprite);
        addComponentClass(Object);
        addComponentClass(Transform);
        addComponentClass(Physic);
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var transform = e.get(Transform);
        var physic = e.get(Physic);
        var object = e.get(Object);
        transform.position = transform.position + physic.velocity * dt;
        transform.y += physic.yVelocity * dt;
        physic.yVelocity -= physic.gravity * dt;
        var sector = object.currentSector;

        if(sector != null) {
            var sprite = e.get(Sprite);

            if(transform.y < sector.bottom) {
                transform.y = sector.bottom;
                physic.yVelocity = 0;
                physic.velocity.set(0, 0);
            }
        }
    }
}
