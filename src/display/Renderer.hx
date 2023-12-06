package display;

import math.Point;

typedef WallResult = {
    var distance:Float;
    var gamma:Float;
    var wall:world.Wall;
    var sector:world.Sector;
}

private class WallResults {
    private var size:Int;
    public var results:Array<WallResult>;

    public function new(size) {
        this.size = size;
        results = [];
    }

    public function add(dist:Float, gamma:Float, wall:world.Wall, sector:world.Sector) {
        if(results.length == 0) {
            results.push({distance:dist, gamma:gamma, wall:wall, sector:sector});
            return;
        }

        var added = false;

        for(i in 0 ... results.length) {
            var r = results[i];

            if(dist < r.distance) {
                results.insert(i, {distance:dist, gamma:gamma, wall:wall, sector:sector});
                added = true;
                break;
            }
        }

        if(!added) {
            results.push({distance:dist, gamma:gamma, wall:wall, sector:sector});
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
    public var floor:Float;
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

@:allow(display.Renderer)
private class Line {
    public var a:Point;
    public var b:Point;
    public var color:Int;

    public function new() {
    }
}

@:allow(display.Renderer)
private class Rect {
    public var center:Point;
    public var extent:Point;
    public var color:Int;

    public function new() {
    }
}

typedef FontInfo = {
    var charExtent:Point;
    var textureName:String;
}

class Renderer {
    var context:Context;
    var canvas:js.html.CanvasElement = cast js.Browser.document.getElementById("canvas");
    var backbuffer:Framebuffer;
    var canvasContext:js.html.CanvasRenderingContext2D;
    static public var screenWidth = 1024;
    static public var screenHeight = 640;
    var halfScreenHeight:Int;
    var halfScreenWidth:Int;
    var halfVerticalFov:Float;
    var halfScreenHeightByTanFov:Float;
    public var halfHorizontalFov:Float;
    var depth:js.lib.Float32Array;
    var floorMap:js.lib.Int32Array;
    var cameraTransform:math.Transform;
    var sprites:Array<Sprite> = [];
    var quads:Array<Quad> = [];
    var lines:Array<Line> = [];
    var rects:Array<Rect> = [];
    var fonts:Map<String, FontInfo> = new Map();

    public function new(context) {
        this.context = context;
    }

    public function initialize(cameraTransform) {
        halfScreenHeight = Std.int(screenHeight / 2);
        halfScreenWidth = Std.int(screenWidth / 2);
        canvasContext = canvas.getContext("2d");
        canvas.width = screenWidth;
        canvas.height = screenHeight;
        depth = new js.lib.Float32Array(screenWidth * screenHeight);
        floorMap = new js.lib.Int32Array(screenWidth * screenHeight);
        backbuffer = Framebuffer.createEmpty(canvasContext, screenWidth, screenHeight);
        halfVerticalFov = Math.PI * 0.125;
        halfScreenHeightByTanFov = halfScreenHeight / Math.tan(halfVerticalFov);
        halfHorizontalFov = Math.atan2(halfScreenWidth, halfScreenHeightByTanFov);
        this.cameraTransform = cameraTransform;
    }

    public function registerFont(name, texture_name, char_width, char_height) {
        fonts[name] = {
            charExtent: [char_width, char_height],
            textureName: texture_name
        };
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

    inline function setPixel32(toBuffer:Framebuffer, x:Int, y:Int, value:Int) {
        toBuffer.data32[toBuffer.width * y + x] = value;
    }

    inline function blendPixel32(toBuffer:Framebuffer, x:Int, y:Int, dst:Int, alpha:Float) {
        var src = toBuffer.data32[toBuffer.width * y + x];
        var inv_alpha = 1.0 - alpha;
        var src_b = Std.int((src >> 16) & 0xff);
        var src_g = Std.int((src >> 8) & 0xff);
        var src_r = Std.int((src >> 0) & 0xff);
        var dst_b = Std.int((dst >> 16) & 0xff);
        var dst_g = Std.int((dst >> 8) & 0xff);
        var dst_r = Std.int((dst >> 0) & 0xff);
        var value = Std.int(src_r * inv_alpha) | Std.int(src_g * inv_alpha) << 8 | Std.int(src_b * inv_alpha) << 16;
        value += Std.int(dst_r * alpha) | Std.int(dst_g * alpha) << 8 | Std.int(dst_b * alpha) << 16;
        toBuffer.data32[toBuffer.width * y + x] = value | 0xff000000;
    }

    inline function getDepth(x, y):Float {
        return depth[screenHeight * x + y];
    }

    inline function setDepth(x, y, value) {
        depth[screenHeight * x + y] = value;
    }

    inline function setDepthColumn(x, value) {
        depth.fill(value, screenHeight * x, screenHeight * (x+1));
    }

    inline function setDepthColumn2(x, value, a, b) {
        depth.fill(value, screenHeight * x + a, screenHeight * x + b);
    }

    inline function getBackbufferIndex(x, y):Int {
        return y * screenWidth + x;
        // return Std.int(y * 0.5 * screenWidth + x * 0.5);
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

    function drawFloorColumn(texture:Framebuffer, x:Int, top:Int, bottom:Int, offset:Float) {
        var camPos = cameraTransform.position;
        var a = cameraTransform.angle;
        var dir:Point = [0, 0];
        dir.setFromAngle(a);
        var o = 0.66;
        var plane:Point = [ - o * Math.sin(a), o * Math.cos(a)];
        var rayDirX0 = dir.x - plane.x;
        var rayDirY0 = dir.y - plane.y;
        var rayDirX1 = dir.x + plane.x;
        var rayDirY1 = dir.y + plane.y;
        var scale = (cameraTransform.y + offset) / 25;

        for(y in top...bottom) {
            var p = Std.int(y - halfScreenHeight);
            var posZ = 0.5 * screenHeight;
            var rowDistance = scale * posZ / p ;
            var floorStepX = rowDistance * (rayDirX1 - rayDirX0) / screenWidth;
            var floorStepY = rowDistance * (rayDirY1 - rayDirY0) / screenWidth;
            var c = 0.0125;
            var floorX = camPos.x * c + rowDistance * rayDirX0;
            var floorY = camPos.y * c + rowDistance * rayDirY0;
            var cellX = Std.int(floorX);
            var cellY = Std.int(floorY);
            {
                floorX += x * floorStepX;
                floorY += x * floorStepY;
                var tx = Std.int(texture.width * (floorX - cellX)) & (texture.width - 1);
                var ty = Std.int(texture.height * (floorY - cellY)) & (texture.height - 1);
                var texIndex = (texture.width * ty + tx);
                copyPixel32(texture, backbuffer, texIndex, getBackbufferIndex(x, y));
            }
        }
    }

    function getWallBottom(h, offset) {
        var toi = h+1;
        var y:Int = halfScreenHeight - offset;

        if(y>0 && y<screenHeight) {
            return  y;
        }

        return screenHeight;
    }

    function drawWallColumn(texture:Framebuffer, tx, x, h:Float, h_factor:Float, offset:Int, tex_scale:Float, depth:Float) {
        var toi = Std.int(h * h_factor) + 1;
        setDepthColumn2(x, depth, halfScreenHeight - toi - offset, halfScreenHeight - offset);
        var theight = texture.height;
        var twidth = texture.width;
        var theight_scaled = theight * tex_scale;
        var init_tex_y = Std.int(theight_scaled);

        for(i in 0...toi) {
            var y:Int = halfScreenHeight - i - offset;

            if(y>0 && y<screenHeight) {
                var tex_y = init_tex_y - (Std.int((i/toi) * theight_scaled) % theight) - 1;
                tex_y %= theight;
                var tex_index = (tex_y * twidth + tx);
                copyPixel32(texture, backbuffer, tex_index, getBackbufferIndex(x, y));
            }
        }
    }

    public function drawWalls(sectors:Array<world.Sector>) {
        var wallH = 13;
        var camPos = cameraTransform.position;

        for(x in 0...screenWidth) {
            var a2 = Math.atan2(x - halfScreenWidth, halfScreenHeightByTanFov);
            var a = cameraTransform.angle + a2;
            var dx = Math.cos(a) * 1024;
            var dy = Math.sin(a) * 1024;
            var camTarget = [camPos[0]+dx, camPos[1]+dy];
            var results = new WallResults(6);

            for(s in sectors) {
                for(w in s.walls) {
                    var r = math.Utils.segmentToSegmentIntersection(camPos, camTarget, w.a, w.b);

                    if(r != null) {
                        var f = Math.cos(a2) * r[0];

                        results.add(f, r[1], w, s);
                    }
                }
            }

            setDepthColumn(x, 1000000);

            if(results.results.length > 0) {
                var magic = 0.2625;
                var i = results.results.length - 1;
                var previous_sector:world.Sector = null;

                while(i>=0) {
                    var wr = results.results[i];
                    var wall = wr.wall;
                    var sector = wr.sector;
                    var texture = wr.wall.texture;
                    var h = (screenHeight / wallH) / wr.distance;
                    var offset = (-cameraTransform.y + sector.bottom) / wr.distance;
                    var bottom = getWallBottom(Std.int(h), Std.int(offset));
                    var depth = wr.distance * 1024;

                    if(texture != null) {
                        var tx = Std.int(wr.gamma * wr.wall.length * wr.wall.textureScale.x) % texture.width;
                        var delta = sector.top - sector.bottom;
                        var ratio = magic * delta/wallH;
                        var tex_scale = delta / (sector.initialTop - sector.initialBottom);
                        drawWallColumn(texture, tx, x, h, ratio, Std.int(offset), wall.textureScale.y * tex_scale, depth);
                        setDepthColumn2(x, depth, bottom, screenHeight);
                    } else if(previous_sector != null) {
                        var delta = previous_sector.bottom - sector.bottom;

                        if(delta > 0) {
                            var h = (screenHeight / wallH) / wr.distance;
                            var texture = wall.bottomTexture;

                            if(texture != null) {
                                var tx = Std.int(wr.gamma * wr.wall.length * wr.wall.textureScale.x) % texture.width;
                                var ratio = magic * delta/wallH;
                                drawWallColumn(texture, tx, x, h, ratio, Std.int(offset), wall.textureScale.y * ratio, depth);
                            }
                        } else {
                            setDepthColumn2(x, depth, bottom, screenHeight);
                        }
                    }

                    if(bottom < screenHeight && sector.floorTexture != null) {
                        drawFloorColumn(sector.floorTexture, x, bottom, screenHeight, -sector.bottom);
                    }

                    --i;
                    previous_sector = sector;
                }
            }
        }
    }

    function drawSpriteColumn(texture:Framebuffer, tx, x, h, offsetH, floor, depth) {
        if(x < 0 || x >= screenWidth) { return; }

        var toi = h+1;
        var fromi = 0;

        if(offsetH - toi < 0) {
            fromi -= offsetH - toi;
        }

        for(i in fromi...toi) {
            var y:Int = offsetH - toi + i;

            if(y>=screenHeight) {
                break;
            }

            if(y >= floor) { break; }

            if(depth < getDepth(x, y)) {
                var texY = Std.int((i/h) * texture.height);
                var texIndex = (texY * texture.width + tx);
                blitPixel32(texture, backbuffer, texIndex, getBackbufferIndex(x, y));
            }
        }
    }

    function drawSprite(buffer:Framebuffer, position:Point, heightOffset:Int, flip:Bool, scale:Float, floor:Float) {
        var cam_pos = cameraTransform.position;
        var cam_ang = cameraTransform.angle;
        var delta = position - cam_pos;
        var angle = delta.getAngle();
        var delta_angle = math.Utils.fixAngle(angle - cam_ang);

        if(Math.abs(delta_angle) < halfHorizontalFov + 0.4) {
            var x = Math.tan(delta_angle) * halfScreenHeightByTanFov + halfScreenWidth;
            var distance = delta.getLength();

            if(distance > 16) {
                distance = Math.cos(delta_angle) * distance;
                var hh = (buffer.height / distance) * 600 * scale;
                var ratio = scale * 600 / distance;
                var w = Std.int(buffer.width * ratio);
                var h = Std.int(hh);
                var hoffset = Std.int(halfScreenHeight + 1000 * (cameraTransform.y - heightOffset) / distance);
                var floorHeight = Std.int(halfScreenHeight + 1000 * (cameraTransform.y - floor) / distance);

                for(xx in 0...w) {
                    var dest_x = Std.int(x + xx - w/ 2);
                    var tx = Std.int((xx / w) * buffer.width);

                    if(flip) {
                        tx = buffer.width - tx;
                    }

                    drawSpriteColumn(buffer, tx, dest_x, h, hoffset, floorHeight, distance);
                }
            }
        }
    }

    function drawQuad(texture:Framebuffer, source_position:Point, source_extent:Point, position:Point, extent:Point) {
        var w = extent != null ? Std.int(extent.x) : texture.width;
        var h = extent != null ? Std.int(extent.y) : texture.height;
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
                var src_index = (ty * texture.width + tx);
                blitPixel32(texture, backbuffer, src_index, getBackbufferIndex(x + ox, y + oy));
            }
        }
    }

    inline function clampX(x) {
        return Std.int(Math.min(Math.max(x, 0), screenWidth));
    }

    inline function clampY(y) {
        return Std.int(Math.min(Math.max(y, 0), screenHeight));
    }

    function drawLine(a:Point, b:Point, color:Int) {
        var x0 = clampX(a.x);
        var y0 = clampY(a.y);
        var x1 = clampX(b.x);
        var y1 = clampY(b.y);
        var dx = Math.abs(x1 - x0);
        var dy = Math.abs(y1 - y0);
        var sx = (x0 < x1) ? 1 : -1;
        var sy = (y0 < y1) ? 1 : -1;
        var err = dx - dy;

        while(true) {
            setPixel32(backbuffer, x0, y0, color);

            if((x0 == x1) && (y0 == y1)) {
                break;
            }

            var e2 = 2*err;

            if(e2 > -dy) { err -= dy; x0 += sx; }

            if(e2 < dx) { err += dx; y0 += sy; }
        }
    }

    function drawRect(center:Point, extent:Point, color:Int) {
        if(center.x < 0 || center.y < 0 || center.x > screenWidth || center.y > screenHeight) { return; }

        var x0 = Std.int(center.x - extent.x / 2);
        var y0 = Std.int(center.y - extent.y / 2);
        var x1 = Std.int(center.x + extent.x / 2);
        var y1 = Std.int(center.y + extent.y / 2);
        var alpha:Float = ((color >> 24) & 0xff) / 0xff;

        if(alpha != 1) {
            for(y in y0...y1) {
                for(x in x0...x1) {
                    blendPixel32(backbuffer, x, y, color, alpha);
                }
            }
        } else {
            for(y in y0...y1) {
                for(x in x0...x1) {
                    setPixel32(backbuffer, x, y, color);
                }
            }
        }
    }

    function drawSprites() {
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
            drawSprite(sprite.texture, sprite.position, sprite.heightOffset, sprite.flip, sprite.scale, sprite.floor);
        }
    }

    public function drawQuads() {
        for(quad in quads) {
            drawQuad(quad.texture, quad.sourcePosition, quad.sourceExtent, quad.position, quad.extent);
        }
    }

    public function drawLines() {
        for(line in lines) {
            drawLine(line.a, line.b, line.color);
        }
    }

    public function drawRects() {
        for(rect in rects) {
            drawRect(rect.center, rect.extent, rect.color);
        }
    }

    public function clear() {
        backbuffer.data32.fill(0);
    }

    public function draw(level:world.Level) {
        if(level.skyTexture != null) {
            drawSky(level.skyTexture);
        }

        drawWalls(level.sectors);
        drawSprites();
        drawRects();
        drawLines();
        drawQuads();
    }

    public function render() {
        canvasContext.putImageData(backbuffer.getImageData(), 0, 0);
    }

    public function flush() {
        sprites = [];
        quads = [];
        lines = [];
        rects = [];
    }

    public function pushSprite(texture:Framebuffer, position:Point, heightOffset:Int, flip:Bool, scale:Float, floor:Float) {
        if(texture != null) {
            var sprite = new Sprite();
            sprite.texture = texture;
            sprite.position = position;
            sprite.heightOffset = heightOffset;
            sprite.flip = flip;
            sprite.scale = scale;
            sprite.floor = floor;
            sprites.push(sprite);
        }
    }

    public function pushQuad(texture:Framebuffer, position:Point, extent:Point = null, source_position:Point = null, source_extent:Point = null) {
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

    public function pushQuad2(texture:Framebuffer, position:Point) {
        if(texture != null) {
            var quad = new Quad();
            quad.texture = texture;
            quad.position = position - [texture.width / 2, texture.height / 2];
            quad.extent = [texture.width, texture.height];
            quads.push(quad);
        }
    }

    public function pushText(font_name:String, position:Point, content:String, centered = false) {
        var font = fonts[font_name];

        if(font == null) {return;}

        var char_extent:Point = font.charExtent;
        var texture = context.textureManager.get(font.textureName);
        var cols = texture.width / char_extent.x;

        for(i in 0...content.length) {
            var code = content.charCodeAt(i);
            code = code - 32;
            var offset = .0;

            if(centered) {
                offset -= content.length * char_extent.x * 0.5;
            }

            var pos:Point = [position.x + char_extent.x*i + offset, position.y];
            var src_pos:Point = [char_extent.x * (code % cols), Std.int(code/cols) * char_extent.y];
            pushQuad(texture, pos, char_extent, src_pos, char_extent);
        }
    }

    public function pushLine(a:Point, b:Point, color:Int) {
        var line = new Line();
        line.a = a.getCopy();
        line.b = b.getCopy();
        line.color = color;
        lines.push(line);
    }

    public function pushRect(center:Point, extent:Point, color:Int) {
        var rect = new Rect();
        rect.center = center;
        rect.extent = extent;
        rect.color = color;
        rects.push(rect);
    }
}
