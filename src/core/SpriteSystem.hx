package core;

import math.Point;
import math.Transform;

class SpriteSystem extends ecs.System {
    var renderer:display.Renderer;
    var textureManager:display.TextureManager;
    var cameraTransform:Transform;

    public function new() {
        super();
        addComponentClass(Transform);
        addComponentClass(Object);
        addComponentClass(Sprite);
    }

    override public function onResume() {
        renderer = context.renderer;
        textureManager = context.textureManager;
        cameraTransform = context.cameraTransform;
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var sprite = e.get(core.Sprite);
        var object = e.get(core.Object);
        var transform = e.get(math.Transform);
        var position = transform.position;

        if(sprite.textures != null && object.currentSector != null) {
            var cam_ang = cameraTransform.angle;
            var angle = transform.angle;
            var delta_angle = math.Utils.fixAngle(angle - cam_ang + renderer.halfHorizontalFov);
            delta_angle += Math.PI;
            var frameIndex = Std.int((delta_angle / (Math.PI * 2)) * sprite.textures.length);
            var texture = sprite.textures[frameIndex];
            var sector = object.currentSector;
            var textureBuffer = textureManager.get(texture.name);

            if(textureBuffer != null) {
                var offset = (texture.offset != null ? texture.offset : 0);

                if(object.isStatic) {
                    offset = -Std.int(textureBuffer.height * transform.scale / 2);
                }

                var floor = object.currentSector.bottom;
                renderer.pushSprite(textureBuffer, transform.position, Std.int(transform.y) + offset, texture.flip, transform.scale, floor);
            }
        }
    }
}
