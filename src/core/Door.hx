package core;

@:allow(core.DoorSystem)
@:allow(core.DoorChangeSystem)
class Door {
    var sector:world.Sector;
    var duration = 1.0;
    public var open = true;

    public function new(sector) {
        this.sector = sector;
    }
}
