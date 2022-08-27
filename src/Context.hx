package;

class Context {
    public var renderer = new display.Renderer();
    public var cameraTransform = new math.Transform();
    public var textureManager = new display.TextureManager();
    public var level = new world.Level();

    public function new() {
    }
}
