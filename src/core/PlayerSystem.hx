package core;

import math.Transform;

class PlayerSystem extends ecs.System {

    public function new() {
        super();
        addComponentClass(Transform);
        addComponentClass(Player);
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var player = e.get(Player);
        player.time += dt;
        player.timeSinceLastEffect += dt;

        if(player.timeSinceLastEffect > 0.2) {
            var effect = context.level.data.effect;

            if(effect != null) {
                Factory.createEffect(engine, e.get(Transform).position, effect);
            }

            player.timeSinceLastEffect = 0;
        }
    }
}
