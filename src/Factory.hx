package;

class Factory {
    static private var monsters = new Map<String, def.Monster>();

    static public function initialize(callback) {
        var loader = new def.Loader<def.Monsters>(Main.context.dataRoot);
        loader.load2("monsters", function(data) {

            for(entry in data) {
                monsters[entry.name] = entry;
            }
            Main.log('Loaded monsters');
            callback();
        });
    }

    static public function createGibs(engine:ecs.Engine, position:math.Point) {
        for(i in 0...128) {
            var e = new ecs.Entity();
            e.add(new core.Sprite());
            e.add(new core.Object());
            e.add(new math.Transform());
            var distance = 1;
            e.get(math.Transform).position = [position.x + Math.random() * distance - distance/2, position.y + Math.random() * distance - distance/2];
            e.get(math.Transform).y = -200 + Std.random(10);
            e.get(math.Transform).scale = 0.05;
            e.add(new core.SpriteAnimator());
            e.get(core.SpriteAnimator).push("explosion");
            var physic = new core.Physic();
            physic.velocity.setFromAngle(Math.random() * Math.PI * 2);
            physic.velocity *= 10 + Math.random() * 100;
            physic.yVelocity = 1000 + Math.random() * 2000;
            e.add(physic);
            engine.addEntity(e);
        }
    }

    static public function createImpact(engine:ecs.Engine, position:math.Point) {
        var e = new ecs.Entity();
        e.add(new core.Sprite());
        e.add(new core.Object());
        e.add(new math.Transform());
        e.get(math.Transform).position.copyFrom(position);
        e.get(math.Transform).scale = 0.2;
        e.add(new core.SpriteAnimator());
        e.get(core.SpriteAnimator).push("impact");
        return e;
    }

    static public function createMonster(which:String, position:math.Point) {
        var monster = monsters[which];
        var e = new ecs.Entity();
        e.add(new core.Sprite());
        e.add(new core.Object());
        e.add(new core.Hittable());
        e.get(core.Hittable).life = monster.life;
        e.add(new core.Character());
        e.add(new math.Transform());
        e.get(math.Transform).position.copyFrom(position);
        e.get(math.Transform).angle = Math.random() * Math.PI * 2;
        e.add(new core.SpriteAnimator());
        e.get(core.SpriteAnimator).push(monster.animations.idle);
        e.add(new core.Monster());
        return e;
    }

    static public function createPlayer(position) {
        var e = new ecs.Entity();
        e.add(new math.Transform());
        e.add(new core.Player());
        e.add(new core.Character());
        e.add(new core.Object());
        e.add(new core.Control());
        e.add(new core.Camera());
        e.get(math.Transform).position.copyFrom(position);
        e.get(math.Transform).scale = 0.2;
        e.get(math.Transform).y = 32;
        e.get(core.Object).radius = 32;
        return e;
    }

    static public function createHudWeapon() {
        var e = new ecs.Entity();
        e.add(new math.Transform());
        e.add(new core.Quad());
        e.add(new core.Sprite());
        e.add(new core.SpriteAnimator());
        e.get(math.Transform).position = [10, 10];
        e.get(core.Quad).extent = [640, 400];
        e.get(core.SpriteAnimator).push("shotgun-idle");
        return e;
    }
}
