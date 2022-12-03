package display;

import math.Point;

@:allow(display.Renderer)
private class Sprite {
    public var position:Point;
    public var texture:Framebuffer;
    public var heightOffset = 0;
    public var flip:Bool;
    public var scale:Float;
    private var distance:Float;

    public function new() {
    }
}

@:allow(display.Renderer)
private class Quad {
    public var position:Point;
    public var extent:Point;
    public var texture:Framebuffer;

    public function new() {
    }
}

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
    public var halfHorizontalFov:Float;
    var depth:js.lib.Float32Array;
    var cameraTransform:math.Transform;
    var sprites:Array<Sprite> = [];
    var quads:Array<Quad> = [];

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


    function drawSkyColumn(texture:Framebuffer, tx, x) {
        for(y in 0...halfScreenHeight) {
            var index:Int = (y * screenWidth + x);
            var texY = Std.int((y/(screenHeight * 0.75)) * texture.height);
            var texIndex = (texY * texture.width + tx);
            copyPixel32(texture, backbuffer, texIndex, index);
        }
    }

    function drawSky(texture:Framebuffer) {
        var w = ((halfHorizontalFov * 2) / (2*Math.PI)) * texture.width;
        var atx = screenWidth / w;
        var a = cameraTransform.angle;

        for(x in 0...screenWidth) {
            var h = halfScreenHeight;
            var tx = Std.int(x / atx + (a / (Math.PI * 2)) * texture.width) % texture.width;
            drawSkyColumn(texture, tx, x);
        }
    }

    function drawFloor(texture:Framebuffer) {
        var camPos = cameraTransform.position;
        var a = cameraTransform.angle;
        var dir:Point = [0, 0];
        dir.setFromAngle(a);
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

    function drawWallColumn(texture:Framebuffer, tx, x, h, offset:Int, texScale:Float) {
        var h2 = Std.int(h/2);
        var fromi = 0;
        var toi = h+1;

        for(i in fromi...toi) {
            var y:Int = halfScreenHeight - h2 + i - offset;

            if(y>0 && y<screenHeight) {
                var index:Int = (y * screenWidth + x);
                var texY = Std.int((i/h) * texture.height * texScale) % texture.height;
                var texIndex = (texY * texture.width + tx);
                copyPixel32(texture, backbuffer, texIndex, index);
            }
        }
    }

    public function drawWalls(walls:Array<world.Wall>) {
        var wallH = 13;
        var camPos = cameraTransform.position;

        for(x in 0...screenWidth) {
            var a2 = Math.atan2(x - halfScreenWidth, halfScreenHeightByTanFov);
            var a = cameraTransform.angle + a2;
            var dx = Math.cos(a) * 1024;
            var dy = Math.sin(a) * 1024;
            var camTarget = [camPos[0]+dx, camPos[1]+dy];
            var best = null;
            var bestDistance = 1000000.0;
            var bestGamma:Float = 0;

            for(w in walls) {
                var r = math.Utils.segmentToSegmentIntersection(camPos, camTarget, w.a, w.b);

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

                if(texture != null) {
                    depth[x] = bestDistance * 1024;
                    var h = (screenHeight / wallH) / bestDistance;
                    var d = h;
                    h *= best.height;
                    var offset = Std.int(h * 0.5 - d * 0.5);
                    var tx = Std.int(bestGamma * best.length * 4 * best.textureScale.x) % texture.width;
                    drawWallColumn(texture, tx, x, Std.int(h), offset, best.textureScale.y);
                }
            } else {
                depth[x] = 1000000;
            }
        }
    }

    function drawSpriteColumn(texture:Framebuffer, tx, x, h, offsetH) {
        if(x < 0 || x >= screenWidth) { return; }

        var h2 = Std.int(h/2);
        var fromi = 0;
        var toi = h+1;

        if(h - offsetH > screenHeight) {
            fromi = Std.int((h-screenHeight) /2);
            toi = h - fromi;
        }

        toi = Std.int(Math.min(screenHeight, toi));

        for(i in fromi...toi) {
            var y:Int = halfScreenHeight - h + i + offsetH;
            var index:Int = (y * screenWidth + x);
            var texY = Std.int((i/h) * texture.height);
            var texIndex = (texY * texture.width + tx);
            blitPixel32(texture, backbuffer, texIndex, index);
        }
    }

    function drawSprite(buffer:Framebuffer, position:Point, heightOffset:Int, flip:Bool, scale:Float) {
        var cam_pos = cameraTransform.position;
        var cam_ang = cameraTransform.angle;
        var delta = position - cam_pos;
        var angle = delta.getAngle();
        var delta_angle = math.Utils.fixAngle(angle - cam_ang);

        if(Math.abs(delta_angle) < halfHorizontalFov + 0.1) {
            var distance = delta.getLength();
            var x = (delta_angle / halfHorizontalFov) * halfScreenWidth + halfScreenWidth;
            distance = Math.cos(delta_angle) * distance;
            var hh = (buffer.height / distance) * 600 * scale;
            var ratio = hh/buffer.height;
            var w = Std.int(buffer.width * ratio);
            var h = Std.int(hh);
            var floorHeight = buffer.height * 0.75 - heightOffset;

            for(xx in 0...w) {
                var dest_x = Std.int(x + xx - w/ 2);

                if(depth[dest_x] > distance) {
                    var tx = Std.int((xx / w) * buffer.width);

                    if(flip) {
                        tx = buffer.width - tx;
                    }

                    drawSpriteColumn(buffer, tx, dest_x, h, Std.int(floorHeight * ratio));
                }
            }
        }
    }

    function drawQuad(texture:Framebuffer, position:Point, extent:Point) {
        var w = Std.int(extent.x);
        var h = Std.int(extent.y);
        var ox = Std.int(position.x);
        var oy = Std.int(position.y);

        for(x in 0...w) {
            var tx = Std.int((x / w) * texture.width);

            for(y in 0...h) {
                var ty = Std.int((y / h) * texture.height);
                var dst_index:Int = ((oy + y) * screenWidth + (ox + x));
                var src_index = (ty * texture.width + tx);
                blitPixel32(texture, backbuffer, src_index, dst_index);
            }
        }
    }

    public function drawSprites() {
        function sort(a:Sprite, b:Sprite) {
            if(a.distance < b.distance) { return 1; }
            else if(a.distance > b.distance) { return -1; }
            else { return 0; }
        }

        for(sprite in sprites) {
            var delta = sprite.position - cameraTransform.position;
            sprite.distance = delta.getSquareLength();
        }

        sprites.sort(sort);

        for(sprite in sprites) {
            drawSprite(sprite.texture, sprite.position, sprite.heightOffset, sprite.flip, sprite.scale);
        }
    }

    public function drawQuads() {
        for(quad in quads) {
            drawQuad(quad.texture, quad.position, quad.extent);
        }
    }

    public function clear() {
        backbuffer.data32.fill(0);
    }

    public function draw(level:world.Level) {
        if(level.skyTexture != null) {
            drawSky(level.skyTexture);
        }

        if(level.floorTexture != null) {
            drawFloor(level.floorTexture);
        }

        drawWalls(level.walls);
        drawSprites();
        drawQuads();
    }

    public function flush() {
        canvasContext.putImageData(backbuffer.getImageData(), 0, 0);
        sprites = [];
        quads = [];
    }

    public function pushSprite(texture:Framebuffer, position:Point, heightOffset:Int, flip:Bool, scale:Float) {
        if(texture != null) {
            var sprite = new Sprite();
            sprite.texture = texture;
            sprite.position = position;
            sprite.heightOffset = heightOffset;
            sprite.flip = flip;
            sprite.scale = scale;
            sprites.push(sprite);
        }
    }

    public function pushQuad(texture:Framebuffer, position:Point, extent:Point) {
        if(texture != null) {
            var quad = new Quad();
            quad.texture = texture;
            quad.position = position;
            quad.extent = extent;
            quads.push(quad);
        }
    }
}
