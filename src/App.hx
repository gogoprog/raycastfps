package;

class App {
    private var context = new Context();
    static public var consoleSystem = new core.ConsoleSystem();
    private var canvas:js.html.CanvasElement;
    private var hasFocus = true;
    private var itIsMobile = false;
    private var touchStart:math.Point = [0, 0];
    private var touchActive = 0;
    private var keyboardActive = false;

    static public function isMobile() {
        return js.Syntax.code("(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent))");
    }

    public function new() {
        context.app = this;
        itIsMobile = isMobile();
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
            js.Browser.document.addEventListener("pointerlockchange", function(e) {
                if(js.Browser.document.pointerLockElement == null) {
                    if(engine.isActive(core.InGameSystem)) {
                        gotoMenu();
                    }
                }
            }, false);
        }
        {
            setupEngine(engine);
            gotoMenu();
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
            {
                js.Browser.window.ontouchstart = function(e) {
                    untyped keyboard.keys["Escape"] = true;
                }
                js.Browser.window.ontouchend = function(e) {
                    untyped keyboard.keys["Escape"] = false;
                }
                canvas.ontouchstart = function(e) {
                    var touch = e.changedTouches[0];

                    if(e.touches.length == 1) {
                        touchStart.x = touch.clientX;
                        touchStart.y = touch.clientY;
                        mouse.internalPosition.x = touch.clientX;
                        mouse.internalPosition.y = touch.clientY;
                    } else {
                        mouse.buttons[0] = true;
                    }

                    if(!engine.isActive(core.InGameSystem)) {
                        mouse.buttons[0] = true;
                    }

                    touchActive++;
                    e.stopPropagation();
                }
                canvas.ontouchmove = function(e) {
                    if(e.touches.length == 1) {
                        var touch = e.changedTouches[0];
                        mouse.internalPosition.x = touch.clientX;
                        mouse.internalPosition.y = touch.clientY;
                    }

                    e.stopPropagation();
                }
                canvas.ontouchend = function(e) {
                    if(e.touches.length == 1) {
                        mouse.buttons[0] = false;
                    }

                    if(!engine.isActive(core.InGameSystem)) {
                        mouse.buttons[0] = false;
                    }

                    touchActive--;
                    e.stopPropagation();
                }
            }
            untyped onkeydown = onkeyup = function(e) {
                keyboard.keys[e.key] = e.type[3] == 'd';
                keyboardActive = true;
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

            if(itIsMobile) {
                touchUpdate();
            }

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

    public function touchUpdate() {
        var mouse = context.mouse;
        var keyboard = context.keyboard;

        if(touchActive > 0) {
            var mindx = 16;
            var mindy = 16;
            var dx = mouse.internalPosition.x - touchStart.x;
            var dy = mouse.internalPosition.y - touchStart.y;
            var center_x = Std.int(display.Renderer.screenWidth * 0.75);

            if(Math.abs(dx) > mindx) {
                mouse.moveX = (dx - mindx) * 0.5;
            }

            if(mouse.position.x < center_x) {
                if(!keyboardActive) {
                    if(dy < -mindy) {
                        untyped keyboard.keys["ArrowUp"] = true;
                    } else {
                        untyped keyboard.keys["ArrowUp"] = false;
                    }

                    if(dy > mindy) {
                        untyped keyboard.keys["ArrowDown"] = true;
                    } else {
                        untyped keyboard.keys["ArrowDown"] = false;
                    }
                }
            } else {
                mouse.buttons[0] = true;
            }
        } else {
            if(!keyboardActive) {
                untyped keyboard.keys["ArrowUp"] = false;
                untyped keyboard.keys["ArrowDown"] = false;
            }

            mouse.buttons[0] = false;
        }
    }

    public function gotoMenu() {
        canvas.onclick = function() {};
        context.engine.suspendSystem(core.editor.EditorSystem);
        context.engine.suspendSystem(core.ConsoleSystem);
        context.engine.suspendSystem(core.InGameSystem);
        context.engine.suspendSystem(core.ControlSystem);
        context.engine.suspendSystem(core.TransformControlSystem);
        context.engine.suspendSystem(core.PlayerControlSystem);
        context.engine.suspendSystem(core.HudSystem);
        context.engine.suspendSystem(core.MonsterSystem);
        context.engine.resumeSystem(core.MenuSystem);
    }

    public function gotoIngame() {
        if(!itIsMobile) {
            canvas.onclick = e-> {
                if(js.Browser.document.pointerLockElement == null) {
                    canvas.requestPointerLock();
                }
            }
        }

        context.engine.suspendSystem(core.editor.EditorSystem);
        context.engine.suspendSystem(core.MenuSystem);
        context.engine.suspendSystem(core.ConsoleSystem);
        context.engine.resumeSystem(core.ControlSystem);
        context.engine.resumeSystem(core.TransformControlSystem);
        context.engine.resumeSystem(core.MonsterSystem);
        context.engine.resumeSystem(core.MoveSystem);
        context.engine.resumeSystem(core.HudSystem);
        context.engine.resumeSystem(core.InGameSystem);
        context.engine.resumeSystem(core.PlayerControlSystem);
    }

    public function gotoConsole() {
        context.engine.suspendSystem(core.InGameSystem);
        context.engine.suspendSystem(core.ControlSystem);
        context.engine.suspendSystem(core.TransformControlSystem);
        context.engine.suspendSystem(core.PlayerControlSystem);
        context.engine.resumeSystem(core.ConsoleSystem);
    }

    public function gotoEditor() {
        js.Browser.document.exitPointerLock();
        canvas.onclick = function() {};
        context.engine.suspendSystem(core.InGameSystem);
        context.engine.suspendSystem(core.ControlSystem);
        context.engine.suspendSystem(core.TransformControlSystem);
        context.engine.suspendSystem(core.PlayerControlSystem);
        context.engine.suspendSystem(core.MonsterSystem);
        context.engine.suspendSystem(core.HudSystem);
        context.engine.resumeSystem(core.editor.EditorSystem);
    }

    public function setupEngine(engine:ecs.Engine) {
        engine.addSystem(new core.ControlSystem(), 1);
        engine.addSystem(new core.TransformControlSystem(), 1);
        engine.addSystem(new core.PlayerSystem(), 1);
        engine.addSystem(new core.PlayerControlSystem(), 1);
        engine.addSystem(new core.MoveSystem(), 2);
        engine.addSystem(new core.CameraSystem(), 3);
        engine.addSystem(new core.CharacterSystem(), 6);
        engine.addSystem(new core.BulletSystem(), 7);
        engine.addSystem(new core.ProjectileSystem(), 7);
        engine.addSystem(new core.DeathSystem(), 8);
        engine.addSystem(new core.DoorSystem(), 9);
        engine.addSystem(new core.DoorChangeSystem(), 10);
        engine.addSystem(new core.HudSystem(), 9);
        engine.addSystem(new core.SpriteAnimationSystem(), 97);
        engine.addSystem(new core.PhysicSystem(), 97);
        engine.addSystem(new core.ObjectSystem(), 98);
        engine.addSystem(new core.QuadSystem(), 99);
        engine.addSystem(new core.SpriteSystem(), 100);
        engine.addSystem(new core.MonsterSystem(), 101);
        engine.addSystem(new core.AudioSourceSystem(), 200);
        engine.addSystem(new core.MenuSystem(), 666);
        engine.addSystem(new core.InGameSystem(), 666);
        engine.addSystem(new core.editor.EditorSystem(), 666);
        engine.addSystem(consoleSystem, 667);
        engine.addSystem(new core.LevelSystem(), 1024);
        engine.addSystem(new core.AutoRemoveSystem(), 2048);
    }

    static inline public function log(what) {
        consoleSystem.push(what);
        js.Browser.console.log(what);
    }
}
