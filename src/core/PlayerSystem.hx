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
        var seconds = Std.int(player.time);

        if(seconds != player.lastSeconds) {
            player.lastSeconds = seconds;
            var effect = context.level.data.effect;

            if(effect != null) {
                trace(effect);
                Factory.createEffect(engine, e.get(Transform).position, effect);
            }
        }
    }
}
