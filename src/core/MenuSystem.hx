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
    var currentMenu:Menu;
    var currentMenuIndex:Int;

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
        if(currentMenu == null) {
            return;
        }

        if(Main.isJustPressed('ArrowUp')) {
            currentMenuIndex--;

            if(currentMenuIndex < 0) {
                currentMenuIndex = currentMenu.entries.length - 1;
            }
        }

        if(Main.isJustPressed('ArrowDown')) {
            currentMenuIndex++;

            if(currentMenuIndex >= currentMenu.entries.length) {
                currentMenuIndex = 0;
            }
        }

        var renderer = Main.context.renderer;
        var center_x = Std.int(display.Renderer.screenWidth * 0.5);
        var offset_y = 150;
        var index = 0;
        renderer.pushText("main", [center_x, offset_y], currentMenu.title, true);
        offset_y += 100;

        for(entry in currentMenu.entries) {
            var text = entry.content;

            if(currentMenuIndex == index) {
                text = "> " + entry.content + " <";
            }

            renderer.pushText("main", [center_x, offset_y], text, true);
            offset_y += 50;
            index++;
        }
    }
}
