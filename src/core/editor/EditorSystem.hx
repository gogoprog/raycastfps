package core.editor;

import world.Level;
import def.Level;

private enum Action {
    Selecting;
    MovingVertex;
    MovingWall;
    MovingRoom;
    Panning;
    CreatingRoom;
    ChoosingTexture;
}

class EditorSystem extends ecs.System {
    static var selectedColor = 0xff11ee11;
    static var objectsColors = [ "monster" => 0xff4444dd, "start" =>  0xffdd5544];
    var font:display.Framebuffer = null;
    var entries:Array<String> = [];
    var offset:math.Point = [400, 200];
    var zoom = 0.2;
    var isPanning = false;
    var startPanPosition:math.Point = [];
    var startPanOffset:math.Point = [];
    var startMoveMousePosition:math.Point = [];
    var startMoveWallAPosition:math.Point = [];
    var startMoveWallBPosition:math.Point = [];
    var startMoveRoomVertexPosition:Array<math.Point> = [];

    var level:world.Level;
    var data:def.Level;

    var hoveredVertexIndex:Int;
    var movingVertexIndex:Int;
    var previousVertexIndex:Int;
    var startVertexIndex:Int;

    var hoveredWallIndex:Int;
    var movingWallIndex:Int;

    var hoveredRoomIndex:Int;
    var movingRoomIndex:Int;

    var currentRoomWalls:Array<Int> = [];
    var creatingRoomNewVerticesCount = 0;

    var action = Selecting;

    var textureChooserScroll = 0;
    var textureChooserCurrent:String;
    var textureChooserCallback:String->Void;

    public function new() {
        super();
    }

    override public function onResume() {
        level = context.level;
        data = level.data;
    }

    override public function onSuspend() {
        level.generateSectors();
    }

    override public function update(dt:Float) {
        if(font == null) {
            font = context.textureManager.get("font");
            return;
        }

        var renderer = context.renderer;
        var mouse_position = context.mouse.position;
        draw();
        processAction();
        processControls();
        renderer.pushText("main", [2, 2], "EDITOR", false);
    }

    function convertToMap(p:math.Point):math.Point {
        return [p.x * zoom + offset.x, p.y * zoom + offset.y];
    }

    function convertFromMap(p:math.Point):math.Point {
        return [Std.int((p.x - offset.x) / zoom), Std.int((p.y - offset.y) / zoom)];
    }

    function draw() {
        var renderer = context.renderer;
        var width = display.Renderer.screenWidth;
        var height = display.Renderer.screenHeight;
        renderer.pushRect([width/2, height/2], [width, height], 0xaa000000);

        if(action != ChoosingTexture) {
            processVertices();
            processWalls();
            processRooms();
            processObjects();
        }
    }

    function processTextureChooser() {
        var mouse_position = context.mouse.position;
        var textures = [];
        textures.push(null);

        for(name in context.textureManager.getTextureNames()) {
            if(name.substring(0, 6) == "level/") {
                textures.push(name);
            }
        }

        var size = 128;
        var padding = 8;
        var x = padding;
        var y = 32 + padding;

        if(context.mouse.wheelDelta < 0) {
            textureChooserScroll -= 1;
        }

        if(context.mouse.wheelDelta > 0) {
            textureChooserScroll += 1;
        }

        var tex_per_line = Std.int((display.Renderer.screenWidth - padding) / (padding + size));

        for(i in (textureChooserScroll*tex_per_line)...textures.length) {
            var name = textures[i];
            var pos:math.Point = [x, y];
            var center = [x + size/2, y+size/2];
            var color = 0xff333333;

            if(mouse_position.x > pos.x && mouse_position.x < pos.x + size && mouse_position.y > pos.y && mouse_position.y < pos.y + size) {
                color = 0xffffffff;

                if(context.mouse.isJustPressed(0)) {
                    textureChooserCallback(name);
                }
            }

            context.renderer.pushRect(center, [size+2, size+2], color);
            context.renderer.pushQuad(context.textureManager.get(name), pos, [size, size]);
            x += size + padding;

            if(x + size > display.Renderer.screenWidth) {
                y += size + padding;
                x = padding;

                if(y + size > display.Renderer.screenHeight) {
                    break;
                }
            }
        }
    }

