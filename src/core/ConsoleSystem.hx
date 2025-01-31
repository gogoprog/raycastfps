package core;

class ConsoleSystem extends ecs.System {
    var background:display.Framebuffer = null;
    var entries:Array<String> = [];

    public function new() {
        super();
    }

    override public function update(dt:Float) {
        if(background == null) {
            background = context.textureManager.get("console");
            return;
        }

        var renderer = context.renderer;
        var width = display.Renderer.screenWidth;
        var center_x = Std.int(display.Renderer.screenWidth * 0.5);
        var center_y = Std.int(display.Renderer.screenHeight * 0.5);
        var offset_y = center_y - 7;
        renderer.pushQuad(background, [0, 0], [width, center_y]);

        for(i in 0...46) {
            var entry = entries[entries.length - 1 - i];

            if(entry != null) {
                renderer.pushText("mini", [2, offset_y], entry, false);
            }

            offset_y -= 7;
        }

        if(context.keyboard.isJustPressed('`') || context.keyboard.isJustPressed('Escape')) {
            context.app.gotoIngame();
        }
    }

    public function push(entry) {
        entries.push(entry);

        if(entries.length > 64) {
            entries.shift();
        }
    }
}
