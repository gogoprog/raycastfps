package core;

import math.Point;

class HudSystem extends ecs.System {

    var weaponPosition:Point;
    var weaponOffset:Point;
    var weaponExtent:Point;
    var time:Float = 0;

    var velocity = new Point();

    var weaponEntity:ecs.Entity;

    public function new() {
        super();
        addComponentClass(Player);
        addComponentClass(Object);
        weaponPosition = [display.Renderer.screenWidth / 2 - 320, display.Renderer.screenHeight - 375];
        weaponExtent = [640, 400];
        weaponOffset = [0, 0];
        var e = Factory.createHudWeapon();
        setWeaponEntity(e);
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var object = e.get(core.Object);
        var factor:Float = 0;
        var translation = object.lastTranslation;
        var len = translation.getLength();
        factor = len / (30 * dt);

        if(context.playerEntity != null) {
            var character = context.playerEntity.get(Character);

            if(character != null) {
                if(len != 0) {
                    time += dt * factor;
                    weaponOffset.x = Math.sin(time) * 30;
                    weaponOffset.y = Math.cos(time * 2) * 10;
                } else {
                    var r = math.Utils.smoothDamp(weaponOffset.x, 0.0, velocity.x, 0.5, dt);
                    weaponOffset.x = r.value;
                    velocity.x = r.velocity;
                    var r = math.Utils.smoothDamp(weaponOffset.y, 0.0, velocity.y, 0.5, dt);
                    weaponOffset.y = r.value;
                    velocity.y = r.velocity;
                    time = 0;
                }

                weaponEntity.get(math.Transform).position.copyFrom(weaponPosition+weaponOffset);
                var animator = weaponEntity.get(SpriteAnimator);

                if(character != null) {
                    if(character.didFire) {
                        animator.replace1(character.weapon.animations.fire);
                    }

                    if(animator.getAnimationsCount() == 0) {
                        animator.push(character.weapon.animations.idle);
                    }
                }
            } else {
                engine.removeEntity(weaponEntity);
            }
        }

        drawInfos(dt);
    }

    override public function onResume() {
        engine.addEntity(weaponEntity);
        weaponEntity.get(core.SpriteAnimator).clear();
    }

    override public function onSuspend() {
        engine.removeEntity(weaponEntity);
    }

    public function setWeaponEntity(e:ecs.Entity) {
        weaponEntity = e;
    }

    private function drawInfos(dt:Float) {
        var monsters = engine.getMatchingEntities(core.Monster);
        var player = context.playerEntity;
        var hittable = player.get(Hittable);
        var renderer = context.renderer;
        var offset_x = Std.int(display.Renderer.screenWidth * 0.05);
        var offset_y = Std.int(display.Renderer.screenHeight * 0.92);
        renderer.pushText("main", [offset_x, offset_y], "HP: " + hittable.life, false);
        var offset_x = Std.int(display.Renderer.screenWidth * 0.7);
        renderer.pushText("main", [offset_x, offset_y], "L: " + monsters.length, false);
        {
            var player_player = player.get(Player);
            var hf = player_player.hitFeedbackTimeLeft;

            if(hf > 0.0) {
                hf -= dt;
                hf = Math.max(0, hf);
                player_player.hitFeedbackTimeLeft = hf;
                var alpha = Std.int((hf/0.5) * 200);
                var color = (alpha << 24) | 0xdd;
                var width = display.Renderer.screenWidth;
                var height = display.Renderer.screenHeight;
                renderer.pushRect([width/2, height/2], [width, height], color);
            }
        }
    }
}
