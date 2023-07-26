package core.editor;

class EditorSystem extends ecs.System {
    var enabled = false;
    var font:display.Framebuffer = null;
    var vertex:display.Framebuffer = null;
    var entries:Array<String> = [];
    var offset:math.Point = [200, 200];
    var zoom = 0.2;
    var isPanning = false;
    var startPanPosition:math.Point = [];
    var startPanOffset:math.Point = [];

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
        var width = display.Renderer.screenWidth;
        var height = display.Renderer.screenHeight;
        var level = Main.context.level;
        renderer.pushRect([width/2, height/2], [width, height], 0x000000ff);

        for(sector in level.sectors) {
            for(wall in sector.walls) {
                var a = convertToMap(wall.a);
                var b = convertToMap(wall.b);
                renderer.pushRect(a, [16, 16], 0xffffffff);
                renderer.pushRect(b, [16, 16], 0xffffffff);
                renderer.pushLine(a, b, 0xffffffff);
            }
        }

        if(Main.mouseButtons[0]) {
            if(!isPanning) {
                isPanning = true;
                startPanPosition.copyFrom(Main.mousePosition);
                startPanOffset.copyFrom(offset);
            } else {
                var delta = Main.mousePosition - startPanPosition;
                offset = startPanOffset + delta;
            }
        } else {
            isPanning = false;
        }
    }

    function convertToMap(p:math.Point):math.Point {
        return [p.x * zoom + offset.x, p.y * zoom + offset.y];
    }
}
