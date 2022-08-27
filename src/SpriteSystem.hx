package;

class SpriteNode extends ash.core.Node<SpriteNode> {
    public var transform:Transform;
    public var sprite:SpriteDef;
}

class SpriteSystem extends ash.tools.ListIteratingSystem<SpriteNode> {
    var renderer:Renderer;
    var textureManager:TextureManager;

    public function new() {
        renderer = Main.context.renderer;
        textureManager = Main.context.textureManager;
        super(SpriteNode, updateNode, onNodeAdded, onNodeRemoved);
    }

    private function updateNode(node:SpriteNode, dt:Float):Void {
        renderer.pushSprite(textureManager.get(node.sprite.textures[0]), node.transform.position);
    }

    private function onNodeAdded(node:SpriteNode) {
    }

    private function onNodeRemoved(node:SpriteNode) {
    }

}
