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

        if(untyped !window.noclip) {
            var collides = true;

            while(collides) {
                collides = false;

                for(w in Main.context.level.walls) {
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
            }

            if(!collides) {
                transform.position.copyFrom(test_position);
            }
        }
    }
}
