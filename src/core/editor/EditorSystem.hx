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

    var hoveredWallIndex:Int;
    var movingWallIndex:Int;

    var hoveredRoomIndex:Int;
    var movingRoomIndex:Int;

    var currentRoomWalls:Array<Int> = [];

    var action = Selecting;

    public function new() {
        super();
    }

    override public function onResume() {
        level = Main.context.level;
        data = level.data;
    }

    override public function onSuspend() {
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
        } else {
            if(Main.isJustPressed('Enter')) {
                editing = true;
                Main.gotoEditor();
            }
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
        drawItems();
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

                color = 0xff1111ee;
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
                color = 0xff1111ee;
            }

            renderer.pushLine(a, b, color);
            ++index;
        }
    }

    function processRooms() {
        var center:math.Point = [0, 0];
        var renderer = Main.context.renderer;

        for(room in data.rooms) {
            computeRoomCenter(room, center);
            var pos = convertToMap(center);
            renderer.pushRect(pos, [16, 16], 0xff888888);
        }
    }

    function drawItems() {
        var mouse_position = Main.mouseScreenPosition;
        var renderer = Main.context.renderer;
        renderer.pushRect(mouse_position, [2, 2], 0xff55dd44);
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
                if(hoveredVertexIndex != null) {
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

                if(hoveredVertexIndex != null) {
                    data.vertices.push(new_position.getCopy());
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
                    currentRoomWalls.push(data.walls.length - 1);
                } else {
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
                    currentRoomWalls.push(data.walls.length - 1);
                    {
                        data.rooms.push({
                            walls: currentRoomWalls,
                            floorTextureName: "floor",
                            bottom: 0,
                            top: 3
                        });
                        currentRoomWalls = [];
                        level.generateSectors();
                    }
                    action = Selecting;
                } else {
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

        if(Main.isJustPressed('Enter')) {
            editing = false;
            Main.gotoEditorPreview();
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
            center += v[wall.a];
            center += v[wall.b];
        }

        var len = room.walls.length * 2;
        center.set(center.x/len, center.y/len);
    }
}
