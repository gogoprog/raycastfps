package;

class Renderer {
    var canvas:js.html.CanvasElement = cast js.Browser.document.getElementById("canvas");
    var backbuffer:Framebuffer;
    var canvasContext:js.html.CanvasRenderingContext2D;
    var screenWidth = 1024;
    var screenHeight = 640;
    var halfScreenHeight:Int;
    var halfScreenWidth:Int;
    var halfVerticalFov:Float;
    var halfScreenHeightByTanFov:Float;
    var halfHorizontalFov:Float;
    var depth:js.lib.Float32Array;
    var cameraTransform:Transform;
    var sprites:Array<Sprite> = [];

    public function new() {
    }

    public function initialize(cameraTransform) {
        halfScreenHeight = Std.int(screenHeight / 2);
        halfScreenWidth = Std.int(screenWidth / 2);
        canvasContext = canvas.getContext("2d");
        canvas.width = screenWidth;
        canvas.height = screenHeight;
        depth = new js.lib.Float32Array(screenWidth);
        backbuffer = Framebuffer.createEmpty(canvasContext, screenWidth, screenHeight);
        halfVerticalFov = Math.PI * 0.125;
        halfScreenHeightByTanFov = halfScreenHeight / Math.tan(halfVerticalFov);
        halfHorizontalFov = Math.atan2(halfScreenWidth, halfScreenHeightByTanFov);
        this.cameraTransform = cameraTransform;
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

    inline function blitPixel32(fromBuffer:Framebuffer, toBuffer:Framebuffer, fromIndex:Int, toIndex:Int) {
        var value = fromBuffer.data32[fromIndex];

        if((value & 0x11000000) != 0) {
            toBuffer.data32[toIndex] = value;
        }
    }

    static public function segmentToSegmentIntersection(from1:Point, to1:Point, from2:Point, to2:Point) {
        var dX = to1.x - from1.x;
        var dY = to1.y - from1.y;
        var determinant = dX * (to2.y - from2.y) - (to2.x - from2.x) * dY;
        /* if(determinant == 0) { return null; } */
        var lambda = ((to2.y - from2.y) * (to2.x - from1.x) + (from2.x - to2.x) * (to2.y - from1.y)) / determinant;
        var gamma = ((from1.y - to1.y) * (to2.x - from1.x) + dX * (to2.y - from1.y)) / determinant;

        if(lambda<0 || !(0 <= gamma && gamma <= 1)) { return null; }

        return [lambda, gamma];
    }

    static function fixAngle(angle:Float) {
        while(angle > Math.PI) {
            angle -= 2 * Math.PI;
        }

        while(angle < -Math.PI) {
            angle += 2 * Math.PI;
        }

        return angle;
    }

    public function drawFloor(texture:Framebuffer) {
        var camPos = cameraTransform.position;
        var a = cameraTransform.angle;
        var dir:Point = [Math.cos(a), Math.sin(a)];
        var oldPlaneX = 0;
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

    public function drawWalls(walls:Array<Wall>) {
        var wallH = 13;
        var camPos = cameraTransform.position;

        for(x in 0...screenWidth) {
            var a2 = Math.atan2(x - halfScreenWidth, halfScreenHeightByTanFov);
            var a = cameraTransform.angle + a2;
            var dx = Math.cos(a) * 1024;
            var dy = Math.sin(a) * 1024;
            var camTarget = [camPos[0]+dx, camPos[1]+dy];
            var best = null;
            var bestDistance = 100000.0;
            var bestGamma:Float = 0;

            for(w in walls) {
                var r = segmentToSegmentIntersection(camPos, camTarget, w.a, w.b);

                if(r != null) {
                    var f = Math.cos(a2) * r[0];

                    if(f<bestDistance) {
                        bestDistance = f;
                        best = w;
                        bestGamma = r[1];
                    }
                }
            }

            if(best != null) {
                var texture = best.texture;
                depth[x] = bestDistance * 1024;
                var h = (screenHeight/ wallH) / bestDistance;
                var tx = Std.int(bestGamma * best.length) % texture.width;
                drawWallColumn(texture, tx, x, Std.int(h));
            }
        }
    }

    function drawSpriteColumn(texture:Framebuffer, tx, x, h, offsetH) {
        if(x < 0 || x >= screenWidth) { return; }

        var h2 = Std.int(h/2);
        var fromi = 0;
        var toi = h+1;

        if(h > screenHeight) {
            fromi = Std.int((h-screenHeight) /2);
            toi = h - fromi;
        }

        for(i in fromi...toi) {
            var y:Int = halfScreenHeight - h + i + offsetH;
            var index:Int = (y * screenWidth + x);
            var texY = Std.int((i/h) * texture.height);
            var texIndex = (texY * texture.width + tx);
            blitPixel32(texture, backbuffer, texIndex, index);
        }
    }

    function drawSprite(buffer, position:Point, heightOffset:Int) {
        var cam_pos = cameraTransform.position;
        var cam_ang = cameraTransform.angle;
        var delta = position - cam_pos;
        var angle = delta.getAngle();
        var delta_angle = fixAngle(angle - cam_ang);

        if(Math.abs(delta_angle) < halfHorizontalFov) {
            var distance = delta.getLength();
            var x = (delta_angle / halfHorizontalFov) * halfScreenWidth + halfScreenWidth;
            distance = Math.cos(delta_angle) * distance;
            var hh = (screenHeight / distance) * 55;
            var ratio = hh/buffer.height;
            var w = Std.int(buffer.width * ratio);
            var h = Std.int(hh);
            var floorHeight = buffer.height * 0.75 - heightOffset;

            for(xx in 0...w) {
                var dest_x = Std.int(x + xx - w/ 2);

                if(depth[dest_x] > distance) {
                    var tx = Std.int((xx / w) * buffer.width);
                    drawSpriteColumn(buffer, tx, dest_x, h, Std.int(floorHeight * ratio));
                }
            }
        }
    }

    public function drawSprites() {
        for(sprite in sprites) {
            drawSprite(sprite.texture, sprite.position, sprite.heightOffset);
        }
    }

    public function clear() {
        backbuffer.data32.fill(0);
    }

    public function draw(level:Level) {
        drawFloor(level.floorTexture);
        drawWalls(level.walls);
        drawSprites();
    }

    public function flush() {
        canvasContext.putImageData(backbuffer.getImageData(), 0, 0);
        sprites = [];
    }

    public function pushSprite(texture:Framebuffer, position:Point, heightOffset:Int) {
        if(texture != null) {
            var sprite = new Sprite();
            sprite.texture = texture;
            sprite.position = position;
            sprite.heightOffset = heightOffset;
            sprites.push(sprite);
        }
    }
}
