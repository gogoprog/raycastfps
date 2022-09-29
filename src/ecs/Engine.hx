package ecs;

class Engine {
    private var systems:Array<System> = [];
    private var entities:Array<Entity> = [];

    public function new() {
    }

    public function addSystem<T:System>(system:T, priority:Int, klass:Class<T> = null):T {
        systems.push(system);
        system.engine = this;
        return system;
    }

    public function update(dt:Float) {
        var systems_copy = systems.slice(0);
        var entities_copy = entities.slice(0);

        for(system in systems_copy) {
            system.entities = [];

            for(entity in entities_copy) {
                var matches = true;

                for(klass in system.classes) {
                    if(entity.components.get(klass) == null) {
                        matches = false;
                        break;
                    }
                }

                if(matches) {
                    system.entities.push(entity);
                }
            }

            system.update(dt);
        }
    }

    public function addEntity(entity:Entity) {
        entities.push(entity);
    }

    public function removeEntity(entity:Entity) {
        entities.remove(entity);
    }
}
