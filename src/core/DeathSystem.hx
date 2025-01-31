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
            var sounds = character.sounds;
            var animator = e.get(core.SpriteAnimator);

            if(animator != null) {
                animator.clear();

                if(anims.death != null) {
                    animator.push(anims.death);
                } else {

                    e.remove(core.Sprite);
                }
            }

            if(effects != null) {
                if(effects.death != null) {
                    Factory.createEffect(engine, e.get(Transform), effects.death);
                }
            }

            if(sounds != null) {
                if(sounds.death != null) {
                    e.get(core.AudioSource).force(sounds.death);
                }
            }

            e.remove(Move);

            e.remove(Character);

            if(e.get(core.Player) != null) {

                e.remove(core.Control);
            } else {

                e.remove(Hittable);

                e.add(new core.AutoRemove(1.0));
            }
        }
    }
}
