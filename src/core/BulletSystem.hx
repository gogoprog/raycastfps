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
        engine.removeEntity(e);
        var direction:Point = [];
        direction.setFromAngle(transform.angle);
        var ray_length = 1000;
        var start = transform.position;
        var end = start + direction * ray_length;
        var best_distance = 10000000.0;
        var best_entity:ecs.Entity = null;

        for(h in hittables) {
            var htransform = h.get(Transform);
            var hobject = h.get(Object);
            var collides = math.Utils.lineCircleIntersection(start, end, htransform.position, hobject.radius);

            if(collides) {
                var distance = Point.getSquareDistance(htransform.position, start);

                if(distance < best_distance) {
                    best_distance =distance;
                    best_entity = h;
                }
            }
        }

        for(s in Main.context.level.sectors) {
            for(w in s.walls) {
                if(w.texture != null) {
                    var r = math.Utils.segmentToSegmentIntersection(start, end, w.a, w.b);

                    if(r != null) {
                        var distance = r[0] * ray_length;
                        distance *= distance;

                        if(distance < best_distance) {
                            best_distance = distance;
                            best_entity = null;
                        }
                    }
                }
            }
        }

        if(best_distance != 10000000) {
            var position = start + direction * Math.sqrt(best_distance - 100);
            Factory.createImpact(engine, position);

            if(best_entity != null) {
                hit(best_entity);
            }
        }
    }


    private function hit(target:ecs.Entity) {
        var hittable = target.get(Hittable);
        hittable.life -= 100;
    }
}
