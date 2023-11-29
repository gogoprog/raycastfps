package core;

import math.Transform;

class AudioSourceSystem extends ecs.System {

    public function new() {
        super();
        addComponentClass(AudioSource);
        addComponentClass(Transform);
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
    }
}
