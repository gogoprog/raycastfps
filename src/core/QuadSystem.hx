package core;

import math.Point;
import math.Transform;

class QuadSystem extends ecs.System {
    var renderer:display.Renderer;
    var textureManager:display.TextureManager;

    public function new() {
        super();
        addComponentClass(Transform);
        addComponentClass(Quad);
        addComponentClass(Sprite);
    }

    override public function onResume() {
        renderer = context.renderer;
        textureManager = context.textureManager;
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var sprite = e.get(core.Sprite);
        var quad = e.get(core.Quad);
        var transform = e.get(math.Transform);

        if(sprite.textures != null) {
            var texture = sprite.textures[0];
            renderer.pushQuad(textureManager.get(texture.name), transform.position, quad.extent);
        }
    }
}
