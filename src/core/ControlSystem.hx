package core;

class ControlSystem extends ecs.System {

    public function new() {
        super();
        addComponentClass(Control);
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var control = e.get(Control);
        control.keys = context.keyboard.keys;
        control.mouseMovement = context.mouse.moveX;

        for(i in 0...6) {
            control.previousMouseButtons[i] = control.mouseButtons[i];
            control.mouseButtons[i] = context.mouse.buttons[i];
        }
    }
}
