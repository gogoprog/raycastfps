package core;

import math.Point;
import math.Transform;

class SpriteAnimationNode extends ash.core.Node<SpriteAnimationNode> {
    public var sprite:Sprite;
    public var animation:SpriteAnimation;
}

class SpriteAnimationSystem extends ash.tools.ListIteratingSystem<SpriteAnimationNode> {
    private var loader = new def.Loader<def.Animation>();
    private var animations:Map<String, def.Animation> = new Map();

    public function new() {
        load("grell-idle");
        super(SpriteAnimationNode, updateNode, onNodeAdded, onNodeRemoved);
    }

    private function updateNode(node:SpriteAnimationNode, dt:Float):Void {
        var animation = node.animation;
        var sprite = node.sprite;

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
            var frameIndex = Std.int(animation.time / animation.duration) % len;
            sprite.textures = animation.def.frames[frameIndex];
        }
    }

    private function onNodeAdded(node:SpriteAnimationNode) {
    }

    private function onNodeRemoved(node:SpriteAnimationNode) {
    }

    private function load(name) {
        loader.load('../data/animations/${name}.json', function(data) {
            animations[name] = data;
        });
    }
}
