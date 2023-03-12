package core;

class DoorChangeSystem extends ecs.System {

    public function new() {
        super();
        addComponentClass(math.Transform);
        addComponentClass(core.Door);
        addComponentClass(core.DoorChange);
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var wall = e.get(core.Door).wall;
        wall.offset += dt * 10;
    }
}
