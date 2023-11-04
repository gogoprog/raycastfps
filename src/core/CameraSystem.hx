package core;

class CameraSystem extends ecs.System {
    var cameraTransform:math.Transform;

    public function new() {
        super();
        addComponentClass(Camera);
        addComponentClass(math.Transform);
    }

    override public function onResume() {
        cameraTransform = context.cameraTransform;
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var transform = e.get(math.Transform);
        cameraTransform.position.copyFrom(transform.position);
        cameraTransform.y = transform.y;
        cameraTransform.angle = transform.angle;
    }
}
