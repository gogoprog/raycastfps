package core;

import math.Point;
import math.Transform;

class MoveSystem extends ecs.System {

    public function new() {
        super();
        addComponentClass(Move);
        addComponentClass(Transform);
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var transform = e.get(math.Transform);
        var move = e.get(core.Move);

        if(untyped !window.noclip) {
            var collides = false;

            for(w in Main.context.level.walls) {
                var r = display.Renderer.segmentToSegmentIntersection(transform.position, transform.position + move.translation, w.a, w.b);

                if(r != null && r[0] < 1) {
                    collides = true;
                    break;
                }
            }

            if(!collides) {
                transform.position += move.translation;
            }
        }
    }
}
