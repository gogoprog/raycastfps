package core;

import math.Transform;

class LevelSystem extends ecs.System {
    private var lastSeconds = 0;
    private var time = 0.0;

    private var ended = false;

    public function new() {
        super();
    }

    public function restart() {
        ended = false;
    }

    override public function update(dt:Float) {
        time += dt;
        var seconds = Std.int(time);

        if(seconds != lastSeconds) {
            lastSeconds = seconds;
            var data = context.level.data;

            if(!ended) {
                switch(data.type) {
                    case "exterminate": {
                        var monsters = engine.getMatchingEntities(core.Monster);

                        if(monsters.length == 0) {
                            ended = true;

                            if(data.endMenu != null) {
                                context.app.gotoMenu();
                                engine.getSystem(core.MenuSystem).setMenu(data.endMenu);
                            }
                        }
                    }
                }
            }
        }
    }
}