    function processVertices() {
        var renderer = context.renderer;
        var mouse_position = context.mouse.position;
        var index = 0;
        hoveredVertexIndex = null;

        for(v in data.vertices) {
            var sv = convertToMap(v);
            var delta = (mouse_position - sv);
            var color = 0xffffffff;

            if(delta.getLength() < 64 * zoom) {
                if(index != movingVertexIndex) {
                    hoveredVertexIndex = index;
                }

                color = selectedColor;
            }

            renderer.pushRect(sv, [32 * zoom, 32 * zoom], color);
            // renderer.pushText("mini", sv + new math.Point(4, 16), "" + index);
            index++;
        }
    }

    function processWalls() {
        var renderer = context.renderer;
        var level = context.level;
        var mouse_position = context.mouse.position;
        var index = 0;
        hoveredWallIndex = null;

        for(w in data.walls) {
            var a = convertToMap(data.vertices[w.a]);
            var b = convertToMap(data.vertices[w.b]);
            var color = 0xffffffff;
            var center = (a + b) / 2;
            var delta = (mouse_position - center);

            if(w.textureName == null) {
                color = 0xff888888;
            }

            if(delta.getLength() < 64 * zoom) {
                hoveredWallIndex = index;
                color = selectedColor;
            }

            renderer.pushLine(a, b, color);
            ++index;
        }
    }

    function processRooms() {
        var center:math.Point = [0, 0];
        var renderer = context.renderer;
        var mouse_position = context.mouse.position;
        var index = 0;
        hoveredRoomIndex = null;

        for(room in data.rooms) {
            computeRoomCenter(room, center);
            var pos = convertToMap(center);
            var delta = (mouse_position - pos);
            var color = 0xff444444;

            if(delta.getLength() < 16) {
                hoveredRoomIndex = index;
                color = selectedColor;
            }

            renderer.pushRect(pos, [8, 8], color);

            if(room.door) {
                renderer.pushText("mini", pos, "D");
            }

            ++index;
        }

        if(hoveredRoomIndex != null) {
            for(wi in data.rooms[hoveredRoomIndex].walls) {
                var w = data.walls[wi];
                var a = convertToMap(data.vertices[w.a]);
                var b = convertToMap(data.vertices[w.b]);
                var color = selectedColor;

                if(w.textureName == null) {
                    color = 0xff888888;
                }

                renderer.pushLine(a, b, color);
            }
        }
    }

    static var tmp = new math.Point();
    function processObjects() {
        var mouse_position = context.mouse.position;
        var renderer = context.renderer;
        renderer.pushRect(mouse_position, [2, 2], 0xff55dd44);
        {
            var camTransform = context.cameraTransform;
            var pos = convertToMap(camTransform.position);
            renderer.pushRect(pos, [4, 4], 0xffffffff);

            tmp.setFromAngle(camTransform.angle - 0.5, 20);

            tmp.add(pos);

            renderer.pushLine(pos, tmp, 0xffffffff);

            tmp.setFromAngle(camTransform.angle + 0.5, 20);

            tmp.add(pos);

            renderer.pushLine(pos, tmp, 0xffffffff);
        }

        for(obj in data.objects) {
            var pos = convertToMap(obj.position);
            renderer.pushRect(pos, [8, 8], objectsColors[obj.type]);
        }

        return;
    }

