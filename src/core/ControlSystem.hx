package core;

class ControlSystem extends ecs.System {

    public function new() {
        super();
        addComponentClass(Control);
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var control = e.get(Control);
        control.keys = Main.keys;
        control.mouseMovement = Main.mx;

        for(i in 0...6) {
            control.previousMouseButtons[i] = control.mouseButtons[i];
            control.mouseButtons[i] = Main.mouseButtons[i];
        }

        Main.mx = 0;
    }
}
