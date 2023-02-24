package display;

import math.Point;

typedef WallResult = {
    var distance:Float;
    var gamma:Float;
    var wall:world.Wall;
}

private class WallResults {
    private var size:Int;
    public var results:Array<WallResult>;

    public function new(size) {
        this.size = size;
        results = [];
    }

    public function add(dist:Float, gamma:Float, wall:world.Wall) {
        if(results.length == 0) {
            results.push({distance:dist, gamma:gamma, wall:wall});
            return;
        }

        var added = false;

        for(i in 0 ... results.length) {
            var r = results[i];

            if(dist < r.distance) {
                results.insert(i, {distance:dist, gamma:gamma, wall:wall});
                added = true;
                break;
            }
        }

        if(!added) {
            results.push({distance:dist, gamma:gamma, wall:wall});
        }

        if(results.length > size) {
            results.resize(size);
        }
    }

}

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
    public var sourcePosition:Point;
    public var sourceExtent:Point;
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
            var results = new WallResults(3);

            for(w in walls) {
                var r = math.Utils.segmentToSegmentIntersection(camPos, camTarget, w.a, w.b);

                if(r != null) {
                    var f = Math.cos(a2) * r[0];
                    results.add(f, r[1], w);
                }
            }

            if(results.results.length > 0) {
                var i = results.results.length - 1;

                while(i>=0) {
                    var wr = results.results[i];
                    var texture = wr.wall.texture;

                    if(texture != null) {
                        depth[x] = wr.distance * 1024;
                        var h = (screenHeight / wallH) / wr.distance;
                        var d = h;
                        h *= wr.wall.height;
                        var offset = Std.int(h * 0.5 - d * 0.5);
                        var tx = Std.int(wr.gamma * wr.wall.length * 4 * wr.wall.textureScale.x) % texture.width;
                        drawWallColumn(texture, tx, x, Std.int(h), offset, wr.wall.textureScale.y);
                    }

                    --i;
                }
            } else {
                depth[x] = 1000000;
            }
        }
    }

    function drawSpriteColumn(texture:Framebuffer, tx, x, h, offsetH) {
        if(x < 0 || x >= screenWidth) { return; }

        var fromi = 0;
        var toi = h+1;

        if(offsetH < 0) {
            fromi -= offsetH;
        }

        for(i in fromi...toi) {
            var y:Int = offsetH + i;

            if(y>=screenHeight) {
                break;
            }

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
            var x = Math.tan(delta_angle) * halfScreenHeightByTanFov + halfScreenWidth;
            var distance = delta.getLength();
            distance = Math.cos(delta_angle) * distance;
            var hh = (buffer.height / distance) * 600 * scale;
            var ratio = scale * 600 / distance;
            var w = Std.int(buffer.width * ratio);
            var h = Std.int(hh);
            var floorHeight = Std.int(halfScreenHeight + 25000 / distance - (buffer.height + heightOffset) * ratio);

            for(xx in 0...w) {
                var dest_x = Std.int(x + xx - w/ 2);

                if(depth[dest_x] > distance) {
                    var tx = Std.int((xx / w) * buffer.width);

                    if(flip) {
                        tx = buffer.width - tx;
                    }

                    drawSpriteColumn(buffer, tx, dest_x, h, floorHeight);
                }
            }
        }
    }

    function drawQuad(texture:Framebuffer, source_position:Point, source_extent:Point, position:Point, extent:Point) {
        var w = Std.int(extent.x);
        var h = Std.int(extent.y);
        var ox = Std.int(position.x);
        var oy = Std.int(position.y);
        var sx = source_position != null ? source_position.x : 0;
        var sy = source_position != null ? source_position.y : 0;
        var sw = source_extent != null ? source_extent.x : texture.width;
        var sh = source_extent != null ? source_extent.y : texture.height;

        for(x in 0...w) {
            var tx = Std.int(sx + Std.int((x / w) * sw));

            for(y in 0...h) {
                var ty = Std.int(sy + Std.int((y / h) * sh));
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
            drawQuad(quad.texture, quad.sourcePosition, quad.sourceExtent, quad.position, quad.extent);
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

    public function pushQuad(texture:Framebuffer, position:Point, extent:Point, source_position:Point = null, source_extent:Point = null) {
        if(texture != null) {
            var quad = new Quad();
            quad.sourcePosition = source_position;
            quad.sourceExtent = source_extent;
            quad.texture = texture;
            quad.position = position;
            quad.extent = extent;
            quads.push(quad);
        }
    }

    public function drawText(texture:Framebuffer, position:Point, content:String) {
        var char_extent:Point = [20, 20];
        var cols = 15;

        for(i in 0...content.length) {
            var code = content.charCodeAt(i);
            code = code - 32;
            var pos:Point = [position.x + char_extent.x*i, position.y];
            var src_pos:Point = [char_extent.x * (code % cols), Std.int(code/cols) * char_extent.y];
            pushQuad(texture, pos, char_extent, src_pos, char_extent);
        }
    }
}
