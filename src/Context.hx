package;

class Context {
    static public var dataRoot:String;
    public var app:App;
    public var renderer:display.Renderer;
    public var cameraTransform:math.Transform;
    public var textureManager:display.TextureManager;
    public var audioManager:sound.AudioManager;
    public var level:world.Level;
    public var engine:ecs.Engine;
    public var mouse:input.Mouse;
    public var keyboard:input.Keyboard;
    public var playerEntity:ecs.Entity;

    public function new() {
        renderer = new display.Renderer(this);
        cameraTransform = new math.Transform();
        textureManager = new display.TextureManager(this);
        audioManager = new sound.AudioManager();
        level = new world.Level(this);
        engine = new ecs.Engine(this);
        mouse = new input.Mouse();
        keyboard = new input.Keyboard();
    }
}
