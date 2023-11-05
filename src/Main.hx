package;

import math.Point;

class Main {
    static public var context = new Context();
    static public var consoleSystem = new core.ConsoleSystem();
    static public var canvas:js.html.CanvasElement;

    static function main() {
        canvas = cast js.Browser.document.getElementById("canvas");
        var engine = context.engine;
        var cameraTransform = context.cameraTransform;
        {
            cameraTransform.position = [1024, 1024];
            cameraTransform.angle = 0;
            Context.dataRoot = "../data/";
            context.renderer.initialize(cameraTransform);
            context.textureManager.initialize();
            context.level.old();
            context.renderer.registerFont("main", "font", 20, 20);
            context.renderer.registerFont("mini", "font2", 4, 6);
        }
        {
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
            var hudSystem = engine.addSystem(new core.HudSystem(), 9);
            engine.addSystem(new core.SpriteAnimationSystem(), 97);
            engine.addSystem(new core.PhysicSystem(), 97);
            engine.addSystem(new core.ObjectSystem(), 98);
            engine.addSystem(new core.QuadSystem(), 99);
            engine.addSystem(new core.MonsterSystem(), 101);
            engine.addSystem(new core.MenuSystem(), 666);
            engine.addSystem(new core.editor.EditorSystem(), 666);
            engine.addSystem(consoleSystem, 667);
            gotoIngame();
            function init() {
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
        var lastTime = 0.0;
        function loop(t:Float) {
            var deltaTime = (t - lastTime) / 1000;
            var mouse = context.mouse;
            var keyboard = context.keyboard;
            context.level.update();
            context.renderer.clear();
            mouse.position.x = ((mouse.internalPosition.x - canvas.offsetLeft) / canvas.clientWidth) * display.Renderer.screenWidth;
            mouse.position.y = ((mouse.internalPosition.y - canvas.offsetTop) / canvas.clientHeight) * display.Renderer.screenHeight;
            engine.update(deltaTime);
            context.renderer.draw(context.level);
            context.renderer.flush();
            lastTime = t;

            if(keyboard.isJustPressed('Escape')) {
                if(context.engine.isActive(core.ConsoleSystem)) {
                    gotoIngame();
                } else if(context.engine.isActive(core.MenuSystem)) {
                    gotoIngame();
                } else {
                    gotoMenu();
                }
            }

            if(keyboard.isJustPressed('`')) {
                if(context.engine.isActive(core.ConsoleSystem)) {
                    gotoIngame();
                } else {
                    gotoConsole();
                }
            }

            if(keyboard.isJustPressed('e')) {
                if(context.engine.isActive(core.editor.EditorSystem)) {
                    gotoIngame();
                } else {
                    gotoEditor();
                }
            }

            if(keyboard.isJustPressed('r')) {
                context.level.restart();
            }

            keyboard.previousKeys = js.lib.Object.assign({}, keyboard.keys);
            mouse.previousButtons = mouse.buttons.slice(0);
            mouse.wheelDelta = 0;
            mouse.moveX = 0;
            js.Browser.window.requestAnimationFrame(loop);
        }
        loop(0);
    }

    static inline public function log(what) {
        consoleSystem.push(what);
        js.Browser.console.log(what);
    }

    static public function gotoMenu() {
        canvas.onclick = function() {};
        context.engine.suspendSystem(core.TransformControlSystem);
        context.engine.resumeSystem(core.MenuSystem);
    }

    static public function gotoIngame() {
        canvas.onclick = e->canvas.requestPointerLock();
        context.engine.suspendSystem(core.editor.EditorSystem);
        context.engine.suspendSystem(core.MenuSystem);
        context.engine.suspendSystem(core.ConsoleSystem);
        context.engine.resumeSystem(core.TransformControlSystem);
        context.engine.resumeSystem(core.MonsterSystem);
        context.engine.resumeSystem(core.MoveSystem);
        context.engine.resumeSystem(core.HudSystem);
    }

    static public function gotoConsole() {
        context.engine.suspendSystem(core.TransformControlSystem);
        context.engine.resumeSystem(core.ConsoleSystem);
    }

    static public function gotoEditor() {
        js.Browser.document.exitPointerLock();
        canvas.onclick = function() {};
        context.engine.suspendSystem(core.TransformControlSystem);
        context.engine.suspendSystem(core.MonsterSystem);
        context.engine.suspendSystem(core.HudSystem);
        context.engine.resumeSystem(core.editor.EditorSystem);
    }
}
