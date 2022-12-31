package core;

import math.Point;
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
        /* var bullet = e.get(core.Bullet); */
        var transform = e.get(Transform);
        var direction:Point = [];
        direction.setFromAngle(transform.angle);
        var end = transform.position + direction * 1000;
        var best_distance = 10000000.0;
        var best_entity:ecs.Entity = null;

        for(h in hittables) {
            var htransform = h.get(Transform);
            var hobject = h.get(Object);
            var collides = math.Utils.lineCircleIntersection(transform.position, end, htransform.position, hobject.radius);

            if(collides) {
                var distance = Point.getSquareDistance(htransform.position, transform.position);

                if(distance < best_distance) {
                    best_distance =distance;
                    best_entity = h;
                }
            }

            engine.removeEntity(e);
        }

        if(best_entity != null) {
            hit(best_entity);
        }
    }


    private function hit(target:ecs.Entity) {
        var hittable = target.get(Hittable);
        hittable.life -= 100;
        var e = new ecs.Entity();
        e.add(new core.Sprite());
        e.add(new core.Object());
        e.get(core.Object).heightOffset = 10;
        e.add(new math.Transform());
        e.get(math.Transform).copyFrom(target.get(math.Transform));
        e.add(new core.SpriteAnimator());
        e.get(core.SpriteAnimator).push("impact");
        engine.addEntity(e);
    }
}
