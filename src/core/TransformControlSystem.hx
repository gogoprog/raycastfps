package core;

import math.Point;
import math.Transform;

class TransformControlSystem extends ecs.System {
    var cameraTransform:Transform;

    public function new() {
        super();
        addComponentClass(Control);
        addComponentClass(Transform);
    }

    override public function onResume() {
        cameraTransform = context.cameraTransform;
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var transform = e.get(math.Transform);
        var move = e.get(core.Move);
        var control = e.get(core.Control);
        var keys = control.keys;

        if(move == null) {
            move = new core.Move();

            e.add(move);
        }

        var translation = move.translation;
        translation.set(0, 0);
        var a = transform.angle;
        var forward:Point = [Math.cos(a), Math.sin(a)];
        var lateral:Point = [Math.cos(a + Math.PI/2), Math.sin(a + Math.PI/2)];
        var direction = control.direction;

        if(untyped keys['w']) {
            direction.y = 1;
            control.speed = Math.min(control.speed + control.acceleration * dt, control.maxSpeed);
        } else if(untyped keys['s']) {
            direction.y = -1;
            control.speed = Math.min(control.speed + control.acceleration * dt, control.maxSpeed);
        } else {
            control.speed = Math.max(control.speed - control.deceleration * dt, 0);
        }

        if(untyped keys['d']) {
            direction.x = 1;
            control.lateralSpeed = Math.min(control.lateralSpeed + control.acceleration * dt, control.maxSpeed);
        } else if(untyped keys['a']) {
            direction.x = -1;
            control.lateralSpeed = Math.min(control.lateralSpeed + control.acceleration * dt, control.maxSpeed);
        } else {
            control.lateralSpeed = Math.max(control.lateralSpeed - control.deceleration * dt, 0);
        }

        var fs = control.speed * dt;
        var ls = control.lateralSpeed * dt;
        var move:Point = [forward.x * fs * direction.y + lateral.x * ls * direction.x, forward.y * fs * direction.y + lateral.y * ls * direction.x];

        if(move.getLength() > control.maxSpeed * dt) {
            move.normalize();
            move.mul(control.maxSpeed * dt);
        }

        translation.add(move);

        transform.angle += control.mouseMovement * 0.002;

        if(untyped keys['o']) {
            transform.y += 100 * dt;
        }

        if(untyped keys['l']) {
            transform.y -= 100 * dt;
        }
    }
}
