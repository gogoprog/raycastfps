package;

class Main {
    static function main() {
        var context = new Context();
        var canvas:js.html.CanvasElement = cast js.Browser.document.getElementById("canvas");
        var rcontext:js.html.CanvasRenderingContext2D = canvas.getContext("2d");
        var screenWidth = 1024;
        var screenHeight = 640;
        var halfScreenHeight = Std.int(screenHeight / 2);
        var halfScreenWidth = Std.int(screenWidth / 2);
        canvas.width = screenWidth;
        canvas.height = screenHeight;
        var walls:Array<Dynamic> = [];
        var cameraTransform = context.cameraTransform;
        cameraTransform.position = [512, 512];
        cameraTransform.angle = 0;
        var keys:Dynamic = {};
        var mx:Int = 0;
        var textureCanvas:js.html.CanvasElement;
        var backbuffer:Framebuffer = Framebuffer.createEmpty(rcontext, screenWidth, screenHeight);
        var textureBuffer:Framebuffer;
        {
            textureCanvas = untyped document.createElement("canvas");
            textureCanvas.width = textureCanvas.height = 64;
            var textureContext = textureCanvas.getContext("2d");
            textureContext.fillRect(0, 0, 64, 64);
            textureContext.fillStyle = '#a22';
            textureContext.fillRect(2, 2, 62, 30);
            textureContext.fillRect(0, 34, 30, 29);
            textureContext.fillRect(32, 50, 32, 13);
            textureBuffer = Framebuffer.create(textureContext, 64, 64);
        }
        var textureBuffer2:Framebuffer;
        {
            textureCanvas = untyped document.createElement("canvas");
            textureCanvas.width = textureCanvas.height = 64;
            var textureContext = textureCanvas.getContext("2d");
            textureContext.fillStyle = '#555';
            textureContext.fillRect(0, 0, 64, 64);
            textureContext.fillStyle = '#888';
            textureContext.fillRect(2, 2, 62, 30);
            textureContext.fillRect(0, 34, 30, 29);
            textureContext.fillRect(32, 50, 32, 13);
            textureContext.fillStyle = 'red';
            textureContext.fillText("FLOOR", 0, 12);
            textureBuffer2 = Framebuffer.create(textureContext, 64, 64);
        }
        untyped onmousemove = onmousedown = onmouseup = function(e) {
            mx = e.clientX;
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
        inline function copyPixel(fromBuffer:Framebuffer, toBuffer:Framebuffer, fromIndex:Int, toIndex:Int) {
            toBuffer.data[toIndex * 4 + 0] = fromBuffer.data[fromIndex * 4 + 0];
            toBuffer.data[toIndex * 4 + 1] = fromBuffer.data[fromIndex * 4 + 1];
            toBuffer.data[toIndex * 4 + 2] = fromBuffer.data[fromIndex * 4 + 2];
            toBuffer.data[toIndex * 4 + 3] = fromBuffer.data[fromIndex * 4 + 3];
        }
        inline function copyPixel32(fromBuffer:Framebuffer, toBuffer:Framebuffer, fromIndex:Int, toIndex:Int) {
            toBuffer.data32[toIndex] = fromBuffer.data32[fromIndex];
        }
        function drawFloor(texture:Framebuffer) {
            var camPos = cameraTransform.position;
            var a = cameraTransform.angle;
            var dir:Point = [Math.cos(a), Math.sin(a)];
            var oldPlaneX = 0;
            var rotSpeed = cameraTransform.angle;
            var o = 0.66;
            var plane:Point = [ - o * Math.sin(a), o * Math.cos(a)];
            var rayDirX0 = dir.x - plane.x;
            var rayDirY0 = dir.y - plane.y;
            var rayDirX1 = dir.x + plane.x;
            var rayDirY1 = dir.y + plane.y;

            for(y in halfScreenHeight + 1...screenHeight) {
                var p = Std.int(y - halfScreenHeight);
                var posZ = 0.5 * screenHeight;
                var rowDistance = posZ / p;
                var floorStepX = rowDistance * (rayDirX1 - rayDirX0) / screenWidth;
                var floorStepY = rowDistance * (rayDirY1 - rayDirY0) / screenWidth;
                var floorX = camPos.x * 0.0125 + rowDistance * rayDirX0;
                var floorY = camPos.y * 0.0125 + rowDistance * rayDirY0;
                var cellX = Std.int(floorX);
                var cellY = Std.int(floorY);

                for(x in 0...screenWidth) {
                    var tx = Std.int(texture.width * (floorX - cellX)) & (texture.width - 1);
                    var ty = Std.int(texture.height * (floorY - cellY)) & (texture.height - 1);
                    floorX += floorStepX;
                    floorY += floorStepY;
                    var texIndex = (texture.width * ty + tx);
                    var backbufferIndex = (y * screenWidth + x);
                    copyPixel32(texture, backbuffer, texIndex, backbufferIndex);
                }
            }
        }
        function drawWallColumn(texture:Framebuffer, tx, x, h) {
            var h2 = Std.int(h/2);
            var fromi = 0;
            var toi = h+1;

            if(h > screenHeight) {
                fromi = Std.int((h-screenHeight) /2);
                toi = h - fromi;
            }

            for(i in fromi...toi) {
                var y:Int = halfScreenHeight - h2 + i;
                var index:Int = (y * screenWidth + x);
                var texY = Std.int((i/h) * texture.height);
                var texIndex = (texY * texture.width + tx);
                copyPixel32(texture, backbuffer, texIndex, index);
            }
        }
        function drawWalls() {
            var wallH = 13;
            var hfov = Math.PI * 0.125;
            var d = halfScreenHeight / Math.tan(hfov);
            var camPos = cameraTransform.position;

            for(x in 0...screenWidth) {
                var a2 = Math.atan2(x - halfScreenWidth, d);
                var a = cameraTransform.angle + a2;
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
                cameraTransform.angle = mx / 32;
                /* cameraTransform.angle += 0.01; */

                for(w in walls) {
                    var r = segmentToSegmentIntersection(prevPos, camPos, w[0], w[1]);

                    if(r != null && r[0] < 1) {
                        cameraTransform.position = prevPos;
                    }
                }
            }
            // rendering
            {
                backbuffer.data.fill(0);
                drawFloor(textureBuffer2);
                drawWalls();
            }
            rcontext.putImageData(backbuffer.getImageData(), 0, 0);
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
            addWall(1, 1, 8, 1);
            addWall(8, 2, 8, 1);
            addWall(8, 2, 1, 2);
            addWall(1, 1, 1, 2);
        }
        loop(0);
    }
}
