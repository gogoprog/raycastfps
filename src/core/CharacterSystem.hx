package core;

import math.Transform;
import math.Point;

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
            var interval = 1.0 / character.weapon.rate;

            if(character.timeSinceLastFire >= interval) {
                var weapon = character.weapon;
                character.timeSinceLastFire = 0;
                character.didFire = true;
                character.requestFire = false;

                if(weapon.sounds != null) {
                    if(weapon.sounds.fire != null) {
                        e.get(core.AudioSource).force(weapon.sounds.fire);
                    }
                }

                if(weapon.type == "bullet") {
                    var gap = weapon.fireGap;
                    var offset = (weapon.fireCount - 1) * gap * 0.5;

                    for(i in 0...weapon.fireCount) {
                        spawnBullet(e, weapon, transform, -offset + gap * i);
                    }
                } else if(weapon.type == "projectile") {
                    var gap = weapon.fireGap;
                    var offset = (weapon.fireCount - 1) * gap * 0.5;

                    for(i in 0...weapon.fireCount) {
                        spawnProjectile(e, weapon, transform, -offset + gap * i);
                    }
                } else {
                    throw "Unsupported";
                }
            }
        }

        if(character.requestOpen) {
            var doors = engine.getMatchingEntities(core.Door);

            for(e in doors) {
                var door_pos = e.get(math.Transform).position;
                var distance = math.Point.getSquareDistance(door_pos, transform.position);

                if(distance < 200 * 200) {
                    if(e.get(core.DoorChange) == null) {
                        var door_change = new core.DoorChange();
                        var door = e.get(core.Door);
                        door_change.opening = !door.open;

                        e.add(door_change);
                    }
                }
            }
        }

        character.timeSinceLastFire += dt;
        character.time += dt;
        var seconds = Std.int(character.time);

        if(seconds != character.lastSeconds) {
            character.lastSeconds = seconds;
            var r = Math.random();
            var sounds = character.sounds;

            if(sounds != null) {
                if(sounds.gruntrate != null) {
                    if(r < sounds.gruntrate) {
                        if(e.get(AudioSource).soundName == null) {
                            var r = Std.random(sounds.grunts.length);
                            e.get(AudioSource).soundName = sounds.grunts[r];
                        }
                    }
                }
            }
        }
    }

    private function spawnBullet(source, weapon, transform, angle_offset) {
        var b = new ecs.Entity();

        b.add(new core.Bullet());

        b.get(core.Bullet).weapon = weapon;
        b.get(core.Bullet).source = source;

        b.add(new math.Transform());

        b.get(Transform).copyFrom(transform);
        b.get(Transform).y += 28;
        b.get(Transform).angle += angle_offset;
        engine.addEntity(b);
    }

    private function spawnProjectile(source, weapon, transform, angle_offset) {
        var e = Factory.createProjectile(weapon);
        e.get(core.Projectile).source = source;
        e.get(Transform).copyFrom(transform);
        e.get(Transform).y += 32;
        e.get(Transform).angle += angle_offset;
        e.get(Transform).scale = weapon.projectile.scale;
        engine.addEntity(e);
    }
}
