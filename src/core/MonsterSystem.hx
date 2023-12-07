package core;

import math.Point;
import math.Transform;

class MonsterSystem extends ecs.System {

    public function new() {
        super();
        addComponentClass(Character);
        addComponentClass(Monster);
        addComponentClass(Transform);
        addComponentClass(Hittable);
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var move = e.get(core.Move);
        var transform = e.get(Transform);

        if(e.get(Hittable).life > 0) {
            var monster = e.get(core.Monster);
            monster.timeLeft -= dt;
            monster.timeSinceLastAttack += dt;

            if(monster.timeLeft < 0) {
                if(move == null) {
                    move = new core.Move();

                    e.add(move);
                }

                var angle = Math.random() * Math.PI * 2;
                move.translation.setFromAngle(angle);
                e.get(Transform).angle = angle;
                monster.timeLeft = 1 + Std.random(3);
            }

            var canSeePlayer = true;

            if(canSeePlayer) {
                if(monster.weapon != null) {
                    if(monster.timeSinceLastAttack > monster.attackInterval) {

                        var player_transform = context.playerEntity.get(Transform);
                        var delta = player_transform.position - transform.position;
                        transform.angle = Math.atan2(delta.y, delta.x);

                        var a = monster.def.attackIntervalMin;
                        var b = monster.def.attackIntervalMax;
                        monster.attackInterval = a + (b - a) * Math.random();
                        e.get(Character).requestFire = true;
                        monster.timeSinceLastAttack = 0;
                    }
                }
            }
        } else {
            if(move != null) {
                move.translation = move.translation * 0.1;

                e.remove(core.Move);
            }
        }
    }
}
