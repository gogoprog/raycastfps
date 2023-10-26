package;

class Factory {
    static var levelFilePaths = Macro.getDataFilePaths("levels");
    static private var monsters = new Map<String, def.Monster>();
    static private var weapons = new Map<String, def.Weapon>();
    static public var levels = new Map<String, def.Level>();

    static public function initialize(callback) {
        var loaders = 3;
        function localcallback() {
            --loaders;

            if(loaders == 0) {
                callback();
            }
        }
        var loader = new def.Loader<def.Monster>(Main.context.dataRoot);
        loader.fill(monsters, localcallback);
        var loader = new def.Loader<def.Weapon>(Main.context.dataRoot);
        loader.fill(weapons, localcallback);
        var loader = new def.Loader<def.Level>(Main.context.dataRoot);
        loader.fill2(levels, levelFilePaths, localcallback);
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

        e.get(core.Object).isStatic = true;

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
        e.get(core.Character).weapon = weapons["shotgun"];
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
        // e.get(core.SpriteAnimator).push("shotgun-idle");
        return e;
    }
}
