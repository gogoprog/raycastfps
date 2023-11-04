package core;

import math.Point;
import math.Transform;

class MoveSystem extends ecs.System {

    public function new() {
        super();
        addComponentClass(Move);
        addComponentClass(Object);
        addComponentClass(Transform);
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var transform = e.get(math.Transform);
        var move = e.get(core.Move);
        var object = e.get(core.Object);
        var test_position:Point = transform.position + move.translation;
        object.lastTranslation.copyFrom(move.translation);

        if(untyped !window.noclip) {
            var collides = true;

            while(collides) {
                collides = false;

                for(s in context.level.sectors) {
                    for(w in s.walls) {
                        if(w.texture == null) { continue; }

                        var r = math.Utils.getSegmentPointDistance(w.a, w.b, test_position);

                        if(r < object.radius) {
                            var delta = (w.b - w.a);
                            var normal:Point = [-delta.y, delta.x];
                            normal.normalize();

                            if(Point.dot(move.translation, normal) > 0) {
                                normal *= -1;
                            }

                            while(math.Utils.getSegmentPointDistance(w.a, w.b, test_position) < object.radius) {
                                test_position += normal;
                            }

                            collides = true;
                            break;
                        }
                    }

                    if(collides) {
                        break;
                    }
                }
            }

            if(!collides) {
                var current_height = 0.0;

                for(s in context.level.sectors) {
                    if(s.contains(transform.position)) {
                        current_height = s.bottom;

                        for(w in s.walls) {
                            if(w.texture == null) { continue; }

                            var r = math.Utils.segmentToSegmentIntersection(transform.position, test_position, w.a, w.b);

                            if(r != null && r[0] < 1)  {
                                collides = true;
                                break;
                            }
                        }

                        break;
                    }
                }

                if(!collides) {
                    for(s in context.level.sectors) {
                        if(s.contains(test_position)) {
                            var new_height = s.bottom;

                            if(new_height - current_height < 20) {
                                transform.position.copyFrom(test_position);
                                object.currentSector = s;
                            }

                            break;
                        }
                    }
                }
            }
        }

        if(object.currentSector != null) {
            var floor_height = object.currentSector.bottom + 32;

            if(floor_height < transform.y) {
                object.velocityY -= 1000 * dt;
                transform.y += object.velocityY * dt;

                if(floor_height > transform.y) {
                    transform.y = floor_height;
                    object.velocityY = 0;
                }
            }

            if(floor_height > transform.y) {
                transform.y = floor_height;
                object.velocityY = 0;
            }
        } else {
            for(s in context.level.sectors) {
                if(s.contains(test_position)) {
                    object.currentSector = s;
                    transform.y = object.currentSector.bottom + 32;
                }
            }
        }
    }
}
