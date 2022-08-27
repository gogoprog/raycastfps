package core;

import math.Point;
import math.Transform;

class SpriteNode extends ash.core.Node<SpriteNode> {
    public var transform:Transform;
    public var sprite:SpriteDef;
}

class SpriteSystem extends ash.tools.ListIteratingSystem<SpriteNode> {
    var renderer:display.Renderer;
    var textureManager:display.TextureManager;
    var cameraTransform:Transform;

    public function new() {
        renderer = Main.context.renderer;
        textureManager = Main.context.textureManager;
        cameraTransform = Main.context.cameraTransform;
        super(SpriteNode, updateNode, onNodeAdded, onNodeRemoved);
    }

    private function updateNode(node:SpriteNode, dt:Float):Void {
        var sprite = node.sprite;
        var position = node.transform.position;

        var cam_ang = cameraTransform.angle;
        var angle = node.transform.angle;
        var delta_angle = math.Utils.fixAngle(angle - cam_ang + renderer.halfHorizontalFov);

        delta_angle += Math.PI;

        var frameIndex = Std.int((delta_angle / (Math.PI * 2)) * sprite.textures.length);
        var texture = sprite.textures[frameIndex];

        renderer.pushSprite(textureManager.get(texture.name), node.transform.position, node.sprite.heightOffset, texture.flip);
    }

    private function onNodeAdded(node:SpriteNode) {
    }

    private function onNodeRemoved(node:SpriteNode) {
    }

}
