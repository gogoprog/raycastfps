package core;

import math.Point;
import math.Transform;

class ProjectileSystem extends ecs.System {
    var hittables:Array<ecs.Entity>;
    var previousPosition:math.Point = [0, 0];

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

        previousPosition.copyFrom(transform.position);

        transform.position.add(proj.velocity * dt);

        proj.time += dt;

        if(proj.time > proj.weapon.projectile.lifetime) {
            engine.removeEntity(e);
            return;
        }

        var start = previousPosition;
        var end = transform.position;

        for(h in hittables) {
            var htransform = h.get(Transform);
            var hobject = h.get(Object);

            if(proj.source != h) {
                var collides = math.Utils.lineCircleIntersection(start, end, htransform.position, hobject.radius);

                if(collides) {
                    h.get(Hittable).life -= 5;
                    engine.removeEntity(e);
                    return;
                }
            }
        }

        for(s in context.level.sectors) {
            for(w in s.walls) {
                if(w.texture != null || transform.y < s.bottom) {
                    var a = w.a;
                    var b = w.b;

                    if(w.texture == null) {
                        a = w.b;
                        b = w.a;
                    }

                    var r = math.Utils.segmentToSegmentIntersection(start, end, a, b);

                    if(r != null) {
                        if(r[0] < 1) {
                            var impact = proj.weapon?.effects?.impact;
                            var new_transform = new math.Transform();
                            new_transform.position.copyFrom(start);
                            new_transform.y = transform.y;

                            if(impact != null) {
                                Factory.createEffect(engine, new_transform, impact);
                            }

                            engine.removeEntity(e);
                            return;
                        }
                    }
                }
            }
        }
    }

    private function hit(target:ecs.Entity) {
        var hittable = target.get(Hittable);
        hittable.life -= 100;
    }
}