    function onMouseLeftPressed() {
        var mouse_position = context.mouse.position;

        switch(action) {
            case Selecting: {
                if(hoveredVertexIndex != null) {
                    action = MovingVertex;
                    movingVertexIndex = hoveredVertexIndex;
                } else if(hoveredWallIndex != null) {
                    action = MovingWall;
                    movingWallIndex = hoveredWallIndex;
                    var wall = data.walls[movingWallIndex];
                    startMoveMousePosition.copyFrom(convertFromMap(mouse_position));
                    startMoveWallAPosition.copyFrom(data.vertices[wall.a]);
                    startMoveWallBPosition.copyFrom(data.vertices[wall.b]);
                } else if(hoveredRoomIndex != null) {
                    action = MovingRoom;
                    movingRoomIndex = hoveredRoomIndex;
                    startMoveMousePosition.copyFrom(convertFromMap(mouse_position));
                    var room = data.rooms[movingRoomIndex];
                    startMoveRoomVertexPosition = [];

                    for(w in room.walls) {
                        var wall = data.walls[w];
                        startMoveRoomVertexPosition.push(data.vertices[wall.a].getCopy());
                        startMoveRoomVertexPosition.push(data.vertices[wall.b].getCopy());
                    }
                }
            }

            default:
        }
    }

    function onMouseLeftReleased() {
        switch(action) {
            case MovingVertex: {
                action = Selecting;
                movingVertexIndex = null;
            }

            case MovingWall: {
                action = Selecting;
                movingWallIndex = null;
            }

            case MovingRoom : {
                action = Selecting;
                movingRoomIndex = null;
            }

            default:
        }
    }

    function onMouseRightPressed() {
        switch(action) {
            case Selecting: {
                if(hoveredRoomIndex != null) {
                    data.rooms[hoveredRoomIndex].door = !data.rooms[hoveredRoomIndex].door;

                    if(data.rooms[hoveredRoomIndex].door) {
                        data.rooms[hoveredRoomIndex].floorTextureName = "door";
                    }
                } else if(hoveredVertexIndex != null) {
                } else if(hoveredWallIndex != null) {
                    var wall = data.walls[hoveredWallIndex];
                    wall.textureName = null;
                }
            }

            default:
        }
    }

    function onMouseRightReleased() {
        switch(action) {
            case MovingVertex: {
            }

            case MovingWall: {
            }

            default:
        }
    }

    function onSpacePressed() {
        var mouse_position = context.mouse.position;
        var new_position = convertFromMap(mouse_position);
        alignPoint(new_position);

        switch(action) {
            case Selecting: {
                action = CreatingRoom;
                creatingRoomNewVerticesCount = 0;

                if(hoveredVertexIndex != null) {
                    data.vertices.push(new_position.getCopy());
                    creatingRoomNewVerticesCount++;
                    var last_index = data.vertices.length - 1;
                    var wall:def.Wall = {
                        a: hoveredVertexIndex,
                        b: last_index,
                        bottomTextureName: "door",
                        textureName: "wall",
                        textureScale: [1, 1]
                    };
                    data.walls.push(wall);
                    movingVertexIndex = last_index;
                    previousVertexIndex = hoveredVertexIndex;
                    startVertexIndex = hoveredVertexIndex;
                    currentRoomWalls.push(data.walls.length - 1);
                } else {
                    creatingRoomNewVerticesCount++;
                    data.vertices.push(new_position.getCopy());
                    data.vertices.push(new_position.getCopy());
                    var last_index = data.vertices.length - 1;
                    var wall:def.Wall = {
                        a: last_index - 1,
                        b: last_index,
                        bottomTextureName: "door",
                        textureName: "wall",
                        textureScale: [1, 1]
                    };
                    data.walls.push(wall);
                    startVertexIndex = last_index - 1;
                    movingVertexIndex = last_index;
                    previousVertexIndex = last_index - 1;
                    currentRoomWalls.push(data.walls.length - 1);
                }
            }

            case CreatingRoom : {
                if(hoveredVertexIndex != null) {
                    data.vertices.pop();
                    data.walls.pop();
                    currentRoomWalls.pop();
                    var wall:def.Wall = {
                        a: previousVertexIndex,
                        b: hoveredVertexIndex,
                        bottomTextureName: "door",
                        textureName: "wall",
                        textureScale: [1, 1]
                    };
                    data.walls.push(wall);
                    movingVertexIndex = null;
                    currentRoomWalls.push(data.walls.length - 1);
                    previousVertexIndex = null;

                    if(startVertexIndex == hoveredVertexIndex) {
                        currentRoomWalls.push(data.walls.length - 1);
                        {
                            data.rooms.push({
                                walls: currentRoomWalls,
                                floorTextureName: "floor",
                                bottom: 0,
                                top: 64
                            });
                            currentRoomWalls = [];
                            level.generateSectors();
                        }
                    } else {
                        var cancel = true;
                        var missing_walls = findWalls(startVertexIndex, hoveredVertexIndex, currentRoomWalls);

                        if(missing_walls != null) {
                            for(w in missing_walls) {
                                currentRoomWalls.push(w);
                                data.walls[w].textureName = null;
                            }

                            data.rooms.push({
                                walls: currentRoomWalls,
                                floorTextureName: "floor",
                                bottom: 0,
                                top: 64
                            });
                            currentRoomWalls = [];
                            level.generateSectors();
                            cancel = false;
                        }

                        if(cancel) {
                            for(i in 0...currentRoomWalls.length) {
                                data.walls.pop();
                            }

                            for(i in 0...creatingRoomNewVerticesCount - 1) {
                                data.vertices.pop();
                            }

                            currentRoomWalls = [];
                        }
                    }

                    action = Selecting;
                } else {
                    creatingRoomNewVerticesCount++;
                    data.vertices.push(new_position.getCopy());
                    var last_index = data.vertices.length - 1;
                    var wall:def.Wall = {
                        a: movingVertexIndex,
                        b: last_index,
                        bottomTextureName: "door",
                        textureName: "wall",
                        textureScale: [1, 1]
                    };
                    data.walls.push(wall);
                    previousVertexIndex = movingVertexIndex;
                    movingVertexIndex = last_index;
                    currentRoomWalls.push(data.walls.length - 1);
                }
            }

            default:
        }
    }

