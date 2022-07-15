abstract Point(Array<Float>) from Array<Float> to Array<Float> {
    public var x(get, set):Float;
    inline function get_x() return this[0];
    inline function set_x(value) return this[0] = value;
    public var y(get, set):Float;
    inline function get_y() return this[1];
    inline function set_y(value) return this[1] = value;
}

class Main {
    static function main() {
        var canvas:js.html.CanvasElement = cast js.Browser.document.getElementById("canvas");
        var context:js.html.CanvasRenderingContext2D = canvas.getContext("2d");
        var screenWidth = 1024;
        var screenHeight = 640;
        var halfScreenHeight = Std.int(screenHeight / 2);
        canvas.width = screenWidth;
        canvas.height = screenHeight;
        var randomSeed = 0;
        var time:Int = 0;
        var walls:Array<Dynamic> = [];
        var camPos:Point = [512, 512];
        var camAngle:Float = 0;
        var keys:Dynamic = {};
        var mx:Int = 0;
        var mmove:Int = 0;
        var textureCanvas:js.html.CanvasElement;
        var backbuffer = context.createImageData(screenWidth, screenHeight);
        var textureBuffer:js.html.ImageData;
        inline function createTexture() {
            textureCanvas = untyped document.createElement("canvas");
            textureCanvas.width = textureCanvas.height = 64;
            var textureContext = textureCanvas.getContext("2d");
            textureContext.fillRect(0, 0, 64, 64);
            textureContext.fillStyle = '#a22';
            textureContext.fillRect(2, 2, 62, 30);
            textureContext.fillRect(0, 34, 30, 29);
            textureContext.fillRect(32, 50, 32, 13);
            textureBuffer = textureContext.getImageData(0, 0, 64, 64);
        }
        createTexture();
        inline function col(n : Dynamic) {
            context.fillStyle = n;
        }
        inline function drawRect(x:Float, y:Float, w:Float, h:Float) {
            context.fillRect(x, y, w, h);
        }
        untyped onmousemove = onmousedown = onmouseup = function(e) {
            mx = e.clientX;
            mmove = (e.buttons);
        }
        untyped onkeydown = onkeyup = function(e) {
            keys[e.key] = e.type[3] == 'd';
        }
        canvas.oncontextmenu = e->false;
        function segmentToSegmentIntersection(from1:Point, to1:Point, from2:Point, to2:Point) {
            var dX = to1.x - from1.x;
            var dY = to1.y - from1.y;
            var determinant = dX * (to2.y - from2.y) - (to2.x - from2.x) * dY;
            /* if(determinant == 0) { return null; } */
            var lambda = ((to2.y - from2.y) * (to2.x - from1.x) + (from2.x - to2.x) * (to2.y - from1.y)) / determinant;
            var gamma = ((from1.y - to1.y) * (to2.x - from1.x) + dX * (to2.y - from1.y)) / determinant;

            if(lambda<0 || !(0 <= gamma && gamma <= 1)) { return null; }

            return [lambda, gamma];
        }
        function addWall(a:Float, b:Float, c:Float, d:Float) {
            var n = walls.length;
            var len = Math.sqrt((c-a)*(c-a)+(d-b)*(d-b));
            walls[n] = [[a* 100, b * 100], [c * 100, d * 100], len * 100];
        }
        function drawWallColumn(texture:js.html.ImageData, tx, x, h) {
            var h2 = Std.int(h/2);
            var fromi = 0;
            var toi = h+1;

            if(h > screenHeight) {
                fromi = Std.int((h-screenHeight) /2);
                toi = h - fromi;
            }

            for(i in fromi...toi) {
                var y:Int = halfScreenHeight - h2 + i;
                var index:Int = (y * screenWidth + x)*4;
                var texY = Std.int((i/h) * texture.height);
                var texIndex = (texY * texture.width + tx) *4;
                backbuffer.data[index + 0] = texture.data[texIndex + 0];
                backbuffer.data[index + 1] = texture.data[texIndex + 1];
                backbuffer.data[index + 2] = texture.data[texIndex + 2];
                backbuffer.data[index + 3] = texture.data[texIndex + 3];
            }
        }
        function drawWalls() {
            var wallH = 26;
            var hfov = Math.PI * 0.25;
            var d = halfScreenHeight / Math.tan(hfov);

            for(x in 0...screenWidth) {
                var a2 = Math.atan2(x - halfScreenHeight, d);
                var a = camAngle + a2;
                var dx = Math.cos(a) * 1024;
                var dy = Math.sin(a) * 1024;
                var camTarget = [camPos[0]+dx, camPos[1]+dy];
                var best = null;
                var bestDistance = 100000.0;
                var bestGamma:Float = 0;

                for(w in walls) {
                    var r = segmentToSegmentIntersection(camPos, camTarget, w[0], w[1]);

                    if(untyped r) {
                        var f = Math.cos(a2) * r[0];

                        if(f<bestDistance) {
                            bestDistance = f;
                            best = w;
                            bestGamma = r[1];
                        }
                    }
                }

                if(best != null) {
                    var h = (screenHeight/ wallH) / bestDistance;
                    var tx = Std.int(bestGamma * best[2]) % 64;
                    drawWallColumn(textureBuffer, tx, x, Std.int(h));
                }
            }
        }
        function loop(t:Float) {
            // controls
            {
                var a = camAngle;
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
                camAngle = mx / 32;//* 0.04;

                for(w in walls) {
                    var r = segmentToSegmentIntersection(prevPos, camPos, w[0], w[1]);

                    if(r != null && r[0] < 1) {
                        camPos = prevPos;
                    }
                }
            }
            // rendering
            {
                backbuffer.data.fill(0);
                col('#666');
                /* drawRect(0, 0, screenSize, halfSize); */
                col('#999');
                /* drawRect(0, halfSize, screenSize, halfSize); */
                drawWalls();
                /* col('#841'); */
                /* drawRect(halfSize - 12, screenSize * 0.96, 24, screenSize); */
                /* col('#222'); */
                /* drawRect(halfSize - 8, screenSize * 0.95, 16, screenSize); */

                if(camPos.x < -1100) {
                    context.fillText("WIN !", 32, 32);
                }
            }
            context.putImageData(backbuffer, 0, 0);

            for(i in 0...200) {
                backbuffer.data[i*4 +0] = 0;
                backbuffer.data[i*4 +1] = 0;
                backbuffer.data[i*4 +2] = 0;
                backbuffer.data[i*4 +3] = 255;
            }

            untyped requestAnimationFrame(loop);
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
            /* addWall(1, 1, 8, 1, 7); */
            /* addWall(8, 2, 8, 1, 1); */
            /* addWall(8, 2, 1, 2, 7); */
            /* addWall(1, 1, 1, 2, 1); */
        }
        loop(0);
    }
}
