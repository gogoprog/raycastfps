package core;

import math.Transform;

class PlayerSystem extends ecs.System {

    public function new() {
        super();
        addComponentClass(Transform);
        addComponentClass(Player);
        addComponentClass(Hittable);
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var player = e.get(Player);
        var hittable = e.get(Hittable);
        player.time += dt;
        player.timeSinceLastEffect += dt;

        if(player.timeSinceLastEffect > 0.2) {
            var effect = context.level.data.effect;

            if(effect != null) {
                Factory.createEffect(engine, e.get(Transform), effect);
            }

            player.timeSinceLastEffect = 0;
        }

        if(hittable.life < 0) {
            player.cameraOffsetY = Math.max(player.cameraOffsetY - dt * 20, 2);
        }
    }
}