    function processAction() {
        var mouse_position = context.mouse.position;
        var new_position = convertFromMap(mouse_position);

        if(!context.keyboard.isPressed("Shift")) {
            alignPoint(new_position);
        }

        switch(action) {
            case Selecting: {
                if(hoveredRoomIndex != null) {
                    var room = data.rooms[hoveredRoomIndex];
                    var step = 8;

                    if(context.keyboard.isJustPressed("PageUp")) {
                        room.bottom += step;
                        level.generateSectors();
                    }

                    if(context.keyboard.isJustPressed("PageDown")) {
                        room.bottom -= step;
                        level.generateSectors();
                    }

                    if(context.keyboard.isJustPressed("Home")) {
                        room.top += step;
                        level.generateSectors();
                    }

                    if(context.keyboard.isJustPressed("End")) {
                        room.top -= step;
                        level.generateSectors();
                    }

                    if(context.keyboard.isJustPressed("Delete")) {
                        deleteRoom(hoveredRoomIndex);
                    }

                    if(context.keyboard.isJustPressed("t")) {
                        action = ChoosingTexture;
                        textureChooserCurrent = data.rooms[hoveredRoomIndex].floorTextureName;
                        textureChooserCallback = function(name) {
                            action = Selecting;
                            data.rooms[hoveredRoomIndex].floorTextureName = name;
                            level.generateSectors();
                        }
                    }

                    {
                        var texture = context.textureManager.get(data.rooms[hoveredRoomIndex].floorTextureName);
                        context.renderer.pushText("main", [840, 4], "floor", false);
                        context.renderer.pushQuad(texture, [840, 32], [128, 128]);
                    }
                } else if(hoveredWallIndex != null) {
                    if(context.keyboard.isJustPressed("t")) {
                        action = ChoosingTexture;
                        textureChooserCurrent = data.walls[hoveredWallIndex].textureName;
                        textureChooserCallback = function(name) {
                            action = Selecting;
                            data.walls[hoveredWallIndex].textureName = name;
                            level.generateSectors();
                        }
                    }

                    if(context.keyboard.isJustPressed("b")) {
                        action = ChoosingTexture;
                        textureChooserCurrent = data.walls[hoveredWallIndex].bottomTextureName;
                        textureChooserCallback = function(name) {
                            action = Selecting;
                            data.walls[hoveredWallIndex].bottomTextureName = name;
                            level.generateSectors();
                        }
                    }

                    {
                        var texture = context.textureManager.get(data.walls[hoveredWallIndex].textureName);
                        context.renderer.pushText("main", [840, 4], "wall", false);
                        context.renderer.pushQuad(texture, [840, 32], [128, 128]);
                        var texture = context.textureManager.get(data.walls[hoveredWallIndex].bottomTextureName);
                        context.renderer.pushText("main", [840, 160], "bottom", false);
                        context.renderer.pushQuad(texture, [840, 188], [128, 128]);
                    }
                } else if(hoveredVertexIndex != null) {
                    if(context.keyboard.isJustPressed("Delete")) {
                        deleteVertex(hoveredVertexIndex);
                    }
                }

                if(context.keyboard.isJustPressed("m")) {
                    var obj = {
                        type: "monster",
                        name: "grell",
                        position:new_position
                    };
                    data.objects.push(obj);
                    level.placeObjects(true);
                }

                if(context.keyboard.isJustPressed("s")) {
                    save();
                }
            }

            case MovingVertex: {
                context.renderer.pushText("main", [128, 2], " : Moving vertex", false);
                data.vertices[movingVertexIndex].copyFrom(new_position);
            }

            case MovingWall: {
                context.renderer.pushText("main", [128, 2], " : Moving wall", false);
                var wall = data.walls[movingWallIndex];
                var delta = new_position - startMoveMousePosition;
                data.vertices[wall.a].copyFrom(startMoveWallAPosition + delta);
                data.vertices[wall.b].copyFrom(startMoveWallBPosition + delta);
            }

            case MovingRoom : {
                context.renderer.pushText("main", [128, 2], " : Moving room", false);
                var room = data.rooms[movingRoomIndex];
                var delta = new_position - startMoveMousePosition;
                var i = 0;

                for(w in room.walls) {
                    var wall = data.walls[w];
                    data.vertices[wall.a].copyFrom(startMoveRoomVertexPosition[i] + delta);
                    data.vertices[wall.b].copyFrom(startMoveRoomVertexPosition[i + 1] + delta);
                    i+=2;
                }
            }

            case CreatingRoom: {
                context.renderer.pushText("main", [128, 2], " : Creating room", false);
                data.vertices[movingVertexIndex].copyFrom(new_position);
            }

            case ChoosingTexture: {
                context.renderer.pushText("main", [128, 2], " : Choosing texture", false);
                processTextureChooser();
            }

            default:
        }
    }

