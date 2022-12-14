package;

class Factory {
    static public function createGibs(engine:ecs.Engine, position:math.Point) {
        for(i in 0...128) {
            var e = new ecs.Entity();
            e.add(new core.Sprite());
            e.add(new core.Object());
            e.get(core.Object).heightOffset = -200 + Std.random(10);
            e.add(new math.Transform());
            var distance = 1;
            e.get(math.Transform).position = [position.x + Math.random() * distance - distance/2, position.y + Math.random() * distance - distance/2];
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
}
