package world;

class Sector {
    public var floorTextureName:String;
    public var floorTexture:display.Framebuffer;
    public var walls:Array<Wall> = [];
    public var bottom:Float = 0;
    public var top:Float = 3;
    public var center:math.Point;

    public function new() {
    }

    public function contains(p:math.Point) {
        for(wall in walls) {
            if(!math.Utils.isPointOnRight(wall.a, wall.b, p)) {
                return false;
            }
        }

        return true;
    }

    public function computeCenter() {
        center = [0, 0];

        for(wall in walls) {
            center += wall.a;
            center += wall.b;
        }

        center /= walls.length * 2;
    }

    public function reorderWalls() {
        for(wall in walls) {
            if(!math.Utils.isPointOnRight(wall.a, wall.b, center)) {
                var tmp = wall.a;
                wall.a = wall.b;
                wall.b = tmp;
            }
        }
    }
}