    function processControls() {
        var mouse_position = context.mouse.position;

        if(context.mouse.buttons[2]) {
            if(!isPanning) {
                isPanning = true;
                startPanPosition.copyFrom(mouse_position);
                startPanOffset.copyFrom(offset);
            } else {
                var delta = mouse_position - startPanPosition;
                offset = startPanOffset + delta;
            }
        } else {
            isPanning = false;
        }

        if(context.mouse.isJustPressed(0)) {
            onMouseLeftPressed();
        }

        if(context.mouse.isJustReleased(0)) {
            onMouseLeftReleased();
        }

        if(context.mouse.isJustPressed(2)) {
            onMouseRightPressed();
        }

        if(context.mouse.isJustReleased(2)) {
            onMouseRightReleased();
        }

        if(context.keyboard.isJustPressed(' ')) {
            onSpacePressed();
        }

        if(context.keyboard.isJustPressed('e')) {
            context.app.gotoIngame();
        }

        if(context.keyboard.isJustPressed('Escape')) {
            action = Selecting;
        }

        if(action != ChoosingTexture) {
            if(context.keyboard.isJustPressed('-') || context.mouse.wheelDelta < 0) {
                zoom *= 1.4;
            }

            if(context.keyboard.isJustPressed('+') || context.mouse.wheelDelta > 0) {
                zoom /= 1.4;
            }
        }
    }

