package math;

typedef SmoothDampResult = {
    var value:Float;
    var velocity:Float;
}

class Utils {

    public static function fixAngle(angle:Float) {
        while(angle > Math.PI) {
            angle -= 2 * Math.PI;
        }

        while(angle < -Math.PI) {
            angle += 2 * Math.PI;
        }

        return angle;
    }

    public static function isPointOnRight(rayStart:Point, rayEnd:Point, point: Point): Bool {
        var dx1 = point.x - rayStart.x;
        var dy1 = point.y - rayStart.y;
        var dx2 = rayEnd.x - rayStart.x;
        var dy2 = rayEnd.y - rayStart.y;

        var crossProduct = dx1 * dy2 - dy1 * dx2;

        return crossProduct < 0;
    }

    static public function segmentToSegmentIntersection(from1:Point, to1:Point, from2:Point, to2:Point) {
        var dX = to1.x - from1.x;
        var dY = to1.y - from1.y;
        var determinant = dX * (to2.y - from2.y) - (to2.x - from2.x) * dY;

        if(determinant <= 0) {
            return null;
        }

        var lambda = ((to2.y - from2.y) * (to2.x - from1.x) + (from2.x - to2.x) * (to2.y - from1.y)) / determinant;
        var gamma = ((from1.y - to1.y) * (to2.x - from1.x) + dX * (to2.y - from1.y)) / determinant;

        if(lambda<0 || !(0 <= gamma && gamma <= 1)) { return null; }

        return [lambda, gamma];
    }

    static public function getSegmentPointDistance(v:Point, w:Point, p:Point) {
        var l2 = (w - v).getSquareLength();
        var t = ((p.x - v.x) * (w.x - v.x) + (p.y - v.y) * (w.y - v.y)) / l2;
        t = Math.max(0, Math.min(1, t));
        var tmp:Point = [v.x + t * (w.x - v.x), v.y + t*(w.y-v.y)];
        return (p - tmp).getLength();
    }

    static public function smoothDamp(current:Float, target:Float, currentVelocity:Float, smoothTime:Float, deltaTime:Float):SmoothDampResult {
        var omega = 2.0 / smoothTime;
        var x = omega * deltaTime;
        var exp = 1.0 / (1.0 + x + 0.48 * x * x + 0.235 * x * x * x);
        var change = current - target;
        var originalTo = target;
        target = current - change;
        var temp = (currentVelocity + omega * change) * deltaTime;
        currentVelocity = (currentVelocity - omega * temp) * exp;
        var output = target + (change + temp) * exp;

        if((originalTo - current > 0.0) == (output > originalTo)) {
            output = originalTo;
            currentVelocity = (output - originalTo) / deltaTime;
        }

        return {value:output, velocity:currentVelocity};
    }

    static public function lineCircleIntersection(a:Point, b:Point, c:Point, radius:Float):Bool {
        var ac = c - a;
        var ab = b - a;
        var ab2 = Point.dot(ab, ab);
        var acab = Point.dot(ac, ab);
        var t = acab / ab2;
        t = (t < 0) ? 0 : t;
        t = (t > 1) ? 1 : t;
        var h:Point = [(ab[0] * t + a.x) - c.x, (ab[1] * t + a.y) - c.y];
        var h2 = Point.dot(h, h);
        return h2 <= radius * radius;
    }

    static public function getRandom(min:Float, max:Float):Float {
        return min + Math.random() * (max - min);
    }
}
