package;

import math.Point;

class Main {
    static public var context = new Context();
    static public var keys:Dynamic = {};
    static public var mx:Int = 0;
    static public var mouseButtons:Array<Bool> = [];

    static function main() {
        var canvas:js.html.CanvasElement = cast js.Browser.document.getElementById("canvas");
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
            canvas.onclick = e->canvas.requestPointerLock();
            canvas.onmousedown = function(e) {
                mouseButtons[e.button] = true;
            }
            canvas.onmouseup = function(e) {
                mouseButtons[e.button] = false;
            }
            canvas.onmousemove = function(e) {
                mx += e.movementX;
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
            js.Browser.window.requestAnimationFrame(loop);
            {
                var font = Main.context.textureManager.get("font");

                if(font != null) {
                    context.renderer.drawText(font, [10, 10], "Hello World!");
                }
            }
        }
        loop(0);
    }
}
