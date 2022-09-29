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
        control.mouseButtons = Main.mouseButtons;
        Main.mx = 0;
    }
}
