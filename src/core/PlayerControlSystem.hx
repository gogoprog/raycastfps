package core;

import math.Point;
import math.Transform;

class PlayerControlSystem extends ecs.System {

    public function new() {
        super();
        addComponentClass(Control);
        addComponentClass(Player);
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var control = e.get(core.Control);
        var player = e.get(Player);

        if(control.mouseButtons[0]) {
            player.requestFire = true;
        } else {
            player.requestFire = false;
        }
    }
}