    function computeRoomCenter(room:def.Room, center:math.Point) {
        center.set(0, 0);
        var v = data.vertices;

        for(wi in room.walls) {
            var wall = data.walls[wi];

            center.add(v[wall.a]);

            center.add(v[wall.b]);
        }

        var len = room.walls.length * 2;
        center.set(center.x/len, center.y/len);
    }

    function findWall(a, b) {
        for(index in 0...data.walls.length) {
            var wall = data.walls[index];

            if((wall.a == a && wall.b == b) || (wall.a == b && wall.b == a)) {
                return index;
            }
        }

        return null;
    }

    function findConnectedVertices(index:Int) {
        var result = [];

        for(wall in data.walls) {
            var next = wall.a == index ? wall.b : (wall.b == index ? wall.a : null);

            if(next != null) {
                result.push(next);
            }
        }

        return result;
    }

    function findWalls(a:Int, b:Int, excluded:Array<Int>):Array<Int> {
        var nodes = [[a]];
        var best = null;

        while(nodes.length > 0) {
            var path = nodes.pop();
            var last = path[path.length - 1];

            if(last == b) {
                if(best == null || best.length > path.length) {
                    best = path;
                    continue;
                }
            }

            if(best != null) {
                if(best.length < path.length) {
                    continue;
                }
            }

            var wi = 0;

            for(wall in data.walls) {
                if(excluded.indexOf(wi) == -1) {
                    var next = wall.a == last ? wall.b : (wall.b == last ? wall.a : null);

                    if(next != null) {
                        if(path.indexOf(next) == -1) {
                            var copy = path.slice(0);
                            copy.push(next);
                            nodes.push(copy);
                        }
                    }
                }

                ++wi;
            }
        }

        if(best != null) {
            var result = [];

            for(i in 0...best.length - 1) {
                var a = best[i];
                var b = best[i+1];
                var w = findWall(a, b);
                result.push(w);
            }

            return result;
        }

        return null;
    }

    function alignPoint(position:math.Point) {
        var align = 32;
        position.x = Std.int(position.x / align) * align;
        position.y = Std.int(position.y / align) * align;
    }

    function save() {
        var content = haxe.Json.stringify(data, "  ");
        App.log(content);
        download("level.json", content);
    }

    function download(filename, text) {
        var element = js.Browser.document.createElement('a');
        element.setAttribute('href', 'data:text/plain;charset=utf-8,' + untyped encodeURIComponent(text));
        element.setAttribute('download', filename);
        element.style.display = 'none';
        js.Browser.document.body.appendChild(element);
        element.click();
        js.Browser.document.body.removeChild(element);
    }

    function deleteRoom(index) {
    }

    function deleteWall(index) {
        for(room in data.rooms) {

            room.walls.remove(index);

            for(i in 0...room.walls.length) {
                var w = room.walls[i];

                if(w > index) {
                    room.walls[i]--;
                }
            }
        }

        data.walls.splice(index, 1);
    }

    function deleteVertex(index) {
        var connecteds = findConnectedVertices(index);

        if(connecteds.length == 2) {
            var new_w = createWall(connecteds[0], connecteds[1]);

            for(c in connecteds) {
                var wall = findWall(index, c);

                // deleteWall(wall);
                for(room in data.rooms) {
                    var i = room.walls.indexOf(wall);

                    if(i != -1) {
                        if(room.walls.indexOf(new_w) == -1) {
                            room.walls.insert(i, new_w);
                        }
                    }
                }
            }

            for(c in connecteds) {
                var wall = findWall(index, c);
                deleteWall(wall);
            }

            var i = data.walls.length - 1;

            for(wall in data.walls) {
                if(wall.a > index) {
                    wall.a--;
                }

                if(wall.b > index) {
                    wall.b--;
                }
            }

            data.vertices.splice(index, 1);
        }
    }

    function createWall(a, b) {
        var wall:def.Wall = {
            a: a,
            b: b,
            bottomTextureName: "door",
            textureName: "wall",
            textureScale: [1, 1]
        };
        data.walls.push(wall);
        return data.walls.length - 1;
    }
}
