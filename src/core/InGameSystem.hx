package core;

class InGameSystem extends ecs.System {

    public function new() {
        super();
    }

    override public function update(dt:Float) {
        var keyboard = context.keyboard;
        var app = context.app;

        if(keyboard.isJustPressed('Escape')) {
            app.gotoMenu();
        }

        if(keyboard.isJustPressed('`')) {
            app.gotoConsole();
        }

        if(keyboard.isJustPressed('e')) {
            app.gotoEditor();
        }

        if(keyboard.isJustPressed('r')) {
            context.level.restart();
        }
    }
}
