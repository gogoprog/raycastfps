package core;

import math.Point;
import math.Transform;

class ObjectSystem extends ecs.System {
    var renderer:display.Renderer;
    var textureManager:display.TextureManager;
    var cameraTransform:Transform;

    public function new() {
        super();
        addComponentClass(Transform);
        addComponentClass(Object);
        addComponentClass(Sprite);
        renderer = Main.context.renderer;
        textureManager = Main.context.textureManager;
        cameraTransform = Main.context.cameraTransform;
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var sprite = e.get(core.Sprite);
        var object = e.get(core.Object);
        var transform = e.get(math.Transform);
        var position = transform.position;

        if(sprite.textures != null) {
            var cam_ang = cameraTransform.angle;
            var angle = transform.angle;
            var delta_angle = math.Utils.fixAngle(angle - cam_ang + renderer.halfHorizontalFov);
            delta_angle += Math.PI;
            var frameIndex = Std.int((delta_angle / (Math.PI * 2)) * sprite.textures.length);
            var texture = sprite.textures[frameIndex];
            renderer.pushSprite(textureManager.get(texture.name), transform.position, Std.int(object.heightOffset) + (texture.offset != null ? texture.offset : 0), texture.flip, transform.scale);
        }
    }
}
