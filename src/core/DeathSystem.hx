package core;

import math.Point;
import math.Transform;

class DeathSystem extends ecs.System {

    public function new() {
        super();
        addComponentClass(Hittable);
        addComponentClass(Character);
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var character = e.get(core.Character);
        var hittable = e.get(core.Hittable);

        if(hittable.life <= 0) {
            var anims = character.animations;
            var effects = character.effects;
            var animator = e.get(core.SpriteAnimator);
            animator.clear();

            if(anims.death != null) {
                animator.push(anims.death);
            } else {
                e.remove(core.Sprite);
            }

            if(effects != null) {
                if(effects.death != null) {
                    Factory.createEffect(engine, e.get(Transform).position, effects.death);
                }
            }

            e.remove(Hittable);

            e.remove(Move);
        }
    }
}
