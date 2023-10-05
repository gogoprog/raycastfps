package core;

class DoorChangeSystem extends ecs.System {

    public function new() {
        super();
        addComponentClass(math.Transform);
        addComponentClass(core.Door);
        addComponentClass(core.DoorChange);
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var door = e.get(core.Door);
        var door_change = e.get(core.DoorChange);
        var sector = door.sector;
        door_change.time += dt;
        var ratio = door_change.time / door.duration;
        var a = door_change.opening ? sector.initialTop : sector.initialBottom;
        var b = !door_change.opening ? sector.initialTop : sector.initialBottom;
        sector.bottom = a + (b-a) * ratio;

        if(ratio >= 1.0) {
            ratio = 1.0;
            sector.bottom = b;
            door.open = !door.open;
            e.remove(core.DoorChange);
        }
    }
}
