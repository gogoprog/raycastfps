package;

import math.Point;

class Main {
    static public var context = new Context();
    static public var previousKeys:Dynamic = {};
    static public var keys:Dynamic = {};
    static public var mx:Int = 0;
    static public var mouseButtons:Array<Bool> = [];
    static public var mousePosition:math.Point = [];
    static public var consoleSystem = new core.ConsoleSystem();
    static public var canvas:js.html.CanvasElement;

    static function main() {
        canvas = cast js.Browser.document.getElementById("canvas");
        var engine = context.engine;
        var cameraTransform = context.cameraTransform;
        {
            cameraTransform.position = [1024, 1024];
            cameraTransform.angle = 0;
            context.dataRoot = "../data/";
            context.renderer.initialize(cameraTransform);
            context.textureManager.initialize();
            context.level.load();
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
            {
                for(i in 0...128) {
                    var e = Factory.createMonster([Math.random() * 2000, Math.random() * 2000]);
                    engine.addEntity(e);
                }

                {
                    var e = Factory.createPlayer();
                    engine.addEntity(e);
                    hudSystem.setPlayerEntity(e);
                }

                {
                    var e = Factory.createHudWeapon();
                    engine.addEntity(e);
                    hudSystem.setWeaponEntity(e);
                }
            }
        }
        function setupControls() {
            canvas.onmousedown = function(e) {
                mouseButtons[e.button] = true;
            }
            canvas.onmouseup = function(e) {
                mouseButtons[e.button] = false;
            }
            canvas.onmousemove = function(e) {
                mx += e.movementX;
                mousePosition.x = e.x;
                mousePosition.y = e.y;
            }
            untyped onkeydown = onkeyup = function(e) {
                keys[e.key] = e.type[3] == 'd';
            }
            canvas.oncontextmenu = e->false;
        }
        setupControls();
        var lastTime = 0.0;
        function loop(t:Float) {
            var deltaTime = (t - lastTime) / 1000;
            context.level.update();
            context.renderer.clear();
            engine.update(deltaTime);
            context.renderer.draw(context.level);
            context.renderer.flush();
            lastTime = t;

            if(isJustPressed('Escape')) {
                if(context.engine.isActive(core.ConsoleSystem)) {
                    gotoIngame();
                } else if(context.engine.isActive(core.MenuSystem)) {
                    gotoIngame();
                } else {
                    gotoMenu();
                }
            }

            if(isJustPressed('`')) {
                if(context.engine.isActive(core.ConsoleSystem)) {
                    gotoIngame();
                } else {
                    gotoConsole();
                }
            }

            if(isJustPressed('e')) {
                if(context.engine.isActive(core.editor.EditorSystem)) {
                    gotoIngame();
                } else {
                    gotoEditor();
                }
            }

            previousKeys = js.lib.Object.assign({}, keys);
            js.Browser.window.requestAnimationFrame(loop);
        }
        loop(0);
    }

    static inline public function isJustPressed(k:String) {
        return untyped !previousKeys[k] && untyped keys[k];
    }

    static public function log(what) {
        consoleSystem.push(what);
    }

    static public function gotoMenu() {
        canvas.onclick = function() {};
        context.engine.suspendSystem(core.ControlSystem);
        context.engine.resumeSystem(core.MenuSystem);
    }

    static public function gotoIngame() {
        canvas.onclick = e->canvas.requestPointerLock();
        context.engine.suspendSystem(core.editor.EditorSystem);
        context.engine.suspendSystem(core.MenuSystem);
        context.engine.suspendSystem(core.ConsoleSystem);
        context.engine.resumeSystem(core.ControlSystem);
    }

    static public function gotoConsole() {
        context.engine.suspendSystem(core.ControlSystem);
        context.engine.resumeSystem(core.ConsoleSystem);
    }

    static public function gotoEditor() {
        canvas.onclick = function() {};
        context.engine.suspendSystem(core.ControlSystem);
        context.engine.resumeSystem(core.editor.EditorSystem);
    }
}
