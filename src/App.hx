package;

class App {
    private var context = new Context();
    static public var consoleSystem = new core.ConsoleSystem();
    private var canvas:js.html.CanvasElement;
    private var hasFocus = true;

    public function new() {
        context.app = this;
    }

    function onFocus(value) {
        hasFocus = value;
    }

    public function initialize() {
        canvas = cast js.Browser.document.getElementById("canvas");
        var engine = context.engine;
        var cameraTransform = context.cameraTransform;
        {
            cameraTransform.position = [1024, 1024];
            cameraTransform.angle = 0;
            Context.dataRoot = Macro.getDataRootPath();
            context.renderer.initialize(cameraTransform);
            context.textureManager.initialize();
            context.audioManager.initialize();
            context.renderer.registerFont("main", "font", 20, 20);
            context.renderer.registerFont("mini", "font2", 4, 6);
            js.Browser.document.addEventListener("focus", function(e) {
                onFocus(true);
            }, false);
            js.Browser.document.addEventListener("blur", function(e) {
                onFocus(false);
            }, false);
            js.Browser.window.addEventListener("focus", function(e) {
                onFocus(true);
            }, false);
            js.Browser.window.addEventListener("blur", function(e) {
                onFocus(false);
            }, false);
        }
        {
            setupEngine(engine);
            gotoIngame();
            function init() {
                context.level.load(Factory.levels["first"]);
                context.level.restart();
            }
            Factory.initialize(init);
        }
        function setupControls() {
            var mouse = context.mouse;
            var keyboard = context.keyboard;
            canvas.onmousedown = function(e) {
                mouse.buttons[e.button] = true;
            }
            canvas.onmouseup = function(e) {
                mouse.buttons[e.button] = false;
            }
            canvas.onmousemove = function(e) {
                mouse.moveX += e.movementX;
                mouse.internalPosition.x = e.x;
                mouse.internalPosition.y = e.y;
            }
            untyped onkeydown = onkeyup = function(e) {
                keyboard.keys[e.key] = e.type[3] == 'd';
            }
            canvas.onwheel = function(e) {
                mouse.wheelDelta = e.deltaY;
            }
            canvas.oncontextmenu = e->false;
        }
        setupControls();
    }

    public function run() {
        var engine = context.engine;
        var lastTime = 0.0;
        function loop(t:Float) {
            var deltaTime = (t - lastTime) / 1000;
            var mouse = context.mouse;
            var keyboard = context.keyboard;
            context.level.update();
            mouse.position.x = ((mouse.internalPosition.x - canvas.offsetLeft) / canvas.clientWidth) * display.Renderer.screenWidth;
            mouse.position.y = ((mouse.internalPosition.y - canvas.offsetTop) / canvas.clientHeight) * display.Renderer.screenHeight;
            engine.update(deltaTime);

            if(hasFocus) {
                context.renderer.clear();
                context.renderer.draw(context.level);
                context.renderer.render();
            }

            context.renderer.flush();
            lastTime = t;
            keyboard.previousKeys = js.lib.Object.assign({}, keyboard.keys);
            mouse.previousButtons = mouse.buttons.slice(0);
            mouse.wheelDelta = 0;
            mouse.moveX = 0;
            js.Browser.window.requestAnimationFrame(loop);
        }
        loop(0);
    }

    public function gotoMenu() {
        canvas.onclick = function() {};
        context.engine.suspendSystem(core.InGameSystem);
        context.engine.suspendSystem(core.TransformControlSystem);
        context.engine.suspendSystem(core.PlayerControlSystem);
        context.engine.resumeSystem(core.MenuSystem);
    }

    public function gotoIngame() {
        canvas.onclick = e->canvas.requestPointerLock();
        context.engine.suspendSystem(core.editor.EditorSystem);
        context.engine.suspendSystem(core.MenuSystem);
        context.engine.suspendSystem(core.ConsoleSystem);
        context.engine.resumeSystem(core.TransformControlSystem);
        context.engine.resumeSystem(core.MonsterSystem);
        context.engine.resumeSystem(core.MoveSystem);
        context.engine.resumeSystem(core.HudSystem);
        context.engine.resumeSystem(core.InGameSystem);
        context.engine.resumeSystem(core.PlayerControlSystem);
    }

    public function gotoConsole() {
        context.engine.suspendSystem(core.TransformControlSystem);
        context.engine.suspendSystem(core.InGameSystem);
        context.engine.resumeSystem(core.ConsoleSystem);
    }

    public function gotoEditor() {
        js.Browser.document.exitPointerLock();
        canvas.onclick = function() {};
        context.engine.suspendSystem(core.InGameSystem);
        context.engine.suspendSystem(core.TransformControlSystem);
        context.engine.suspendSystem(core.PlayerControlSystem);
        context.engine.suspendSystem(core.MonsterSystem);
        context.engine.suspendSystem(core.HudSystem);
        context.engine.resumeSystem(core.editor.EditorSystem);
    }

    public function setupEngine(engine:ecs.Engine) {
        engine.addSystem(new core.ControlSystem(), 1);
        engine.addSystem(new core.TransformControlSystem(), 1);
        engine.addSystem(new core.PlayerControlSystem(), 1);
        engine.addSystem(new core.MoveSystem(), 2);
        engine.addSystem(new core.CameraSystem(), 3);
        engine.addSystem(new core.CharacterSystem(), 6);
        engine.addSystem(new core.BulletSystem(), 7);
        engine.addSystem(new core.DeathSystem(), 8);
        engine.addSystem(new core.DoorSystem(), 9);
        engine.addSystem(new core.DoorChangeSystem(), 10);
        engine.addSystem(new core.HudSystem(), 9);
        engine.addSystem(new core.SpriteAnimationSystem(), 97);
        engine.addSystem(new core.PhysicSystem(), 97);
        engine.addSystem(new core.ObjectSystem(), 98);
        engine.addSystem(new core.QuadSystem(), 99);
        engine.addSystem(new core.MonsterSystem(), 101);
        engine.addSystem(new core.AudioSourceSystem(), 200);
        engine.addSystem(new core.MenuSystem(), 666);
        engine.addSystem(new core.InGameSystem(), 666);
        engine.addSystem(new core.editor.EditorSystem(), 666);
        engine.addSystem(consoleSystem, 667);
    }

    static inline public function log(what) {
        consoleSystem.push(what);
        js.Browser.console.log(what);
    }
}
