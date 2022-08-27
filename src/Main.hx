package;

class Main {
    static public var context = new Context();

    static function main() {
        var canvas:js.html.CanvasElement = cast js.Browser.document.getElementById("canvas");
        var engine = new ash.core.Engine();
        var cameraTransform = context.cameraTransform;
        var keys:Dynamic = {};
        var previousMx:Int = 0;
        var mx:Int = 0;
        {
            cameraTransform.position = [1024, 1024];
            cameraTransform.angle = 0;
            context.renderer.initialize(cameraTransform);
            context.textureManager.initialize();
            context.level.load();
        }
        {
            engine.addSystem(new SpriteSystem(), 10);
            {
                var spriteDef = new SpriteDef();
                spriteDef.textures.push({name:"grell-1"});
                spriteDef.textures.push({name:"grell-0"});
                spriteDef.textures.push({name:"grell-2"});
                spriteDef.textures.push({name:"grell-3"});
                spriteDef.textures.push({name:"grell-4"});
                spriteDef.textures.push({name:"grell-3", flip:true});
                spriteDef.textures.push({name:"grell-2", flip:true});
                spriteDef.textures.push({name:"grell-0", flip:true});
                spriteDef.heightOffset = 10;
                var e = new ash.core.Entity();
                e.add(spriteDef);
                e.add(new Transform());
                e.get(Transform).position = [512, 512];
                engine.addEntity(e);
                var e = new ash.core.Entity();
                e.add(spriteDef);
                e.add(new Transform());
                e.get(Transform).position = [512, 700];
                engine.addEntity(e);

                for(i in 0...100) {
                var e = new ash.core.Entity();
                e.add(spriteDef);
                e.add(new Transform());
                e.get(Transform).position = [Math.random() * 4000, Math.random() * 4000];
                engine.addEntity(e);
                }
            }
        }
        canvas.onmousemove = canvas.onmousedown = canvas.onmouseup = function(e) {
            mx = e.clientX;
        }
        canvas.onmouseenter = function(e) {
            previousMx = mx = e.clientX;
        }
        untyped onkeydown = onkeyup = function(e) {
            keys[e.key] = e.type[3] == 'd';
        }
        canvas.oncontextmenu = e->false;
        function loop(t:Float) {
            // controls
            {
                var camPos = cameraTransform.position;
                var a = cameraTransform.angle;
                var dir:Point = [Math.cos(a), Math.sin(a)];
                var lat = {x:Math.cos(a + Math.PI/2), y:Math.sin(a + Math.PI/2)};
                var prevPos = [camPos.x, camPos.y];
                var move = {x:0, y:0};

                if(untyped keys['w']) {
                    move.y = 1;
                }

                if(untyped keys['s']) {
                    move.y = -1;
                }

                if(untyped keys['d']) {
                    move.x = 1;
                }

                if(untyped keys['a']) {
                    move.x = -1;
                }

                var s = 4;
                camPos.x += dir.x * move.y * s;
                camPos.y += dir.y * move.y * s;
                camPos.x += lat.x * move.x * s;
                camPos.y += lat.y * move.x * s;
                cameraTransform.angle += (mx-previousMx) * 0.01;
                /* cameraTransform.angle += 0.01; */

                for(w in context.level.walls) {
                    var r = Renderer.segmentToSegmentIntersection(prevPos, camPos, w.a, w.b);

                    if(r != null && r[0] < 1) {
                        cameraTransform.position = prevPos;
                    }
                }
            }
            // rendering
            {
                context.renderer.clear();
                /* var texture = context.textureManager.get("doomguy"); */
                /* context.renderer.pushSprite(texture, [256, 256]); */
                /* context.renderer.pushSprite(texture, [312, 356]); */
                engine.update(1/60.0);
                context.renderer.draw(context.level);
                context.renderer.flush();
            }
            js.Browser.window.requestAnimationFrame(loop);
            previousMx = mx;
        }
        loop(0);
    }
}
