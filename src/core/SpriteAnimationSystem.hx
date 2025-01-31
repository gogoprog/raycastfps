package core;

import math.Point;
import math.Transform;

class SpriteAnimationSystem extends ecs.System {
    private var loader:def.Loader<def.Animation>;
    private var animations:Map<String, def.Animation> = new Map();

    public function new() {
        super();
        loader = new def.Loader<def.Animation>(Data.dataPath);

        addComponentClass(Sprite);
        addComponentClass(SpriteAnimator);

        var filePaths = Data.getFilePaths("animations");

        for(file in filePaths) {
            load(file);
        }
    }

    override public function updateSingle(dt:Float, e:ecs.Entity):Void {
        var animation = e.get(core.SpriteAnimator);
        var sprite = e.get(core.Sprite);

        var name = animation.getName();

        if(name != animation.currentName) {
            if(animations[name] != null) {
                animation.currentName = name;
                animation.time = 0;
                animation.def = animations[name];
                animation.duration = animation.def.frames.length / animation.def.rate;
            }
        }

        animation.time += dt;

        if(animation.def != null) {
            var len = animation.def.frames.length;
            var frameIndex = Std.int((animation.time / animation.duration) * len) % len;

            if(animation.time >= animation.duration) {
                if(animation.def.loop) {
                    if(animation.names.length > 1) {
                        animation.names.pop();
                        frameIndex = len - 1;
                        animation.currentName = "";
                    }
                } else {
                    frameIndex = len - 1;
                }
            }

            sprite.textures = animation.def.frames[frameIndex];
        }
    }

    private function load(filename) {
        var name = filename.substring(0, filename.length - 5);
        loader.load(name, function(data) {
            animations[name] = data;
            App.log('Loaded animation ${name}');
        });
    }
}
