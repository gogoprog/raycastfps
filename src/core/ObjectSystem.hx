package core;

import math.Point;
import math.Transform;

class ObjectSystem extends ecs.System {

    public function new() {
        super();
        addComponentClass(Transform);
        addComponentClass(Object);
    }

    override public function onResume() {
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var object = e.get(core.Object);
        var transform = e.get(math.Transform);
        var position = transform.position;

        if(object.currentSector == null) {
            for(s in context.level.sectors) {
                if(s.contains(position)) {
                    object.currentSector = s;

                    if(!object.isStatic) {
                        transform.y = object.currentSector.bottom;
                    }
                }
            }
        }
    }
}
