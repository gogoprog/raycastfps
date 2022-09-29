package core;

import math.Point;
import math.Transform;

class SpriteAnimationSystem extends ecs.System {
    private var loader = new def.Loader<def.Animation>(Main.context.dataRoot);
    private var animations:Map<String, def.Animation> = new Map();

    public function new() {
        super();
        addComponentClass(Sprite);
        addComponentClass(SpriteAnimator);
        load("grell-idle");
        load("shotgun-idle");
        load("shotgun-fire");
    }

    override public function updateSingle(dt:Float, e:ecs.Entity):Void {
        var animation = e.get(core.SpriteAnimator);
        var sprite = e.get(core.Sprite);

        if(animation.name != animation.currentName) {
            if(animations[animation.name] != null) {
                animation.currentName = animation.name;
                animation.time = 0;
                animation.def = animations[animation.name];
                animation.duration = animation.def.frames.length / animation.def.rate;
            }
        }

        animation.time += dt;

        if(animation.def != null) {
            var len = animation.def.frames.length;
            var frameIndex = Std.int((animation.time / animation.duration) * len) % len;
            sprite.textures = animation.def.frames[frameIndex];
        }
    }

    private function load(name) {
        loader.load(name, function(data) {
            animations[name] = data;
            trace('Loaded animation ${name}');
        });
    }
}
