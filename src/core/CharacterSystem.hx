package core;

import math.Transform;

class CharacterSystem extends ecs.System {

    public function new() {
        super();
        addComponentClass(Character);
        addComponentClass(Transform);
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var character = e.get(core.Character);
        var transform = e.get(Transform);
        character.didFire = false;

        if(character.requestFire) {
            var interval = 1.0 / character.fireRate;

            if(character.timeSinceLastFire >= interval) {
                character.timeSinceLastFire = 0;
                character.didFire = true;
                character.requestFire = false;
                {
                    spawnBullet(transform, 0);
                    spawnBullet(transform, 0.01);
                    spawnBullet(transform, -0.01);
                }
            }
        }

        character.timeSinceLastFire += dt;
    }

    private function spawnBullet(transform, angle_offset) {
        var b = new ecs.Entity();
        b.add(new core.Bullet());
        b.add(new math.Transform());
        b.get(Transform).copyFrom(transform);
        b.get(Transform).angle += angle_offset;
        engine.addEntity(b);
    }
}
