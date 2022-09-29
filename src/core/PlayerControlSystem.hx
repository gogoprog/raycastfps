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
        var player = e.get(Player);
        var mouseButtons = Main.mouseButtons;
        Main.mouseButtons = 0;

        if(mouseButtons != 0) {
            player.requestFire = true;
        }
    }
}
