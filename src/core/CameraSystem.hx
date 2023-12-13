package core;

class CameraSystem extends ecs.System {
    var cameraTransform:math.Transform;

    public function new() {
        super();
        addComponentClass(Camera);
        addComponentClass(Player);
        addComponentClass(math.Transform);
    }

    override public function onResume() {
        cameraTransform = context.cameraTransform;
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var transform = e.get(math.Transform);
        var player = e.get(Player);
        cameraTransform.position.copyFrom(transform.position);
        cameraTransform.y = transform.y + player.cameraOffsetY;
        cameraTransform.angle = transform.angle;
    }
}
