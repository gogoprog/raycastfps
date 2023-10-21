package core.editor;

import world.Level;

private enum Action {
    Selecting;
    MovingVertex;
    MovingWall;
    Panning;
    CreatingRoom;
}

class EditorSystem extends ecs.System {
    static var selectedColor = 0xff11ee11;
    static var objectsColors = [ "monster" => 0xff4444dd, "start" =>  0xffdd5544];
    var editing = true;
    var font:display.Framebuffer = null;
    var vertex:display.Framebuffer = null;
    var entries:Array<String> = [];
    var offset:math.Point = [400, 200];
    var zoom = 0.2;
    var isPanning = false;
    var startPanPosition:math.Point = [];
    var startPanOffset:math.Point = [];
    var startMoveWallMousePosition:math.Point = [];
    var startMoveWallAPosition:math.Point = [];
    var startMoveWallBPosition:math.Point = [];

    var level:world.Level;
    var data:world.LevelData;

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

    public function new() {
        super();
    }

    override public function onResume() {
        level = Main.context.level;
        data = level.data;
    }

    override public function onSuspend() {
        level.generateSectors();
    }

    override public function update(dt:Float) {
        if(font == null || vertex == null) {
            font = Main.context.textureManager.get("font");
            vertex = Main.context.textureManager.get("door");
            return;
        }

        var renderer = Main.context.renderer;

        if(editing) {
            var mouse_position = Main.mouseScreenPosition;
            draw();
            processAction();
            processControls();
        }

        renderer.pushText("main", [2, 2], "EDITOR", false);
    }

    function convertToMap(p:math.Point):math.Point {
        return [p.x * zoom + offset.x, p.y * zoom + offset.y];
    }

    function convertFromMap(p:math.Point):math.Point {
        return [Std.int((p.x - offset.x) / zoom), Std.int((p.y - offset.y) / zoom)];
    }

    function draw() {
        processVertices();
        processWalls();
        processRooms();
        processObjects();
    }

    function processVertices() {
        var renderer = Main.context.renderer;
        var mouse_position = Main.mouseScreenPosition;
        var width = display.Renderer.screenWidth;
        var height = display.Renderer.screenHeight;
        var index = 0;
        renderer.pushRect([width/2, height/2], [width, height], 0xaa000000);
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

            renderer.pushRect(sv, [64 * zoom, 64 * zoom], color);
            index++;
        }
    }

    function processWalls() {
        var renderer = Main.context.renderer;
        var level = Main.context.level;
        var mouse_position = Main.mouseScreenPosition;
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
        var renderer = Main.context.renderer;
        var mouse_position = Main.mouseScreenPosition;
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

    function processObjects() {
        var mouse_position = Main.mouseScreenPosition;
        var renderer = Main.context.renderer;
        renderer.pushRect(mouse_position, [2, 2], 0xff55dd44);

        for(obj in data.objects) {
            var pos = convertToMap(obj.position);
            renderer.pushRect(pos, [8, 8], objectsColors[obj.type]);
        }

        return;
    }

    function onMouseLeftPressed() {
        var mouse_position = Main.mouseScreenPosition;

        switch(action) {
            case Selecting: {
                if(hoveredVertexIndex != null) {
                    action = MovingVertex;
                    movingVertexIndex = hoveredVertexIndex;
                } else if(hoveredWallIndex != null) {
                    action = MovingWall;
                    movingWallIndex = hoveredWallIndex;
                    var wall = data.walls[movingWallIndex];
                    startMoveWallMousePosition.copyFrom(convertFromMap(mouse_position));
                    startMoveWallAPosition.copyFrom(data.vertices[wall.a]);
                    startMoveWallBPosition.copyFrom(data.vertices[wall.b]);
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
        var mouse_position = Main.mouseScreenPosition;
        var new_position = convertFromMap(mouse_position);

        switch(action) {
            case Selecting: {
                action = CreatingRoom;
                creatingRoomNewVerticesCount = 0;

                if(hoveredVertexIndex != null) {
                    data.vertices.push(new_position.getCopy());
                    creatingRoomNewVerticesCount++;
                    var last_index = data.vertices.length - 1;
                    var wall:world.WallData = {
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
                    var wall:world.WallData = {
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
                    var wall:world.WallData = {
                        a: previousVertexIndex,
                        b: hoveredVertexIndex,
                        bottomTextureName: "door",
                        textureName: "wall",
                        textureScale: [1, 1]
                    };
                    data.walls.push(wall);
                    movingVertexIndex = null;
                    previousVertexIndex = null;
                    var missing_wall = findWall(startVertexIndex, hoveredVertexIndex);

                    if(missing_wall != null || startVertexIndex == hoveredVertexIndex) {
                        if(missing_wall != null) {
                            currentRoomWalls.push(missing_wall);
                        }

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

                        if(missing_wall != null) {
                            data.walls[missing_wall].textureName = null;
                        }
                    } else {
                        for(i in 0...currentRoomWalls.length + 1) {
                            data.walls.pop();
                        }

                        for(i in 0...creatingRoomNewVerticesCount - 1) {
                            data.vertices.pop();
                        }
                    }

                    action = Selecting;
                } else {
                    creatingRoomNewVerticesCount++;
                    data.vertices.push(new_position.getCopy());
                    var last_index = data.vertices.length - 1;
                    var wall:world.WallData = {
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
        var mouse_position = Main.mouseScreenPosition;
        var new_position = convertFromMap(mouse_position);

        switch(action) {
            case Selecting: {
            }

            case MovingVertex: {
                if(Main.isPressed("Shift")) {
                    var align = 64;
                    new_position.x = Std.int(new_position.x / 64) * 64;
                    new_position.y = Std.int(new_position.y / 64) * 64;
                }

                data.vertices[movingVertexIndex].copyFrom(new_position);
            }

            case MovingWall: {
                var wall = data.walls[movingWallIndex];
                var delta = convertFromMap(mouse_position) - startMoveWallMousePosition;
                data.vertices[wall.a].copyFrom(startMoveWallAPosition + delta);
                data.vertices[wall.b].copyFrom(startMoveWallBPosition + delta);
            }

            case CreatingRoom: {
                data.vertices[movingVertexIndex].copyFrom(new_position);
            }

            default:
        }
    }

    function processControls() {
        var mouse_position = Main.mouseScreenPosition;

        if(Main.mouseButtons[2]) {
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

        if(Main.isMouseButtonJustPressed(0)) {
            onMouseLeftPressed();
        }

        if(Main.isMouseButtonJustReleased(0)) {
            onMouseLeftReleased();
        }

        if(Main.isMouseButtonJustPressed(2)) {
            onMouseRightPressed();
        }

        if(Main.isMouseButtonJustReleased(2)) {
            onMouseRightReleased();
        }

        if(Main.isJustPressed(' ')) {
            onSpacePressed();
        }

        if(Main.isJustPressed('PageDown') || Main.mouseWheelDelta < 0) {
            zoom *= 1.1;
        }

        if(Main.isJustPressed('PageUp') || Main.mouseWheelDelta > 0) {
            zoom /= 1.1;
        }
    }

    function computeRoomCenter(room:RoomData, center:math.Point) {
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
}
