package core;

class ConsoleSystem extends ecs.System {
    var enabled = false;
    var font:display.Framebuffer = null;
    var background:display.Framebuffer = null;
    var previousStates = {};
    var entries:Array<String> = [];

    static var keyList = ["`", "ArrowUp", "ArrowDown", "Enter"];

    public function new() {
        super();
    }

    override public function update(dt:Float) {
        if(font == null || background == null) {
            font = Main.context.textureManager.get("font");
            background = Main.context.textureManager.get("console");
            return;
        }

        var keys = Main.keys;
        var currentStates = {};
        var justPressed = {};

        for(key in keyList) {
            var state = untyped keys[key];

            if(state && untyped !previousStates[key]) {
                untyped justPressed[key] = true;
            } else {
                untyped justPressed[key] = false;
            }

            untyped previousStates[key] = state;
        }

        if(untyped justPressed['`']) {
            enabled = !enabled;
        }

        if(enabled) {
            var renderer = Main.context.renderer;
            var width = display.Renderer.screenWidth;
            var center_x = Std.int(display.Renderer.screenWidth * 0.5);
            var center_y = Std.int(display.Renderer.screenHeight * 0.5);
            var offset_y = center_y - 16;
            renderer.pushQuad(background, [0, 0], [width, center_y]);

            for(i in 0...24) {
                var entry = entries[entries.length - 1 - i];

                if(entry != null) {
                    renderer.pushText(font, [2, offset_y], entry, false);
                }

                offset_y -= 16;
            }
        }
    }

    public function push(entry) {
        entries.push(entry);

        if(entries.length > 64) {
            entries.shift();
        }
    }
}
