package core;

typedef MenuEntry = {
    var content:String;
    var target:String;
}

typedef Menu = {
    var title:String;
    var entries:Array<MenuEntry>;
}

class MenuSystem extends ecs.System {
    var enabled = false;
    var font:display.Framebuffer = null;
    var previousStates = {};
    var currentMenu:Menu;
    var currentMenuIndex:Int;

    static var keyList = ["Escape", "ArrowUp", "ArrowDown", "Enter"];

    public function new() {
        super();
        currentMenu = {
            title: "Main Menu",
            entries: [
            {
                content: "New Game",
                target: ""
            },
            {
                content: "Load Game",
                target: ""
            },
            {
                content: "Options",
                target: ""
            },
            {
                content: "Credits",
                target: ""
            },
            {
                content: "Quit",
                target: ""
            }
            ]
        };
        currentMenuIndex = 0;
    }

    override public function update(dt:Float) {
        if(font == null) {
            font = Main.context.textureManager.get("font");
            return;
        }

        if(currentMenu == null) {
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

        if(untyped justPressed['Escape']) {
            enabled = !enabled;
        }

        if(untyped justPressed['ArrowUp']) {
            currentMenuIndex--;

            if(currentMenuIndex < 0) {
                currentMenuIndex = currentMenu.entries.length - 1;
            }
        }

        if(untyped justPressed['ArrowDown']) {
            currentMenuIndex++;

            if(currentMenuIndex >= currentMenu.entries.length) {
                currentMenuIndex = 0;
            }
        }

        if(enabled) {
            var renderer = Main.context.renderer;
            var center_x = Std.int(display.Renderer.screenWidth * 0.5);
            var offset_y = 150;
            var index = 0;
            renderer.drawText(font, [center_x, offset_y], currentMenu.title, true);
            offset_y += 100;

            for(entry in currentMenu.entries) {
                var text = entry.content;

                if(currentMenuIndex == index) {
                    text = "> " + entry.content + " <";
                }

                renderer.drawText(font, [center_x, offset_y], text, true);
                offset_y += 50;
                index++;
            }
        }
    }
}
