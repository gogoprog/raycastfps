package;

class Main {
    static public var context = new Context();

    static function main() {
        var canvas:js.html.CanvasElement = cast js.Browser.document.getElementById("canvas");
        var walls:Array<Dynamic> = [];
        var cameraTransform = context.cameraTransform;
        cameraTransform.position = [512, 512];
        cameraTransform.angle = 0;
        var keys:Dynamic = {};
        var previousMx:Int = 0;
        var mx:Int = 0;
        context.renderer.initialize(cameraTransform);
        context.textureManager.initialize();
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
        function addWall(a:Float, b:Float, c:Float, d:Float) {
            var n = walls.length;
            var len = Math.sqrt((c-a)*(c-a)+(d-b)*(d-b));
            walls[n] = [[a* 100, b * 100], [c * 100, d * 100], len * 100];
        }
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

                for(w in walls) {
                    var r = Renderer.segmentToSegmentIntersection(prevPos, camPos, w[0], w[1]);

                    if(r != null && r[0] < 1) {
                        cameraTransform.position = prevPos;
                    }
                }
            }
            // rendering
            {
                var texture = context.textureManager.get("doomguy");
                context.renderer.pushSprite(texture, [256, 256]);
                context.renderer.pushSprite(texture, [312, 356]);
                context.renderer.clear();
                context.renderer.drawFloor(context.textureManager.get("floor"));
                context.renderer.drawWalls(context.textureManager.get("wall"), walls);
                context.renderer.drawSprites();
                context.renderer.flush();
            }
            js.Browser.window.requestAnimationFrame(loop);
            previousMx = mx;
        }
        {
            /* addWall(0, 0, 9, 0, 9); */
            /* addWall(0, 0, 0, 9, 9); */
            /* addWall(0, 9, 9, 9, 9); */
            /* addWall(9, 0, 9, 9, 9); */
            // T
            addWall(0, 0, 9, 4);
            addWall(9, 4, 6, 4);
            addWall(6, 9, 6, 4);
            addWall(6, 9, 4, 9);
            addWall(4, 4, 4, 9);
            addWall(4, 4, -12, 4);
            addWall(-12, 3, -12, 4);
            addWall(-12, 3, 0, 3);
            addWall(0, 0, 0, 3);
            /* // Pillar */
            addWall(1, 1, 8, 1);
            addWall(8, 2, 8, 1);
            addWall(8, 2, 1, 2);
            addWall(1, 1, 1, 2);
        }
        loop(0);
    }
}
