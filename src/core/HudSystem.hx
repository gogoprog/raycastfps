package core;

import math.Point;

class HudSystem extends ecs.System {

    var textureManager:display.TextureManager;
    var renderer:display.Renderer;
    var weaponPosition:Point;
    var weaponOffset:Point;
    var weaponExtent:Point;
    var weaponTexture:display.Framebuffer;
    var time:Float = 0;

    var velocity = new Point();

    public function new() {
        super();
        addComponentClass(Player);
        addComponentClass(Object);
        textureManager = Main.context.textureManager;
        renderer = Main.context.renderer;
        weaponPosition = [1024 / 2 - 320, 640 - 375];
        weaponExtent = [640, 400];
        weaponOffset = [0, 0];
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        weaponTexture = textureManager.get("shotgun/0");
        var object = e.get(core.Object);
        var factor:Float = 0;
        var translation = object.lastTranslation;
        var len = translation.getLength();
        factor = len / (30 * dt);

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

        renderer.pushQuad(weaponTexture, weaponPosition + weaponOffset, weaponExtent);
    }
}
