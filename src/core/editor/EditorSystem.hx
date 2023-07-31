package core.editor;

class EditorSystem extends ecs.System {
    var editing = true;
    var font:display.Framebuffer = null;
    var vertex:display.Framebuffer = null;
    var entries:Array<String> = [];
    var offset:math.Point = [200, 200];
    var zoom = 0.2;
    var isPanning = false;
    var startPanPosition:math.Point = [];
    var startPanOffset:math.Point = [];

    var hoveredVertex:math.Point;

    public function new() {
        super();
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
            var width = display.Renderer.screenWidth;
            var height = display.Renderer.screenHeight;
            var level = Main.context.level;
            // renderer.pushRect([width/2, height/2], [width, height], 0x11000000);
            renderer.pushRect([width/2, height/2], [width, height], 0xaa000000);
            var data = level.data;

            for(v in data.vertices) {
                var sv = convertToMap(v);
                var delta = (mouse_position - sv);
                var color = 0xffffffff;

                if(delta.getLength() < 16) {
                    hoveredVertex = v;
                    color = 0xff1111ee;
                }

                renderer.pushRect(sv, [16, 16], color);
            }

                renderer.pushRect(mouse_position, [16, 16], 0xff55dd44);

            for(w in data.walls) {
                var a = convertToMap(data.vertices[w.a]);
                var b = convertToMap(data.vertices[w.b]);
                renderer.pushLine(a, b, 0xffffffff);
            }

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
        } else {
            if(Main.isJustPressed('Enter')) {
                editing = true;
                Main.gotoEditor();
            }
        }

        renderer.pushText(font, [2, 2], "EDITOR", false);
    }

    function convertToMap(p:math.Point):math.Point {
        return [p.x * zoom + offset.x, p.y * zoom + offset.y];
    }
}
