package;

class Factory {
    static public var monsters = new Map<String, def.Monster>();
    static public var items = new Map<String, def.Item>();
    static private var weapons = new Map<String, def.Weapon>();
    static private var effects = new Map<String, def.Effect >();
    static public var levels = new Map<String, def.Level>();
    static public var context:Context;

    static public function initialize(callback) {
        var loaders = 5;
        function localcallback() {
            --loaders;

            if(loaders == 0) {
                callback();
            }
        }
        var levelFilePaths = Data.getFilePaths("levels");
        var loader = new def.Loader<def.Monster>(Data.dataPath);
        loader.fill(monsters, localcallback);
        var loader = new def.Loader<def.Item>(Data.dataPath);
        loader.fill(items, localcallback);
        var loader = new def.Loader<def.Weapon>(Data.dataPath);
        loader.fill(weapons, localcallback);
        var loader = new def.Loader<def.Effect>(Data.dataPath);
        loader.fill(effects, localcallback);
        var loader = new def.Loader<def.Level>(Data.dataPath);
        loader.fill2(levels, levelFilePaths, localcallback);
    }

    static public function createEffect(engine:ecs.Engine, transform:math.Transform, which:String) {
        var effect = effects[which];
        var position = transform.position;

        for(i in 0...effect.spriteCount) {
            var e = new ecs.Entity();

            e.add(new core.Sprite());

            e.add(new core.Object());

            e.get(core.Object).isStatic = true;

            e.add(new math.Transform());

            var distance = effect.distance != null ? effect.distance : 1;
            e.get(math.Transform).position = [position.x + Math.random() * distance - distance/2, position.y + Math.random() * distance - distance/2];
            e.get(math.Transform).y = transform.y + effect.startYMin + (effect.startYMax - effect.startYMin) * Math.random();
            var scale = effect.scale != null ? effect.scale : (effect.scaleMin + (effect.scaleMax - effect.scaleMin) * Math.random());
            e.get(math.Transform).scale = scale;

            e.add(new core.SpriteAnimator());

            e.get(core.SpriteAnimator).push(effect.animation);
            var physic = new core.Physic();
            physic.velocity.setFromAngle(Math.random() * Math.PI * 2);
            physic.velocity *= math.Utils.getRandom(effect.speedMin, effect.speedMax);
            physic.yVelocity = math.Utils.getRandom(effect.upSpeedMin, effect.upSpeedMax);

            if(effect.gravity != null) {
                physic.gravity = effect.gravity;
            }

            e.add(physic);

            e.add(new core.AutoRemove(effect.lifetime));

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

        e.get(core.Character).weapon = weapons[monster.weapon];

        e.add(new math.Transform());

        e.get(math.Transform).position.copyFrom(position);
        e.get(math.Transform).angle = Math.random() * Math.PI * 2;
        e.get(math.Transform).scale = monster.scale;

        e.add(new core.SpriteAnimator());

        e.get(core.SpriteAnimator).push(monster.animations.idle);
        e.get(core.Character).animations = monster.animations;
        e.get(core.Character).effects = monster.effects;
        e.get(core.Character).sounds = monster.sounds;

        e.add(new core.Monster());

        e.get(core.Monster).def = monster;
        e.get(core.Monster).weapon = weapons[monster.weapon];

        e.add(new core.AudioSource());

        return e;
    }

    static public function createItem(which:String, position:math.Point) {
        var item = items[which];
        var e = new ecs.Entity();

        e.add(new core.Sprite());

        e.add(new core.Object());

        e.add(new core.Character());

        e.add(new math.Transform());

        e.get(math.Transform).position.copyFrom(position);
        e.get(math.Transform).angle = 0;
        e.get(math.Transform).scale = item.scale;

        e.add(new core.SpriteAnimator());

        e.get(core.SpriteAnimator).push(item.animations.idle);
        return e;
    }

    static public function createPlayer(position) {
        var e = new ecs.Entity();

        e.add(new math.Transform());

        e.add(new core.Player());

        e.add(new core.Character());

        e.add(new core.Hittable());

        e.get(core.Hittable).life = 100;

        e.add(new core.Object());

        e.add(new core.Control());

        e.add(new core.Camera());

        e.add(new core.AudioSource());

        e.get(math.Transform).position.copyFrom(position);
        e.get(math.Transform).scale = 0.2;
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
        return e;
    }

    static public function createProjectile(weapon:def.Weapon) {
        var e = new ecs.Entity();

        e.add(new core.Sprite());

        e.add(new core.Object());

        e.get(core.Object).isStatic = true;

        e.add(new math.Transform());

        e.add(new core.SpriteAnimator());

        e.add(new core.Projectile());

        e.get(core.SpriteAnimator).push(weapon.animations.projectile);
        e.get(core.Projectile).weapon = weapon;
        return e;
    }
}
