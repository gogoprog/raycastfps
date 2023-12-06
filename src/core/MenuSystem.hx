package core;

typedef MenuEntry = {
    var content:String;
    @:optional var action:String;
    @:optional var param:String;
    @:optional var submenu:Menu;
}

typedef Menu = {
    @:optional var image:String;
    var title:String;
    var entries:Array<MenuEntry>;
}

class MenuSystem extends ecs.System {
    static var fileContent = Macro.getFileContent("menu.json");
    var menus:Array<Menu>;
    var currentMenu:Menu;
    var cursorIndices:Array<Int> = [];

    public function new() {
        super();
        menus = cast haxe.Json.parse(fileContent);
        currentMenu = menus[0];
        cursorIndices.push(0);
    }

    override public function update(dt:Float) {
        if(currentMenu == null) {
            return;
        }

        {
            var renderer = context.renderer;
            var width = display.Renderer.screenWidth;
            var height = display.Renderer.screenHeight;
            renderer.pushRect([width/2, height/2], [width, height], 0xbb000010);
        }

        var cursorIndex = cursorIndices[cursorIndices.length - 1];

        if(context.keyboard.isJustPressed('ArrowUp')) {
            cursorIndex--;

            if(cursorIndex < 0) {
                cursorIndex = currentMenu.entries.length - 1;
            }

            cursorIndices[cursorIndices.length - 1] = cursorIndex;
        }

        if(context.keyboard.isJustPressed('ArrowDown')) {
            cursorIndex++;

            if(cursorIndex >= currentMenu.entries.length) {
                cursorIndex = 0;
            }

            cursorIndices[cursorIndices.length - 1] = cursorIndex;
        }

        if(context.keyboard.isJustPressed('Enter')) {
            apply(currentMenu.entries[cursorIndex]);
        }

        if(context.keyboard.isJustPressed('Escape')) {
            doEscape();
        }

        var renderer = context.renderer;
        var center_x = Std.int(display.Renderer.screenWidth * 0.5);
        var offset_y = 100;
        var index = 0;
        renderer.pushQuad2(context.textureManager.get(currentMenu.image), [center_x, offset_y]);
        offset_y += 100;
        renderer.pushText("main", [center_x, offset_y], currentMenu.title, true);
        offset_y += 100;

        for(entry in currentMenu.entries) {
            var text = entry.content;

            if(cursorIndex == index) {
                text = "> " + entry.content + " <";
            }

            renderer.pushText("main", [center_x, offset_y], text, true);
            offset_y += 50;
            index++;
        }
    }

    function apply(entry:MenuEntry) {
        if(entry.submenu != null) {
            menus.push(entry.submenu);
            cursorIndices.push(0);
            currentMenu = menus[menus.length - 1];
            return;
        }

        switch(entry.action) {
            case "list_levels": {
                var menu:Menu = {
                    title: "Load level",
                    entries: []
                };

                for(k => v in Factory.levels) {
                    menu.entries.push({
                        content: k,
                        action: "load_level",
                        param: k
                    });
                }

                menus.push(menu);
                cursorIndices.push(0);
                currentMenu = menus[menus.length - 1];
            }

            case "load_level": {
                var level = Factory.levels[entry.param];
                context.level.load(level);
                context.level.restart();
                context.app.gotoIngame();

                while(menus.length > 1) {
                    menus.pop();
                    cursorIndices.pop();
                }

                currentMenu = menus[0];
            }
        }
    }

    function doEscape() {
        if(menus.length > 1) {
            menus.pop();
            currentMenu = menus[menus.length - 1];
            cursorIndices.pop();
        } else {
            context.app.gotoIngame();
        }
    }
}
