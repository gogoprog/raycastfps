package core;

import math.Point;
import math.Transform;

class PlayerControlSystem extends ecs.System {

    public function new() {
        super();
        addComponentClass(Control);
        addComponentClass(Character);
        addComponentClass(Player);
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var control = e.get(core.Control);
        var character = e.get(Character);

        if(control.mouseButtons[0]) {
            character.requestFire = true;
        } else {
            character.requestFire = false;
        }
    }
}
