package core;

import math.Point;
import math.Transform;

class ControlSystem extends ecs.System {
    var cameraTransform:Transform;

    public function new() {
        super();
        addComponentClass(Control);
        addComponentClass(Transform);
        cameraTransform = Main.context.cameraTransform;
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var keys = Main.keys;
        var mx = Main.mx;
        Main.mx = 0;
        var transform = e.get(math.Transform);
        var move = e.get(core.Move);

        if(move == null) {
            move = new core.Move();
            e.add(move);
        }

        var translation = move.translation;
        translation.set(0, 0);
        var a = transform.angle;
        var forward:Point = [Math.cos(a), Math.sin(a)];
        var lateral:Point = [Math.cos(a + Math.PI/2), Math.sin(a + Math.PI/2)];
        var requested_direction:Point = [0, 0];

        if(untyped keys['w']) {
            requested_direction.y = 1;
        }

        if(untyped keys['s']) {
            requested_direction.y = -1;
        }

        if(untyped keys['d']) {
            requested_direction.x = 1;
        }

        if(untyped keys['a']) {
            requested_direction.x = -1;
        }

        if(requested_direction.getSquareLength() > 0) {
            requested_direction.normalize();
        }

        var s = 400 * dt;
        translation.x += forward.x * requested_direction.y * s;
        translation.y += forward.y * requested_direction.y * s;
        translation.x += lateral.x * requested_direction.x * s;
        translation.y += lateral.y * requested_direction.x * s;
        transform.angle += mx * 0.01;
    }
}
