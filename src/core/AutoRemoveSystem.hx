package core;

class AutoRemoveSystem extends ecs.System {

    public function new() {
        super();
        addComponentClass(AutoRemove);
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var auto = e.get(AutoRemove);
        auto.time += dt;

        if(auto.time > auto.duration) {
            engine.removeEntity(e);
        }
    }
}
