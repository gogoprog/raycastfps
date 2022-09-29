package;

import math.Point;

class Main {
    static public var context = new Context();
    static public var keys:Dynamic = {};
    static public var mx:Int = 0;
    static public var mouseButtons:Array<Bool> = [];

    static function main() {
        var canvas:js.html.CanvasElement = cast js.Browser.document.getElementById("canvas");
        var engine = new ecs.Engine();
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
            engine.addSystem(new core.SpriteAnimationSystem(), 9);
            engine.addSystem(new core.ObjectSystem(), 10);
            var hudSystem = engine.addSystem(new core.HudSystem(), 11);
            engine.addSystem(new core.QuadSystem(), 12);
            {
                for(i in 0...128) {
                    var e = new ecs.Entity();
                    e.add(new core.Sprite());
                    e.add(new core.Object());
                    e.get(core.Object).heightOffset = 10;
                    e.add(new math.Transform());
                    e.get(math.Transform).position = [Math.random() * 2000, Math.random() * 2000];
                    e.get(math.Transform).angle = Math.random() * Math.PI * 2;
                    e.add(new core.SpriteAnimator());
                    e.get(core.SpriteAnimator).push("grell-idle");
                    engine.addEntity(e);
                }

                {
                    var e = new ecs.Entity();
                    e.add(new math.Transform());
                    e.add(new core.Player());
                    e.add(new core.Object());
                    e.add(new core.Control());
                    e.add(new core.Camera());
                    e.get(math.Transform).position = [1024, 1024];
                    e.get(core.Object).radius = 32;
                    engine.addEntity(e);
                    hudSystem.setPlayerEntity(e);
                }

                {
                    var e = new ecs.Entity();
                    e.add(new math.Transform());
                    e.add(new core.Quad());
                    e.add(new core.Sprite());
                    e.add(new core.SpriteAnimator());
                    e.get(math.Transform).position = [10, 10];
                    e.get(core.Quad).extent = [640, 400];
                    e.get(core.SpriteAnimator).push("shotgun-idle");
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
        }
        loop(0);
    }
}
