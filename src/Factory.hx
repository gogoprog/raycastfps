package;

class Factory {
    static public function createGibs(engine:ecs.Engine, position:math.Point) {
        for(i in 0...128) {
            var e = new ecs.Entity();
            e.add(new core.Sprite());
            e.add(new core.Object());
            e.get(core.Object).heightOffset = 10 + Std.random(20);
            e.add(new math.Transform());
            var distance = 1;
            e.get(math.Transform).position = [position.x + Math.random() * distance - distance/2, position.y + Math.random() * distance - distance/2];
            e.get(math.Transform).scale = 0.01 + Math.random() * 0.1;
            e.add(new core.SpriteAnimator());
            e.get(core.SpriteAnimator).push("explosion");
            var physic = new core.Physic();
            physic.velocity.setFromAngle(Math.random() * Math.PI * 2);
            physic.velocity *= 10 + Math.random() * 100;
            physic.yVelocity = 0 + Math.random() * 4000;
            e.add(physic);
            engine.addEntity(e);
        }
    }
}
