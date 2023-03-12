package core;

class DoorSystem extends ecs.System {

    public function new() {
        super();
        addComponentClass(math.Transform);
        addComponentClass(core.Door);
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
    }
}
